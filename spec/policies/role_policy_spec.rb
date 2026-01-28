require 'rails_helper'

RSpec.describe RolePolicy, type: :policy do
  subject(:policy) { described_class.new(user, role) }

  let(:other_user) { create(:user) }
  let(:role) { other_user.role }

  describe "#show?" do
    context "quando usuário é admin" do
      let(:user) { create(:user, :admin) }

      it "permite acesso" do
        expect(policy.show?).to be true
      end
    end

    context "quando usuário é RH" do
      let(:user) { create(:user, :hr) }

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
      let(:user) { create(:user, :admin) }

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
      let(:user) { create(:user, :admin) }

      it "permite listagem" do
        expect(policy.index?).to be true
      end
    end

    context "quando usuário é RH" do
      let(:user) { create(:user, :hr) }

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

    context "quando usuário é admin" do
      let(:user) { create(:user, :admin) }
      let!(:other_roles) { create_list(:user, 3).map(&:role) }

      it "retorna todos os roles" do
        expect(resolved_scope).to match_array(Role.all)
      end
    end

    context "quando usuário é RH" do
      let(:user) { create(:user, :hr) }
      let!(:other_roles) { create_list(:user, 3).map(&:role) }

      it "retorna todos os roles" do
        expect(resolved_scope).to match_array(Role.all)
      end
    end

    context "quando usuário comum" do
      let(:user) { create(:user) }
      let!(:other_roles) { create_list(:user, 3).map(&:role) }

      it "retorna apenas o próprio role" do
        expect(resolved_scope).to contain_exactly(user.role)
      end
    end
  end
end
