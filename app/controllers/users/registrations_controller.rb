class Users::RegistrationsController < Devise::RegistrationsController
  include LocaleSettable

  def new
    build_resource
    yield resource if block_given?

    render Devise::Registrations::SignUpView.new(
      resource: resource,
      resource_name: resource_name,
      devise_mapping: devise_mapping,
      flash_hash: flash.to_hash
    )
  end

  def create
    build_resource(sign_up_params)

    resource.save
    if resource.persisted?
      set_flash_message! :notice, :signed_up if is_flashing_format?
      sign_up(resource_name, resource)
      redirect_to after_sign_in_path_for(resource)
    else
      clean_up_passwords(resource)
      set_minimum_password_length

      render Devise::Registrations::SignUpView.new(
        resource: resource,
        resource_name: resource_name,
        devise_mapping: devise_mapping,
        flash_hash: flash.to_hash
      ), status: :unprocessable_entity
    end
  end
end
