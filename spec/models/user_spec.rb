require "rails_helper"

RSpec.describe User, type: :model do
  
  describe "validations" do
    subject { build(:user) }

    context "com atributos válidos" do
      it "é válido" do
        user = User.new(
          email: "teste@exemplo.com",
          password: "senha123",
          name: "João Silva"
        )
        expect(user).to be_valid
      end
    end

    # Testes com a gem Shoulda Matchers que fornece “matchers” (testes prontos) para o RSpec, permitindo testar:
    # Validações; Associações; Delegações; Estruturas de database; Permissões (em alguns casos)
    context "validações de email" do
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should allow_value('user@example.com').for(:email) }
      it { should allow_value('USER@EXAMPLE.COM').for(:email) }
      it { should_not allow_value('invalid_email').for(:email) }

      it "normaliza o e-mail antes de salvar" do
        user = create(:user, email: 'TEST@EXAMPLE.COM')
        expect(user.reload.email).to eq('test@example.com')
      end
    end

    context "validações de nome" do
      it { should validate_presence_of(:name) }
      it { should validate_length_of(:name).is_at_least(2) }
      it { should validate_length_of(:name).is_at_most(100) }
    end

    context "validações de password" do
      it { should validate_presence_of(:password) }
      it { should validate_length_of(:password).is_at_least(6) }
  
      it "requer senha na criação" do
        user = User.new(email: 'test@example.com', name: 'Test User')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include(I18n.t("errors.messages.blank"))
      end
  
      it "não requer senha na atualização" do
        user = create(:user)
        user.name = 'Atualiza Nome'
        expect(user).to be_valid
      end

      it "criptografa o password" do
        user = create(:user, password: 'senha123')
        expect(user.password_digest).to be_present
        expect(user.password_digest).not_to eq("senha123")
      end
    end
  end

  describe "factory" do
    it "tem um factory válido" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "cria um usuário com factory" do
      user = create(:user)
      expect(user).to be_persisted
      expect(user.email).to be_present
      expect(user.name).to be_present
    end

    it "cria emails únicos" do
      user1 = create(:user)
      user2 = create(:user)
      expect(user1.email).not_to eq(user2.email)
    end
  end

  describe "authentication" do
    it "autentica com password correto" do
      user = create(:user, password: 'senha123')
      expect(user.authenticate('senha123')).to eq(user)
    end

    it "não se autentica com password errado" do
      user = create(:user, password: 'senha123')
      expect(user.authenticate('senha_errada')).to be_falsey
    end
  end
end
