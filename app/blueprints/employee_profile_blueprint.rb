class EmployeeProfileBlueprint < Blueprinter::Base
  identifier :id

  # View usada para listagens (index). Expõe apenas dados básicos para reduzir payload e evitar exposição de informações sensíveis.
  view :minimal do
    fields :position, :department, :status
  end

  # View: detail (detalhes padrão)
  view :detail do
    include_view :minimal
    fields :name, :hire_date, :address

    # Campos calculados
    field :first_name
    field :last_name
    field :age

    # CPF é armazenado apenas com números no banco e exposto formatado na API
    field :cpf do |employee|
      employee.formatted_cpf
    end

    # Telefone é armazenado apenas com dígitos e formatado na resposta da API
    field :phone do |employee|
      employee.formatted_phone
    end

    # Timestamps
    fields :created_at, :updated_at

    # Associação: User
    association :user, blueprint: UserBlueprint
  end


  # View administrativa inclui campos sensíveis utilizados pelo RH ou usuários com permissões elevadas.
  view :admin do
    # Incluir tudo do default
    include_view :detail

    # + Campos sensíveis
    field :salary do |employee|
      employee.salary&.to_f
    end
    field :termination_date
  end
end
