module Api
  module V1
    class AuthenticationController < ApplicationController
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
