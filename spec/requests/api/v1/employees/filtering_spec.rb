require "rails_helper"

RSpec.describe "API::V1::Employees", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "GET /api/v1/employees com filtros" do
    let!(:dev1) { create(:employee_profile, user: create(:user, name: "Carlos Silva"), position: "Desenvolvedor", department: "TI", status: :active) }
    let!(:dev2) { create(:employee_profile, user: create(:user, name: "Ana Santos"), position: "Desenvolvedora", department: "TI", status: :active) }
    let!(:designer) { create(:employee_profile, user: create(:user, name: "Bruno Costa"), position: "Designer", department: "Marketing", status: :active) }
    let!(:inactive_dev) { create(:employee_profile, user: create(:user, name: "Ana Lima"), position: "Desenvolvedor", department: "TI", status: :inactive) }

    context "search" do
      it "busca por nome" do
        get_auth "/api/v1/employees?search=Carlos", user: admin

        expect(response).to have_http_status(:ok)
        expect(json["employees"].length).to eq(1)
        expect(json["employees"].first["user"]["name"]).to eq("Carlos Silva")
      end

      it "busca por nome parcial" do
        get_auth "/api/v1/employees?search=Silva", user: admin

        expect(json["employees"].first["user"]["name"]).to eq("Carlos Silva")
      end

      it "busca por CPF" do
        get_auth "/api/v1/employees?search=#{dev1.cpf}", user: admin

        expect(json["employees"].length).to eq(1)
        expect(json["employees"].first["id"]).to eq(dev1.id)
      end

      it "retorna vazio quando não encontra resultados" do
        get_auth "/api/v1/employees?search=XYZ", user: admin

        expect(response).to have_http_status(:ok)
        expect(json["employees"]).to be_empty
        expect(json["meta"]["total"]).to eq(0)
        expect(json["meta"]["filtered"]).to eq(true)
      end

      it "ignora busca vazia" do
        get_auth "/api/v1/employees?search=", user: admin

        expect(json["employees"].length).to eq(4)
      end
    end

    context "filter by status" do
      it "filtra por status active" do
        get_auth "/api/v1/employees?status=active", user: admin

        expect(json["employees"].length).to eq(3)
        expect(json["employees"]).not_to include(
          hash_including('id' => inactive_dev.id)
        )
      end
      it "filtra por status inactive" do
        get_auth "/api/v1/employees?status=inactive", user: admin

        expect(json["employees"].length).to eq(1)
        expect(json["employees"].first["id"]).to eq(inactive_dev.id)
      end

      it "ignora status inválido e retorna todos os registros" do
        get_auth "/api/v1/employees?status=banana", user: admin

        expect(response).to have_http_status(:ok)
        expect(json["employees"].length).to eq(4)
        expect(json["meta"]["filtered"]).to eq(false)
      end
    end

    context "filter by department" do
      it "filtros por departamento" do
        get_auth "/api/v1/employees?department=TI", user: admin

        expect(json["employees"].length).to eq(3)
      end

      it "filtros por departamento (case insensitive)" do
        get_auth "/api/v1/employees?department=ti", user: admin

        expect(json["employees"].length).to eq(3) # 2 ativos + 1 inativo
      end

      it "ignora múltiplos filtros inválidos" do
        get_auth "/api/v1/employees?status=banana&department=???", user: admin

        expect(json["employees"].length).to eq(4)
        expect(json["meta"]["filtered"]).to eq(false)
      end
    end

    context "filter by position" do
      it "filtros por posição" do
        get_auth "/api/v1/employees?position=Designer", user: admin

        expect(json["employees"].length).to eq(1)
        expect(json["employees"].first["id"]).to eq(designer.id)
      end
    end

    context "sorting" do
      it "sorts pelo nome ascendente" do
        get_auth "/api/v1/employees?sort=name:asc", user: admin

        names = json["employees"].map { |e| e["user"]["name"] }
        expected = [ "Ana Lima", "Ana Santos", "Bruno Costa", "Carlos Silva" ]
        expect(names).to eq(expected)
      end

      it "sorts pelo nome decrescente" do
        get_auth "/api/v1/employees?sort=name:desc", user: admin

        names = json["employees"].map { |e| e["user"]["name"] }
        expect(names).to eq(names.sort.reverse)
      end

      it "ignora sort inválido" do
        get_auth "/api/v1/employees?sort=banana", user: admin

        names = json["employees"].map { |e| e["user"]["name"] }

        expect(names).to match_array([
          "Carlos Silva",
          "Ana Santos",
          "Bruno Costa",
          "Ana Lima"
        ])
      end
    end

    context "combined filters" do
      it "combina search + status" do
        get_auth "/api/v1/employees?search=Carlos&status=active", user: admin

        expect(json["employees"].length).to eq(1)
        expect(json["employees"].first["id"]).to eq(dev1.id)
      end

      it "combina department + status + sort" do
        get_auth "/api/v1/employees?department=TI&status=active&sort=name:asc", user: admin

        names = json["employees"].map { |e| e["user"]["name"] }
        expect(json["employees"].length).to eq(2)
        expect(names).to eq([ "Ana Santos", "Carlos Silva" ])
      end
    end

    context "metadata" do
      it "inclui contagem total" do
        get_auth "/api/v1/employees", user: admin

        expect(json["meta"]).to be_present
        expect(json["meta"]["total"]).to eq(4)
      end

      it "inclui contagem filtrada" do
        get_auth "/api/v1/employees?status=active", user: admin

        expect(json["meta"]["total"]).to eq(3)
        expect(json["meta"]["filtered"]).to eq(true)
      end
    end
  end
end
