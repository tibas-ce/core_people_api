module Api
  module V1
    class RolesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_role, only: %i[show update]

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

      # O controller busca o registro sem aplicar regra de permissão.
      # Quem decide se o usuário pode acessar é exclusivamente a policy.
      def set_role
        @role = Role.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Role não encontrado" }, status: :not_found
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
      # Nunca deve usar Role.count diretamente.
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
