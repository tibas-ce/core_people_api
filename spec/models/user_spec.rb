require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "é válido com atributos válidos" do
      user = User.new(
        email: "teste@exemplo.com",
        password: "senha123",
        name: "João Silva"
      )
      expect(user).to be_valid
    end

    # Testes com a gem Shoulda Matchers que fornece “matchers” (testes prontos) para o RSpec, permitindo testar:
    # Validações; Associações; Delegações; Estruturas de database; Permissões (em alguns casos)
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2) }
    it { should validate_length_of(:name).is_at_most(100) }

    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }

    it "requer senha na criação" do
      user = User.new(email: 'test@example.com', name: 'Test User')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("Não pode estar em branco")
    end

    it "não requer senha na atualização" do
      user = User.new(
        email: "teste@exemplo.com",
        password: "senha123",
        name: "João Silva"
      )
      user.name = 'Atualiza Nome'
      expect(user).to be_valid
    end
  end
end
