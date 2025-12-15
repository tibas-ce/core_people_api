FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    name { Faker::Name.name }
    password { 'senha123' }
    password_confirmation { 'senha123' }

    # O role padrão é criado no callback do model User

    # Traits pra criar users com roles específicas
    trait :admin do
      after(:create) do |user|
        user.role.update!(name: Role::ADMIN)
      end
    end

    trait :hr do
      after(:create) do |user|
        user.role.update!(name: Role::HR)
      end
    end

    trait :manager do
      after(:create) do |user|
        user.role.update!(name: Role::MANAGER)
      end
    end
  end
end
