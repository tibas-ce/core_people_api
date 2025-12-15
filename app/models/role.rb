class Role < ApplicationRecord
  # Associações
  belongs_to :user

  # Constantes
  ADMIN = "admin"
  HR = "hr"
  MANAGER = "manager"
  EMPLOYEE = "employee"

  VALID_ROLES = [ ADMIN, HR, MANAGER, EMPLOYEE ].freeze

  # Validações
  validates :name, presence: true, inclusion: { in: VALID_ROLES }
  validates :user_id, uniqueness: { message: "já possui um role atribuído" }

  # Escopos
  scope :admins, -> { where(name: ADMIN) }
  scope :hrs, -> { where(name: HR) }
  scope :managers, -> { where(name: MANAGER) }
  scope :employees, -> { where(name: EMPLOYEE) }

  # Métodos de instância
  def admin?
    name == ADMIN
  end

  def hr?
    name == HR
  end

  def manager?
    name == MANAGER
  end

  def employee?
    name == EMPLOYEE
  end
end
