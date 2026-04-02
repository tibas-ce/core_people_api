Rails.application.config.middleware.insert_before 0, Rack::Cors do
   allow do
     if Rails.env.production?
      # Em produção, permitir apenas domínios específicos
      origins ENV.fetch("CORS_ORIGINS", "localhost:3000").split(",")
     else
      # Em desenvolvimento, permitir localhost
      origins "localhost:3000", "localhost:5173", "127.0.0.1:3000"
     end

     resource "*",
       headers: :any,
       methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
       credentials: true
   end
end
