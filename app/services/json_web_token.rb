class JsonWebToken
  SECRET_KEY = ENV["JWT_SECRET_KEY"]

  # Gera um token JWT com uma carga útil (payload) e expiração
  def self.encode(payload, exp = 24.hours.from_now)
    # Adiciona ao payload o tempo de expiração
    payload[:exp] = exp.to_i
    # Retorna o token JWT assinado com algoritmo HS256
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  # Decodifica um token JWT e retorna o payload
  def self.decode(token)
    # JWT.decode retorna um array: [payload, header]
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")[0]
    # Converte chaves para tipo indiferente: :user_id ou "user_id" funcionam
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    # Retorna nil se algo der errado (token malformado, assinatura errada, expirado etc)
    nil
  end
end
