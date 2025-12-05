module Api
  module V1
    class HealthController < ApplicationController
      # Endpoint usado por serviços externos e pela infraestrutura (ex: Kubernetes) para verificar se a API está ativa e funcionando corretamente.
      def show
        render json: {
          status: "ok",
          timestamp: Time.current.iso8601
        }
      end
    end
  end
end
