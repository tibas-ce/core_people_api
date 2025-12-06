require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "é válido com atributos válidos" do
      user = User.new(
        email: "teste@exemplo.com",
        password: "senha123",
        name: "João Silva"
      )
      expect(user).to be_valid
    end
  end
end
