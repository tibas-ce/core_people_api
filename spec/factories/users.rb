FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    name { Faker::Name.name }
    password { 'senha123' }
    password_confirmation { 'senha123'}
  end
end
