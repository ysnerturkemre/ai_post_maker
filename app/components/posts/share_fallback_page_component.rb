# frozen_string_literal: true

module Posts
  class ShareFallbackPageComponent < ApplicationComponent
    def initialize(post:, platform:, asset_url:)
      @post = post
      @platform = platform
      @asset_url = asset_url
    end

    def view_template
      render ::Panels::NavBarComponent.new

      div class: "dashboard-main" do
        div class: "dashboard-grid justify-content-center" do
          section class: "gallery-column w-100" do
            div class: "panel-surface mx-auto", style: "max-width: 760px;" do
              h3(class: "gallery-title mb-2") { I18n.t("panels.recent.fallback_title") }
              p(class: "gallery-subtitle mb-4") do
                I18n.t("panels.recent.fallback_description", platform: platform_label)
              end

              div class: "preview-box mb-3" do
                if @asset_url.present?
                  img src: @asset_url, alt: "Generated asset", class: "preview-image"
                else
                  span(class: "text-muted small px-3") { I18n.t("panels.recent.no_preview") }
                end
              end

              div class: "d-flex flex-wrap gap-2 justify-content-end" do
                download_button
                copy_button
                a href: home_path, class: "btn btn-primary btn-sm" do
                  I18n.t("panels.recent.back_to_home")
                end
              end
            end
          end
        end
      end
    end

    private

    def platform_label
      @platform == "tiktok" ? "TikTok" : "Instagram"
    end

    def download_button
      return if @asset_url.blank?

      a href: @asset_url,
        class: "btn btn-outline-light btn-sm",
        download: true,
        target: "_blank",
        rel: "noopener" do
        I18n.t("panels.recent.download")
      end
    end

    def copy_button
      return if @post.caption.blank?

      button class: "btn btn-outline-light btn-sm",
        type: "button",
        data: {
          controller: "clipboard",
          action: "clipboard#copy",
          clipboard_text_value: @post.caption,
          clipboard_copied_label_value: I18n.t("panels.recent.copy_done")
        } do
        I18n.t("panels.recent.copy_caption")
      end
    end
  end
end
