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
    @post.update!(status: "failed")

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
end
