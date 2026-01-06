# frozen_string_literal: true

module Dashboard
  class RightPanelComponent < ApplicationComponent
    def initialize(recent_jobs:)
      @recent_jobs = Array(recent_jobs).compact
    end

    def view_template
      div class: "d-flex flex-column gap-3" do
        render_recent_section
      end
    end

    private

    def render_recent_section
      div class: "panel-surface" do
        div class: "d-flex align-items-center justify-content-between mb-2" do
          h6(class: "mb-0 text-white") { I18n.t("panels.recent.title") }
        end

        if @recent_jobs.blank?
          div class: "text-muted small" do
            I18n.t("panels.recent.empty")
          end
          return
        end

        hero, *rest = @recent_jobs

        render Dashboard::RecentHeroCardComponent.new(job: hero) if hero

        if rest.any?
          div class: "recent-grid row row-cols-1 row-cols-sm-2 g-3 mt-2" do
            rest.each do |job|
              render Dashboard::JobMiniCardComponent.new(job: job)
            end
          end
        end
      end
    end
  end
end
