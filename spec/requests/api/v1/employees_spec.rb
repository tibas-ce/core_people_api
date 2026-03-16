require "rails_helper"

RSpec.describe "API::V1::Employees", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:hr_user) { create(:user, :hr) }
  let(:manager) { create(:user, :manager) }
  let(:employee_user) { create(:user) }

  let(:admin_token) { JsonWebToken.encode(user_id: admin.id) }
  let(:hr_token) { JsonWebToken.encode(user_id: hr_user.id) }
  let(:manager_token) { JsonWebToken.encode(user_id: manager.id) }
  let(:employee_user_token) { JsonWebToken.encode(user_id: employee_user.id) }

  describe "GET /api/v1/employees" do
    let!(:profiles) { create_list(:employee_profile, 5) }

    context "como administrado" do
      it "retorna todos os perfis de funcionários" do
        get "/api/v1/employees",
            headers: { "Authorization": "Bearer #{admin_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["employees"]).to be_an(Array)
        expect(json["employees"].length).to eq(5)
        expect(json["employees"].first).to have_key("name")
        expect(json["employees"].first).not_to have_key("salary")
      end
    end

    context "como RH" do
      it "retorna todos os perfis de funcionários" do
        get "/api/v1/employees",
            headers: { "Authorization": "Bearer #{hr_token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "como gerente" do
      it "retorna apenas o próprio perfil" do
        get "/api/v1/employees",
            headers: { "Authorization": "Bearer #{manager_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["employees"].length).to eq(1)
      end
    end

    context "como funcionário" do
      it "retornos proibidos" do
        get "/api/v1/employees",
            headers: { "Authorization": "Bearer #{employee_user_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "sem autenticação" do
      it "retorna não autorizado" do
        get "/api/v1/employees",
          headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/employees/:id" do
    let(:employee_profile) { create(:employee_profile, salary: 8000) }

    context "como administrador" do
      it "retorna perfil de funcionário com dado sensível" do
        get "/api/v1/employees/#{employee_profile.id}",
            headers: { "Authorization": "Bearer #{admin_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["employee"]["user"]["name"]).to be_present
        expect(json["employee"]["salary"]).to eq(8000.0)
      end
    end

    context "como RH" do
      it "retorna perfil de funcionário com dado sensível" do
        get "/api/v1/employees/#{employee_profile.id}",
            headers: { "Authorization": "Bearer #{hr_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["employee"]["salary"]).to be_present
      end
    end

    context "como funcionário visualizando o próprio perfil" do
      let(:own_profile) { create(:employee_profile, user: employee_user, salary: 5000) }

      it "retorna o próprio perfil com dados sensíveis" do
        get "/api/v1/employees/#{own_profile.id}",
            headers: { "Authorization": "Bearer #{employee_user_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["employee"]["salary"]).to eq(5000)
      end
    end

    context "perfil não encontrado" do
      it "retorna não encontrado" do
        get "/api/v1/employees/9999",
            headers: { "Authorization": "Bearer #{admin_token}" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/v1/employees/me" do
    let!(:employee_profile) { create(:employee_profile, user: employee_user, salary: 6000) }

    it "retorna o perfil atual do funcionário solicitado" do
      get "/api/v1/employees/me",
            headers: { "Authorization": "Bearer #{employee_user_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["employee"]["user"]["id"]).to eq(employee_user.id)
        expect(json["employee"]["salary"]).to eq(6000)
    end

    context "usuário sem perfil de funcionário" do
      it "retorna não encontrado" do
        user_without_profile = create(:user)
        token = JsonWebToken.encode(user_id: user_without_profile.id)

        get "/api/v1/employees/me",
            headers: { "Authorization": "Bearer #{token}" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/employees" do
    let(:valid_params) do
      {
        employee: {
          user_id: create(:user, name: "Maria Silva").id,
          cpf: "12345678909",
          position: "Desenvolvedora",
          hire_date: Date.today,
          salary: 7000,
          department: "TI"
        }
      }
    end

    context "como administrador" do
      it "cria perfil de funcionário" do
        expect {
          post "/api/v1/employees",
               params: valid_params,
               headers: { "Authorization": "Bearer #{admin_token}" }
        }.to change(EmployeeProfile, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["employee"]["user"]["name"]).to eq("Maria Silva")
      end
    end

    context "como RH" do
      it "cria perfil de funcionário" do
        expect {
          post "/api/v1/employees",
               params: valid_params,
               headers: { "Authorization": "Bearer #{hr_token}" }
        }.to change(EmployeeProfile, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "como gerente" do
      it "retornos proibidos" do
        post "/api/v1/employees",
               params: valid_params,
               headers: { 'Authorization': "Bearer #{manager_token}" }


        expect(response).to have_http_status(:forbidden)
      end
    end

    context "com dados inválidos" do
      it "retorna erros de validação" do
        invalid_params = valid_params.deep_dup
        invalid_params[:employee][:cpf] = "111.111.111-11"

        post '/api/v1/employees',
             params: invalid_params,
             headers: { "Authorization": "Bearer #{admin_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "PUT /api/v1/employees/:id" do
    let(:employee_profile) { create(:employee_profile, user: create(:user, name: "João Silva")) }

    context "como administrador" do
      it "atualiza o perfil dos funcionário" do
        put "/api/v1/employees/#{employee_profile.id}",
            params: { employee: { name: "João Santos" } },
            headers: { "Authorization": "Bearer #{admin_token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["employee"]["user"]["name"]).to eq("João Santos")
        expect(employee_profile.user.reload.name).to eq("João Santos")
      end
    end

    context "como funcionário atualizando perfil próprio" do
      let(:own_profile) { create(:employee_profile, user: employee_user, phone: "85999999999") }

      it "pode atualizar campos não sensíveis" do
        put "/api/v1/employees/#{own_profile.id}",
            params: { employee: { phone: "85988888888", address: "Nova Rua, 123" } },
            headers: { "Authorization": "Bearer #{employee_user_token}" }

        expect(response).to have_http_status(:ok)
        expect(own_profile.reload.phone).to eq("85988888888")
      end
    end

    context "com dados inválidos" do
      it "retorna erros de validação" do
        put "/api/v1/employees/#{employee_profile.id}",
            params: { employee: { cpf: "invalid" } },
            headers: { "Authorization": "Bearer #{admin_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    let!(:employee_profile) { create(:employee_profile) }

    context "como administrador" do
      it "desativa o funcionário (soft delete)" do
        delete "/api/v1/employees/#{employee_profile.id}",
               headers: { "Authorization": "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        expect(employee_profile.reload.status).to eq("inactive")
      end
    end

    context "como RH" do
      it "desativa o funcionário (soft delete)" do
        delete "/api/v1/employees/#{employee_profile.id}",
               headers: { "Authorization": "Bearer #{hr_token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "como funcionário" do
      it "retornos proibidos" do
        delete "/api/v1/employees/#{employee_profile.id}",
               headers: { "Authorization": "Bearer #{employee_user_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
