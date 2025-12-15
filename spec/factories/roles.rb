FactoryBot.define do
  factory :role do
    # Cada role pertence a um usuário
    association :user

    # Role padrão
    name { Role::EMPLOYEE }

    trait :admin do
      name { Role::ADMIN }
    end

    trait :hr do
      name { Role::HR }
    end

    trait :manager do
      name { Role::MANAGER }
    end
  end
end
