require "rails_helper"

RSpec.describe "Api::V1::Roles", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:hr) { create(:user, :hr) }
  let(:manager) { create(:user, :manager) }
  let(:employee) { create(:user) }
  let(:target_user) { create(:user) }

  describe "GET /api/v1/users/:user_id/role" do
    it "admin pode ver o role de outro usuário" do
      get_auth "/api/v1/users/#{target_user.id}/role", user: admin

      expect(response).to have_http_status(:ok)
      expect(json["role"]["name"]).to eq("employee")
    end

    it "employee pode ver o próprio role" do
      get_auth "/api/v1/users/#{employee.id}/role", user: employee

      expect(response).to have_http_status(:ok)
      expect(json["role"]["name"]).to eq("employee")
    end

    it "employee não pode ver role de outro usuário" do
      get_auth "/api/v1/users/#{target_user.id}/role", user: employee

      expect(response).to have_http_status(:forbidden)
    end

    it "retorna unauthorized sem token" do
      get "/api/v1/users/#{target_user.id}/role"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /api/v1/users/:user_id/role" do
    it "admin pode alterar o role do usuário" do
      put_auth "/api/v1/users/#{target_user.id}/role",
          user: admin,
          params: { role: { name: "hr" } }

      expect(response).to have_http_status(:ok)
      expect(json["role"]["name"]).to eq("hr")
      expect(target_user.reload.role.name).to eq("hr")
    end

    it "admin recebe erro ao enviar role inválido" do
      put_auth "/api/v1/users/#{target_user.id}/role",
          user: admin,
          params: { role: { name: "invalid" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "employee não pode alterar role" do
      put_auth "/api/v1/users/#{target_user.id}/role",
          user: employee,
          params: { role: { name: "hr" } }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/roles" do
    before do
      create(:user, :admin)
      create(:user, :hr)
      create(:user, :manager)
      create_list(:user, 3)
    end

    it "admin vê lista de roles" do
      get_auth "/api/v1/roles", user: admin

      expect(response).to have_http_status(:ok)
      expect(json["roles"]).to be_an(Array)
      expect(json["summary"]["total"]).to eq(User.count)
    end

    it "employee não pode listar roles" do
      get_auth "/api/v1/roles", user: employee

      expect(response).to have_http_status(:forbidden)
    end
  end
end
