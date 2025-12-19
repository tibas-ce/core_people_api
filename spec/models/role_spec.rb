require "rails_helper"

RSpec.describe Role, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:name).in_array(Role::VALID_ROLES) }
  end

  describe "constants" do
    it "define roles válidos" do
      expect(Role::VALID_ROLES).to eq([ "admin", "hr", "manager", "employee" ])
      expect(Role::ADMIN).to eq("admin")
      expect(Role::HR).to eq("hr")
      expect(Role::MANAGER).to eq("manager")
      expect(Role::EMPLOYEE).to eq("employee")
    end
  end

  describe "scopes" do
    let!(:admin_user) { create(:user, :admin) }
    let!(:manager_user) { create(:user, :manager) }
    let!(:hr_user) { create(:user, :hr) }
    let!(:employee_user) { create(:user) }

    it "retorna apenas admins" do
      expect(Role.admins).to contain_exactly(admin_user.role)
    end

    it "retorna apenas managers" do
      expect(Role.managers).to contain_exactly(manager_user.role)
    end

    it "retorna apenas hrs" do
      expect(Role.hrs).to contain_exactly(hr_user.role)
    end

    it "retorna apenas employees" do
      expect(Role.employees).to include(employee_user.role)
    end
  end

  describe "métodos de instância" do
    let(:role) { build(:role, name: "admin") }

    it "checa se é a função de admin" do
      expect(role.admin?).to be true
      expect(role.hr?).to be false
    end

    it "checa se é a função de hr" do
      role.name = 'hr'
      expect(role.hr?).to be true
      expect(role.admin?).to be false
    end

    it "checa se é a função de manager" do
      role.name = 'manager'
      expect(role.manager?).to be true
    end

    it "checa se é a função de employee" do
      role.name = 'employee'
      expect(role.employee?).to be true
    end
  end
end
