class Devise::Registrations::SignUpView < ApplicationComponent
  def initialize(resource:, resource_name:, devise_mapping:, flash_hash: {})
    @resource = resource
    @resource_name = resource_name
    @devise_mapping = devise_mapping
    @flash_hash = flash_hash.to_h
  end

  def view_template
    content_for :full_screen, true

    turbo_frame_tag "auth_frame" do
      render Auth::CardComponent.new(
        title: "Kayıt Ol",
        subtitle: "Hesabını oluştur ve AI workspace'ine giriş yap."
      ) do
        flash_messages
        error_messages
        register_form
        footer_links
      end
    end

    flash_dismiss_script
  end

  private

  attr_reader :resource, :resource_name, :devise_mapping, :flash_hash

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

  def register_form
    bootstrap_form_with model: resource,
      url: user_registration_path,
      method: :post,
      local: true,
      data: { turbo_frame: "_top" } do |f|

      f.custom_control :email,
        label: { text: "E-posta", class: "form-label fw-semibold text-body-secondary" } do
        div(class: "input-group input-group-lg") do
          span(class: "input-group-text bg-primary-subtle text-primary fw-semibold border-0 shadow-sm") { "@" }
          f.email_field_without_bootstrap :email,
            autofocus: true,
            class: "form-control border-0 bg-white shadow-sm",
            placeholder: "ornek@mail.com"
        end
      end

      password_field(f, :password, "Şifre", "••••••••")

      if devise_mapping.confirmable?
        div(class: "text-muted small mb-2") { "Onay e-postası alacaksın." }
      end

      password_field(f, :password_confirmation, "Şifre (tekrar)", "••••••••")

      div(class: "d-grid mb-3") do
        f.submit "Kayıt ol", class: "btn btn-primary btn-lg shadow-sm"
      end
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

  def footer_links
    div(class: "text-center") do
      small(class: "text-muted") do
        span { "Zaten hesabın var mı? " }
        a href: new_user_session_path,
          class: "fw-semibold text-decoration-none",
          data: { turbo_frame: "auth_frame" } do
          "Giriş yap"
        end
      end
    end
  end

  def password_field(form, field, label_text, placeholder)
    form.custom_control field,
      label: { text: label_text, class: "form-label fw-semibold text-body-secondary" } do
      div(class: "input-group input-group-lg") do
        span(class: "input-group-text bg-primary-subtle text-primary fw-semibold border-0 shadow-sm") { "••" }
        form.password_field_without_bootstrap field,
          class: "form-control border-0 bg-white shadow-sm text-body",
          placeholder: placeholder
      end
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
end
