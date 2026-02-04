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
      div class: "panel-surface gallery-panel",
        data: { controller: "view-toggle" } do
        header_row
        filter_controls

        if @recent_jobs.blank?
          div class: "text-muted small" do
            I18n.t("panels.recent.empty")
          end
          return
        end

        div class: "gallery-grid row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4",
          data: { "view-toggle-target": "grid" } do
          @recent_jobs.each do |job|
            render Dashboard::JobMiniCardComponent.new(job: job)
          end
        end
      end
    end

    def header_row
      div class: "gallery-header" do
        div class: "gallery-header-text" do
          h3(class: "gallery-title") { "Your Creations" }
          p(class: "gallery-subtitle") { "High-quality AI generated visual content" }
        end
        div class: "view-toggle" do
          button class: "view-toggle-button is-active",
            type: "button",
            data: { action: "view-toggle#grid", "view-toggle-target": "gridButton" } do
            span(class: "material-symbols-outlined") { "grid_view" }
          end
          button class: "view-toggle-button",
            type: "button",
            data: { action: "view-toggle#list", "view-toggle-target": "listButton" } do
            span(class: "material-symbols-outlined") { "format_list_bulleted" }
          end
        end
      end
    end

    def filter_controls
      div class: "gallery-filters" do
        render_kind_tabs
        render_search
      end
    end

    def render_kind_tabs
      div class: "btn-group w-100 gallery-toggle-group" do
        filter_link(I18n.t("panels.recent.filters.all"), "all")
        filter_link(I18n.t("panels.recent.filters.images"), "image")
        filter_link(I18n.t("panels.recent.filters.videos"), "video")
      end
    end

    def render_search
      form_with url: home_dashboard_jobs_path,
        method: :get,
        data: { turbo_frame: "dashboard_jobs" },
        class: "d-flex gap-2 flex-wrap" do |f|
        f.hidden_field :gallery_kind, value: current_kind
        f.text_field :search,
          value: current_search,
          placeholder: I18n.t("panels.recent.filters.search_placeholder"),
          class: "form-control filter-search-input"
        f.submit I18n.t("panels.recent.filters.search_button"), class: "btn btn-outline-light filter-search-button"
      end
    end

    def filter_link(label, kind)
      params = {}
      params[:gallery_kind] = kind if kind.present?
      params[:search] = current_search if current_search.present?
      active = current_kind == kind || (current_kind.blank? && kind == "all")
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
