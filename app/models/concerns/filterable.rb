module Filterable
  extend ActiveSupport::Concern

  class_methods do
    # Busca por nome ou CPF
    def search(query)
      return all if query.blank?

      # Remove máscara do CPF para buscar
      clean_query = query.gsub(/\D/, "")

      left_joins(:user).where(
        "users.name ILIKE :term OR employee_profiles.cpf LIKE :cpf",
        term: "%#{query}%",
        cpf: "%#{clean_query}%"
      )
    end

    # Filtra por status
    def filter_by_status(status)
      return all if status.blank?

      where(status: status)
    end

    # Filtra por departamento
    def filter_by_department(department)
      return all if department.blank?

      where("LOWER(department) = ?", department.downcase)
    end

    # Filtra por cargo
    def filter_by_position(position)
      return all if position.blank?

      where("LOWER(position) = ?", position.downcase)
    end

    def sort_by_column(column, direction = "asc")
      # Colunas permitidas para ordenação (segurança)
      allowed_columns = {
        "name" => "users.name",
        "position" => "employee_profiles.position",
        "department" => "employee_profiles.department",
        "hire_date" => "employee_profiles.hire_date",
        "salary" => "employee_profiles.salary",
        "status" => "employee_profiles.status",
        "created_at" => "employee_profiles.created_at"
      }

      # Defaults seguros
      direction = %w[asc desc].include?(direction) ? direction : "asc"
      column_sql = allowed_columns[column.to_s] || "employee_profiles.id"

      relation = self
      relation = relation.left_joins(:user) if column == "name"

      relation.order("#{column_sql} #{direction}")
    end
  end
end
