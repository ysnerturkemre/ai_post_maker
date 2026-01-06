require "test_helper"

class AiHordeImageServiceTest < ActiveSupport::TestCase
  FakeEnv = Struct.new(:url)
  FakeResponse = Struct.new(:status, :body, :env) do
    def success?
      status.to_i.between?(200, 299)
    end
  end

  RequestStub = Struct.new(:headers, :body)

  class FakeClient
    def initialize(post_response:, get_responses:)
      @post_response = post_response
      @get_responses = Array(get_responses)
    end

    def post(_path)
      yield RequestStub.new({}, nil) if block_given?
      @post_response
    end

    def get(_path)
      yield RequestStub.new({}, nil) if block_given?
      @get_responses.shift || @get_responses.last
    end
  end

  test "raises error when prompt is blank" do
    service = AiHordeImageService.new(prompt_text: "")
    assert_raises(AiHordeImageService::Error) { service.call }
  end

  test "returns generation data with http url" do
    post_response = FakeResponse.new(
      200,
      { "id" => "job_1" },
      FakeEnv.new("https://aihorde.net/api/v2/generate/async")
    )
    status_response = FakeResponse.new(
      200,
      { "generations" => [ { "img" => "https://cdn.example.com/img.png", "width" => 512, "height" => 512 } ] },
      FakeEnv.new("https://aihorde.net/api/v2/generate/check/job_1")
    )
    client = FakeClient.new(post_response: post_response, get_responses: [status_response])

    service = AiHordeImageService.new(prompt_text: "Hello", aspect: :square)
    service.instance_variable_set(:@client, client)
    result = service.call

    assert_equal "https://cdn.example.com/img.png", result[:url]
    assert_equal 512, result[:width]
    assert_equal 512, result[:height]
    assert_equal "job_1", result[:job_id]
  end

  test "normalizes base64 image data" do
    post_response = FakeResponse.new(
      200,
      { "id" => "job_2" },
      FakeEnv.new("https://aihorde.net/api/v2/generate/async")
    )
    status_response = FakeResponse.new(
      200,
      { "generations" => [ { "img" => "BASE64DATA" } ] },
      FakeEnv.new("https://aihorde.net/api/v2/generate/check/job_2")
    )
    client = FakeClient.new(post_response: post_response, get_responses: [status_response])

    service = AiHordeImageService.new(prompt_text: "Hello", aspect: :square)
    service.instance_variable_set(:@client, client)
    result = service.call

    assert_equal "data:image/png;base64,BASE64DATA", result[:url]
  end

  test "raises error when generation is faulted" do
    post_response = FakeResponse.new(
      200,
      { "id" => "job_3" },
      FakeEnv.new("https://aihorde.net/api/v2/generate/async")
    )
    status_response = FakeResponse.new(
      200,
      { "generations" => [], "faulted" => "error" },
      FakeEnv.new("https://aihorde.net/api/v2/generate/check/job_3")
    )
    client = FakeClient.new(post_response: post_response, get_responses: [status_response])

    service = AiHordeImageService.new(prompt_text: "Hello", aspect: :square)
    service.instance_variable_set(:@client, client)

    assert_raises(AiHordeImageService::Error) do
      service.call
    end
  end

  test "raises error when generation is impossible" do
    post_response = FakeResponse.new(
      200,
      { "id" => "job_4" },
      FakeEnv.new("https://aihorde.net/api/v2/generate/async")
    )
    status_response = FakeResponse.new(
      200,
      { "generations" => [], "is_possible" => false },
      FakeEnv.new("https://aihorde.net/api/v2/generate/check/job_4")
    )
    client = FakeClient.new(post_response: post_response, get_responses: [status_response])

    service = AiHordeImageService.new(prompt_text: "Hello", aspect: :square)
    service.instance_variable_set(:@client, client)

    assert_raises(AiHordeImageService::Error) do
      service.call
    end
  end

  test "raises canceled when canceled callback returns true" do
    post_response = FakeResponse.new(
      200,
      { "id" => "job_5" },
      FakeEnv.new("https://aihorde.net/api/v2/generate/async")
    )
    status_response = FakeResponse.new(
      200,
      { "generations" => [] },
      FakeEnv.new("https://aihorde.net/api/v2/generate/check/job_5")
    )
    client = FakeClient.new(post_response: post_response, get_responses: [status_response])

    service = AiHordeImageService.new(prompt_text: "Hello", aspect: :square)
    service.instance_variable_set(:@client, client)

    assert_raises(AiHordeImageService::Canceled) do
      service.call(canceled: -> { true })
    end
  end
end
