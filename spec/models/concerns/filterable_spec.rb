require "rails_helper"

RSpec.describe Filterable do
  let(:dummy_class) do
    # criar um modelo dummy para testar o concern
    Class.new(ApplicationRecord) do
      self.table_name = "employee_profiles"
      include Filterable
    end
  end

  let!(:employee1) {
    create(:employee_profile,
      user: create(:user, name: "João Silva"),
      cpf: "12345678909",
      position: "Desenvolvedor",
      department: "TI",
      status: :active,
      hire_date: 2.years.ago
    )
  }

  let!(:employee2) {
    create(:employee_profile,
      user: create(:user, name: "Maria Santos"),
      cpf: "98765432100",
      position: "Designer",
      department: "Marketing",
      status: :active,
      hire_date: 1.years.ago
    )
  }

  let!(:employee3) {
    create(:employee_profile,
      user: create(:user, name: "João Pedro"),
      cpf: "11122233344",
      position: "Gerente",
      department: "TI",
      status: :inactive,
      hire_date: 3.years.ago
    )
  }

  describe ".search" do
    it "pesquisas por nome completo" do
      results = dummy_class.search("João")

      expect(results.count).to eq(2)
      expect(results).to include(employee1, employee3)
    end

    it "pesquisas por nome parcial (case insensitive)" do
      results = dummy_class.search("silva")

      expect(results.count).to eq(1)
      expect(results.first.id).to eq(employee1.id)
    end

    it "pesquisas por CPF (com ou sem máscara)" do
      results = dummy_class.search("123.456.789-09")

      expect(results.count).to eq(1)
      expect(results.first.id).to eq(employee1.id)
    end

    it "pesquisas por CPF sem máscara" do
      results = dummy_class.search("98765432100")

      expect(results.count).to eq(1)
      expect(results.first.id).to eq(employee2.id)
    end

    it "retorna todos os resultados se a pesquisa estiver vazia" do
      results = dummy_class.search("")

      expect(results.count).to eq(3)
    end

    it "retorna todos os resultados se a pesquisa for nula" do
      results = dummy_class.search(nil)

      expect(results.count).to eq(3)
    end
  end

  describe ".filter_by_status" do
    it "filtra por status ativo" do
      results = dummy_class.filter_by_status("active")

      expect(results.count).to eq(2)
      expect(results).to include(employee1, employee2)
    end

    it "filtra por status inativo" do
      results = dummy_class.filter_by_status("inactive")

      expect(results.count).to eq(1)
      expect(results.first.id).to eq(employee3.id)
    end

    it "retorna todos se o status estiver em branco" do
      results = dummy_class.filter_by_status("")

      expect(results.count).to eq(3)
    end
  end

  describe ".filter_by_department" do
    it "filtra por departamento" do
      results = dummy_class.filter_by_department("TI")

      expect(results.count).to eq(2)
      expect(results).to include(employee1, employee3)
    end

    it "filtra por departamento (case insensitive)" do
      results = dummy_class.filter_by_department("ti")

      expect(results.count).to eq(2)
      end

    it "retorna tudo se o departamento estiver em branco" do
      results = dummy_class.filter_by_department("")

      expect(results.count).to eq(3)
    end
  end

  describe ".filter_by_position" do
    it "filtra por posição" do
      results = dummy_class.filter_by_position("Desenvolvedor")

      expect(results.count).to eq(1)
      expect(results.first.id).to eql(employee1.id)
    end

    it "filtra por posição (case insensitive)" do
      results = dummy_class.filter_by_position("desenvolvedor")

      expect(results.count).to eq(1)
      end

    it "retorna tudo se a posição estiver em branco" do
      results = dummy_class.filter_by_position("")

      expect(results.count).to eq(3)
    end
  end

  describe ".sort_by_column" do
    it "ordena por nome completo em ordem crescente" do
      results = dummy_class.sort_by_column("name", "asc")

      expect(results.first.id).to eq(employee3.id) # João Pedro
      expect(results.last.id).to eq(employee2.id)  # Maria Santos
    end

    it "ordena por nome completo em ordem decrescente" do
      results = dummy_class.sort_by_column("name", "desc")

      expect(results.first.id).to eq(employee2.id) # Maria Santos
      expect(results.last.id).to eq(employee3.id)  # João Pedro
    end

    it "ordena por data de contratação em ordem crescente (da mais antiga para a mais recente)" do
      results = dummy_class.sort_by_column("hire_date", "asc")

      expect(results.first.id).to eq(employee3.id) # 3 anos atrás
      expect(results.last.id).to eq(employee2.id)  # 1 ano atrás
    end

    it "ordena por data de contratação em ordem decrescente (da mais recente para a mais antiga)" do
      results = dummy_class.sort_by_column("hire_date", "desc")

      expect(results.first.id).to eq(employee2.id) # 1 ano atrás
      expect(results.last.id).to eq(employee3.id)  # 3 anos atrás
    end

    it "se a coluna for inválida, o padrão é usar a ordem crescente do id" do
      results = dummy_class.sort_by_column("invalid_column", "asc")

      expect(results.first.id).to eq(employee1.id)
    end

    it "se a direção for inválida, o padrão é ascendente" do
      results = dummy_class.sort_by_column("name", "invalid")

      expect(results.first.user.name).to eq("João Pedro")
    end
  end

  describe "chaining filters" do
    it "pode encadear pesquisas + filter_by_status" do
      results = dummy_class.search("João").filter_by_status("active")

      expect(results.count).to eq(1)
      expect(results.first.id).to eq(employee1.id)
    end

    it "pode encadear filter_by_department + filter_by_status + sort" do
      results = dummy_class.search
                  .filter_by_department("TI")
                  .filter_by_status("active")
                  .sort_by_column("name", "asc")

      expect(results.count).to eq(1)
      expect(results.first.id).to eq(employee1.id)
    end

    it "pode encadear todos os filtros" do
      results = dummy_class
                  .search("João")
                  .filter_by_department("TI")
                  .filter_by_status("active")
                  .sort_by_column("name", "asc")

      expect(results.count).to eq(1)
    end
  end
end
