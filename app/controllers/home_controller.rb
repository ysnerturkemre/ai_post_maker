# app/controllers/home_controller.rb
class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    render_index(prompt: current_user.prompts.build)
  end

  def create
    @prompt = current_user.prompts.build(prompt_params)

    if @prompt.save
      post = @prompt.posts.create!(status: "queued", kind: @prompt.kind, user: current_user)

      GenerateImageJob.perform_later(@prompt.id, post.id) if @prompt.image?

      GenerateCaptionJob.perform_later(@prompt.id)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("prompt_form", Panels::CreatePanelComponent.new(prompt: current_user.prompts.build)),
            turbo_stream.replace("dashboard_jobs", dashboard_jobs_frame(fetch_dashboard_jobs))
          ]
        end
        format.html { redirect_to root_path, notice: I18n.t("flash.home.enqueued") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "prompt_form",
            Panels::CreatePanelComponent.new(prompt: @prompt)
          ), status: :unprocessable_entity
        end
        format.html { render_index(prompt: @prompt, status: :unprocessable_entity) }
      end
    end
  rescue => e
    @prompt ||= current_user.prompts.build
    @prompt.errors.add(:base, I18n.t("flash.home.error", message: e.message))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "prompt_form",
          Panels::CreatePanelComponent.new(prompt: @prompt)
        ), status: :internal_server_error
      end
      format.html { render_index(prompt: @prompt, status: :internal_server_error) }
    end
  end

  def dashboard_jobs
    filters = current_dashboard_filters
    recent_jobs = fetch_dashboard_jobs(filters)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("dashboard_jobs", dashboard_jobs_frame(recent_jobs, filters))
      end
      format.html do
        if turbo_frame_request?
          render html: dashboard_jobs_frame(recent_jobs, filters)
        else
          redirect_to home_path
        end
      end
    end
  end

  private

  def prompt_params
    params.require(:prompt).permit(:text, :lang, :tone, :kind)
  end

  def render_index(prompt:, status: :ok)
    recent_posts = current_user.posts.includes(:assets, :prompt).order(created_at: :desc).limit(6)
    filters = current_dashboard_filters
    recent_jobs = fetch_dashboard_jobs(filters)

    render Views::Home::Index.new(
      recent_posts: recent_posts,
      recent_jobs: recent_jobs,
      prompt: prompt,
      filters: filters
    ), status: status
  end

  # Recent jobs = kuyruktaki ve tamamlanan/başarısız olan Post'lar
  def fetch_dashboard_jobs(filters = current_dashboard_filters)
    recent_statuses = %w[queued processing generated published failed canceled]

    recent_posts = current_user.posts.includes(:assets, :prompt)
      .where(status: recent_statuses)
      .order(created_at: :desc)
      .limit(12)

    if filters[:kind].present?
      recent_posts = recent_posts.where(kind: filters[:kind])
    end

    if filters[:search].present?
      term = ActiveRecord::Base.sanitize_sql_like(filters[:search])
      recent_posts = recent_posts.joins(:prompt).where("prompts.text ILIKE ?", "%#{term}%")
    end

    recent_posts.map { |p| build_job_view(p) }
  end

  def dashboard_jobs_frame(recent_jobs, filters = current_dashboard_filters)
    view_context.turbo_frame_tag("dashboard_jobs", data: poller_data(filters)) do
      view_context.render(Dashboard::RightPanelComponent.new(recent_jobs: recent_jobs, filters: filters))
    end
  end

  def current_dashboard_filters
    {
      kind: normalize_kind(params[:kind]),
      search: params[:search].to_s.strip.presence
    }
  end

  def normalize_kind(kind)
    %w[image video].include?(kind.to_s) ? kind.to_s : nil
  end

  def poller_data(filters)
    {
      controller: "poller",
      poller_url_value: home_dashboard_jobs_path(format: :turbo_stream, **poller_params(filters)),
      poller_interval_value: 5
    }
  end

  def poller_params(filters)
    params = {}
    params[:kind] = filters[:kind] if filters[:kind].present?
    params[:search] = filters[:search] if filters[:search].present?
    params
  end

  def build_job_view(post)
    asset = post.assets.first
    DashboardJob.new(
      id: post.id,
      status: post.status,
      prompt: post.prompt&.text,
      output_type: post.kind,
      created_at: post.created_at,
      asset_url: asset_url_for(asset),
      caption: post.caption,
      error_message: post.data.is_a?(Hash) ? post.data["image_error"] : nil,
      caption_error: post.data.is_a?(Hash) ? post.data["caption_error"] : nil
    )
  end

  def asset_url_for(asset)
    return if asset.blank?

    if asset.file.attached?
      url_for(asset.file)
    else
      asset.file_url
    end
  rescue => e
    Rails.logger.warn("[HomeController] asset url error: #{e.message}")
    asset.file_url
  end
end
