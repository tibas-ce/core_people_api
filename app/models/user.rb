class User < ApplicationRecord
  # Autenticação
  has_secure_password

  # Associações
  has_one :role, dependent: :destroy

  # Callsbacks
  before_save :normalize_email
  after_create :assign_default_role

  # Validações
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: "Deve ser um email válido"
            }

  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 100 }

  validates :password,
            presence: true,
            length: { minimum: 6 },
            if: :password_required?

  # Métodos de Role
  delegate :admin?, :hr?, :manager?, :employee?, to: :role, allow_nil: true

  def role_name
    role&.name
  end

  private

  # Normaliza email antes de salvar
  def normalize_email
    self.email = email.to_s.downcase.strip
  end

  # Exige senha apenas quando necessário
  def password_required?
    password_digest.blank? || password.present?
  end

  # Garante que todo usuário tenha um role
  def assign_default_role
    create_role(name: Role::EMPLOYEE) unless role
  end
end
