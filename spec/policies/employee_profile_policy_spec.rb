require "rails_helper"

RSpec.describe EmployeeProfilePolicy do
  subject { described_class }

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

  permissions :index? do
    it "concede acesso ao administrador" do
      expect(subject).to permit(admin, EmployeeProfile)
    end

    it "concede acesso ao RH" do
      expect(subject).to permit(hr_user, EmployeeProfile)
    end

    it "concede acesso ao gerente" do
      expect(subject).to permit(manager, EmployeeProfile)
    end

    it "nega acesso ao funcionário" do
      expect(subject).not_to permit(employee_user, EmployeeProfile)
    end
  end

  permissions :show? do
    context "como administrador" do
      it "pode visualizar qualquer perfil" do
        expect(subject).to permit(admin, employee_profile)
        expect(subject).to permit(admin, other_profile)
      end

      it "pode visualizar o próprio perfil" do
        expect(subject).to permit(admin, admin_profile)
      end
    end

    context "como RH" do
      it "pode visualizar qualquer perfil" do
        expect(subject).to permit(hr_user, employee_profile)
        expect(subject).to permit(hr_user, other_profile)
      end

      it "pode visualizar o próprio perfil" do
        expect(subject).to permit(hr_user, hr_profile)
      end
    end

    context "como gerente" do
      it "pode visualizar o próprio perfil" do
        expect(subject).to permit(manager, manager_profile)
      end
      # OBS: implementar lógica de equipe depois
    end

    context "como funcionário" do
      it "pode visualizar o próprio perfil" do
        expect(subject).to permit(employee_user, employee_profile)
      end

      it "não podem visualizar outros perfis" do
        expect(subject).not_to permit(employee_user, other_profile)
      end
    end
  end

  permissions :create? do
    it "concede acesso ao administrador" do
      expect(subject).to permit(admin, EmployeeProfile)
    end

    it "concede acesso ao RH" do
      expect(subject).to permit(hr_user, EmployeeProfile)
    end

    it "nega acesso ao gerente" do
      expect(subject).not_to permit(manager, EmployeeProfile)
    end

    it "nega acesso ao funcionário" do
      expect(subject).not_to permit(employee_user, EmployeeProfile)
    end
  end

  permissions :update? do
    context "como administrador" do
      it "pode atualizar qualquer perfil" do
        expect(subject).to permit(admin, employee_profile)
        expect(subject).to permit(admin, other_profile)
      end
    end

    context "como RH" do
      it "pode atualizar qualquer perfil" do
        expect(subject).to permit(hr_user, employee_profile)
        expect(subject).to permit(hr_user, other_profile)
      end
    end

    context "como gerente" do
      it "pode atualizar o próprio perfil" do
        expect(subject).to permit(manager, manager_profile)
      end

      it "não podem atualizar outros perfis" do
        expect(subject).not_to permit(manager, employee_profile)
      end
    end

    context "como funcionário" do
      it "pode atualizar o próprio perfil" do
        expect(subject).to permit(employee_user, employee_profile)
      end

      it "não podem atualizar outros perfis" do
        expect(subject).not_to permit(employee_user, other_profile)
      end
    end
  end

  permissions :destroy? do
    it "concede acesso ao administrador" do
      expect(subject).to permit(admin, employee_profile)
    end

    it "concede acesso ao RH" do
      expect(subject).to permit(hr_user, employee_profile)
    end

    it "nega acesso ao gerente" do
      expect(subject).not_to permit(manager, employee_profile)
    end

    it "nega acesso ao funcionário" do
      expect(subject).not_to permit(employee_user, employee_profile)
    end
  end

  # Controle de acesso a dados sensíveis (ex: salário, CPF). Usado para decidir se a view admin do blueprint pode ser utilizada.
  permissions :show_sensitive_data? do
    it "concede acesso ao administrador" do
      expect(subject).to permit(admin, employee_profile)
    end

    it "concede acesso ao RH" do
      expect(subject).to permit(hr_user, employee_profile)
    end

    it "concede acesso ao gerente para visualizar o próprio perfil" do
      expect(subject).to permit(manager, manager_profile)
    end

    it "nega acesso ao gerente que está visualizando os outros" do
      expect(subject).not_to permit(manager, employee_profile)
    end

    it "concede acesso ao funcionário para visualizar o próprio perfil" do
      expect(subject).to permit(employee_user, employee_profile)
    end

    it "nega acesso ao funcionário que está visualizando os outros" do
      expect(subject).not_to permit(employee_user, other_profile)
    end
  end

  # Scope define quais registros são visíveis no index dependendo do papel do usuário.
  describe "Scope" do
    let!(:profiles) { create_list(:employee_profile, 5) }

    context "como administrador" do
      it "retorna todos os perfis" do
        scope = Pundit.policy_scope(admin, EmployeeProfile)
        expect(scope.count).to eq(5)
      end
    end

    context "como RH" do
      it "retorna todos os perfis" do
        scope = Pundit.policy_scope(hr_user, EmployeeProfile)
        expect(scope.count).to eq(5)
      end
    end

    context "como gerente" do
      it "retorna o próprio perfil" do
        create(:employee_profile, user: manager)
        scope = Pundit.policy_scope(manager, EmployeeProfile)
        expect(scope.count).to eq(1)
        expect(scope.first.user_id).to eq(manager.id)
      end
      # OBS: + team members quando implementar equipe
    end

    context "como funcionário" do
      it "retorna o próprio perfil" do
        create(:employee_profile, user: employee_user)
        scope = Pundit.policy_scope(employee_user, EmployeeProfile)
        expect(scope.count).to eq(1)
        expect(scope.first.user_id).to eq(employee_user.id)
      end
    end
  end
end
