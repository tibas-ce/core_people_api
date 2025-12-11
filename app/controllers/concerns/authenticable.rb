module Authenticable
  extend ActiveSupport::Concern

  included do
    # Disponibiliza o current_user para controllers que incluírem o concern
    attr_reader :current_user

    # Carrega o usuário antes de cada ação
    before_action :set_current_user
  end

  # Exige que o usuário esteja autenticado
  def authenticate_user!
    unless current_user
      render json: { error: "Token inválido ou expirado" },
             status: :unauthorized
    end
  end

  private

  # Tenta identificar o usuário pelo token JWT
  def set_current_user
    token = extract_token_from_header
    return unless token

    begin
      decoded = JsonWebToken.decode(token)

      # O ID do usuário pode vir com chave símbolo (:user_id) ou string ("user_id")
      user_id = decoded[:user_id] || decoded["user_id"]
      @current_user = User.find_by(id: user_id)
    rescue StandardError => e
      # Se o token for inválido, estiver expirado ou der qualquer erro, evitamos erro 500 e apenas deixamos current_user como nil
      Rails.logger.warn("Erro ao decodificar JWT: #{e.message}")
      @current_user = nil
    end
  end

  # Extrai o token enviado no header Authorization: Bearer <token>
  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")

    header.split(" ").last
  end
end
