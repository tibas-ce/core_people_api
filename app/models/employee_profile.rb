class EmployeeProfile < ApplicationRecord
  # Includes
  include Filterable

  # Associações
  belongs_to :user
  delegate :name, to: :user

  # Enums
  enum :status, {
    active: 0,
    inactive: 1,
    on_leave: 2,
    terminated: 3
  }

  # Validações básicas
  validates :hire_date, presence: true
  validates :position, presence: true
  validates :status, presence: true

  # Validação de CPF usando brazilian_docs
  validates :cpf, presence: true, uniqueness: { case_sensitive: false }
  validate :cpf_must_be_valid

  # Validações de data
  validate :hire_date_cannot_be_in_future
  validate :birth_date_cannot_be_in_future
  validate :employee_must_be_at_least_16_years_old

  # Validações de salário
  validates :salary, numericality: { greater_than: 0 }, allow_nil: true

  # Callbacks
  before_validation :normalize_cpf
  before_validation :normalize_phone

  # Métodos de instâcia
  def first_name
    user.name.split.first
  end

  def last_name
    user.name.split[1..].join(" ")
  end

  def age
    return nil unless birth_date

    today = Date.current
    age = today.year - birth_date.year
    age -= 1 if today < birth_date + age.years
    age
  end

  def formatted_cpf
    BrazilianDocs::CPF.format(cpf) if cpf.present?
  end

  def formatted_phone
    return nil unless phone.present?

    # Formato (85) 98765-4322
    phone.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
  end

  private

  def normalize_cpf
    self.cpf = cpf.gsub(/\D/, "") if cpf.present?
  end

  def normalize_phone
    self.phone = phone.gsub(/\D/, "") if phone.present?
  end

  def cpf_must_be_valid
    return if cpf.blank?

    unless BrazilianDocs::CPF.valid?(cpf)
      errors.add(:cpf, "não é válido")
    end
  end

  def hire_date_cannot_be_in_future
    return if hire_date.blank?

    if hire_date > Date.current
      errors.add(:hire_date, "não pode ser no futuro")
    end
  end

  def birth_date_cannot_be_in_future
    return if birth_date.blank?

    if birth_date > Date.current
      errors.add(:birth_date, "não pode ser no futuro")
    end
  end

  def employee_must_be_at_least_16_years_old
    return if birth_date.blank?

    if age && age < 16
      errors.add(:birth_date, "funcionário deve ter pelo menos 16 anos")
    end
  end
end
