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
          meta_block
          delete_button
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
      when "failed" then "bg-danger"
      when "completed" then "bg-success"
      else "bg-secondary"
      end
    end

    def asset_label(job)
      job.asset_url.present? ? I18n.t("dashboard.asset_ready") : I18n.t("dashboard.asset_pending")
    end

    def output_label(kind)
      kind.to_s == "video" ? I18n.t("panels.create.video_label") : I18n.t("panels.create.image_label")
    end

    def delete_button
      return unless @job.respond_to?(:id) && @job.id.present?

      div class: "d-flex justify-content-end" do
        button_to post_path(@job.id),
          method: :delete,
          class: "btn btn-outline-danger btn-sm",
          data: { turbo_confirm: I18n.t("panels.recent.delete_confirm") } do
          I18n.t("panels.recent.delete_button")
        end
      end
    end
  end
end
