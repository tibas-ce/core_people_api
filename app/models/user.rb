class User < ApplicationRecord
  has_secure_password

  # Normalizações
  before_save :normalize_email

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'Deve ser um email válido'
            }

  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 100 }

  validates :password,
            presence: true,
            length: { minimum: 6 },
            if: :password_required?

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end

  def password_required?
    password_digest.blank? || password.present?
  end
end
