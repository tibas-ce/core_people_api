require "rails_helper"

RSpec.describe EmployeeProfilesQuery do
  let!(:employee1) { create(:employee_profile, department: "TI", position: "dev") }
  let!(:employee2) { create(:employee_profile, department: "RH") }
  let!(:employee3) { create(:employee_profile, department: "TI", status: "inactive", position: "dev") }

  let(:base_scope) { EmployeeProfile.all }

  describe "#call" do
    it "retorna todos os funcionários por padrão" do
      result = described_class.new(base_scope, {}).call

      expect(result).to include(employee1, employee2, employee3)
    end

    it "incluir associação user para evitar N+1" do
      result = described_class.new(base_scope, {}).call

      expect(result.to_sql).to include("JOIN")
    end
  end

  describe "#filters" do
    it "filtra por departamento" do
      params = { department: "TI" }

      result = described_class.new(base_scope, params).call

      expect(result).to include(employee1, employee3)
      expect(result).not_to include(employee2)
    end

    it "filtra por status" do
      params = { status: "active" }

      result = described_class.new(base_scope, params).call

      expect(result).to include(employee1, employee2)
      expect(result).not_to include(employee3)
    end

    it "filtra por posição" do
      params = { position: "dev" }

      result = described_class.new(base_scope, params).call

      expect(result).to include(employee1, employee3)
      expect(result).not_to include(employee2)
    end
  end

  describe "#sorting" do
    it "ordena por created_at desc por padrão" do
      older = create(:employee_profile, created_at: 2.days.ago)
      newer = create(:employee_profile, created_at: Time.current)

      result = described_class.new(base_scope, {}).call

      expect(result.first).to eq(newer)
    end
  end
end
