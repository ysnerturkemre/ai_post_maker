# app/services/ai_horde_image_service.rb
class AiHordeImageService
  class Error < StandardError; end
  class Canceled < Error; end

  API_BASE_URL = ENV.fetch("AI_HORDE_API_BASE_URL", "https://aihorde.net/api/v2")
  DEFAULT_MODEL = ENV.fetch("AI_HORDE_MODEL", "SDXL 1.0")
  POLL_INTERVAL = Integer(ENV.fetch("AI_HORDE_POLL_INTERVAL_SECONDS", 3))
  # Free Horde kuyruğu uzun sürebildiği için bekleme süresini uzattık.
  POLL_TIMEOUT = Integer(ENV.fetch("AI_HORDE_POLL_TIMEOUT_SECONDS", 600))
  CLIENT_AGENT = ENV.fetch("AI_HORDE_CLIENT_AGENT", "ai_post_maker/0.1 (rails)")

  # Horde needs dimensions divisible by 64.
  ASPECT_DIMENSIONS = {
    square: { width: 832, height: 832 },
    portrait: { width: 704, height: 1024 },
    landscape: { width: 1024, height: 704 }
  }.freeze

  def initialize(prompt_text: nil, aspect: :square)
    @prompt_text = prompt_text
    @aspect = aspect&.to_sym
  end

  def call(canceled: nil)
    raise Error, "Prompt metni boş olamaz." if @prompt_text.blank?

    job_id = queue_generation
    yield(job_id) if block_given?
    generation = wait_for_generation(job_id, canceled: canceled)
    format_generation(generation).merge(job_id: job_id)
  end

  def cancel(job_id)
    return false if job_id.blank?

    response = client.delete("generate/status/#{job_id}") do |req|
      req.headers.update(default_headers)
    end

    return true if response.success?

    raise Error, "AI Horde iptal isteği başarısız: HTTP #{response.status}"
  rescue Faraday::Error => e
    raise Error, "AI Horde iptal isteği başarısız: #{e.message}"
  end

  private

  def queue_generation
    response = client.post("generate/async") do |req|
      req.headers.update(default_headers)
      req.body = request_body
    end

    body = parse_response(response)
    body["id"] || raise(Error, "AI Horde job id dönmedi: #{body}")
  rescue Faraday::Error => e
    raise Error, "AI Horde isteği başarısız: #{e.message}"
  end

  def wait_for_generation(job_id, canceled: nil)
    deadline = Time.current + POLL_TIMEOUT.seconds

    loop do
      raise Canceled, "AI Horde isteği iptal edildi." if canceled&.call

      status = fetch_status(job_id)
      generations = Array(status["generations"])
      return generations.first if generations.any?

      raise Error, "AI Horde üretimi başarısız: #{status['faulted']}" if status["faulted"].present?
      raise Error, "AI Horde üretimi mümkün değil." if status.key?("is_possible") && status["is_possible"] == false
      raise Error, "AI Horde zaman aşımına uğradı." if Time.current > deadline

      sleep POLL_INTERVAL
    end
  end

  def fetch_status(job_id)
    response = client.get("generate/check/#{job_id}") do |req|
      req.headers.update(default_headers)
    end
    parse_response(response)
  rescue Faraday::Error => e
    raise Error, "AI Horde durum sorgusu başarısız: #{e.message}"
  end

  def request_body
    dims = ASPECT_DIMENSIONS.fetch(@aspect, ASPECT_DIMENSIONS[:square])

    {
      prompt: @prompt_text,
      nsfw: false,
      censor_nsfw: true,
      # Daha hızlı ve geniş worker havuzu için trusted_workers'u kapat.
      trusted_workers: false,
      r2: true, # R2 CDN linki dönsün, base64 yerine URL gelsin.
      models: [DEFAULT_MODEL],
      params: {
        steps: 20,
        cfg_scale: 7,
        width: dims[:width],
        height: dims[:height],
        sampler_name: "k_euler",
        seed: "-1", # Horde beklediği tip string; -1 rastgele için.
        n: 1
      }
    }
  end

  def format_generation(generation)
    dims = ASPECT_DIMENSIONS.fetch(@aspect, ASPECT_DIMENSIONS[:square])
    raw_img = generation["img"]
    url = normalize_image_url(raw_img)

    {
      url: url,
      width: generation["width"] || dims[:width],
      height: generation["height"] || dims[:height]
    }
  end

  def normalize_image_url(raw_img)
    return if raw_img.blank?
    return raw_img if raw_img.to_s.start_with?("http")

    "data:image/png;base64,#{raw_img}"
  end

  def parse_response(response)
    unless response.success?
      raise Error, "AI Horde HTTP #{response.status} (#{response.env.url}): #{response.body}"
    end

    response.body.is_a?(String) ? JSON.parse(response.body) : response.body
  rescue JSON::ParserError => e
    raise Error, "AI Horde JSON parse hatası: #{e.message}"
  end

  def client
    @client ||= Faraday.new(url: API_BASE_URL) do |f|
      f.request :json
      f.response :json, content_type: /\bjson$/
      f.adapter Faraday.default_adapter
      f.options.timeout = 15
      f.options.open_timeout = 5
    end
  end

  def default_headers
    headers = { "Client-Agent" => CLIENT_AGENT }
    # Horde anon anahtarına düş, yoksa env'deki anahtarı kullan.
    headers["apikey"] = ENV["AI_HORDE_API_KEY"].presence || "0000000000"
    headers
  end
end
