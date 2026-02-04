# frozen_string_literal: true

module Dashboard
  class RightPanelComponent < ApplicationComponent
    def initialize(recent_jobs:, filters: {})
      @recent_jobs = Array(recent_jobs).compact
      @filters = filters || {}
    end

    def view_template
      div class: "d-flex flex-column gap-3" do
        render_recent_section
      end
    end

    private

    def render_recent_section
      div class: "panel-surface" do
        header_row
        filter_controls

        if @recent_jobs.blank?
          div class: "text-muted small" do
            I18n.t("panels.recent.empty")
          end
          return
        end

        div class: "recent-grid row row-cols-1 row-cols-md-2 g-3 mt-2" do
          @recent_jobs.each do |job|
            render Dashboard::JobMiniCardComponent.new(job: job)
          end
        end
      end
    end

    def header_row
      div class: "d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3" do
        h6(class: "mb-0 text-white") { I18n.t("panels.recent.title") }
      end
    end

    def filter_controls
      div class: "d-flex flex-column gap-3 mb-2" do
        render_kind_tabs
        render_search
      end
    end

    def render_kind_tabs
      div class: "btn-group w-100 gallery-toggle-group" do
        filter_link(I18n.t("panels.recent.filters.all"), nil)
        filter_link(I18n.t("panels.recent.filters.images"), "image")
        filter_link(I18n.t("panels.recent.filters.videos"), "video")
      end
    end

    def render_search
      form_with url: home_dashboard_jobs_path,
        method: :get,
        data: { turbo_frame: "dashboard_jobs" },
        class: "d-flex gap-2 flex-wrap" do |f|
        f.hidden_field :kind, value: current_kind
        f.text_field :search,
          value: current_search,
          placeholder: I18n.t("panels.recent.filters.search_placeholder"),
          class: "form-control filter-search-input"
        f.submit I18n.t("panels.recent.filters.search_button"), class: "btn btn-outline-light filter-search-button"
      end
    end

    def filter_link(label, kind)
      params = {}
      params[:kind] = kind if kind.present?
      params[:search] = current_search if current_search.present?
      active = current_kind == kind || (current_kind.blank? && kind.blank?)
      classes = ["btn", "filter-toggle", active ? "btn-light" : "btn-outline-light"].join(" ")

      a href: home_dashboard_jobs_path(params),
        class: classes,
        data: { turbo_frame: "dashboard_jobs" } do
        label
      end
    end

    def current_kind
      @filters[:kind].to_s.presence
    end

    def current_search
      @filters[:search].to_s.presence
    end
  end
end
