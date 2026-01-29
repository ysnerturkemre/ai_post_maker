# frozen_string_literal: true

require "json"

class ComfyuiImageService
  class Error < StandardError; end
  class Canceled < Error; end

  DEFAULT_WORKFLOW_PATH = "config/comfyui/workflows/aimaker_image_v1.json"
  WORKFLOW_PATH = ENV.fetch("COMFYUI_WORKFLOW_PATH", DEFAULT_WORKFLOW_PATH)
  POLL_INTERVAL = Integer(ENV.fetch("COMFYUI_POLL_INTERVAL_SECONDS", 3))
  POLL_TIMEOUT = Integer(ENV.fetch("COMFYUI_POLL_TIMEOUT_SECONDS", 600))

  def initialize(client: ComfyuiClient.new, workflow_path: WORKFLOW_PATH)
    @client = client
    @workflow_path = workflow_path
  end

  def call(prompt_text:, client_id: "ai_post_maker", canceled: nil)
    raise Error, "Prompt metni boş olamaz." if prompt_text.blank?

    workflow = load_workflow
    patched = patch_prompt(workflow, prompt_text)
    response = @client.submit(patched, client_id: client_id)
    prompt_id = response["prompt_id"] || response[:prompt_id]
    raise Error, "ComfyUI prompt_id dönmedi: #{response}" if prompt_id.blank?

    yield prompt_id if block_given?

    image_info = wait_for_output(prompt_id, canceled: canceled)
    download = @client.download(
      filename: image_info[:filename],
      subfolder: image_info[:subfolder].to_s,
      type: image_info[:type].presence || "output"
    )

    { prompt_id: prompt_id, image: download }
  end

  private

  def load_workflow
    JSON.parse(File.read(@workflow_path))
  rescue Errno::ENOENT => e
    raise Error, "Workflow bulunamadı: #{e.message}"
  rescue JSON::ParserError => e
    raise Error, "Workflow JSON parse hatası: #{e.message}"
  end

  def patch_prompt(workflow, prompt_text)
    nodes = workflow.values.select do |node|
      node.is_a?(Hash) &&
        node["class_type"] == "CLIPTextEncode" &&
        node.dig("inputs", "text").present?
    end

    return workflow if nodes.empty?

    nodes.first["inputs"]["text"] = prompt_text
    workflow
  end

  def wait_for_output(prompt_id, canceled: nil)
    deadline = Time.current + POLL_TIMEOUT.seconds

    loop do
      raise Canceled, "ComfyUI isteği iptal edildi." if canceled&.call

      history = @client.history(prompt_id)
      image_info = extract_first_image(history, prompt_id)
      return image_info if image_info

      raise Error, "ComfyUI zaman aşımına uğradı." if Time.current > deadline

      sleep POLL_INTERVAL
    end
  end

  def extract_first_image(history, prompt_id)
    record = history[prompt_id.to_s] || history.values.first
    outputs = record.is_a?(Hash) ? record["outputs"] : nil
    return nil unless outputs.is_a?(Hash)

    outputs.each_value do |output|
      images = output["images"]
      next unless images.is_a?(Array) && images.any?

      image = images.first
      next unless image.is_a?(Hash)

      filename = image["filename"]
      next if filename.blank?

      return {
        filename: filename,
        subfolder: image["subfolder"],
        type: image["type"] || "output"
      }
    end

    nil
  end
end
