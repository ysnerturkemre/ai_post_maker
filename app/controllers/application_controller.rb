class ApplicationController < ActionController::Base
  include LocaleSettable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path(locale: I18n.locale)
  end
end
