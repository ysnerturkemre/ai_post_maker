require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "destroys post and keeps prompt when other posts exist" do
    prompt = prompts(:one)
    extra_post = Post.create!(prompt: prompt, status: "queued", kind: "image", user: users(:one))
    post = posts(:one)

    assert_difference -> { Post.count }, -1 do
      assert_no_difference -> { Prompt.count } do
        delete post_path(post)
      end
    end

    assert Post.exists?(extra_post.id)
  end

  test "destroys prompt when last post is removed" do
    prompt = Prompt.create!(text: "Cleanup prompt", kind: "image", user: users(:one))
    post = Post.create!(prompt: prompt, status: "queued", kind: "image", user: users(:one))

    assert_difference -> { Post.count }, -1 do
      assert_difference -> { Prompt.count }, -1 do
        delete post_path(post)
      end
    end
  end

  test "cancel marks post as canceled" do
    post = posts(:one)

    post cancel_post_path(post)

    assert_equal "canceled", post.reload.status
  end

  test "cancel does not change non-cancelable posts" do
    post = posts(:two)
    post.update!(status: "generated")

    post cancel_post_path(post)

    assert_equal "generated", post.reload.status
  end

  test "share renders fallback page for instagram and tiktok" do
    post = posts(:one)

    get share_post_path(post, platform: "instagram")
    assert_response :success
    assert_includes response.body, "Platform Redirect"

    get share_post_path(post, platform: "tiktok")
    assert_response :success
    assert_includes response.body, "TikTok"
  end

  test "share falls back to instagram for unknown platform" do
    post = posts(:one)

    get share_post_path(post, platform: "x")

    assert_response :success
    assert_includes response.body, "Instagram"
  end

  test "prevents access to posts owned by other users" do
    sign_in users(:two)
    post = posts(:one)

    delete post_path(post)
    assert_response :not_found

    post cancel_post_path(post)
    assert_response :not_found

    get share_post_path(post, platform: "instagram")
    assert_response :not_found
  end
end
