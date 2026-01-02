class RolePolicy < ApplicationPolicy
  # um role pode ser visualizado por:
  # - administradores e RH (acesso global)
  # - o próprio usuário dono do role
  def show?
    admin_or_hr? || record.user_id == user.id
  end

  # alterar o role de um usuário impacta permissões do sistema, por isso essa ação é restrita apenas a administradores
  def update?
    user.admin?
  end

  # a listagem de roles é usada para visão geral do sistema, disponível apenas para administradores e RH
  def index?
    admin_or_hr?
  end

  private

  def admin_or_hr?
    user.admin? || user.hr?
  end

  class Scope < ApplicationPolicy::Scope
    # define quais registros o usuário pode enxergar em consultas
    # - admin e RH: acesso a todos os roles
    # - demais usuários: apenas o próprio role
    def resolve
      return scope.all if user.admin? || user.hr?

      scope.where(user_id: user.id)
    end
  end
end
