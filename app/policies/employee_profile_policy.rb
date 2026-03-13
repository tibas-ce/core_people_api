class EmployeeProfilePolicy < ApplicationPolicy
  def index?
    # apenas papéis administrativos podem listar perfis
    # funcionários comuns não devem navegar por outros usuários
    user.admin? || user.hr? || user.manager?
  end

  def show?
    # admin e HR podem acessar qualquer perfil
    # usuários comuns podem acessar apenas o próprio perfil
    user.admin? || user.hr? || own_profile?
  end

  def create?
    # apenas admin e hr podem criar usuários
    user.admin? || user.hr?
  end

  def update?
    # admin e hr podem atualizar qualquer um
    # qualquer um pode atualizar seu próprio perfil
    user.admin? || user.hr? || own_profile?
  end

  def destroy?
    # apenas admin e hr podem desativar funcionários
    user.admin? || user.hr?
  end

  def show_sensitive_data?
    # controla acesso a dados sensíveis (ex: salário, CPF)
    # usado para decidir se o serializer pode expor campos restritos
    user.admin? || user.hr? || own_profile?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.hr?
        # admin e hr veem todos
        scope.all
      elsif user.manager?
        # manager vê apenas seu próprio perfil
        # OBS: adicionar membros da equipe quando implementar departamentos
        scope.where(user_id: user.id)
      else
        # employee vê apenas seu próprio perfil
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def own_profile?
    record.user_id == user.id
  end
end
