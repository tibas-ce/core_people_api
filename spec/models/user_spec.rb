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
  end
end
