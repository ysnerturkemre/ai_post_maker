require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "destroys post and keeps prompt when other posts exist" do
    prompt = prompts(:one)
    extra_post = Post.create!(prompt: prompt, status: "queued", kind: "image")
    post = posts(:one)

    assert_difference -> { Post.count }, -1 do
      assert_no_difference -> { Prompt.count } do
        delete post_path(post)
      end
    end

    assert Post.exists?(extra_post.id)
  end

  test "destroys prompt when last post is removed" do
    prompt = Prompt.create!(text: "Cleanup prompt", kind: "image")
    post = Post.create!(prompt: prompt, status: "queued", kind: "image")

    assert_difference -> { Post.count }, -1 do
      assert_difference -> { Prompt.count }, -1 do
        delete post_path(post)
      end
    end
  end

  test "cancel marks post as failed" do
    post = posts(:one)

    post cancel_post_path(post)

    assert_equal "failed", post.reload.status
  end
end
