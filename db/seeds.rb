# SEGURANÇA: Bloqueio preventivo
if Rails.env.production? && ENV["ALLOW_SEED"] != "true"
  puts "ERRO: Seeds bloqueados em produção! Defina ALLOW_SEED=true para liberar."
  exit
end

seed_mode = ENV["SEED_MODE"] || "default"
puts "--- Iniciando Seeds [Modo: #{seed_mode.upcase}] ---"

# HELPERS
def create_user(email:, name:, password:, role_name:)
  # Busca ou cria a Role primeiro
  role = Role.find_or_create_by!(name: role_name)

  user = User.find_or_initialize_by(email: email)
  user.update!(
    name: name,
    password: password,
    password_confirmation: password,
    role: role # Atribuição direta da relação
  )
  user
end

def find_or_create_employee(user:, attrs:)
  profile = user.employee_profile || user.build_employee_profile
  profile.update!(attrs)
  profile
end

# LÓGICA DE MODOS
if seed_mode == "reset"
  puts "Limpando dados..."
  # Use destroy_all para garantir que callbacks de limpeza sejam disparados
  EmployeeProfile.destroy_all
  User.destroy_all
  Role.destroy_all
  puts "Dados limpos!"
end

# CRIAÇÃO DE DADOS MESTRES (Sempre roda se não for demo)
unless seed_mode == "demo"
  puts "Criando usuários de controle..."

  # Admin
  admin = create_user(email: 'admin@corepeople.com', name: 'Admin System', password: 'admin123456', role_name: Role::ADMIN)
  find_or_create_employee(user: admin, attrs: { position: "CEO", department: "Diretoria", salary: 25_000, status: "active" })

  # RH
  hr = create_user(email: 'hr@corepeople.com', name: 'Maria Silva', password: 'hr123456', role_name: Role::HR)
  find_or_create_employee(user: hr, attrs: { position: "Gerente de RH", department: "RH", salary: 15_000, status: "active" })
end

# DADOS DE TESTE / DEMO
if seed_mode == "demo" || seed_mode == "default"
  puts "Criando Administrador"

  # Admin
  admin = create_user(email: 'admin@corepeople.com', name: 'Admin System', password: 'admin123456', role_name: Role::ADMIN)
  puts "Populando funcionários de exemplo..."
  find_or_create_employee(user: admin, attrs: { position: "CEO", department: "Diretoria", salary: 25_000, status: "active" })

  employees = [
    { email: "dev1@core.com", name: "Dev Junior 1", dept: "TI" },
    { email: "mkt1@core.com", name: "Marketing 1", dept: "Marketing" }
  ]

  employees.each do |data|
    u = create_user(email: data[:email], name: data[:name], password: "123456", role_name: Role::EMPLOYEE)
    find_or_create_employee(user: u, attrs: { position: "Employee", department: data[:dept], salary: 3000, status: "active" })
  end
end

puts "--- Seeds concluídos! ---"
puts "Usuários: #{User.count} | Perfis: #{EmployeeProfile.count}"
