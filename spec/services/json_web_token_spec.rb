require "rails_helper"

RSpec.describe JsonWebToken do
  let(:user) { create(:user) }
  let(:payload) { { user_id: user.id } }

  describe ".encode" do
    it "codifica a carga útil em um token JWT" do
      token = JsonWebToken.encode(payload)

      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3)
    end

    it "inclui o tempo de expiração" do
      token = JsonWebToken.encode(payload)
      decoded = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, algorithm: 'HS256')[0]

      expect(decoded['exp']).to be_present
      expect(decoded['user_id']).to eq(user.id)
    end

    it "permite o tempo de expiração personalizado" do
      custom_exp = 2.hours.from_now
      token = JsonWebToken.encode(payload, custom_exp)
      decoded = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, algorithm: 'HS256')[0]

      expect(decoded['exp']).to be_within(5).of(custom_exp.to_i)
    end
  end

  describe ".decode" do
    it "Decodifica um token JWT válido" do
      token = JsonWebToken.encode(payload)
      decode = JsonWebToken.decode(token)

      expect(decode[:user_id]).to eq(user.id)
    end

    it "retorna nil para token inválido" do
      invalid_token = "invalid.token.here"
      decode = JsonWebToken.decode(invalid_token)

      expect(decode).to be_nil
    end

    it "retorna nil para token expirado" do
      token = JsonWebToken.encode(payload, 1.second.ago)
      sleep 1
      decode = JsonWebToken.decode(token)

      expect(decode).to be_nil
    end
  end
end
