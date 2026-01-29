require "test_helper"

class ComfyuiClientTest < ActiveSupport::TestCase
  class FakeHTTP
    attr_accessor :use_ssl, :open_timeout, :read_timeout
    attr_reader :requests

    def initialize(responses)
      @responses = responses
      @requests = []
    end

    def request(req)
      @requests << req
      @responses.shift
    end
  end

  def build_response(code:, body: "", headers: {})
    klass = Net::HTTPResponse::CODE_TO_OBJ.fetch(code)
    response = klass.new("1.1", code, "")
    headers.each { |key, value| response[key] = value }
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, body)
    response
  end

  test "system_stats returns parsed json" do
    response = build_response(code: "200", body: "{\"ok\":true}")
    fake = FakeHTTP.new([response])

    Net::HTTP.stub(:new, ->(*_args) { fake }) do
      client = ComfyuiClient.new(base_url: "http://example.test")
      result = client.system_stats
      assert_equal({ "ok" => true }, result)
      assert_equal "GET", fake.requests.first.method
    end
  end

  test "submit posts prompt graph" do
    response = build_response(code: "200", body: "{\"prompt_id\":\"abc\"}")
    fake = FakeHTTP.new([response])

    Net::HTTP.stub(:new, ->(*_args) { fake }) do
      client = ComfyuiClient.new(base_url: "http://example.test")
      result = client.submit({ "1" => { "class_type" => "CLIPTextEncode" } }, client_id: "client")
      assert_equal "abc", result["prompt_id"]

      req = fake.requests.first
      assert_equal "POST", req.method
      assert_match "application/json", req["Content-Type"]
    end
  end

  test "download returns io and content type" do
    response = build_response(code: "200", body: "img", headers: { "Content-Type" => "image/png" })
    fake = FakeHTTP.new([response])

    Net::HTTP.stub(:new, ->(*_args) { fake }) do
      client = ComfyuiClient.new(base_url: "http://example.test")
      result = client.download(filename: "x.png", subfolder: "", type: "output")
      assert_equal "image/png", result[:content_type]
      assert_equal "img", result[:io].read
    end
  end

  test "raises on non-2xx responses" do
    response = build_response(code: "500", body: "fail")
    fake = FakeHTTP.new([response])

    Net::HTTP.stub(:new, ->(*_args) { fake }) do
      client = ComfyuiClient.new(base_url: "http://example.test")
      assert_raises(ComfyuiClient::Error) { client.system_stats }
    end
  end
end
