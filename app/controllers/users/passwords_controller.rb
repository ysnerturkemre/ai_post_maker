# Şifre sıfırlama/sıfırdan şifre belirleme akışı bir sonraki sürüme ertelendi.
# Bu controller şu an kapalı; ileride Devise recoverable akışı veya benzer bir çözümle tekrar açılacak.
# class Users::PasswordsController < Devise::PasswordsController
#   def new
#     self.resource = resource_class.new
#     render Devise::Passwords::ResetView.new(
#       resource: resource,
#       resource_name: resource_name,
#       devise_mapping: devise_mapping
#     )
#   end
#
#   # Direkt şifre değişimi: e-posta + yeni şifre al, kullanıcıyı güncelle ve giriş yap.
#   def create
#     self.resource = resource_class.find_by(email: reset_password_params[:email])
#
#     unless resource
#       self.resource = resource_class.new
#       resource.errors.add(:email, "bulunamadı")
#       return render_reset_view(status: :unprocessable_entity)
#     end
#
#     resource.password = reset_password_params[:password]
#     resource.password_confirmation = reset_password_params[:password_confirmation]
#
#     if resource.save
#       sign_in(resource_name, resource)
#       set_flash_message!(:notice, :updated) if respond_to?(:set_flash_message!)
#       redirect_to after_sign_in_path_for(resource), status: :see_other
#     else
#       render_reset_view(status: :unprocessable_entity)
#     end
#   end
#
#   private
#
#   def reset_password_params
#     params.require(resource_name).permit(:email, :password, :password_confirmation)
#   end
#
#   def render_reset_view(status: :ok)
#     render Devise::Passwords::ResetView.new(
#       resource: resource,
#       resource_name: resource_name,
#       devise_mapping: devise_mapping
#     ), status: status
#   end
# end
