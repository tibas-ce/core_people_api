# Segurança básica
if Rails.env.production? && ENV["ALLOW_SEED"] != "true"
  puts "Seeds bloqueados em produção!"
  exit
end

# Setup FactoryBot
require 'factory_bot_rails'
include FactoryBot::Syntax::Methods

seed_mode = ENV["SEED_MODE"] || "default"

puts "Modo de seed: #{seed_mode}"

# HELPERS
def create_user_with_profile(email:, name:, password:, role:, profile_attrs: {})
  user = User.find_or_create_by!(email: email) do |u|
    u.name = name
    u.password = password
    u.password_confirmation = password
  end

  user.role.update!(name: role)

  unless user.employee_profile
    create(:employee_profile, { user: user }.merge(profile_attrs))
  end

  puts "Criado: #{email} (#{role})"
  user
end

def create_employees(count, *traits, **attrs)
  count.times do
    create(:employee_profile, *traits, **attrs)
  end
end

if seed_mode == "demo"
  puts "Rodando seed em modo DEMO..."

  create_user_with_profile(
    email: "admin@corepeople.com",
    name: "Admin System",
    password: "admin123456",
    role: Role::ADMIN
  )

  create_employees(2, :junior, department: "Tecnologia da Informação")
  create_employees(1, :senior, department: "Tecnologia da Informação")
  create_employees(1, department: "Marketing")

  create(:employee_profile, :inactive)

  puts "CREDENCIAIS DE ACESSO:"
  puts ""
  puts "ADMIN:"
  puts "  Email: admin@corepeople.com"
  puts "  Senha: admin123456"
  puts ""
  puts "Demo pronto!"
  return
elsif seed_mode == "reset"
  # Limpeza
  puts "Limpando dados antigos..."
  EmployeeProfile.destroy_all
  Role.destroy_all
  User.destroy_all
  puts "Dados limpos!"
end

puts "Iniciando seeds..."
puts ""

# USUÁRIOS FIXOS (CONTROLE)
puts "Criando usuários principais..."

admin = create_user_with_profile(
  email: 'admin@corepeople.com',
  name: 'Admin System',
  password: 'admin123456',
  role: Role::ADMIN,
  profile_attrs: {
    position: 'CEO',
    department: 'Diretoria',
    salary: 25_000,
    hire_date: 10.years.ago
  }
)

hr = create_user_with_profile(
  email: 'hr@corepeople.com',
  name: 'Maria Santos Silva',
  password: 'hr123456',
  role: Role::HR,
  profile_attrs: {
    position: 'Gerente de RH',
    department: 'Recursos Humanos',
    salary: 15_000,
    hire_date: 5.years.ago
  }
)

manager = create_user_with_profile(
  email: 'manager@corepeople.com',
  name: 'Carlos Eduardo Souza',
  password: 'manager123456',
  role: Role::MANAGER,
  profile_attrs: {
    position: 'Gerente de TI',
    department: 'Tecnologia da Informação',
    salary: 18_000,
    hire_date: 8.years.ago
  }
)

puts ""

# FUNCIONÁRIOS (ESCALÁVEL)

puts "Criando funcionários de TI..."
create_employees(3, :junior, department: 'Tecnologia da Informação')
create_employees(2, :senior, department: 'Tecnologia da Informação')
create_employees(1, :manager, department: 'Tecnologia da Informação')

puts "Criando funcionários de Marketing..."
create_employees(3, department: 'Marketing')

puts "Criando funcionários de Financeiro..."
create_employees(2, department: 'Financeiro')

puts "Criando funcionário inativo..."
create(:employee_profile, :inactive, department: 'Comercial')

puts ""

# ESTATÍSTICAS

puts "=" * 60
puts "Seeds concluídos com sucesso!"
puts "=" * 60
puts ""

puts "ESTATÍSTICAS:"
puts " - Total de usuários: #{User.count}"
puts " - Total de funcionários: #{EmployeeProfile.count}"
puts " - Total de roles: #{Role.count}"
puts ""

puts "CREDENCIAIS DE ACESSO:"
puts ""
puts "ADMIN:"
puts "  Email: admin@corepeople.com"
puts "  Senha: admin123456"
puts ""
puts "HR:"
puts "  Email: hr@corepeople.com"
puts "  Senha: hr123456"
puts ""
puts "MANAGER:"
puts "  Email: manager@corepeople.com"
puts "  Senha: manager123456"
puts ""

puts ""
puts "Modo utilizado: #{seed_mode.upcase}"

puts "API pronta para testes!"
puts "=" * 60
