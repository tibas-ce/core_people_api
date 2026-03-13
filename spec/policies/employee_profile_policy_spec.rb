require "rails_helper"

RSpec.describe EmployeeProfilePolicy do
  let(:admin) { create(:user, :admin) }
  let(:hr_user) { create(:user, :hr) }
  let(:manager) { create(:user, :manager) }
  let(:employee_user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:admin_profile) { create(:employee_profile, user: admin) }
  let(:hr_profile) { create(:employee_profile, user: hr_user) }
  let(:manager_profile) { create(:employee_profile, user: manager) }
  let(:employee_profile) { create(:employee_profile, user: employee_user) }
  let(:other_profile) { create(:employee_profile, user: other_user) }

  def policy(user, record)
    described_class.new(user, record)
  end

  describe "#index?" do
    it "concede acesso ao administrador" do
      expect(policy(admin, EmployeeProfile).index?).to be true
    end

    it "concede acesso ao RH" do
      expect(policy(hr_user, EmployeeProfile).index?).to be true
    end

    it "concede acesso ao gerente" do
      expect(policy(manager, EmployeeProfile).index?).to be true
    end

    it "nega acesso ao funcionário" do
      expect(policy(employee_user, EmployeeProfile).index?).to be false
    end
  end

  describe "#show?" do
    context "como administrador" do
      it "pode visualizar qualquer perfil" do
        expect(policy(admin, employee_profile).show?).to be true
        expect(policy(admin, other_profile).show?).to be true
      end

      it "pode visualizar o próprio perfil" do
        expect(policy(admin, admin_profile).show?).to be true
      end
    end

    context "como RH" do
      it "pode visualizar qualquer perfil" do
        expect(policy(hr_user, employee_profile).show?).to be true
        expect(policy(hr_user, other_profile).show?).to be true
      end

      it "pode visualizar o próprio perfil" do
        expect(policy(hr_user, hr_profile).show?).to be true
      end
    end

    context "como gerente" do
      it "pode visualizar o próprio perfil" do
        expect(policy(manager, manager_profile).show?).to be true
      end
      # OBS: implementar lógica de equipe depois
    end

    context "como funcionário" do
      it "pode visualizar o próprio perfil" do
        expect(policy(employee_user, employee_profile).show?).to be true
      end

      it "não pode visualizar outros perfis" do
        expect(policy(employee_user, other_profile).show?).to be false
      end
    end
  end

  describe "#create?" do
    it "concede acesso ao administrador" do
      expect(policy(admin, EmployeeProfile).create?).to be true
    end

    it "concede acesso ao RH" do
      expect(policy(hr_user, EmployeeProfile).create?).to be true
    end

    it "nega acesso ao gerente" do
      expect(policy(manager, EmployeeProfile).create?).to be false
    end

    it "nega acesso ao funcionário" do
      expect(policy(employee_user, EmployeeProfile).create?).to be false
    end
  end

  describe "#update?" do
    context "como administrador" do
      it "pode atualizar qualquer perfil" do
        expect(policy(admin, employee_profile).update?).to be true
        expect(policy(admin, other_profile).update?).to be true
      end
    end

    context "como RH" do
      it "pode atualizar qualquer perfil" do
        expect(policy(hr_user, employee_profile).update?).to be true
        expect(policy(hr_user, other_profile).update?).to be true
      end
    end

    context "como gerente" do
      it "pode atualizar o próprio perfil" do
        expect(policy(manager, manager_profile).update?).to be true
      end

      it "não pode atualizar outros perfis" do
        expect(policy(manager, employee_profile).update?).to be false
      end
    end

    context "como funcionário" do
      it "pode atualizar o próprio perfil" do
        expect(policy(employee_user, employee_profile).update?).to be true
      end

      it "não pode atualizar outros perfis" do
        expect(policy(employee_user, other_profile).update?).to be false
      end
    end
  end

  describe "#destroy?" do
    it "concede acesso ao administrador" do
      expect(policy(admin, employee_profile).destroy?).to be true
    end

    it "concede acesso ao RH" do
      expect(policy(hr_user, employee_profile).destroy?).to be true
    end

    it "nega acesso ao gerente" do
      expect(policy(manager, employee_profile).destroy?).to be false
    end

    it "nega acesso ao funcionário" do
      expect(policy(employee_user, employee_profile).destroy?).to be false
    end
  end

  describe "#show_sensitive_data?" do
    it "concede acesso ao administrador" do
      expect(policy(admin, employee_profile).show_sensitive_data?).to be true
    end

    it "concede acesso ao RH" do
      expect(policy(hr_user, employee_profile).show_sensitive_data?).to be true
    end

    it "concede acesso ao gerente para visualizar o próprio perfil" do
      expect(policy(manager, manager_profile).show_sensitive_data?).to be true
    end

    it "nega acesso ao gerente visualizando outros perfis" do
      expect(policy(manager, employee_profile).show_sensitive_data?).to be false
    end

    it "concede acesso ao funcionário para visualizar o próprio perfil" do
      expect(policy(employee_user, employee_profile).show_sensitive_data?).to be true
    end

    it "nega acesso ao funcionário visualizando outros perfis" do
      expect(policy(employee_user, other_profile).show_sensitive_data?).to be false
    end
  end

  describe "Scope" do
    let!(:profiles) { create_list(:employee_profile, 5) }

    def resolve_scope(user)
      described_class::Scope.new(user, EmployeeProfile.all).resolve
    end

    context "como administrador" do
      it "retorna todos os perfis" do
        expect(resolve_scope(admin).count).to eq(5)
      end
    end

    context "como RH" do
      it "retorna todos os perfis" do
        expect(resolve_scope(hr_user).count).to eq(5)
      end
    end

    context "como gerente" do
      it "retorna apenas o próprio perfil" do
        create(:employee_profile, user: manager)
        expect(resolve_scope(manager).count).to eq(1)
        expect(resolve_scope(manager).first.user_id).to eq(manager.id)
      end
      # OBS: + membros da equipe quando implementar departamentos
    end

    context "como funcionário" do
      it "retorna apenas o próprio perfil" do
        create(:employee_profile, user: employee_user)
        expect(resolve_scope(employee_user).count).to eq(1)
        expect(resolve_scope(employee_user).first.user_id).to eq(employee_user.id)
      end
    end
  end
end
