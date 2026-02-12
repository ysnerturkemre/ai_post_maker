class Panels::NavBarComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo
  def view_template
    header class: "glass-nav" do
      div class: "nav-inner" do
        brand_block
        # nav_links # temporarily disabled
        right_actions
      end
    end
  end

  private

  def brand_block
    div class: "brand" do
      div class: "logo-blob" do
        span class: "material-symbols-outlined logo-icon" do
          "auto_awesome"
        end
      end
      div do
        h1(class: "brand-title") do
          plain I18n.t("navbar.title")
          span(class: "brand-accent") { ".pro" }
        end
        p(class: "brand-subtitle") { I18n.t("navbar.subtitle") }
      end
    end
  end

  def nav_links
    nav class: "nav-links" do
      a(class: "nav-link-pill is-active", href: "#") { "Dashboard" }
      a(class: "nav-link-pill", href: "#") { "Library" }
      a(class: "nav-link-pill", href: "#") { "Analytics" }
    end
  end

  def right_actions
    div class: "nav-actions" do
      # credits_block
      logout_button
    end
  end

  def credits_block
    div class: "credits-block" do
      div class: "credits-meta" do
        span(class: "credits-label") { "Credits" }
        span(class: "credits-value") { "420 / 1000" }
      end
      div class: "credits-bar" do
        div class: "credits-bar-fill"
      end
    end
  end

  def logout_button
    button_to destroy_user_session_path,
      method: :delete,
      form_class: "logout-form",
      class: "logout-button" do
      I18n.t("navbar.logout")
    end
  end

  def user_display_name
    current_user&.email.presence || I18n.t("navbar.user_placeholder")
  end

  def user_initial
    user_display_name[0]&.upcase || "?"
  end
end
