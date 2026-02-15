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
              platform_button("X", "shareX")
              platform_button("Instagram", "fallback", share_post_path(@job.id, platform: "instagram"))
              platform_button("TikTok", "fallback", share_post_path(@job.id, platform: "tiktok"))
              platform_button("Reddit", "shareReddit")
            end
          end

          div class: "d-flex flex-wrap gap-2 justify-content-end" do
            modal_download_button
            modal_copy_button
          end
        end
      end
    end

    def platform_button(label, action, fallback_url = nil)
      data = { action: "click->share-modal##{action}" }
      data[:url] = fallback_url if fallback_url.present?

      button type: "button", class: "share-platform-btn", data: data do
        label
      end
    end

    def modal_download_button
      return if @job.asset_url.blank?

      a href: @job.asset_url,
        class: "btn btn-outline-secondary btn-sm",
        download: true,
        target: "_blank",
        rel: "noopener",
        data: { action: "click->share-modal#stopPropagation" } do
        I18n.t("panels.recent.download")
      end
    end

    def modal_copy_button
      return if @job.caption.blank?

      button class: "btn btn-outline-secondary btn-sm",
        type: "button",
        data: {
          controller: "clipboard",
          action: "click->share-modal#stopPropagation clipboard#copy",
          clipboard_text_value: @job.caption,
          clipboard_copied_label_value: I18n.t("panels.recent.copy_done")
        } do
        I18n.t("panels.recent.copy_caption")
      end
    end

    def share_text
      @job.caption.to_s.presence || @job.prompt.to_s
    end

    def share_url
      @job.asset_url.to_s.presence || home_path
    end
  end
end
