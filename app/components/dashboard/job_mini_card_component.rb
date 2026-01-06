# frozen_string_literal: true

module Dashboard
  class JobMiniCardComponent < ApplicationComponent
    include Phlex::Rails::Helpers::ButtonTo
    include ActionView::Helpers::FormTagHelper

    def initialize(job:)
      @job = job
    end

    def view_template
      turbo_frame_tag dom_id(@job) do
        div class: "col" do
          div class: "card h-100 recent-card position-relative" do
            div class: "position-absolute top-0 end-0 mt-2 me-2" do
              status_badge(@job.status)
            end

            if @job.asset_url.present?
              div class: "ratio ratio-1x1" do
                img src: @job.asset_url, alt: "Generated asset", class: "recent-thumb-image"
              end
            end

            div class: "card-body d-flex flex-column gap-2 h-100" do
              div class: "d-flex flex-column gap-2 flex-grow-1" do
                p(class: "mb-0 small text-muted") { truncate(@job.prompt.to_s, length: 80) }
                mini_meta
                created_at_text
              end
              delete_button
            end
          end
        end
      end
    end

    private

    def status_badge(status)
      span class: "badge #{status_class(status)} px-2 py-1" do
        status_label(status)
      end
    end

    def mini_meta
      div class: "d-flex align-items-center gap-2 small text-white" do
        span class: "badge bg-light text-body" do
          output_label(@job.output_type)
        end
        if @job.asset_url.blank? && @job.status.to_s == "failed"
          span class: "text-danger-emphasis" do
            @job.error_message.presence || I18n.t("panels.recent.default_error")
          end
        end
      end
    end

    def created_at_text
      return unless @job.created_at

      p(class: "mb-0 text-muted small") do
        I18n.l(@job.created_at, format: :short)
      end
    end

    def status_label(status)
      I18n.t("panels.recent.statuses.#{status}", default: status.to_s)
    end

    def status_class(status)
      case status.to_s
      when "queued" then "bg-warning text-dark"
      when "processing" then "bg-info text-dark"
      when "failed" then "bg-danger"
      when "completed" then "bg-success"
      else "bg-secondary"
      end
    end

    def output_label(kind)
      kind.to_s == "video" ? I18n.t("panels.create.video_label") : I18n.t("panels.create.image_label")
    end

    def delete_button
      return unless @job.respond_to?(:id) && @job.id.present?

      button_to post_path(@job.id),
        method: :delete,
        class: "btn btn-outline-danger btn-sm w-100",
        data: { turbo_confirm: I18n.t("panels.recent.delete_confirm") } do
        I18n.t("panels.recent.delete_button")
      end
    end
  end
end
