> ⚠️ **Projeto de Estudos**  
> Este projeto tem foco educacional e de portfólio, priorizando clareza de regras de negócio, organização de código e boas práticas de teste.


<div align="center">

# CORE PEOPLE API

</div>

![Tests](https://img.shields.io/badge/tests-88%20passing-brightgreen)
![Rails](https://img.shields.io/badge/rails-8.0.4-red)
![Ruby](https://img.shields.io/badge/ruby-3.4.5-red)


# 🏢 Sistema de Gerenciamento de RH - API

API RESTful para gerenciamento de recursos humanos, desenvolvida com Ruby on Rails 8.0.4 em modo API, seguindo práticas de TDD (Test-Driven Development).

---

## 🚀 Tecnologias Utilizadas

- Ruby 3.4.5+
- Rails 8.0.4+ (API mode)
- PostgreSQL (banco de dados)
- JWT (autenticação)
- Pundit (autorização)
- RSpec (testes)
- FactoryBot (fixtures de teste)
- SimpleCov (cobertura de testes)

### 📦 Pré-requisitos

- Ruby 3.4.5 ou superior
- PostgreSQL 12 ou superior
- Bundler

---

## 🔧 Instalação

1. Clonar o repositório
```bash
git clone https://github.com/seu-usuario/minha-api.git
cd minha-api
```
2. Instalar dependências
```bash
bundle install
```
3. Configurar variáveis de ambiente

Copie o arquivo de exemplo:
```bash
cp .env.example .env
```
Edite o arquivo `.env` e configure:
```bash
DATABASE_USERNAME=seu_usuario_postgres
DATABASE_PASSWORD=sua_senha_postgres
DATABASE_HOST=localhost
JWT_SECRET_KEY=sua_chave_secreta_jwt
```
Para gerar uma chave JWT segura:
```bash
rails secret
```
4. Criar e configurar banco de dados
```bash
rails db:create
rails db:migrate
```
5. (Opcional) Popular com dados de exemplo
```bash
rails db:seed
```
### 🏃 Rodando o Projeto
Servidor de desenvolvimento
```bash
rails server
```
A API estará disponível em: http://localhost:3000

### Rodar testes
#### Todos os testes
```bash
bundle exec rspec
```
#### Testes específicos
```bash
bundle exec rspec spec/models
bundle exec rspec spec/requests
```
#### Com cobertura
```bash
bundle exec rspec
open coverage/index.html
```

---

## 📚 Documentação da API

#### Endpoints Principais
Autenticação

- POST /api/v1/signup - Criar conta
- POST /api/v1/login - Fazer login
- GET /api/v1/me - Dados do usuário logado

Roles (Permissões)

- GET /api/v1/roles - Listar roles
- GET /api/v1/users/:id/role - Ver role de usuário
- PUT /api/v1/users/:id/role - Atualizar role (admin)

Utilitários

- GET /api/v1/health - Health check

#### 🔐 Sistema de Roles
A API implementa 4 níveis de acesso:
| Role     | Descrição        | Permissões                                          |
|----------|------------------|-----------------------------------------------------|
| admin    | Administrador    | Acesso total ao sistema                             |
| hr       | Recursos Humanos | Gerenciar funcionários e ver dados sensíveis        |
| manager  | Gerente          | Gerenciar sua equipe e aprovar solicitações         |
| employee | Funcionário      | Acessar apenas seus próprios dados                  |

---

## 🧪 Testes
O projeto segue TDD rigoroso com:

- ✅ Testes de modelo (validações, associações)
- ✅ Testes de request (endpoints)
- ✅ Testes de policies (autorização)
- ✅ Testes de services (lógica de negócio)

Cobertura acima de 90%

---

## 📁 Estrutura do Projeto
```text
app/
├── controllers/
│   ├── concerns/
│   │   └── authenticable.rb       # Middleware de autenticação
│   └── api/v1/
│       ├── authentication_controller.rb
│       ├── roles_controller.rb
│       └── health_controller.rb
├── models/
│   ├── user.rb                    # Usuário + autenticação
│   └── role.rb                    # Roles e permissões
├── policies/
│   ├── application_policy.rb
│   └── role_policy.rb             # Regras de autorização
└── services/
    └── json_web_token.rb          # Encode/decode JWT

spec/
├── factories/                     # Fixtures para testes
├── models/                        # Testes de modelos
├── requests/                      # Testes de API
└── services/                      # Testes de services
```

---

## 🧠 Decisões de Arquitetura

### User sempre possui um Role
Todo usuário é criado automaticamente com um role padrão (`employee`).
Essa decisão evita estados inválidos no sistema e simplifica a lógica
de autorização, eliminando verificações defensivas espalhadas pelo código.

Essa regra é garantida por:
- callback no modelo `User`
- testes de integração
- policies baseadas exclusivamente em `Role`

### Controllers enxutos, regras nas Policies
Os controllers não contêm lógica de permissão.
Eles apenas:
- carregam recursos
- delegam autorização às policies
- retornam respostas HTTP

Isso mantém o código mais legível, testável e fácil de evoluir.

---

## 🔐 Autorização com Pundit

O controle de acesso é feito com Pundit, utilizando policies explícitas
para cada ação sensível do sistema.

As permissões são baseadas em:
- tipo de role (`admin`, `hr`, `manager`, `employee`)
- ownership (usuário acessando seus próprios dados)

Benefícios dessa abordagem:
- regras centralizadas e claras
- fácil escrita de testes de autorização
- alinhamento direto entre código, regras de negócio e testes

---

## 🧪 Estratégia de Testes

O projeto segue uma abordagem de TDD, priorizando testes de comportamento
em vez de testes acoplados à implementação.

Cobertura por camada:
- **Models**: validações, associações e regras de domínio
- **Policies**: autorização baseada em role e ownership
- **Requests**: autenticação, autorização e contrato da API
- **Services**: lógica isolada (JWT)

Essa estratégia permite refatorações seguras
sem quebra de regras de negócio.

---

## ⚠️ Limitações Conhecidas

Por se tratar de um projeto de estudos, alguns pontos foram deixados fora
intencionalmente:

- não há rate limiting
- não há refresh tokens para JWT
- não há auditoria de alterações de role
- não há controle de permissões por recurso específico

Esses pontos são considerados próximos passos naturais
em um ambiente de produção.

---

## 🌐 Base URL
> http://localhost:3000/api/v1

### 🔐 Autenticação
A API usa JWT (JSON Web Tokens) para autenticação.
Como autenticar

Faça login ou signup para receber um token
Inclua o token no header de todas as requisições protegidas:
```bash
Authorization: Bearer seu_token_jwt_aqui
Expiração
```
Tokens expiram em 24 horas

Após expirar, faça login novamente para obter novo token


### 📋 Endpoints

#### 🔓 Autenticação
1. Criar Conta (Signup)

Cria uma nova conta de usuário.

Endpoint: `POST /signup`

Headers:
```
Content-Type: application/json`
```
Body:
```json
{
  "user": {
    "name": "João Silva",
    "email": "joao@exemplo.com",
    "password": "senha123",
    "password_confirmation": "senha123"
  }
}
```
Resposta de Sucesso (201):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@exemplo.com",
    "role": "employee",
    "created_at": "2024-12-08T10:30:00.000Z"
  }
}
```

Erros Possíveis:

- 422 Unprocessable Entity - Validação falhou
```json
{
  "errors": [
    "Email já está em uso",
    "Senha é muito curta (mínimo: 6 caracteres)"
  ]
}
```
2. Login
Autentica um usuário existente.

Endpoint: `POST /login`

Headers:

`Content-Type: application/json`

Body:
```json
{
  "email": "joao@exemplo.com",
  "password": "senha123"
}
```
Resposta de Sucesso (200):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@exemplo.com",
    "role": "employee",
    "created_at": "2024-12-08T10:30:00.000Z"
  }
}
```
Erros Possíveis:

401 Unauthorized - Credenciais inválidas
```json
{
  "error": "Email ou senha inválidos"
}
```
400 Bad Request - Parâmetros faltando
```json
{
  "error": "Email e senha são obrigatórios"
}
```
3. Dados do Usuário Logado
Retorna os dados do usuário autenticado.

Endpoint: `GET /me`

Headers:
```
Authorization: Bearer seu_token_aqui
```
Resposta de Sucesso (200):
```json
{
  "user": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@exemplo.com",
    "role": "employee",
    "created_at": "2024-12-08T10:30:00.000Z"
  }
}
```
Erros Possíveis:

401 Unauthorized - Token inválido ou expirado
```json
{
  "error": "Token inválido ou expirado"
}
```
#### 👥 Roles (Permissões)
4. Listar Todos os Roles

Lista todos os roles do sistema com resumo.

Endpoint: `GET /roles`

Permissão: `admin` ou `hr`

Headers:
```
Authorization: Bearer token_do_admin_ou_hr
```
Resposta de Sucesso (200):
```json
{
  "roles": [
    {
      "id": 1,
      "name": "admin",
      "user_id": 1,
      "user_name": "Admin User",
      "user_email": "admin@exemplo.com",
      "created_at": "2024-12-08T10:00:00.000Z",
      "updated_at": "2024-12-08T10:00:00.000Z"
    },
    {
      "id": 2,
      "name": "employee",
      "user_id": 2,
      "user_name": "João Silva",
      "user_email": "joao@exemplo.com",
      "created_at": "2024-12-08T10:30:00.000Z",
      "updated_at": "2024-12-08T10:30:00.000Z"
    }
  ],
  "summary": {
    "total": 10,
    "admins": 1,
    "hrs": 2,
    "managers": 3,
    "employees": 4
  }
}
```
Erros Possíveis:

403 Forbidden - Usuário não tem permissão
```json
{
  "error": "Você não tem permissão para realizar esta ação"
}
```
5. Ver Role de um Usuário

Retorna o role de um usuário específico.

Endpoint: `GET /users/:user_id/role`

Permissão:

`admin` e `hr` podem ver qualquer role
`employee` pode ver apenas seu próprio role

Headers:
```
Authorization: Bearer seu_token
```
Resposta de Sucesso (200):
```json
{
  "role": {
    "id": 2,
    "name": "employee",
    "user_id": 2,
    "user_name": "João Silva",
    "user_email": "joao@exemplo.com",
    "created_at": "2024-12-08T10:30:00.000Z",
    "updated_at": "2024-12-08T10:30:00.000Z"
  }
}
```
Erros Possíveis:

404 Not Found - Usuário não encontrado

403 Forbidden - Sem permissão para ver este role


6. Atualizar Role de um Usuário

Atualiza o role de um usuário.

Endpoint: `PUT /users/:user_id/role`

Permissão: Apenas `admin`

Headers:
```
Authorization: Bearer token_do_admin
Content-Type: application/json
```
Body:
```json
{
  "role": {
    "name": "manager"
  }
}
```
Valores permitidos para `role: name`:

`"admin"`

`"hr"`

`"manager"`

`"employee"`

Resposta de Sucesso (200):
```json
{
  "role": {
    "id": 2,
    "name": "manager",
    "user_id": 2,
    "user_name": "João Silva",
    "user_email": "joao@exemplo.com",
    "created_at": "2024-12-08T10:30:00.000Z",
    "updated_at": "2024-12-08T11:00:00.000Z"
  },
  "message": "Role atualizado com sucesso"
}
```
Erros Possíveis:

422 Unprocessable Entity - Role inválido
```json
{
  "errors": [
    "Name não está incluído na lista"
  ]
}
```
403 Forbidden - Usuário não é admin


#### 🏥 Utilitários

7. Health Check

Verifica se a API está funcionando.

Endpoint: `GET /health`

Headers: Nenhum (endpoint público)
Resposta (200):
```json
{
  "status": "ok",
  "timestamp": "2024-12-08T12:00:00Z"
}
```

---

## 📊 Códigos de Status HTTP

HTTP Status Codes: https://httpstatuses.com/

## 🔐 Matriz de Permissões

| Ação / Role                 | admin | hr  | manager | employee |
|-----------------------------|:-----:|:---:|:-------:|:--------:|
| Criar conta                 | ✅    | ✅  | ✅      | ✅       |
| Login                       | ✅    | ✅  | ✅      | ✅       |
| Ver próprios dados          | ✅    | ✅  | ✅      | ✅       |
| Listar todos os roles       | ✅    | ✅  | ❌      | ❌       |
| Ver role de qualquer usuário| ✅    | ✅  | ❌      | ❌       |
| Ver próprio role            | ✅    | ✅  | ✅      | ✅       |
| Atualizar role              | ✅    | ❌  | ❌      | ❌       |

---

## 🧪 Exemplos com cURL
Criar conta

```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "João Silva",
      "email": "joao@exemplo.com",
      "password": "senha123",
      "password_confirmation": "senha123"
    }
  }'
```
Login

```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@exemplo.com",
    "password": "senha123"
  }'
```
Ver meus dados (com token)

```bash
curl http://localhost:3000/api/v1/me \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
Atualizar role (admin apenas)
bashcurl -X PUT http://localhost:3000/api/v1/users/5/role \
  -H "Authorization: Bearer TOKEN_DO_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{
    "role": {
      "name": "manager"
    }
  }'
```

---

## 📝 Notas Importantes

1. Todos os endpoints (exceto signup, login e health) requerem autenticação
2. Tokens JWT expiram em 24 horas
3. Novos usuários recebem automaticamente o role employee
4. Email é case-insensitive (JOAO@exemplo.com = joao@exemplo.com)
5. Senha mínima de 6 caracteres

---

## 📘 Aprendizados

Durante o desenvolvimento deste projeto, foram consolidados aprendizados como:

- modelagem de permissões baseada em regras de negócio reais
- uso de policies para evitar lógica de autorização em controllers
- escrita de testes de autorização e integração
- desenho de APIs REST com autenticação via JWT
- importância de evitar estados inválidos no domínio (ex: usuário sem role)

O foco foi menos em quantidade de features
e mais em qualidade, clareza e testabilidade.

---

## 🚀 Possíveis Evoluções

Possíveis evoluções para o projeto:

- implementar refresh tokens e logout
- adicionar rate limiting
- criar histórico/auditoria de mudanças de role
- versionamento de API
- documentação automática com OpenAPI / Swagger
- permissões mais granulares por recurso

As evoluções acima representam estudo e planejamento,
não compromissos de implementação.

---

## 🐛 Troubleshooting
#### Token expirado

Erro: 401 Unauthorized - Token inválido ou expirado

Solução: Faça login novamente para obter novo token
#### Sem permissão
Erro: 403 Forbidden

Solução: Verifique se seu role tem permissão para esta ação

#### Email já existe

Erro: 422 - Email já está em uso

Solução: Use um email diferente ou faça login se já tem conta

---

## 🔄 Workflow de Desenvolvimento
Este projeto segue:

- TDD (Test-Driven Development)
- Git Flow simplificado
- Conventional Commits

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

---

## 👤 Autor
Tibério dos Santos Ferreira

GitHub: @tibas-ce
Email: tiberio.ferreiracs@gmail.com

---

## 📄 Licença
Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.