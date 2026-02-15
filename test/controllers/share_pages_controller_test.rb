require "test_helper"

class SharePagesControllerTest < ActionDispatch::IntegrationTest
  test "landing page is publicly accessible with og metadata" do
    post = posts(:one)

    get share_landing_path(post)

    assert_response :success
    assert_includes response.body, 'property="og:title"'
    assert_includes response.body, 'property="og:image"'
    assert_includes response.body, 'name="twitter:card"'
    assert_includes response.body, "summary_large_image"
  end

  test "landing page returns 404 for missing post" do
    get share_landing_path(id: 999_999)
    assert_response :not_found
  end
end
