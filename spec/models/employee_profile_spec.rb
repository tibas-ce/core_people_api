require "rails_helper"

RSpec.describe EmployeeProfile, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user) }
  end

  describe "validations" do
    subject { build(:employee_profile) }

    # Obrigatórios
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:cpf) }
    it { should validate_presence_of(:hire_date) }
    it { should validate_presence_of(:position) }
    it { should validate_presence_of(:status) }

    # Unicidade
    it { should validate_uniqueness_of(:cpf).case_insensitive }

    context "validações de CPF com brazilian_docs" do
      it "rejeita CPF inválido" do
        profile = build(:employee_profile, cpf: '111.111.111-11')
        expect(profile).not_to be_valid
        expect(profile.errors[:cpf]).to include('não é válido')
      end

      it 'rejeita o CPF com formato inválido' do
        profile = build(:employee_profile, cpf: '123')
        expect(profile).not_to be_valid
        expect(profile.errors[:cpf]).to include('não é válido')
      end

      it "aceita CPF válido com máscara" do
        profile = build(:employee_profile, cpf: '123.456.789-09')
        expect(profile).to be_valid
      end

      it "aceita CPF válido sem máscara" do
        profile = build(:employee_profile, cpf: '12345678909')
        expect(profile).to be_valid
      end

      it "aceita CPF independentemente de maiúsculas e minúsculas (unicidade)." do
        create(:employee_profile, cpf: '123.456.789-09')
        duplicate = build(:employee_profile, cpf: '12345678909')

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:cpf]).to include('já está em uso')
      end
    end

    # Status
    it { should define_enum_for(:status).with_values(
      active: "active",
      inactive: "inactive",
      on_leave: "on_leave",
      terminated: "terminated"
    ) }

    context "validações de data" do
      it "valida se a data de contratação não está no futuro" do
        profile = build(:employee_profile, hire_date: 1.day.from_now)
        expect(profile).not_to be_valid
        expect(profile.errors[:hire_date]).to include('não pode ser no futuro')
      end

      it "valida se a data de nascimento não está no futuro" do
        profile = build(:employee_profile, birth_date: 1.day.from_now)
        expect(profile).not_to be_valid
        expect(profile.errors[:birth_date]).to include('não pode ser no futuro')
      end

      it "valida se o funcionário tem pelo menos 16 anos de idade" do
        profile = build(:employee_profile, birth_date: 15.years.ago)
        expect(profile).not_to be_valid
        expect(profile.errors[:birth_date]).to include('funcionário deve ter pelo menos 16 anos')
      end
    end

    context "validação de salário" do
      it "valida se o salário é positivo" do
        profile = build(:employee_profile, salary: -100)
        expect(profile).not_to be_valid
        expect(profile.errors[:salary]).to include('deve ser maior que 0')
      end

      it "aceita salário nulo (opcional)" do
        profile = build(:employee_profile, salary: nil)
        expect(profile).to be_valid
      end
    end
  end

  describe "callbacks" do
    it "normaliza o CPF antes de salvar (remove a máscara)" do
      profile = create(:employee_profile, cpf: '123.456.789-09')
      expect(profile.reload.cpf).to eq('12345678909')
    end

    it "normaliza o telefone antes de salvar (remove a máscara)" do
      profile = create(:employee_profile, phone: '(85) 98765-4321')
      expect(profile.reload.phone).to eq('85987654321')
    end
  end

  describe "scopes" do
    let!(:active_employee) { create(:employee_profile, status: :active) }
    let!(:inactive_employee) { create(:employee_profile, status: :inactive) }
    let!(:on_leave_employee) { create(:employee_profile, status: :on_leave) }

    it "filtra funcionários ativos" do
      expect(EmployeeProfile.active).to include(active_employee)
      expect(EmployeeProfile.active).not_to include(inactive_employee)
    end

    it "filtra funcionários inativos" do
      expect(EmployeeProfile.inactive).to include(inactive_employee)
      expect(EmployeeProfile.inactive).not_to include(active_employee)
    end

    it "filtra funcionários em licença" do
      expect(EmployeeProfile.on_leave).to include(on_leave_employee)
    end
  end

  describe "instance methods" do
    let(:profile) { build(:employee_profile, full_name: 'João Silva Santos') }
    describe "#first_name" do
      it "retorna primeiro nome" do
        expect(profile.first_name).to eq('João')
      end
    end
    describe "#last_name" do
      it 'retorna sobrenome' do
        expect(profile.last_name).to eq('Santos')
      end
    end

    describe "#active" do
      it "retorna true se status for active" do
        profile.status = :active
        expect(profile.active?).to be true
      end

      it "retorna false se for outros status" do
        profile.status = :inactive
        expect(profile.active?).to be false
      end
    end

    describe "#age" do
      it "calcula a idade corretamente" do
        profile.birth_date = 30.years.ago.to_date
        expect(profile.age).to eq(30)
      end

      it "retorna nulo se não houver data de nascimento" do
        profile.birth_date = nil
        expect(profile.age).to be_nil
      end
    end

    describe "#formatted_cpf" do
      it "Formata CPF com máscara" do
        profile.cpf = '12345678909'
        expect(profile.formatted_cpf).to eq('123.456.789-09')
      end
    end

    describe "#formatted_phone" do
      it "formata telefone com máscara" do
        profile.phone = '85987654321'
        expect(profile.formatted_phone).to eq('(85) 98765-4321')
      end
    end
  end
end
