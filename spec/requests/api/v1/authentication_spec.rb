require "rails_helper"

RSpec.describe "API::V1::Authentication", type: :request do
  describe "POST /api/v1/signup" do
    let(:valid_params) do
      {
        user: {
          name: "Tibério Ferreira",
          email: "tiberio@exemplo.com",
          password: "senha123",
          password_confirmation: "senha123"
        }
      }
    end

    context "com parâmetros válidos" do
      it "criando um novo usuário" do
        expect {
          post "/api/v1/signup", params: valid_params
      }.to change(User, :count).by(1)
      end

      it "retorna um JWT token" do
        post "/api/v1/signup", params: valid_params
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json["token"]).to be_present
        expect(json["token"]).to be_a(String)
      end

      it "retorna um JWT token válido" do
        post "/api/v1/signup", params: valid_params
        json = JSON.parse(response.body)

        decoded = JsonWebToken.decode(json["token"])
        expect(decoded[:user_id]).to eq(User.last.id)
      end
    end

    context "com parâmetros inválidos" do
      it "não cria usuário com e-mail inválido" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:email] = "invalid_email"

        expect {
          post "/api/v1/signup", params: invalid_params
      }.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      end

      it "não cria usuário com password pequeno" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:password] = "123"
        invalid_params[:user][:password_confirmation] = "123"

        expect {
          post "/api/v1/signup", params: invalid_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      end

      it "não cria usuário com incompatibilidade de password" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:password_confirmation] = "different"

        expect {
          post "/api/v1/signup", params: invalid_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      end

      it "retorna mensagens de erros" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:email] = ""

        post "/api/v1/signup", params: invalid_params
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_present
        expect(json["errors"]).to be_an(Array)
      end
    end

    context "com email duplicado" do
      it "não cria usuário com e-mail existente" do
        create(:user, email: "tiberio@exemplo.com")

        expect {
          post "/api/v1/signup", params: valid_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

describe "POST /api/v1/login" do
  let!(:user) {
    create(
      :user,
      email: "tiberio@exemplo.com",
      password: "senha123"
    )
  }

  let(:valid_params) do
    {
      email: "tiberio@exemplo.com",
      password: "senha123"
    }
  end

  context "com credenciais válidas" do
    it "retorna um JWT token" do
      post "/api/v1/login", params: valid_params
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["token"]).to be_present
      expect(json["user"]["email"]).to eq("tiberio@exemplo.com")
    end

    it "retorna um JWT token válido" do
      post "/api/v1/login", params: valid_params
      json = JSON.parse(response.body)

      decoded = JsonWebToken.decode(json["token"])
      expect(decoded[:user_id]).to eq(user.id)
    end

    it "é case insensitive para email" do
      post "/api/v1/login", params: { email: "TIBERIO@EXEMPLO.COM", password: "senha123" }
      json = JSON.parse(response.body)

      expect(json["token"]).to be_present
      expect(response).to have_http_status(:ok)
      expect(json["user"]["email"]).to eq("tiberio@exemplo.com")
    end
  end

  context "com credenciais inválidas" do
    it "retorno não autorizado com senha errada" do
      post "/api/v1/login", params: { email: "tiberio@exemplo.com", password: "senha_errada" }
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq('Email ou senha inválidos')
    end

    it "retorna não autorizado com email inexistente" do
      post "/api/v1/login", params: { email: "naoexiste@exemplo.com", password: "senha123" }
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq('Email ou senha inválidos')
    end

    it "retorna bad request com parâmetros ausentes" do
      post "/api/v1/login", params: { email: "tiberio@exemplo.com" }

      expect(response).to have_http_status(:bad_request)
    end
  end
end

describe "GET /api/v1/me" do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  context "com token válido" do
    it "retorna dados atuais do usuário" do
      get '/api/v1/me', headers: { 'Authorization': "Bearer #{token}" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json['user']['id']).to eq(user.id)
        expect(json['user']['email']).to eq(user.email)
        expect(json['user']['name']).to eq(user.name)
    end
  end

  context "sem token" do
    it "retorna não autorizado" do
      get "/api/v1/me"
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna não autorizado com mensagem de error" do
      get "/api/v1/me"
      expect(response).to have_http_status(:unauthorized)

      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Token inválido ou expirado")
    end
  end

  context "com token inválido" do
    it "retorna não autorizado com mensagem de erro" do
      get "/api/v1/me", headers: { "Authorization": "Bearer token_invalido_123" }
      expect(response).to have_http_status(:unauthorized)

      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Token inválido ou expirado")
    end
  end
end
