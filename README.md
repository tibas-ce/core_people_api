<div align="center">

# **Core People API — HR Management System**

API RESTful para gestão de recursos humanos com autenticação JWT, controle de acesso por roles (RBAC) e cobertura de testes robusta.

<p align="center">
  <img src="https://img.shields.io/badge/Ruby-3.4+-red?logo=ruby" />
  <img src="https://img.shields.io/badge/Rails-8.0+-red?logo=rubyonrails" />
  <img src="https://img.shields.io/badge/PostgreSQL-Database-blue?logo=postgresql" />
  
  <img src="https://img.shields.io/badge/Auth-JWT-orange" />
  <img src="https://img.shields.io/badge/Authorization-Pundit-purple" />

  <img src="https://img.shields.io/badge/Tested%20with-RSpec-green" />
  <img src="https://img.shields.io/badge/Coverage-93%25-brightgreen" />

  [![Live API](https://img.shields.io/badge/API-Online-success)](https://corepeopleapi-production.up.railway.app/api/v1/health)

  <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
</p>

**Produção:** [Core People API](https://corepeopleapi-production.up.railway.app/api/v1/health)

</div>

---

## Sobre o Projeto

Este projeto simula um sistema real de RH, com autenticação, autorização por papéis e operações completas sobre funcionários.

Mais do que funcionalidades, o foco em organização, testabilidade e boas práticas de software.

## Destaques Técnicos

- ✅ Arquitetura orientada a **responsabilidade única**
- ✅ Uso de **TDD** com cobertura consistente
- ✅ API padronizada com contratos JSON bem definidos
- ✅ Controle de acesso por **roles (RBAC)**
- ✅ Otimização de queries (evitando N+1)
- ✅ Deploy real em ambiente cloud (Railway)

## Decisões de Arquitetura

### 🔹 Query Objects
Encapsulamento da lógica de busca em `EmployeeProfilesQuery`, evitando models inchados e facilitando testes isolados.

### 🔹 Autorização com Pundit
Separação clara entre regras de negócio e controle de acesso, permitindo escalabilidade e manutenção simples.

### 🔹 Serialização com Blueprinter
Controle explícito da exposição de dados, evitando vazamento de informações sensíveis e mantendo performance.

### 🔹 Otimização de Queries
Uso de `eager_load` para eliminar problemas de N+1 queries.

## Desafios e Soluções

### 🔸 Filtros dinâmicos combináveis
Implementação de múltiplos filtros (`search`, `status`, `department`, `sort`) sem acoplamento ou fragilidade.

### 🔸 Ordenação entre tabelas
Ordenação por atributos de tabelas relacionadas (ex: nome do usuário), resolvida com joins explícitos e controle de ambiguidade no PostgreSQL.

### 🔸 Deploy real
Configuração completa de ambiente com:
- variáveis seguras
- migrations automáticas
- pipeline funcional

## Stack Tecnológica

- **Ruby 3.4+ / Rails 8 (API mode)**
- **PostgreSQL**
- **JWT** (autenticação stateless)
- **Pundit** (autorização)
- **Blueprinter** (serialização)
- **RSpec** + **SimpleCov** (testes)

## Filtros Disponíveis (Employees)

A API suporta filtros dinâmicos via Query Params:

  * `search`: Busca textual por **Nome** ou **CPF**.
  * `status`: Filtra por `active` ou `inactive`.
  * `department` & `position`: Filtros por departamento ou cargo (case-insensitive).
  * `sort`: Ordenação dinâmica no formato `coluna:direção` (ex: `name:asc`, `created_at:desc`).

### Exemplo de uso:
```
GET /employees?search=joao&status=active&sort=name:asc
```

## Suíte de Testes (TDD)

O projeto segue abordagem **Test-Driven Development**, garantindo confiabilidade e evolução segura.

```bash
bundle exec rspec
```

  * **Request Specs**: Validação rigorosa dos contratos JSON e status HTTP.
  * **Policy Specs**: Testes unitários para garantir que cada Role acesse apenas o que lhe é permitido.

## Instalação Local

```bash
git clone https://github.com/tibas-ce/core_people_api.git
cd core_people_api
bundle install
cp .env.example .env # Configure suas credenciais
rails db:create db:migrate db:seed
rails server
```

## Documentação de Rotas

Para facilitar o teste da API, incluí coleção pronta para importação:

  * [Insomnia Export](./docs/insomnia_export.json)

## Caso de uso

Imagine um sistema de RH onde:

- Administradores gerenciam funcionários
- Managers visualizam suas equipes
- Funcionários acessam seus próprios dados

A API foi projetada para suportar esse cenário com segurança e escalabilidade.

## Qualidade e cobertura

- 239 testes automatizados
- 0 falhas
- 93%+ de cobertura de código
- Testes de:
  - Models
  - Policies (autorização)
  - Requests (API)
  - Services
  - Queries

Foco em TDD desde o início do projeto.

## Autor

**Tibério dos Santos Ferreira**

  * **GitHub:** [@tibas-ce](https://github.com/tibas-ce)
  * **LinkedIn:** [@Tibério Dos Santos Ferreira](https://www.linkedin.com/in/tiberio-ferreira/)

**Licença:** MIT