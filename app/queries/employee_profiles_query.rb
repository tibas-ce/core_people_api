class EmployeeProfilesQuery
  def initialize(scope = EmployeeProfile.all, params = {})
    @scope = scope
    @params = params
  end

  def call
    # Começamos com o eager_load para que a tabela 'users' esteja disponível para filtros e sort
    employees = @scope.eager_load(:user)
    employees = apply_filters(employees)
    employees = apply_sorting(employees)
    employees
  end

  private

  def apply_filters(scope)
    scope = scope.search(@params[:search]) if @params[:search].present?

    if @params[:status].present? && EmployeeProfile.statuses.key?(@params[:status])
      scope = scope.filter_by_status(@params[:status])
    end

    if @params[:department].present?
      if EmployeeProfile.where("LOWER(department) = ?", @params[:department].downcase).exists?
        scope = scope.filter_by_department(@params[:department])
      end
    end

    if @params[:position].present?
      if EmployeeProfile.where("LOWER(position) = ?", @params[:position].downcase).exists?
        scope = scope.filter_by_position(@params[:position])
      end
    end

    scope
  end

  def apply_sorting(scope)
    # Se não houver sort, usamos o padrão.
    # Importante usar .reorder para limpar qualquer ordenação prévia.
    return scope.reorder(created_at: :desc) if @params[:sort].blank?

    column, direction = @params[:sort].split(":")

    # Garante que direction seja 'asc' ou 'desc'
    direction = %w[asc desc].include?(direction&.downcase) ? direction : "asc"

    # Se o sorting for por nome, precisamos referenciar a tabela users
    if column == "name"
      scope.reorder("users.name #{direction}")
    else
      # Se o seu model tiver o método sort_by_column, use-o, caso contrário use o order padrão do Rails
      scope.respond_to?(:sort_by_column) ? scope.sort_by_column(column, direction) : scope.reorder("#{column} #{direction}")
    end
  end
end
