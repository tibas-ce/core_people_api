module Api
  module V1
    class RolesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user, only: [ :show, :update ]
      before_action :set_role, only: [ :show, :update ]

      # GET /api/v1/roles
      def index
        authorize Role

        roles = policy_scope(Role).includes(:user)

        render json: {
          roles: roles.map { |role| role_response(role) },
          summary: roles_summary(roles)
        }
      end

      # GET /api/v1/roles/:id
      def show
        authorize @role

        render json: {
          role: role_response(@role)
        }
      end

      # PATCH/PUT /api/v1/roles/:id
      def update
        authorize @role

        if @role.update(role_params)
          render json: {
            role: role_response(@role),
            message: "Role atualizado com sucesso"
          }
        else
          render json: {
            errors: @role.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      # Carrega o usuário alvo a partir do user_id da rota.
      # Retorna 404 caso o usuário não exista.
      def set_user
        @user = User.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Usuário não encontrado" }, status: :not_found
      end

      # O controller apenas carrega o registro.
      # As regras de acesso e permissão são responsabilidade exclusiva da policy.
      def set_role
        @role = @user.role
        unless @role
          render json: { error: "Usuário não possui role atribuído" }, status: :not_found
        end
      end

      def role_params
        params.require(:role).permit(:name)
      end

      # Formatação da resposta da API.
      # (Em projetos maiores, isso deveria ir para um Presenter ou Serializer.)
      def role_response(role)
        {
          id: role.id,
          name: role.name,
          user_id: role.user_id,
          user_name: role.user.name,
          user_email: role.user.email,
          created_at: role.created_at,
          updated_at: role.updated_at
        }
      end

      # O summary respeita o mesmo escopo autorizado da listagem.
      # Nunca deve usar Role.count diretamente para evitar vazamento de dados.
      def roles_summary(roles_scope)
        {
          total: roles_scope.count,
          admins: roles_scope.admins.count,
          hrs: roles_scope.hrs.count,
          managers: roles_scope.managers.count,
          employees: roles_scope.employees.count
        }
      end
    end
  end
end
