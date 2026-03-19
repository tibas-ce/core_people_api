module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_employee, only: [ :show, :update, :destroy ]

      # GET /employees
      def index
        authorize EmployeeProfile

        # Aplica policy_scope (Pundit) para filtrar registros conforme o papel do usuário
        # Includes evita N+1 queries ao carregar o user associado
        @employees = policy_scope(EmployeeProfile).includes(:user)

        render json: {
          employees: EmployeeProfileBlueprint.render_as_hash(@employees, view: :minimal)
        }
      end

      # GET /employees/:id
      def show
        authorize @employee

        # Define dinamicamente a view com base na permissão
        # Usuários autorizados veem dados sensíveis (:admin), outros veem versão limitada (:detail)
        view = policy(@employee).show_sensitive_data? ? :admin : :detail

        render_employee(@employee, view: view)
      end

      # GET /employees/me
      def me
        # Recupera o perfil do usuário autenticado
        @employee = current_user.employee_profile

        # Retorna erro se não existir perfil associado
        if @employee.nil?
          return render json: {
            error: "Perfil de funcionário não encontrado"
          }, status: :not_found
        end

        # Usuário sempre pode ver seus próprios dados completos
        render_employee(@employee, view: :admin)
      end

      # POST /employees
      def create
        authorize EmployeeProfile

        # Inicializa novo perfil com parâmetros permitidos
        @employee = EmployeeProfile.new(employee_params)

        if @employee.save
          # Atualiza nome no User, se enviado
          # Mantém separação de responsabilidades (User vs EmployeeProfile)
          if user_params[:name].present? && @employee.user.present?
            @employee.user.update(user_params)
          end
          render_employee(
            @employee,
            view: :admin,
            message: "Funcionário criado com sucesso",
            status: :created
            )
        else
          render json: {
            errors: @employee.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PUT /employees/:id
      def update
        authorize @employee

        # Define quais parâmetros podem ser atualizados
        # Admin/RH podem alterar tudo, outros apenas campos básicos
        params_to_use = can_update_sensitive_fields? ? employee_params : limited_employee_params

        if @employee.update(params_to_use)
          # Atualiza nome no User, se enviado
          if user_params[:name].present? && @employee.user.present?
            @employee.user.update(user_params)
          end

          # Define view conforme permissão
          view = policy(@employee).show_sensitive_data? ? :admin : :detail

          render_employee(
            @employee,
            view: view,
            message: "Perfil atualizado com sucesso",
            status: :ok
            )
        else
          render json: {
            errors: @employee.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /employees/:id
      def destroy
        authorize @employee

        # Soft delete: marca como inativo ao invés de remover do banco
        @employee.update(status: :inactive)

        render json: {
          message: "Funcionário desativado com sucesso"
        }
      end

      private

      # Busca funcionário pelo ID
      def set_employee
        @employee = EmployeeProfile.find(params[:id])
      end

      # Tratamento de erro para registro não encontrado
      def record_not_found
        render json: { error: "Funcionário não encontrado" }, status: :not_found
      end

      # Parâmetros permitidos para EmployeeProfile
      # Não inclui :name pois pertence ao User
      def employee_params
        params.require(:employee).permit(
          :user_id,
          :cpf,
          :birth_date,
          :phone,
          :address,
          :position,
          :department,
          :salary,
          :hire_date,
          :termination_date,
          :status
        )
      end

      # Parâmetros permitidos para User
      def user_params
        params.require(:employee).permit(:name)
      end

      # Parâmetros limitados para usuários sem permissão sensível
      def limited_employee_params
        params.require(:employee).permit(
          :phone,
          :address
        )
      end

      # Define quem pode atualizar dados sensíveis
      def can_update_sensitive_fields?
        current_user.admin? || current_user.hr?
      end

      # Método helper para padronizar resposta de um funcionário
      def render_employee(employee, view:, message: nil, status: :ok)
        response = {
          employee: EmployeeProfileBlueprint.render_as_json(employee, view: view)
        }

        # Adiciona mensagem opcional
        response[:message] = message if message

        render json: response, status: status
      end
    end
  end
end
