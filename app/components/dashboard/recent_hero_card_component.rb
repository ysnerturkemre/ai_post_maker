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
        div class: "panel-surface hero-card d-flex flex-column gap-3 position-relative" do
          header_row
          media_block
          prompt_block
          caption_block
          meta_block
          action_buttons
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
      return if @job.caption.blank?

      div class: "p-3 bg-white bg-opacity-10 rounded" do
        p(class: "mb-0 text-white small") { truncate(@job.caption.to_s, length: 240) }
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

      a href: "https://www.instagram.com/",
        class: "btn btn-outline-light btn-sm",
        target: "_blank",
        rel: "noopener" do
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
  end
end
