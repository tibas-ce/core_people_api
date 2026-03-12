class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :email, :created_at

  field :role_name

  # Campos sensíveis de autenticação (password_digest, tokens, etc.) nunca devem ser expostos na API.
end
