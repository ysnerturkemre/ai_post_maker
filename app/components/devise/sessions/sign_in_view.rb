class Devise::Sessions::SignInView < ApplicationComponent
  def initialize(resource:, resource_name:, devise_mapping:, flash_hash: {}, redirect_path: nil, redirect_delay_ms: nil)
    @resource = resource
    @resource_name = resource_name
    @devise_mapping = devise_mapping
    @flash_hash = flash_hash.to_h
    @redirect_path = redirect_path
    @redirect_delay_ms = redirect_delay_ms
  end

  def view_template
    content_for :full_screen, true

    div class: "auth-page" do
      left_visual
      right_panel
    end

    auto_redirect_script if redirect_path && redirect_delay_ms
    flash_dismiss_script
  end

  private

  attr_reader :resource, :devise_mapping, :flash_hash, :redirect_path, :redirect_delay_ms

  def error_messages
    return unless resource.errors.any?

    div(class: "alert alert-danger alert-dismissible fade show") do
      ul(class: "mb-0 list-unstyled") do
        resource.errors.full_messages.each { |msg| li { msg } }
      end
      button type: "button",
        class: "btn-close",
        data: { bs_dismiss: "alert" },
        aria_label: "Kapat"
    end
  end

  def flash_messages
    filtered = flash_hash.to_a.reject { |_type, msg| msg.blank? }
    return if filtered.empty?

    div(class: "login-flash-wrapper", id: "flash-container") do
      filtered.each do |type, msg|
        closable = type.to_s != "notice"
        css_class = flash_classes(type)
        css_class += " alert-dismissible fade show" if closable

        div(
          class: "#{css_class} login-flash",
          role: "alert"
        ) do
          span { msg }
          if closable
            button type: "button",
              class: "btn-close",
              data: { bs_dismiss: "alert" },
              aria_label: "Kapat"
          end
        end
      end
    end
  end

  def login_form
    form_with model: resource,
      url: user_session_path,
      method: :post,
      local: true,
      data: { turbo: false },
      class: "d-flex flex-column gap-4" do |f|

      div class: "d-flex flex-column gap-2" do
        label class: "auth-label" do
          I18n.t("auth.sign_in.email")
        end
        div class: "glass-input auth-input-row" do
          span class: "material-symbols-outlined auth-icon" do
            "mail"
          end
          f.email_field :email,
            autofocus: true,
            placeholder: I18n.t("auth.sign_in.email_placeholder")
        end
      end

      div class: "d-flex flex-column gap-2" do
        label class: "auth-label" do
          I18n.t("auth.sign_in.password")
        end
        div class: "glass-input auth-input-row" do
          span class: "material-symbols-outlined auth-icon" do
            "lock"
          end
          f.password_field :password,
            placeholder: I18n.t("auth.sign_in.password_placeholder")
        end
      end

      if devise_mapping.rememberable?
        div class: "auth-inline-row" do
          div class: "d-flex align-items-center gap-2" do
            f.check_box :remember_me,
              id: "remember_me",
              class: "form-check-input"
            label for: "remember_me" do
              I18n.t("auth.sign_in.remember_me")
            end
          end

          if devise_mapping.recoverable?
            a href: new_user_password_path, class: "auth-muted-link" do
              I18n.t("auth.sign_in.forgot_password")
            end
          end
        end
      end

      button class: "auth-submit", type: "submit" do
        I18n.t("auth.sign_in.submit")
        span(class: "material-symbols-outlined") { "arrow_forward" }
      end
    end
  end

  def footer_links
    div class: "text-center auth-muted-link" do
      span { I18n.t("auth.sign_in.no_account") + " " }
      a href: new_user_registration_path do
        I18n.t("auth.sign_in.sign_up")
      end
    end
  end

  def left_visual
    div class: "auth-left" do
      div class: "auth-left-image",
        style: "background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuC0AKcQkEQMju86NU66WAuw-g_6cUvLC54kBjuUkOANC9y-6ivWYE5xC5-1mnBwNwCetbnvOZH0kj9C4eFhM9UZdt5OpERaSmIvhiV1R3zUcKhHaZzajTxa4RcIIcQ9ceJUnPCezSKQ1NEd2RaQoLxw3dbRDJV2ULmeLKnvxIKqw0dnRMnKUSriDX5JuVRPmyF8CTE_GL2DMkSsX6IKOWvv2lGoUNFIbjj4kTcXLs_P7Nj_XryfPs1LS4TnlWHlSc7eEmtji6RPk7ye');"
      div class: "auth-left-overlay"
      div class: "auth-left-glow"
    end
  end

  def right_panel
    div class: "auth-right" do
      div class: "auth-right-inner" do
        div class: "auth-card" do
          header_block
          flash_messages
          error_messages
          login_form
          footer_links
        end
      end
    end
  end

  def header_block
    div class: "d-flex flex-column gap-2" do
      h1 class: "auth-title" do
        plain "Welcome back "
        span { "Postmaker.pro" }
      end
      p class: "auth-subtitle" do
        I18n.t("auth.sign_in.subtitle")
      end
    end
  end

  def auto_redirect_script
    return unless redirect_path && redirect_delay_ms

    script do
      plain <<~JS
        const scheduleRedirect = () => {
          setTimeout(() => {
            if (window.Turbo) {
              Turbo.visit("#{redirect_path}", { action: "replace" });
            } else {
              window.location.href = "#{redirect_path}";
            }
          }, #{redirect_delay_ms});
        };

        if (document.readyState === "complete" || document.readyState === "interactive") {
          scheduleRedirect();
        } else {
          document.addEventListener("DOMContentLoaded", scheduleRedirect, { once: true });
        }
      JS
    end
  end

  def flash_dismiss_script
    script do
      plain <<~JS
        if (!window.__flashFadeHook) {
          window.__flashFadeHook = true;

          const armFlashFade = () => {
            const flashes = document.querySelectorAll(".flash-message[data-dismissing='true']");
            flashes.forEach((el) => {
              if (el.dataset.armed) return;
              el.dataset.armed = "1";
              setTimeout(() => {
                el.style.transition = "opacity 0.6s ease";
                el.style.opacity = "0";
                setTimeout(() => el.remove(), 600);
              }, 4000);
            });
          };

          const run = () => {
            armFlashFade();
          };

          if (document.readyState === "complete" || document.readyState === "interactive") {
            run();
          } else {
            document.addEventListener("DOMContentLoaded", run, { once: true });
          }

          document.addEventListener("turbo:load", run);

          document.addEventListener("click", (e) => {
            if (e.target.matches(".flash-message .btn-close")) {
              const fm = e.target.closest(".flash-message");
              if (!fm) return;
              fm.style.transition = "opacity 0.4s ease";
              fm.style.opacity = "0";
              setTimeout(() => fm.remove(), 400);
            }
          });
        }
      JS
    end
  end

  def flash_classes(type)
    base = "alert mb-0"
    case type.to_s
    when "notice"
      "#{base} alert-success"
    when "alert"
      "#{base} alert-danger"
    else
      "#{base} alert-secondary"
    end
  end
end
