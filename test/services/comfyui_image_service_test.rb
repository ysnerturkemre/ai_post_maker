require "test_helper"
require "tempfile"

class ComfyuiImageServiceTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :submitted_prompt, :submitted_client_id

    def submit(prompt_graph, client_id:)
      @submitted_prompt = prompt_graph
      @submitted_client_id = client_id
      { "prompt_id" => "abc" }
    end

    def history(_prompt_id)
      {
        "abc" => {
          "outputs" => {
            "1" => {
              "images" => [
                { "filename" => "img.png", "subfolder" => "", "type" => "output" }
              ]
            }
          }
        }
      }
    end

    def download(filename:, subfolder:, type:)
      { io: StringIO.new("img"), content_type: "image/png", filename: filename }
    end
  end

  test "patches prompt and returns image data" do
    workflow = {
      "1" => { "class_type" => "CLIPTextEncode", "inputs" => { "text" => "old pos" } },
      "2" => { "class_type" => "CLIPTextEncode", "inputs" => { "text" => "old neg" } }
    }

    file = Tempfile.new([ "workflow", ".json" ])
    file.write(JSON.dump(workflow))
    file.close

    client = FakeClient.new
    service = ComfyuiImageService.new(client: client, workflow_path: file.path)
    result = service.call(prompt_text: "new prompt", client_id: "client")

    assert_equal "abc", result[:prompt_id]
    assert_equal "new prompt", client.submitted_prompt["1"]["inputs"]["text"]
    assert_equal "old neg", client.submitted_prompt["2"]["inputs"]["text"]
    assert_equal "img.png", result[:image][:filename]
  ensure
    file&.unlink
  end
end
