require "rails_helper"

RSpec.describe "API::V1::Health", type: :request do
  describe "GET /api/v1/health" do
    it "retorna status de sucesso" do
      # Executa a requisição HTTP GET para a rota /api/v1/health
      get "/api/v1/health"

      # Verifica que o HTTP status retornado é 200 (símbolo :ok é mapeado para 200)
      expect(response).to have_http_status(:ok)
      # Verifica que o corpo JSON contém:
      # - status: "ok"
      # - timestamp: uma String (o valor exato não importa)
      # include permite usar matchers dentro do hash, por isso kind_of(String) funciona corretamente aqui.
      expect(JSON.parse(response.body)).to include({
        "status" => "ok",
        "timestamp" => kind_of(String)
      })
    end
  end
end
