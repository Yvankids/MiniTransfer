# MiniTransfer

A simplified mobile money transfer platform built as part of the TGB Solutions SARL technical test (Ref. TGB-TT-STG-FSJ-2026-001).

MiniTransfer allows users to register, log in, check their wallet balance, send money to other users, and view their transaction history — all from a Flutter mobile app backed by a Java/Spring Boot REST API and a MongoDB database.

---

## Project Focus

This project is intentionally scoped to deliver a complete, high-quality mobile + backend experience with a limited feature set. It emphasizes:
- a clean, maintainable architecture for the Flutter client and Spring Boot API,
- a working NoSQL data model with MongoDB and atomic balance updates,
- documented build and run steps including Docker support,
- a Postman collection for API validation,
- personal and original implementation without overly broad or unfinished features.

The result is a focused technical test submission where quality and correctness are prioritized over feature volume.

---

## Technical Choices

### State Management — Flutter
ValueNotifier and ValueListenableBuilder were used for state management. This approach provides a lightweight, reactive way to handle global states like Theme and Language without the overhead of external libraries.

### MongoDB Modelling
Balance modelling choice — stored inside the `users` document

For this technical test the balance is kept as a field on the `users` document (no separate `wallets` collection). Rationale:
- Simplicity: reading a user's balance requires a single document lookup which keeps client code and API responses simple.
- Atomic updates: balance changes are applied with MongoDB's `$inc` operator via `MongoTemplate`, which provides atomic increments and prevents money creation or loss under concurrent updates.
- Fit-for-purpose: for a small-scale mobile-money test app this avoids the complexity of maintaining a separate wallet collection and additional transactional logic.

Trade-offs:
- If the system were to scale to many wallets per user, or require complex ledger/audit requirements, a separate `wallets` or ledger collection would be preferable. That design is intentionally out-of-scope for this exercise.

Collections in the project:
- `users` — stores name, email, phone, hashed password, and `balance` (stored as an integer amount in FCFA)
- `transactions` — stores sender ID, receiver ID, amount, status, and timestamp

### Currency
All amounts are stored as integers in FCFA to avoid floating-point precision issues.

### Security
JWT tokens are issued on login and validated on every protected endpoint via a Spring Security filter chain. Passwords are hashed with BCrypt.

---

## Mobile App (Android priority)

This repository includes a Flutter mobile client targeting Android as the primary platform (iOS is provided as a bonus). Implementation notes and requirements:

- Screens (minimum):
  - **Register** (inscription)
  - **Login** (connexion)
  - **Home**: shows current `balance` and a prominent `Transfer` button
  - **Transfer form**: enter recipient (email or phone) and amount, confirm transfer
  - **Transactions history**: list of sent/received transactions, newest first

- State management: `ValueNotifier` and `ValueListenableBuilder` are used for global reactive state (theme, language, wallet). This choice keeps the app lightweight and easy to reason about for a small-scale project.

- Token storage: JWTs are stored securely on the device. Prefer `flutter_secure_storage` for production; `shared_preferences` may be used as a fallback for non-sensitive demo scenarios. Token storage lives under `mobile/storage/` in the codebase.

- UX and error handling:
  - API errors are surfaced to users via friendly messages (snackbars / dialogs).
  - Loading indicators are shown for network operations (transfers, auth, balance fetch).
  - Validation prevents invalid transfer amounts (≤ 0) and self-transfers before calling the API.

- Currency handling: amounts are integers in FCFA (no floating-point amounts) and the UI displays them formatted appropriately.


## Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Java (JDK) | 17 |
| Maven | 3.8+ |
| Flutter SDK | 3.10+ |
| MongoDB | 6.0+ |
| Docker & Docker Compose | 24+ (optional) |

---

## Installation & Launch

### Option A — Without Docker

#### 1. MongoDB
Make sure MongoDB is running locally on the default port:
```bash
mongod --port 27017
```

#### 2. Backend (Spring Boot)
```bash
cd backend
./mvnw spring-boot:run
```
The API will be available at `http://localhost:8080`.

#### 3. Flutter App
```bash
cd mobile
flutter pub get
flutter run
```
Make sure an Android emulator is running or a physical device is connected.

---

### Option B — With Docker (Bonus)

From the repository root, run:
```bash
docker-compose up --build
```

This composes:
- MongoDB on port `27017`
- Spring Boot API on port `8080`

Files added for Docker support:
- `docker-compose.yml` — compose definition at the repo root
- `backend/Dockerfile` — builds the backend image
- `.env.example` — sample environment variables for local development

The backend service reads MongoDB configuration from environment variables and uses the default database `minitransfer`.
To use the sample environment file, copy `.env.example` to `.env` before running Docker.
The Flutter mobile app is not containerized, so continue running it locally with `flutter run`.

To stop the containers:
```bash
docker-compose down
```

Example `docker-compose.yml` (illustratif):

```yaml
services:
  mongodb:
    image: mongo:6
    ports: ["27017:27017"]
  backend:
    build: ./backend
    ports: ["8080:8080"]
    depends_on: [mongodb]
```

---

## API Endpoints

Base URL: `http://localhost:8080`

All endpoints except `/api/auth/**` require the header:
```
Authorization: Bearer <token>
```

---

### POST /api/auth/register
Register a new user. A wallet with 10,000 FCFA is created automatically.

**Request:**
```json
{
  "name": "Jorel Nguemo",
  "email": "jorel@example.com",
  "phone": "699000000",
  "password": "secret123"
}
```

**Response `201 Created`:**
```json
{
  "id": "664f1a2b3c4d5e6f7a8b9c0d",
  "name": "Jorel Nguemo",
  "email": "jorel@example.com",
  "phone": "699000000",
  "balance": 10000
}
```

---

### POST /api/auth/login
Authenticate and receive a JWT token.

**Request:**
```json
{
  "email": "jorel@example.com",
  "password": "secret123"
}
```

**Response `200 OK`:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### GET /api/wallet/balance
Get the current balance of the authenticated user.

**Response `200 OK`:**
```json
{
  "balance": 10000
}
```

---

### POST /api/transfers
Send money to another user (identified by email or phone number).

**Request:**
```json
{
  "senderEmail": "jorel@example.com",
  "receiverEmail": "alice@example.com",
  "amount": 2500
}
```

**Response `200 OK`:**
```json
{
  "id": "664f1a2b3c4d5e6f7a8b9c0e",
  "senderId": "664f...",
  "receiverId": "664f...",
  "amount": 2500,
  "status": "SUCCESS",
  "createdAt": "2026-06-25T10:30:00"
}
```

---

### GET /api/transfers/history
Get the full transaction history of the authenticated user (sent and received), sorted by most recent first.

---

## Project Structure

```text
MiniTransfer/
├── README.md                 # This file
├── README_FR.md              # French README
├── docs/                     # Documentation
├── backend/                  # Java Spring Boot project wrapper
│   ├── backend/
│   │   ├── pom.xml
│   │   ├── mvnw
│   │   ├── mvnw.cmd
│   │   ├── Dockerfile         # Backend container build file
│   │   ├── src/main/java/com/minitransfer/backend/
│   │   │   ├── config/
│   │   │   ├── controller/
│   │   │   ├── dto/
│   │   │   ├── model/
│   │   │   ├── repository/
│   │   │   ├── security/
│   │   │   └── service/
│   │   ├── src/test/
│   │   └── src/main/resources/
│   │       └── application.properties
│   ├── postman/
│   │   ├── collections/
│   │   ├── environments/
│   │   ├── flows/
│   │   ├── globals/
│   │   ├── mocks/
│   │   └── specs/
│   └── target/
├── mobile/                   # Flutter app
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── devtools_options.yaml
│   ├── README.md
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── macos/
│   ├── linux/
│   ├── build/
│   └── test/
├── docker-compose.yml        # Compose for backend + MongoDB
└── .gitignore
```

---

*Developed by OMBANG Yvan Jorel — TGB Solutions SARL Technical Test — June 2026*

---

## Known Limits & Unfinished Features

- Failed transfers rejected by business rules are not saved to the `transactions` collection — only successful transfers are persisted. This was a deliberate choice to keep the history concise, but it means some failure cases are not recorded for audit.
- The app was primarily tested on Android; iOS support is included but not fully validated on real hardware.
- No comprehensive automated test suite (unit/integration) exists for the backend or mobile app due to time constraints.
- Advanced features such as multi-wallet support, a full ledger, idempotency keys for API calls, rate limiting, and high-availability deployment were intentionally left out of scope.

Honesty about limitations is intentional: the submission favors a small, well-documented, and correct surface over an unfinished large feature set.

## Approximate Time Spent

| Phase | Time |
|-------|------|
| Backend (API, security, business logic) | ~3 days |
| Flutter (screens, navigation, API integration) | ~2 days |
| Debugging (CORS, balance update, emulator) | ~1 day |
| README & cleanup | ~2 hours |
| **Total** | **~6 days** |

