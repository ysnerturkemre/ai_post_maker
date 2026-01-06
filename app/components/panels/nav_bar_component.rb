class Panels::NavBarComponent < ApplicationComponent
  def view_template
    div class: "header-bar" do
      div class: "brand" do
        div class: "logo-blob"
        div do
          h1(class: "h5 mb-0 fw-bold text-body-emphasis") { I18n.t("navbar.title") }
          p(class: "text-muted small mb-0") { I18n.t("navbar.subtitle") }
        end
      end

      right_actions
    end
  end

  private

  def right_actions
    div class: "d-flex align-items-center gap-3 flex-wrap" do
      span class: "chip" do
        I18n.t("navbar.plan_label")
      end

      div class: "d-flex align-items-center gap-2" do
        div(class: "avatar") { user_initial }
        span(class: "fw-semibold text-body") { user_display_name }
      end

      a href: destroy_user_session_path,
        class: "btn btn-outline-purple btn-sm",
        data: { turbo_method: :delete } do
        I18n.t("navbar.logout")
      end
    end
  end

  def user_display_name
    current_user&.email.presence || I18n.t("navbar.user_placeholder")
  end

  def user_initial
    user_display_name[0]&.upcase || "?"
  end
end
