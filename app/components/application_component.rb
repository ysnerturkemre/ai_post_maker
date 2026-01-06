# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  # Routes önce gelmeli; url_options'u tanımlıyor.
  include Phlex::Rails::Helpers::Routes

  include ActionView::RecordIdentifier
  include ActionView::Helpers::TextHelper
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags
  include Phlex::Rails::Helpers::JavaScriptIncludeTag
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::FormFor
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::TurboIncludeTags
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::Translate

  delegate :current_user, :user_signed_in?, to: :view_context, allow_nil: true

  begin
    require "bootstrap_form"
  rescue LoadError
    # bootstrap_form henüz yüklenmediyse, yardımcı metodu aşağıda uyarı mesajıyla sağlar.
  end

  if defined?(BootstrapForm::ActionViewExtensions::FormHelper)
    include BootstrapForm::ActionViewExtensions::FormHelper
  else
    def bootstrap_form_with(**options, &block)
      Rails.logger&.warn("[bootstrap_form] Gem yüklü değil, form_with ile devam ediliyor.") if defined?(Rails)
      form_with(**options, &block)
    end
  end

  # Ensure we use Phlex's raw (ActionView also defines raw via included helpers).
  def raw(content)
    Phlex::SGML.instance_method(:raw).bind_call(self, content)
  end
end
