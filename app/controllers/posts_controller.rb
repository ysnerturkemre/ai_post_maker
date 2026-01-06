# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @post = Post.find(params[:id])
    prompt = @post.prompt
    frame_id = ActionView::RecordIdentifier.dom_id(@post)

    @post.destroy!
    prompt.destroy! if prompt.posts.reload.blank?

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(frame_id) }
      format.html { redirect_to home_path, notice: I18n.t("flash.posts.deleted") }
    end
  rescue => e
    Rails.logger.error("[PostsController#destroy] #{e.class}: #{e.message}")

    respond_to do |format|
      format.turbo_stream { head :internal_server_error }
      format.html { redirect_to home_path, alert: I18n.t("flash.posts.delete_failed") }
    end
  end

  def cancel
    @post = Post.find(params[:id])
    if @post.canceled?
      respond_to do |format|
        format.html { redirect_to home_path, notice: I18n.t("dashboard.cancel_success") }
        format.turbo_stream { redirect_to home_path }
      end
      return
    end

    unless @post.cancelable?
      respond_to do |format|
        format.html { redirect_to home_path, alert: I18n.t("dashboard.cancel_failed") }
        format.turbo_stream { redirect_to home_path }
      end
      return
    end

    job_id = @post.data.is_a?(Hash) ? @post.data["ai_horde_job_id"] : nil
    if job_id.present?
      begin
        AiHordeImageService.new.cancel(job_id)
      rescue AiHordeImageService::Error => e
        Rails.logger.error("[PostsController#cancel] AI Horde: #{e.message}")
      end
    end
    @post.update!(
      status: "canceled",
      data: merge_data(@post, "canceled_at" => Time.current)
    )

    respond_to do |format|
      format.html { redirect_to home_path, notice: I18n.t("dashboard.cancel_success") }
      format.turbo_stream { redirect_to home_path }
    end
  rescue => e
    Rails.logger.error("[PostsController#cancel] #{e.class}: #{e.message}")
    respond_to do |format|
      format.html { redirect_to home_path, alert: I18n.t("dashboard.cancel_failed") }
      format.turbo_stream { redirect_to home_path }
    end
  end

  private

  def merge_data(post, extra)
    safe_data = post.data.is_a?(Hash) ? post.data : {}
    safe_data.merge(extra).compact
  end
end
