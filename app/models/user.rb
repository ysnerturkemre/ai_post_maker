class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         # :recoverable, # Şifre sıfırlama e-posta akışı sonraki sürümde açılacak.
         :rememberable, :validatable
end
