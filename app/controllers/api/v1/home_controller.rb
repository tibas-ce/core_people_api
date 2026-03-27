class Api::V1::HomeController < ApplicationController
  def index
    render json: {
      name: "Core People API",
      version: "v1",
      status: "online",
      timestamp: Time.current
    }
  end
end
