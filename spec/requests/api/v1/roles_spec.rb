require "rails_helper"

RSpec.describe "Api::V1::Roles", type: :request do
  def auth(token)
    { "Authorization" => "Bearer #{token}" }
  end
  let(:admin) { create(:user, :admin) }
  let(:hr_user) { create(:user, :hr) }
  let(:manager) { create(:user, :manager) }
  let(:employee) { create(:user) }
  let(:target_user) { create(:user) }

  let(:admin_token) { JsonWebToken.encode(user_id: admin.id) }
  let(:hr_token) { JsonWebToken.encode(user_id: hr_user.id) }
  let(:manager_token) { JsonWebToken.encode(user_id: manager.id) }
  let(:employee_token) { JsonWebToken.encode(user_id: employee.id) }

  describe "GET /api/v1/users/:user_id/role" do
    it "admin pode ver o role de outro usuário" do
      get "/api/v1/users/#{target.id}/role",
          headers: auth(admin_token)

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["role"]["name"]).to eq("employee")
    end

    it "employee pode ver o próprio role" do
      get "/api/v1/users/#{employee.id}/role",
          headers: auth(employee_token)

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["role"]["name"]).to eq("employee")
    end

    it "employee não pode ver role de outro usuário" do
      get "/api/v1/users/#{target.id}/role",
          headers: auth(employee_token)

      expect(response).to have_http_status(:forbidden)
    end

    it "retorna unauthorized sem token" do
      get "/api/v1/users/#{target.id}/role"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /api/v1/users/:user_id/role" do
    it "admin pode alterar o role do usuário" do
      put "/api/v1/users/#{target.id}/role",
          params: { role: { name: "hr" } },
          headers: auth(admin_token)

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["role"]["name"]).to eq("hr")
      expect(target.reload.role.name).to eq("hr")
    end

    it "admin recebe erro ao enviar role inválido" do
      put "/api/v1/users/#{target.id}/role",
          params: { role: { name: "invalid" } },
          headers: auth(admin_token)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "employee não pode alterar role" do
      put "/api/v1/users/#{target.id}/role",
          params: { role: { name: "hr" } },
          headers: auth(employee_token)

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
      get "/api/v1/roles", headers: auth(admin_token)

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["roles"]).to be_an(Array)
      expect(json["summary"]["total"]).to eq(User.count)
    end

    it "employee não pode listar roles" do
      get "/api/v1/roles", headers: auth(employee_token)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
