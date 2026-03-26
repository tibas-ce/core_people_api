> ⚠️ **Projeto de Estudos**
> Este projeto tem foco educacional e de portfólio, priorizando clareza de regras de negócio, organização de código e boas práticas de teste.

<div align="center">

# CORE PEOPLE API

</div>

![Coverage](https://img.shields.io/badge/coverage-95.7%25-brightgreen)
![Rails](https://img.shields.io/badge/rails-8.0.4-red)
![Ruby](https://img.shields.io/badge/ruby-3.4.5-red)

---

# 🏢 Core People API - HR Management System

API RESTful para gerenciamento de recursos humanos, desenvolvida com Ruby on Rails em modo API, com foco em regras de negócio, organização e testabilidade.

---

## 🚀 Tecnologias Utilizadas

* Ruby 3.4.5+
* Rails 8.0.4+ (API mode)
* PostgreSQL
* JWT (autenticação)
* Pundit (autorização)
* Blueprinter (serialização JSON)
* RSpec (testes)
* FactoryBot
* SimpleCov (cobertura de testes)
* brazilian_docs (validação de CPF - gem própria)

---

## 📦 Pré-requisitos

* Ruby 3.4.5 ou superior
* PostgreSQL 12+
* Bundler

---

## 🔧 Instalação

```bash
git clone https://github.com/tibas-ce/core_people_api.git
cd core_people_api
bundle install
cp .env.example .env
```

Configure o `.env`:

```env
DATABASE_USERNAME=seu_usuario
DATABASE_PASSWORD=sua_senha
DATABASE_HOST=localhost
JWT_SECRET_KEY=sua_chave_secreta
```

Gerar chave JWT:

```bash
rails secret
```

Banco de dados:

```bash
rails db:create
rails db:migrate
rails db:seed
```

---

## 🏃 Executando

```bash
rails server
```

## 🌐 Base URL

http://localhost:3000/api/v1

---

## 🧪 Testes

```bash
bundle exec rspec
```

- 234 exemplos
- 0 falhas
- Cobertura: ~95.7% (SimpleCov)

O projeto segue uma abordagem baseada em TDD,
com testes cobrindo:

- models (validações e regras de domínio)
- policies (autorização)
- requests (contrato da API)
- services (JWT)
- serializers (blueprints)
- concerns (filtros e autenticação)

---

## 🔐 Autenticação

A API utiliza JWT (JSON Web Tokens) para autenticação stateless.

Header:

```
Authorization: Bearer {token}
```

Tokens expiram em 24h.

---

## 📚 Endpoints Principais

### Auth

* `POST /signup`
* `POST /login`
* `GET /me`

---

### Roles

* `GET /roles`
* `GET /users/:user_id/role`
* `PUT /users/:user_id/role`

---

### Employees

* `GET /employees`
* `GET /employees/:id`
* `GET /employees/me`
* `POST /employees`
* `PUT /employees/:id`
* `DELETE /employees/:id`

---

## 🔎 Filtros disponíveis (Employees)

* `search` (nome ou CPF)
* `status`
* `department`
* `position`
* `sort`

---

## 🔐 Sistema de Roles

| Role     | Descrição       |
| -------- | --------------- |
| admin    | Acesso total    |
| hr       | Gestão de RH    |
| manager  | Acesso limitado |
| employee | Acesso próprio  |

---

## 📊 Matriz de Permissões

| Ação                         | admin |  hr | manager | employee |
| ---------------------------- | :---: | :-: | :-----: | :------: |
| Listar funcionários          |   ✅   |  ✅  |    ✅    |     ❌    |
| Ver qualquer perfil          |   ✅   |  ✅  |    ❌    |     ❌    |
| Ver próprio perfil           |   ✅   |  ✅  |    ✅    |     ✅    |
| Criar funcionário            |   ✅   |  ✅  |    ❌    |     ❌    |
| Atualizar qualquer campo     |   ✅   |  ✅  |    ❌    |     ❌    |
| Atualizar próprio (limitado) |   ✅   |  ✅  |    ✅    |     ✅    |
| Desativar funcionário        |   ✅   |  ✅  |    ❌    |     ❌    |

---

## 🔄 Exemplo de Fluxo

1. Usuário cria conta (`signup`)
2. Recebe role padrão `employee`
3. HR cria perfil de funcionário
4. Admin pode alterar roles
5. Usuários acessam dados conforme permissões

---

## 📁 Estrutura

```text
app/
├── controllers/
├── models/
├── policies/
├── services/
├── blueprints/

spec/
├── models/
├── requests/
├── policies/
├── services/
```

---

## 🧠 Decisões de Arquitetura

- **User sempre possui um Role**
  → evita estados inválidos e simplifica autorização

- **Autorização via Pundit**
  → regras centralizadas e testáveis

- **Serialização com Blueprinter**
  → controle explícito de exposição de dados

- **Filtros isolados em concern**
  → reutilização e testabilidade

- **Soft delete para employees**
  → preservação de histórico

---

## ⚠️ Limitações Conhecidas

Por ser um projeto educacional, algumas simplificações foram adotadas:

* não há rate limiting
* não há refresh tokens
* não há paginação em listagens
* não há auditoria de alterações

Essas limitações foram mantidas intencionalmente para priorizar
clareza de arquitetura e foco em regras de negócio.

---

## 🚀 Possíveis Evoluções

### 🔐 Segurança

* refresh tokens
* logout (blacklist de tokens)
* rate limiting

### 📦 API

* paginação em endpoints
* padronização de erros
* versionamento mais robusto

### 🧠 Regras de Negócio

* escopo de manager por equipe/departamento
* permissões mais granulares
* auditoria de alterações

### 📄 Documentação

* OpenAPI / Swagger
* fluxos completos da API

---

## 🐛 Troubleshooting

**401 Unauthorized**
Token inválido ou expirado → faça login novamente

**403 Forbidden**
Sem permissão → verifique seu role

**422 Unprocessable Entity**
Dados inválidos → revise payload

---

## 📝 Notas

* endpoints protegidos requerem autenticação
* tokens expiram em 24h
* email é case-insensitive
* senha mínima de 6 caracteres

---

## 👤 Autor

Tibério dos Santos Ferreira
GitHub: @tibas-ce

---

## 📄 Licença

MIT
