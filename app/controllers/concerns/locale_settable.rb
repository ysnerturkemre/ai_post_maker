module LocaleSettable
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
    helper_method :current_locale
  end

  private

  def set_locale
    chosen = params[:locale] || session[:locale] || cookies[:locale]
    locale = I18n.available_locales.map(&:to_s).include?(chosen.to_s) ? chosen : I18n.default_locale

    I18n.locale = locale
    session[:locale] = locale
    cookies[:locale] = { value: locale, expires: 1.year.from_now }
  end

  def default_url_options
    { locale: I18n.locale }.compact
  end

  def current_locale
    I18n.locale
  end
end
