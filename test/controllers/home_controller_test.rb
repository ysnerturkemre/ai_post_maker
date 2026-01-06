require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    clear_enqueued_jobs
  end

  test "redirects unauthenticated users" do
    get home_path
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    sign_in users(:one)
    get home_path
    assert_response :success
  end

  test "sets locale from params" do
    sign_in users(:one)
    get home_path(locale: "en")
    assert_response :success
    assert_equal "en", cookies[:locale]
  end

  test "should create prompt and enqueue jobs for image" do
    sign_in users(:one)
    assert_difference -> { Prompt.count }, 1 do
      assert_difference -> { Post.count }, 1 do
        assert_enqueued_jobs 2 do
          post home_path, params: { prompt: { text: "Test prompt", kind: "image" } }
        end
      end
    end
    assert_enqueued_with(job: GenerateImageJob)
    assert_enqueued_with(job: GenerateCaptionJob)
    assert_redirected_to root_path(locale: I18n.locale)
  end

  test "should create prompt and enqueue only caption job for video" do
    sign_in users(:one)
    assert_difference -> { Prompt.count }, 1 do
      assert_no_difference -> { Post.count } do
        assert_enqueued_jobs 1 do
          post home_path, params: { prompt: { text: "Video prompt", kind: "video" } }
        end
      end
    end
    assert_enqueued_with(job: GenerateCaptionJob)
    assert_redirected_to root_path(locale: I18n.locale)
  end

  test "rejects blank prompt" do
    sign_in users(:one)
    assert_no_difference -> { Prompt.count } do
      assert_enqueued_jobs 0 do
        post home_path, params: { prompt: { text: "", kind: "image" } }
      end
    end
    assert_response :unprocessable_entity
  end
end
