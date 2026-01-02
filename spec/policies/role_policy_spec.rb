require 'rails_helper'

RSpec.describe RolePolicy, type: :policy do
  subject(:policy) { described_class.new(user, role) }

  let(:role) { create(:role) }

  describe "#show?" do
    context "quando usuário é admin" do
      let(:user) { create(:user, role: :admin) }

      it "permite acesso" do
        expect(policy.show?).to be true
      end
    end

    context "quando usuário é RH" do
      let(:user) { create(:user, role: :hr) }

      it "permite acesso" do
        expect(policy.show?).to be true
      end
    end

    context "quando usuário é dono do role" do
      let(:user) { role.user }

      it "permite acesso" do
        expect(policy.show?).to be true
      end
    end

    context "quando usuário não é admin, RH nem dono" do
      let(:user) { create(:user) }

      it "nega acesso" do
        expect(policy.show?).to be false
      end
    end
  end

  describe "#update?" do
    context "quando usuário é admin" do
      let(:user) { create(:user, role: :admin) }

      it "permite atualização" do
        expect(policy.update?).to be true
      end
    end

    context "quando usuário não é admin" do
      let(:user) { create(:user) }

      it "nega atualização" do
        expect(policy.update?).to be false
      end
    end
  end

  describe "#index?" do
    context "quando usuário é admin" do
      let(:user) { create(:user, role: :admin) }

      it "permite listagem" do
        expect(policy.index?).to be true
      end
    end

    context "quando usuário é RH" do
      let(:user) { create(:user, role: :hr) }

      it "permite listagem" do
        expect(policy.index?).to be true
      end
    end

    context "quando usuário comum" do
      let(:user) { create(:user) }

      it "nega listagem" do
        expect(policy.index?).to be false
      end
    end
  end

  describe "Scope" do
    subject(:resolved_scope) do
      described_class::Scope.new(user, Role.all).resolve
    end

    let!(:own_role) { create(:role, user: user) }
    let!(:other_role) { create(:role) }

    context "quando usuário é admin" do
      let(:user) { create(:user, role: :admin) }

      it "retorna todos os roles" do
        expect(resolved_scope).to match_array(Role.all)
      end
    end

    context "quando usuário é RH" do
      let(:user) { create(:user, role: :hr) }

      it "retorna todos os roles" do
        expect(resolved_scope).to match_array(Role.all)
      end
    end

    context "quando usuário comum" do
      let(:user) { create(:user) }

      it "retorna apenas o próprio role" do
        expect(resolved_scope).to contain_exactly(own_role)
      end
    end
  end
end
