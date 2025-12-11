class ApplicationController < ActionController::API
  # Inclui o módulo que cuida da autenticação via JWT (current_user, authenticate_user!, etc)
  include Authenticable

  # Inclui o Pundit para autorização (verificar o que o usuário pode ou não pode fazer)
  include Pundit::Authorization

  # Quando o Pundit levantar um erro de permissão, chamamos o método user_not_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Resposta padrão quando o usuário não tem permissão para acessar algo
  def user_not_authorized
    render json: {
      error: "Você não tem permissão para realizar esta ação"
    }, status: :forbidden
  end
end
