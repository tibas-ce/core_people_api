module Api
  module V1
    class AuthenticationController < ApplicationController
      # Executa a autenticação somente antes do endpoint /me
      before_action :authenticate_user!, only: [ :me ]

      # POST /api/v1/signup
      # Cria um novo usuário e retorna um JWT junto com seus dados
      def signup
        # Inicializa o usuário com os parâmetros permitidos
        @user = User.new(signup_params)

        if @user.save
          # Gera token JWT passando o ID do usuário
          token = JsonWebToken.encode(user_id: @user.id)
          # Retorna token e informações básicas do usuário
          render json: {
            token: token,
            user: user_response(@user)
          }, status: :created
        else
          # Caso de erro de validação, retorna mensagens do modelo
          render json: {
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def login
        # Validar parâmetros obrigatórios
        unless params[:email].present? && params[:password].present?
          return render json: { error: "Email e senha são obrigatórios" },
                        status: :bad_request
        end

        # Buscar usuário de forma case-insensitive
        @user = User.find_by("LOWER(email) = ?", params[:email].downcase)

        # Verifica a senha
        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: @user.id)

          render json: {
            token: token,
            user: user_response(@user)
          }, status: :ok
        else
          render json: {
            error: "Email ou senha inválidos"
          }, status: :unauthorized
        end
      end

      # Retorna os dados do usuário que está logado
      def me
        render json: {
          user: user_response(current_user)
        }, status: :ok
      end

      private
      # Strong params: garante que apenas atributos permitidos sejam enviados
      def signup_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      # Formata a resposta que será enviada ao front-end
      def user_response(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
