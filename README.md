# API JWT + RBAC e App Flutter

Este repositório contém duas pastas:

- `api_rest_server/`: API Node.js com autenticação JWT e RBAC (ADMIN/USER)
- `api_rest/`: App Flutter que consome a API (login, splash, RBAC, CRUD de cursos e administração de usuários)

Requisitos mínimos:
- Node.js 18+
- Flutter 3.6+

---

## 1) Como rodar a API (api_rest_server)

Dentro de `api_rest_server/`:

```
npm install
npm run dev
```

A API sobe em `http://localhost:3000`.

Usuário ADMIN (seed):
- email: `admin@email.com`
- senha: `admin123`

Rotas principais:
- `POST /login` → retorna `{ token }`
- `GET /me` (Auth)
- `GET /users` (ADMIN)
- `POST /users` (ADMIN)
- `GET /users/:id` (ADMIN)
- `PUT /users/:id` (ADMIN)
- `DELETE /users/:id` (ADMIN)
- `GET /courses` (pública)
- `POST /courses` (Auth)
- `PUT /courses/:id` (dono ou ADMIN)
- `DELETE /courses/:id` (dono ou ADMIN)
- `GET /admin` (ADMIN)

Observações:
- CORS está habilitado.
- O “banco” é em memória (reiniciar o servidor limpa os dados). O usuário ADMIN seedado é recriado a cada início.

---

## 2) Como rodar o App Flutter (api_rest)

Dentro de `api_rest/`:

```
flutter pub get
flutter run
```

Para rodar no Chrome:
```
flutter run -d chrome
```

### Base URL (configuração automática)
O app resolve a `baseUrl` em tempo de execução (arquivo `lib/core/api_client.dart`):
- Web: usa o mesmo host do app web e porta `3000` (ex.: `http://localhost:3000`).
- Emulador Android: usa `http://10.0.2.2:3000` para alcançar o `localhost` do computador.
- Dispositivo físico: se necessário, altere o `baseUrl` para o IP da máquina (ex.: `http://192.168.0.10:3000`).

### Fluxo do app
- Splash (`lib/screens/splash_screen.dart`): verifica token salvo e tenta usar um cache do `/me` para redireciono imediato; atualiza `/me` em background.
- Login (`lib/screens/login_screen.dart`): valida e-mail/senha, chama `/login`, salva token e chama `/me` (cacheado). Redireciona por papel:
  - ADMIN → `AdminScreen`
  - USER → `UserScreen`
- Admin:
  - Botão para `Usuários (ADMIN)` → CRUD completo sobre `/users`.
  - Botão para `CRUD de Cursos`.
- User:
  - Acesso a `Cursos` (lista pública; criar/editar/excluir conforme regras da API).
- Logout limpa token e cache local.

---

## 3) Teste rápido
1. Inicie a API: `npm run dev` em `api_rest_server/`.
2. Rode o app: `flutter run -d chrome` em `api_rest/`.
3. Login com:
   - email: `admin@email.com`
   - senha: `admin123`
4. Acesse as telas de Administração de Usuários e CRUD de Cursos.

---

## 4) Estrutura principal de código
- App Flutter
  - `lib/core/api_client.dart` (Dio + interceptor + baseUrl dinâmica)
  - `lib/core/token_storage.dart` (SharedPreferences)
  - `lib/core/user_cache.dart` (cache de `/me`)
  - `lib/models/` (`user.dart`, `course.dart`)
  - `lib/repositories/` (`auth_repository.dart`, `course_repository.dart`, `user_repository.dart`)
  - `lib/screens/` (splash, login, admin, user, courses, users/*)
- API Node
  - `src/server.js` (rotas)
  - `src/auth.js` (JWT e middlewares)
  - `src/db.js` (dados em memória)

---

## 5) Ajustes comuns
- Porta da API: altere em `src/server.js` (`PORT`) e reinicie.
- Base URL fixa: se preferir, troque a função `_resolveBaseUrl()` em `lib/core/api_client.dart` por uma constante.
