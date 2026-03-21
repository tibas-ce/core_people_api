module Filterable
  extend ActiveSupport::Concern

  class_methods do
    # Realiza busca por nome (associado ao User) ou CPF (EmployeeProfile)
    # - Preserva o escopo atual (evita que joins afetem filtros anteriores)
    # - Usa subquery de IDs para manter isolamento do scope original
    # - Utiliza unscoped + left join para garantir acesso a users.name sem perder registros
    # - Suporta CPF com ou sem máscara
    # - Se a query não contiver dígitos, busca apenas por nome
    # - Retorna todos os registros se a query estiver vazia
    def search(query)
      return all if query.blank?

      # Remove máscara do CPF para buscar
      clean_query = query.gsub(/\D/, "")

      scoped_ids = all.select(:id)

      scope = unscoped
        .left_joins(:user)
        .where(employee_profiles: { id: scoped_ids })

      clean_query.present? ? scope.where(
        "users.name ILIKE :term OR employee_profiles.cpf LIKE :cpf",
        term: "%#{query}%",
        cpf: "%#{clean_query}%"
      ) : scope.where("users.name ILIKE :term", term: "%#{query}%")
    end

    # Filtra registros pelo status (ex: active, inactive)
    # Retorna todos se o parâmetro estiver vazio
    def filter_by_status(status)
      return all if status.blank?

      where(status: status)
    end

    # Filtra por departamento (case insensitive)
    # Normaliza o valor para evitar inconsistências de capitalização
    def filter_by_department(department)
      return all if department.blank?

      where("LOWER(department) = ?", department.downcase)
    end

    # Filtra por cargo/posição (case insensitive)
    def filter_by_position(position)
      return all if position.blank?

      where("LOWER(position) = ?", position.downcase)
    end

    # Ordena resultados por coluna e direção
    # - Usa whitelist para evitar SQL Injection
    # - Suporta ordenação por campo associado (users.name)
    # - Mantém encadeamento com scopes anteriores
    def sort_by_column(column, direction = "asc")
      # Mapeia colunas permitidas para seus respectivos campos no banco
      allowed_columns = {
        "name" => "users.name",
        "position" => "employee_profiles.position",
        "department" => "employee_profiles.department",
        "hire_date" => "employee_profiles.hire_date",
        "salary" => "employee_profiles.salary",
        "status" => "employee_profiles.status",
        "created_at" => "employee_profiles.created_at"
      }

      # Garante direção válida (segurança)
      direction = %w[asc desc].include?(direction) ? direction : "asc"

      # Define coluna segura ou fallback para id
      column_sql = allowed_columns[column.to_s] || "employee_profiles.id"

      # Matém encadeamento com scopes anteriores
      relation = self

      # Adiciona JOIN quando necessário para ordenar por campo associado
      relation = relation.left_joins(:user) if column == "name"

      relation.order("#{column_sql} #{direction}")
    end
  end
end
