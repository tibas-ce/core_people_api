require "rails_helper"

RSpec.describe Authenticable, type: :controller do
  # Criamos um controller anônimo para incluir o módulo Authenticable
  controller(ApplicationController) do
    include Authenticable
    before_action :authenticate_user!

    # Endpoint fictício que só retorna o usuário logado
    def index
      render json: { message: "Success", user_id: current_user.id }
    end
  end

  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  # Definimos a rota do controller anônimo
  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  describe "#authenticate_user!" do
    context "com token válido" do
      it "permite acesso" do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index

        expect(response).to have_http_status(:ok)
      end

      it "define current_user corretamente" do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        json = JSON.parse(response.body)

        expect(json['user_id']).to eq(user.id)
      end
    end

    context "sem token" do
      it "retorna não autorizado e não define current_user" do
        get :index
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(json["error"]).to eq("Token inválido ou expirado")
        expect(controller.current_user).to be_nil
      end
    end

    context "com token inválido" do
      it "retorna não autorizado e não define current_user" do
        request.headers['Authorization'] = "Bearer invalid_token"
        get :index
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(json["error"]).to eq("Token inválido ou expirado")
        expect(controller.current_user).to be_nil
      end
    end

    context "com token expirado" do
      it "retorna não autorizado e não define current_user" do
        expired_token = JsonWebToken.encode({ user_id: user.id }, Time.current - 10.seconds)
        request.headers['Authorization'] = "Bearer #{expired_token}"
        get :index
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(json["error"]).to eq("Token inválido ou expirado")
        expect(controller.current_user).to be_nil
      end
    end
  end
end
