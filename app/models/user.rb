class User < ApplicationRecord
  has_secure_password

  # Normalizações
  before_save { self.email = email.downcase.strip }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: URI::Mailto::EMAIL_REGEXP,
              message: 'Deve ser um email válido'
            }
end
