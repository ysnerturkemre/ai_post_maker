# frozen_string_literal: true

module Dashboard
  class RecentHeroCardComponent < ApplicationComponent
    include Phlex::Rails::Helpers::ButtonTo

    def initialize(job:)
      @job = job
    end

    def view_template
      return unless @job

      turbo_frame_tag dom_id(@job) do
        div class: "panel-surface hero-card d-flex flex-column gap-3 position-relative",
          data: share_data do
          header_row
          media_block
          prompt_block
          caption_block
          meta_block
          action_buttons
          share_modal
        end
      end
    end

    private

    def header_row
      div class: "d-flex align-items-center justify-content-between" do
        h5(class: "mb-0 text-white") { I18n.t("panels.recent.title") }
        status_badge(@job.status)
      end
    end

    def media_block
      return if @job.asset_url.blank?

      div class: "ratio ratio-1x1 rounded overflow-hidden bg-light-subtle" do
        img src: @job.asset_url, alt: "Generated asset", class: "recent-thumb-image"
      end
    end

    def prompt_block
      div do
        p(class: "fw-semibold text-white mb-1") { truncate(@job.prompt.to_s, length: 120) }
      end
    end

    def caption_block
      if @job.caption.present?
        div class: "p-3 bg-white bg-opacity-10 rounded" do
          p(class: "mb-0 text-white small") { truncate(@job.caption.to_s, length: 240) }
        end
        return
      end

      return if @job.caption_error.blank?

      div class: "p-3 bg-danger bg-opacity-10 rounded" do
        p(class: "mb-0 text-danger-emphasis small") do
          I18n.t("panels.recent.caption_error", message: @job.caption_error)
        end
      end
    end

    def meta_block
      div class: "d-flex flex-wrap gap-2 align-items-center text-white" do
        pill(output_label(@job.output_type))
        pill(asset_label(@job))
        if @job.created_at
          pill(I18n.l(@job.created_at, format: :short))
        end
        if @job.status.to_s == "failed" && @job.error_message.present?
          span class: "badge bg-danger" do
            @job.error_message
          end
        end
      end
    end

    def pill(text)
      span class: "badge bg-light text-body fw-semibold" do
        text
      end
    end

    def status_badge(status)
      span class: "badge #{status_class(status)} px-3 py-2" do
        status_label(status)
      end
    end

    def status_label(status)
      I18n.t("panels.recent.statuses.#{status}", default: status.to_s)
    end

    def status_class(status)
      case status.to_s
      when "queued" then "bg-warning text-dark"
      when "processing" then "bg-info text-dark"
      when "generated", "published" then "bg-success"
      when "failed" then "bg-danger"
      when "canceled" then "bg-secondary"
      else "bg-secondary"
      end
    end

    def asset_label(job)
      job.asset_url.present? ? I18n.t("dashboard.asset_ready") : I18n.t("dashboard.asset_pending")
    end

    def output_label(kind)
      kind.to_s == "video" ? I18n.t("panels.create.video_label") : I18n.t("panels.create.image_label")
    end

    def action_buttons
      return unless @job.respond_to?(:id) && @job.id.present?

      div class: "d-flex flex-wrap gap-2 justify-content-end" do
        download_button
        copy_button
        share_button
        cancel_button
        delete_button
      end
    end

    def download_button
      return if @job.asset_url.blank?

      a href: @job.asset_url,
        class: "btn btn-outline-light btn-sm",
        download: true,
        target: "_blank",
        rel: "noopener" do
        I18n.t("panels.recent.download")
      end
    end

    def copy_button
      return if @job.caption.blank?

      button class: "btn btn-outline-light btn-sm",
        type: "button",
        data: {
          controller: "clipboard",
          action: "clipboard#copy",
          clipboard_text_value: @job.caption,
          clipboard_copied_label_value: I18n.t("panels.recent.copy_done")
        } do
        I18n.t("panels.recent.copy_caption")
      end
    end

    def share_button
      return if @job.asset_url.blank? && @job.caption.blank?

      button class: "btn btn-outline-light btn-sm",
        type: "button",
        data: { action: "click->share-modal#open" } do
        span(class: "material-symbols-outlined me-1", aria_hidden: true) { "share" }
        I18n.t("panels.recent.share")
      end
    end

    def cancel_button
      return unless cancelable?

      button_to cancel_post_path(@job.id),
        method: :post,
        class: "btn btn-outline-warning btn-sm",
        data: { turbo_confirm: I18n.t("dashboard.cancel_confirm") } do
        I18n.t("dashboard.cancel_job")
      end
    end

    def delete_button
      button_to post_path(@job.id),
        method: :delete,
        class: "btn btn-outline-danger btn-sm",
        data: { turbo_confirm: I18n.t("panels.recent.delete_confirm") } do
        I18n.t("panels.recent.delete_button")
      end
    end

    def cancelable?
      %w[queued processing].include?(@job.status.to_s)
    end

    def share_data
      {
        controller: "share-modal",
        share_modal_title_value: @job.prompt.to_s,
        share_modal_text_value: share_text,
        share_modal_url_value: share_url
      }
    end

    def share_modal
      div class: "share-modal-backdrop",
        hidden: true,
        data: {
          "share-modal-target": "modal",
          action: "click->share-modal#closeFromBackdrop"
        } do
        div class: "share-modal-card", data: { action: "click->share-modal#stopPropagation" } do
          div class: "share-modal-head" do
            h5(class: "share-modal-title mb-0") { I18n.t("panels.recent.share_modal_title") }
            button type: "button",
              class: "share-modal-close",
              data: { action: "click->share-modal#close" } do
              "×"
            end
          end

          div class: "preview-box mb-3" do
            if @job.asset_url.present?
              img src: @job.asset_url, alt: "Generated asset", class: "preview-image"
            else
              span(class: "text-muted small px-3") { I18n.t("panels.recent.no_preview") }
            end
            div class: "share-platform-bar",
              data: { action: "click->share-modal#stopPropagation" } do
              platform_button("X", "shareX", "x")
              platform_button("Instagram", "shareInstagram", "instagram")
              platform_button("TikTok", "shareTikTok", "tiktok")
              platform_button("Reddit", "shareReddit", "reddit")
              modal_download_button
            end
          end
        end
      end
    end

    def platform_button(label, action, platform)
      data = { action: "click->share-modal##{action}" }

      button type: "button", class: "share-platform-btn", data: data do
        platform_icon(platform)
        span { label }
      end
    end

    def platform_icon(platform)
      svg xmlns: "http://www.w3.org/2000/svg",
        viewBox: "0 0 24 24",
        class: "share-platform-icon-svg",
        aria_hidden: true do |icon|
        icon.path d: platform_icon_path(platform)
      end
    end

    def platform_icon_path(platform)
      case platform
      when "instagram"
        "M7.75 2h8.5A5.75 5.75 0 0 1 22 7.75v8.5A5.75 5.75 0 0 1 16.25 22h-8.5A5.75 5.75 0 0 1 2 16.25v-8.5A5.75 5.75 0 0 1 7.75 2zm0 1.9a3.85 3.85 0 0 0-3.85 3.85v8.5a3.85 3.85 0 0 0 3.85 3.85h8.5a3.85 3.85 0 0 0 3.85-3.85v-8.5a3.85 3.85 0 0 0-3.85-3.85h-8.5zm8.93 1.5a1.37 1.37 0 1 1 0 2.74 1.37 1.37 0 0 1 0-2.74zM12 7.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6zm0 1.9a2.9 2.9 0 1 0 0 5.8 2.9 2.9 0 0 0 0-5.8z"
      when "tiktok"
        "M14.75 2h2.85c.2 1.72 1.22 3.2 2.72 3.95v2.9c-1.43-.04-2.8-.43-3.97-1.14v7.24c0 3.63-2.97 6.6-6.6 6.6s-6.6-2.97-6.6-6.6 2.97-6.6 6.6-6.6c.36 0 .72.03 1.06.09v2.9a3.76 3.76 0 1 0 2.99 3.68V2z"
      when "reddit"
        "M24 11.5c0-1.26-1.03-2.29-2.29-2.29-.61 0-1.16.24-1.57.63-1.54-1.01-3.63-1.66-5.96-1.75l1.01-3.18 2.74.64A1.72 1.72 0 1 0 18.23 4l-3.41-.8a.96.96 0 0 0-1.13.63l-1.29 4.07c-2.47.04-4.7.69-6.3 1.73a2.28 2.28 0 0 0-1.53-.59 2.29 2.29 0 1 0 1.55 3.98 4.54 4.54 0 0 0-.08.82c0 3.25 3.77 5.89 8.41 5.89 4.65 0 8.42-2.64 8.42-5.89 0-.29-.03-.58-.1-.86A2.28 2.28 0 0 0 24 11.5zm-13.95 1.63a1.36 1.36 0 1 1 0-2.72 1.36 1.36 0 0 1 0 2.72zm6.9 0a1.36 1.36 0 1 1 0-2.72 1.36 1.36 0 0 1 0 2.72zm-1.14 3.96c-1.05 1.05-3.57 1.05-4.62 0a.95.95 0 1 1 1.34-1.34c.27.27 1.67.27 1.94 0a.95.95 0 0 1 1.34 1.34z"
      else
        "M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231z"
      end
    end

    def modal_download_button
      return if @job.asset_url.blank?

      a href: @job.asset_url,
        class: "share-platform-btn",
        download: true,
        target: "_blank",
        rel: "noopener",
        data: { action: "click->share-modal#stopPropagation" } do
        span(class: "material-symbols-outlined share-platform-icon-material", aria_hidden: true) { "download" }
        span { I18n.t("panels.recent.download") }
      end
    end

    def share_text
      @job.caption.to_s.presence || @job.prompt.to_s
    end

    def share_url
      "#{view_context.request.base_url}#{share_landing_path(@job.id)}"
    end
  end
end
