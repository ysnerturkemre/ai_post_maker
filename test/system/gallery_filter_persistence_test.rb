require "application_system_test_case"

class GalleryFilterPersistenceTest < ApplicationSystemTestCase
  test "image filter stays selected after poll refresh" do
    sign_in users(:one)
    visit home_path

    click_on "Görseller"
    assert_selector ".gallery-toggle-group .btn-light", text: "Görseller"

    sleep 6

    assert_selector ".gallery-toggle-group .btn-light", text: "Görseller"
  end
end
