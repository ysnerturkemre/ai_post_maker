# frozen_string_literal: true

module Dashboard
  class JobMiniCardComponent < ApplicationComponent
    include Phlex::Rails::Helpers::ButtonTo
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::DateHelper

    def initialize(job:)
      @job = job
    end

    def view_template
      turbo_frame_tag dom_id(@job) do
        div class: "col" do
          article class: "recent-card h-100" do
            media_block
            card_body
          end
        end
      end
    end

    private

    def media_block
      div class: "card-media" do
        if @job.asset_url.present?
          img src: @job.asset_url, alt: "Generated asset", class: "recent-thumb-image"
        end
        div class: "media-badge" do
          time_badge_text
        end
      end
    end

    def card_body
      div class: "card-body recent-card-body" do
        div class: "card-type" do
          "Type: #{output_label(@job.output_type)}"
        end
        p(class: "card-prompt") { truncate(@job.prompt.to_s, length: 120) }
        caption_snippet
        action_buttons
        tag_row
      end
    end

    def time_badge_text
      return "Just now" unless @job.created_at

      minutes = ((Time.zone.now - @job.created_at) / 60).floor
      if minutes < 60
        "#{minutes.zero? ? 1 : minutes}m ago"
      elsif minutes < 1440
        "#{(minutes / 60).round}hr ago"
      else
        "#{(minutes / 1440).round}d ago"
      end
    end

    def caption_snippet
      return if @job.caption.blank? && @job.caption_error.blank?

      if @job.caption.present?
        div class: "caption-surface" do
          p(class: "mb-0 small text-body-secondary") { truncate(@job.caption.to_s, length: 90) }
        end
        return
      end

      div class: "caption-surface caption-error" do
        p(class: "mb-0 small text-danger-emphasis") do
          I18n.t("panels.recent.caption_error", message: @job.caption_error)
        end
      end
    end

    def output_label(kind)
      kind.to_s == "video" ? "16:9 Video" : "1:1 Portrait"
    end

    def action_buttons
      return unless @job.respond_to?(:id) && @job.id.present?

      div class: "card-actions" do
        div class: "action-left" do
          download_button
          copy_button
          share_button
        end
        div class: "action-right" do
          cancel_button
          delete_button
        end
      end
    end

    def download_button
      return if @job.asset_url.blank?

      a href: @job.asset_url,
        class: "icon-button",
        download: true,
        target: "_blank",
        rel: "noopener" do
        span(class: "material-symbols-outlined") { "download" }
      end
    end

    def copy_button
      return if @job.caption.blank?

      button class: "icon-button",
        type: "button",
        data: {
          controller: "clipboard",
          action: "clipboard#copy",
          clipboard_text_value: @job.caption,
          clipboard_copied_label_value: I18n.t("panels.recent.copy_done")
        } do
        span(class: "material-symbols-outlined") { "content_copy" }
      end
    end

    def share_button
      return if @job.asset_url.blank? && @job.caption.blank?

      a href: "https://www.instagram.com/",
        class: "icon-button instagram-gradient",
        target: "_blank",
        rel: "noopener" do
        span(class: "material-symbols-outlined") { "share" }
      end
    end

    def cancel_button
      return unless cancelable?

      form_with url: cancel_post_path(@job.id), method: :post, class: "action-form" do
        button class: "icon-button warning-button",
          type: "submit",
          data: { turbo_confirm: I18n.t("dashboard.cancel_confirm") } do
          span(class: "material-symbols-outlined") { "close" }
        end
      end
    end

    def delete_button
      form_with url: post_path(@job.id), method: :delete, class: "action-form" do
        button class: "icon-button danger-button",
          type: "submit",
          data: { turbo_confirm: I18n.t("panels.recent.delete_confirm") } do
          span(class: "material-symbols-outlined") { "delete" }
        end
      end
    end

    def cancelable?
      %w[queued processing].include?(@job.status.to_s)
    end

    def tag_row
      div class: "card-tags" do
        tag_labels.each_with_index do |label, index|
          span class: index.zero? ? "tag tag-primary" : "tag" do
            "##{label}"
          end
        end
      end
    end

    def tag_labels
      primary = @job.output_type.to_s == "video" ? "VIDEO" : "IMAGE"
      secondary = @job.status.to_s.presence || "AI"
      [primary, secondary.upcase]
    end
  end
end
