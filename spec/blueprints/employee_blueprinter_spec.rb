require "rails_helper"

RSpec.describe EmployeeBlueprint do
  let(:user) { create(:user, name: "João Silva Santos", email: "joao@example.com") }
  let(:employee) { create(:employee_profile,
    user: user,
    cpf: "12345678909",
    birth_date: 30.years.ago.to_date,
    phone: "85987654325",
    position: "Desenvolvedor",
    department: "TI",
    salary: 8000.00,
    hire_date: 2.years.ago.to_date,
    status: 0
  ) }

  describe "visualização mínima" do
    subject { JSON.parse(EmployeeBlueprint.render(employee, view: :minimal)) }

    it "inclui apenas campos básicos" do
      expect(subject["position"]).to eq("Desenvolvedor")
      expect(subject["department"]).to eq("TI")
      expect(subject["status"]).to eq("active")
    end

    it "não inclui dados sensíveis" do
      expect(subject).not_to have_key("salary")
      expect(subject).not_to have_key("cpf")
    end

    it "não inclui dados do usuário" do
      expect(subject).not_to have_key("user")
    end
  end

  describe "visualização padrão" do
    subject { JSON.parse(EmployeeBlueprint.render(employee)) }

    it "inclui todos os campos não sensíveis" do
      expect(subject["user"]["id"]).to eq(user.id)
      expect(subject["user"]["name"]).to eq("João Silva Santos")
      expect(subject["first_name"]).to eq("João")
      expect(subject["last_name"]).to eq("Silva Santos")
      expect(subject["position"]).to eq("Desenvolvedor")
      expect(subject["department"]).to eq("TI")
      expect(subject["status"]).to eq("active")
      expect(subject["hire_date"]).to be_present
    end

    it "inclui CPF formatado (mascarado)" do
      expect(subject["cpf"]).to eq("123.456.789-09")
    end

    it "inclui telefone formatado" do
      expect(subject["phone"]).to eq("(85)98765-4325")
    end

    it "inclui idade" do
      expect(subject["age"]).to eq(30)
    end

    it "inclui informações básicas de user" do
      expect(subject["user"]).to be_present
      expect(subject["user"]["id"]).to eq(user.id)
      expect(subject["user"]["name"]).to eq("João Silva Santos")
      expect(subject["user"]["email"]).to eq("joao@example.com")
    end

    it "não inclui salário" do
      expect(subject).not_to have_key("salary")
    end
  end

  describe "visualização de admin" do
    subject { JSON.parse(EmployeeBlueprint.render(employee, view: :admin)) }

    it "inclui todos os campos da visualização padrão" do
      expect(subject["id"]).to eq(employee.id)
      expect(subject["user"]["name"]).to eq("João Silva Santos")
      expect(subject["cpf"]).to eq("123.456.789-09")
    end

    it "inclui dados salariais sensíveis" do
      expect(subject["salary"]).to eq(8000.0)
    end

    it "inclui a data de término, se presente" do
      employee.update(termination_date: 1.month.ago.to_date)
      result = JSON.parse(EmployeeBlueprint.render(employee, view: :admin))
      expect(result["termination_date"]).to be_present
    end
  end

  describe "renderizando coleções" do
    let!(:employees) { create_list(:employee_profile, 3) }
    
    it "renderiza uma array de employees" do
      result = JSON.parse(EmployeeBlueprint.render(employees, view: :minimal))
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(3)
      expect(result.first).to have_key("position")
    end
  end

  describe "edge cases" do
    it "gerencia employee sem data de nascimento" do
      employee.update(birth_date: nil)
      result = JSON.parse(EmployeeBlueprint.render(employee))
      
      expect(result["age"]).to be_nil
    end

    it "gerencia employee sem telefone" do
      employee.update(phone: nil)
      result = JSON.parse(EmployeeBlueprint.render(employee))
      
      expect(result["phone"]).to be_nil
    end

    it "gerencia employee sem salário" do
      employee.update(salary: nil)
      result = JSON.parse(EmployeeBlueprint.render(employee, view: :admin))
      
      expect(result["salary"]).to be_nil
    end
  end
end