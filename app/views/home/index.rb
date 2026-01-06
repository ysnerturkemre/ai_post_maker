class Views::Home::Index < ApplicationComponent
  def initialize(recent_posts: Post.none, recent_jobs: [], prompt: Prompt.new)
    @recent_posts = recent_posts
    @recent_jobs = recent_jobs
    @prompt = prompt
  end

  def view_template
    div class: "page-container container" do
      render ::Panels::NavBarComponent.new
      divider_line
      glass_card
    end
  end

  private

  def divider_line
    div class: "section-divider"
  end

  def glass_card
    div class: "glass-card" do
      div class: "row g-4" do
        div class: "col-12 col-lg-6" do
          turbo_frame_tag "prompt_form" do
            panel_surface { render ::Panels::CreatePanelComponent.new(prompt: @prompt) }
          end
        end
        div class: "col-12 col-lg-6" do
          turbo_frame_tag "dashboard_jobs" do
            render ::Dashboard::RightPanelComponent.new(recent_jobs: @recent_jobs)
          end
        end
      end
    end
  end

  def panel_surface(&block)
    div class: "panel-surface" do
      block.call
    end
  end
end
