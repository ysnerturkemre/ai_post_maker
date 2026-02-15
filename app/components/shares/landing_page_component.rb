# frozen_string_literal: true

module Shares
  class LandingPageComponent < ApplicationComponent
    def initialize(post:, asset_url:, share_url:)
      @post = post
      @asset_url = asset_url
      @share_url = share_url
    end

    def view_template
      div class: "dashboard-main" do
        div class: "dashboard-grid justify-content-center" do
          section class: "gallery-column w-100" do
            div class: "panel-surface mx-auto", style: "max-width: 760px;" do
              h3(class: "gallery-title mb-2") { I18n.t("panels.recent.share_landing_title") }
              p(class: "gallery-subtitle mb-4") { truncate(@post.prompt&.text.to_s, length: 180) }

              div class: "preview-box mb-3" do
                if @asset_url.present?
                  img src: @asset_url, alt: "Generated asset", class: "preview-image"
                else
                  span(class: "text-muted small px-3") { I18n.t("panels.recent.no_preview") }
                end
              end

              if @post.caption.present?
                div class: "caption-surface mb-3" do
                  p(class: "mb-0 small text-body-secondary") { @post.caption.to_s }
                end
              end

              div class: "d-flex justify-content-end" do
                a href: @share_url, class: "btn btn-outline-secondary btn-sm" do
                  I18n.t("panels.recent.share_landing_copy_link_hint")
                end
              end
            end
          end
        end
      end
    end
  end
end
