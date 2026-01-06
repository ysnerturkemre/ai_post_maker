class Users::SessionsController < Devise::SessionsController
  include LocaleSettable

  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?

    render Devise::Sessions::SignInView.new(
      resource: resource,
      resource_name: resource_name,
      devise_mapping: devise_mapping,
      flash_hash: flash.to_hash
    )
  end

  def create
    self.resource = warden.authenticate(auth_options)

    if resource
      # Flash sadece mevcut ekranda görünsün; yönlendirme sonrası taşınmasın.
      flash.now[:notice] = I18n.t("flash.sessions.signed_in")
      sign_in(resource_name, resource)
      yield resource if block_given?

      respond_to do |format|
        format.html do
          response.set_header("Refresh", "3; url=#{after_sign_in_path_for(resource)}")
          render Devise::Sessions::SignInView.new(
            resource: resource,
            resource_name: resource_name,
            devise_mapping: devise_mapping,
            flash_hash: flash.to_hash,
            redirect_path: after_sign_in_path_for(resource),
            redirect_delay_ms: 3_000
          )
        end

        format.turbo_stream { redirect_to after_sign_in_path_for(resource), status: :see_other }
      end
    else
      submitted_email = sign_in_params[:email]
      user_exists = submitted_email.present? && resource_class.find_for_database_authentication(email: submitted_email.downcase)

      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      flash.now[:alert] = if user_exists
        I18n.t("flash.sessions.wrong_credentials")
      else
        I18n.t("flash.sessions.email_not_found")
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "auth_frame",
            Devise::Sessions::SignInView.new(
              resource: resource,
              resource_name: resource_name,
              devise_mapping: devise_mapping,
              flash_hash: flash.to_hash
            )
          ), status: :unprocessable_entity
        end

        format.html do
          render Devise::Sessions::SignInView.new(
            resource: resource,
            resource_name: resource_name,
            devise_mapping: devise_mapping,
            flash_hash: flash.to_hash
          ), status: :unprocessable_entity
        end
      end
    end
  end
end
