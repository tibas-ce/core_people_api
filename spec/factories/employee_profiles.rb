FactoryBot.define do
  # Gera CPF válido randomicamente
  sequence(:cpf) do |n|
    loop do
      cpf = rand(10000000000..99999999999).to_s
      break cpf if BrazilianDocs::CPF.valid?(cpf)
    end
  end

  factory :employee_profile do
    association :user

    # Gerar CPF válido
    cpf { generate(:cpf) }

    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
    phone { Faker::Number.number(digits: 11) } # Formato: 85987654321
    address { Faker::Address.full_address }

    position { [ 'Desenvolvedor', 'Analista', 'Gerente', 'Designer', 'Coordenador' ].sample }
    department { [ 'TI', 'RH', 'Vendas', 'Marketing', 'Financeiro' ].sample }
    salary { Faker::Number.between(from: 3000, to: 15000) }
    hire_date { Faker::Date.between(from: 5.years.ago, to: Date.today) }

    status { "active" }

    # Traits
    trait :inactive do
      status { "inactive" }
    end

    trait :on_leave do
      status { "on_leave" }
    end

    trait :terminated do
      status { "terminated" }
      termination_date { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    end

    trait :with_high_salary do
      salary { 15000.00 }
    end

    trait :junior do
      position { 'Desenvolvedor Júnior' }
      salary { 3500.00 }
    end

    trait :senior do
      position { 'Desenvolvedor Sênior' }
      salary { 12000.00 }
    end

    trait :manager do
      position { 'Gerente' }
      department { 'TI' }
      salary { 15000.00 }
    end
  end
end
