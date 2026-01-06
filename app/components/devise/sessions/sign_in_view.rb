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

    turbo_frame_tag "auth_frame" do
      render Auth::CardComponent.new(
        title: I18n.t("auth.sign_in.title"),
        subtitle: I18n.t("auth.sign_in.subtitle")
      ) do
        flash_messages
        error_messages
        login_form
        footer_links
      end

      auto_redirect_script if redirect_path && redirect_delay_ms
      flash_dismiss_script
    end
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
    bootstrap_form_with model: resource,
      url: user_session_path,
      method: :post,
      local: true,
      data: { turbo: false } do |f|

      f.custom_control :email,
        label: { text: I18n.t("auth.sign_in.email"), class: "form-label fw-semibold text-body-secondary" } do
        div(class: "input-group input-group-lg") do
          span(class: "input-group-text bg-primary-subtle text-primary fw-semibold border-0 shadow-sm") { "@" }
          f.email_field_without_bootstrap :email,
            autofocus: true,
            class: "form-control border-0 bg-white shadow-sm",
            placeholder: I18n.t("auth.sign_in.email_placeholder")
        end
      end

      f.custom_control :password,
        label: { text: I18n.t("auth.sign_in.password"), class: "form-label fw-semibold text-body-secondary" } do
        div(class: "input-group input-group-lg") do
          span(class: "input-group-text bg-primary-subtle text-primary fw-semibold border-0 shadow-sm") { "••" }
          f.password_field_without_bootstrap :password,
            class: "form-control border-0 bg-white shadow-sm text-body",
            placeholder: I18n.t("auth.sign_in.password_placeholder")
        end
      end

      if devise_mapping.rememberable?
        div(class: "d-flex justify-content-between align-items-center mb-3") do
          f.check_box :remember_me,
            id: "remember_me",
            class: "form-check-input",
            wrapper_class: false,
            label: I18n.t("auth.sign_in.remember_me")

          if devise_mapping.recoverable?
            a href: new_user_password_path, class: "small text-decoration-none" do
              I18n.t("auth.sign_in.forgot_password")
            end
          end
        end
      end

      div(class: "d-grid mb-3") do
        f.submit I18n.t("auth.sign_in.submit"), class: "btn btn-primary btn-lg shadow-sm"
      end
    end
  end

  def footer_links
    div(class: "text-center") do
      small(class: "text-muted") do
        span { I18n.t("auth.sign_in.no_account") + " " }
        a href: new_user_registration_path,
          class: "fw-semibold text-decoration-none",
          data: { turbo_frame: "auth_frame" } do
          I18n.t("auth.sign_in.sign_up")
        end
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
