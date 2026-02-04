class Views::Home::Index < ApplicationComponent
  def initialize(recent_posts: Post.none, recent_jobs: [], prompt: Prompt.new, filters: {})
    @recent_posts = recent_posts
    @recent_jobs = recent_jobs
    @prompt = prompt
    @filters = filters
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
        div class: "col-12 col-lg-6 d-flex" do
          turbo_frame_tag "prompt_form" do
            panel_surface(class_name: "prompt-panel") { render ::Panels::CreatePanelComponent.new(prompt: @prompt) }
          end
        end
        div class: "col-12 col-lg-6" do
          turbo_frame_tag "dashboard_jobs", data: poller_data do
            render ::Dashboard::RightPanelComponent.new(recent_jobs: @recent_jobs, filters: @filters)
          end
        end
      end
    end
  end

  def panel_surface(class_name: nil, &block)
    classes = ["panel-surface", class_name].compact.join(" ")
    div class: classes do
      block.call
    end
  end

  def poller_data
    {
      controller: "poller",
      poller_url_value: home_dashboard_jobs_path(format: :turbo_stream, **poller_params),
      poller_interval_value: 5
    }
  end

  def poller_params
    params = {}
    params[:kind] = @filters[:kind] if @filters[:kind].present?
    params[:search] = @filters[:search] if @filters[:search].present?
    params
  end
end
