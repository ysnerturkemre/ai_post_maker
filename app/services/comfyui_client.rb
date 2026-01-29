# frozen_string_literal: true

require "net/http"
require "json"
require "stringio"

class ComfyuiClient
  class Error < StandardError; end

  def initialize(base_url: ENV.fetch("COMFYUI_BASE_URL", "http://host.docker.internal:8188"))
    @base_uri = URI(base_url)
  end

  def system_stats
    get_json("/system_stats")
  end

  def submit(prompt_graph, client_id: "ai_post_maker")
    post_json("/prompt", { prompt: prompt_graph, client_id: client_id })
  end

  def history(prompt_id)
    get_json("/history/#{prompt_id}")
  end

  def download(filename:, subfolder: "", type: "output")
    response = get_raw("/view", query: { filename: filename, subfolder: subfolder, type: type })

    {
      io: StringIO.new(response.body.to_s),
      content_type: response["Content-Type"] || "application/octet-stream",
      filename: filename
    }
  end

  def cancel_running
    post_json("/interrupt", nil)
  end

  private

  def get_json(path, query: nil)
    response = request(:get, path, query: query)
    parse_json(response)
  end

  def post_json(path, body)
    response = request(:post, path, body: body)
    response.body.to_s.empty? ? {} : parse_json(response)
  end

  def get_raw(path, query: nil)
    request(:get, path, query: query)
  end

  def request(method, path, body: nil, query: nil)
    uri = build_uri(path, query)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 15

    request_class = method == :post ? Net::HTTP::Post : Net::HTTP::Get
    req = request_class.new(uri)
    if body
      req["Content-Type"] = "application/json"
      req.body = JSON.dump(body)
    end

    response = http.request(req)
    return response if response.is_a?(Net::HTTPSuccess)

    raise Error, "ComfyUI HTTP #{response.code} (#{uri}): #{response.body}"
  rescue Error
    raise
  rescue StandardError => e
    raise Error, "ComfyUI isteği başarısız: #{e.message}"
  end

  def parse_json(response)
    JSON.parse(response.body.to_s)
  rescue JSON::ParserError => e
    raise Error, "ComfyUI JSON parse hatası: #{e.message}"
  end

  def build_uri(path, query)
    uri = @base_uri.dup
    base_path = uri.path.to_s
    base_path = "" if base_path == "/"
    uri.path = File.join(base_path, path)
    uri.query = URI.encode_www_form(query) if query
    uri
  end
end
