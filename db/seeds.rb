# SEGURANÇA: Bloqueio preventivo
if Rails.env.production? && ENV["ALLOW_SEED"] != "true"
  puts "ERRO: Seeds bloqueados em produção! Defina ALLOW_SEED=true para liberar."
  exit
end

seed_mode = ENV["SEED_MODE"] || "default"
puts "--- Iniciando Seeds [Modo: #{seed_mode.upcase}] ---"

# HELPERS
def create_user_with_profile(email:, name:, password:, role_name:, profile_attrs: {})
  role = Role.find_or_create_by!(name: role_name)

  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    name: name,
    password: password,
    password_confirmation: password,
    role: role
  )
  user.save!

  profile = user.employee_profile || user.build_employee_profile

  # Atributos padrão para evitar erros de validação (CPF, Hire Date, etc)
  profile.assign_attributes({
    hire_date: Date.today,
    position: "Colaborador",
    department: "Geral",
    salary: 2000,
    status: "active"
  }.merge(profile_attrs))

  profile.save!
  puts "Concluído: #{email}"
  user
end

# LÓGICA DE EXECUÇÃO
if seed_mode == "reset"
  puts "Limpando banco..."
  EmployeeProfile.destroy_all
  User.destroy_all
  Role.destroy_all
end

if [ "demo", "default" ].include?(seed_mode)
  # ADMIN - CPF Válido: 341.382.470-33
  create_user_with_profile(
    email: "admin@corepeople.com",
    name: "Admin System",
    password: "admin123456",
    role_name: Role::ADMIN,
    profile_attrs: {
      position: "CEO",
      department: "Diretoria",
      cpf: "34138247033",
      hire_date: Date.parse("2020-01-01")
    }
  )

  # HR - CPF Válido: 846.516.330-81
  create_user_with_profile(
    email: "hr@corepeople.com",
    name: "Maria Santos",
    password: "hr123456",
    role_name: Role::HR,
    profile_attrs: {
      position: "Gerente de RH",
      department: "RH",
      cpf: "84651633081"
    }
  )

  # DEV - CPF Válido: 080.354.490-50
  create_user_with_profile(
    email: "dev.jr@core.com",
    name: "Lucas Dev",
    password: "password123",
    role_name: Role::EMPLOYEE,
    profile_attrs: {
      position: "Dev Junior",
      department: "TI",
      cpf: "08035449050"
    }
  )
end

puts "--- Seeds finalizados! ---"
