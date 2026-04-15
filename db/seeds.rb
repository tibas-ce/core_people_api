# SEGURANÇA: Bloqueio preventivo
if Rails.env.production? && ENV["ALLOW_SEED"] != "true"
  puts "ERRO: Seeds bloqueados em produção!"
  exit
end

seed_mode = ENV["SEED_MODE"] || "default"
puts "--- Iniciando Seeds [Modo: #{seed_mode.upcase}] ---"

# HELPERS
def create_user_with_profile(email:, name:, password:, role_name:, profile_attrs: {})
  # 1. Cria o usuário primeiro
  # O callback 'after_create' vai criar automaticamente o Role::EMPLOYEE
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    name: name,
    password: password,
    password_confirmation: password
  )
  user.save!

  # 2. Atualiza o Role se for diferente de EMPLOYEE
  # Como o User já criou um Role no 'after_create', nós apenas o atualizamos
  current_role = user.role # Já existe devido ao callback
  if current_role.name != role_name
    current_role.update!(name: role_name)
  end

  # 3. Cria o Perfil
  # Agora o user já tem ID e o Role já está garantido
  profile = user.employee_profile || user.build_employee_profile
  profile.assign_attributes({
    hire_date: Date.today,
    position: "Colaborador",
    department: "Geral",
    salary: 2000,
    status: "active",
    cpf: "12345678909"
  }.merge(profile_attrs))

  profile.save!

  puts "Sucesso: #{email} (#{user.role_name})"
  user
end

if [ "demo", "default" ].include?(seed_mode)
  puts "Limpando banco..."
  EmployeeProfile.destroy_all
  User.destroy_all
  Role.destroy_all
  puts "Limpeza concluída!"
  puts "Criando dados modo DEMO..."

  # ADMIN
  create_user_with_profile(
    email: "admin@corepeople.com",
    name: "Admin System",
    password: "admin123456",
    role_name: Role::ADMIN,
    profile_attrs: {
      cpf: "12345678909",
      position: "CEO",
      department: "Diretoria"
    }
  )

  # RH
  create_user_with_profile(
    email: "rh@corepeople.com",
    name: "RH System",
    password: "rh123456",
    role_name: Role::HR,
    profile_attrs: {
      cpf: "01710530952",
      position: "Gerente de RH",
      department: "RH"
    }
  )

  # MANAGER
  create_user_with_profile(
    email: "manager@corepeople.com",
    name: "Gerente System",
    password: "manager123456",
    role_name: Role::MANAGER,
    profile_attrs: {
      cpf: "40393216853",
      position: "Gerente de TI",
      department: "TI"
    }
  )

  # Funcionários
  create_user_with_profile(
    email: "dev.um@corepeople.com",
    name: "Lucas Ferreira",
    password: "password123",
    role_name: Role::EMPLOYEE,
    profile_attrs: {
      cpf: "29896679380",
      position: "Dev Junior",
      department: "TI"
    }
  )

  create_user_with_profile(
    email: "mkt.dois@corepeople.com",
    name: "Ana Santos",
    password: "password123",
    role_name: Role::EMPLOYEE,
    profile_attrs: {
      cpf: "96813362593",
      position: "Analista",
      department: "Marketing"
    }
  )
end

puts "--- Seeds finalizados! ---"
