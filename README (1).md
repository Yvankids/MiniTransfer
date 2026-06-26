# MiniTransfer

A simplified mobile money transfer platform built as part of the TGB Solutions SARL technical test (Ref. TGB-TT-STG-FSJ-2026-001).

MiniTransfer allows users to register, log in, check their wallet balance, send money to other users, and view their transaction history — all from a Flutter mobile app backed by a Java/Spring Boot REST API and a MongoDB database.

---

## Technical Choices

### State Management — Flutter
Provider was used for state management. It was chosen for its simplicity, its first-party support from the Flutter team, and its suitability for an app of this scale without the overhead of Bloc or Riverpod.

### MongoDB Modelling
The balance is stored directly inside the `users` document (no separate `wallets` collection). This keeps reads simple — fetching a user's balance requires a single document lookup. Balance updates are performed using MongoDB's atomic `$inc` operator via `MongoTemplate` to prevent race conditions and ensure no money is created or lost during concurrent transfers.

Two collections are used:
- `users` — stores name, email, phone, hashed password, and balance (in FCFA as a `Long`)
- `transactions` — stores sender ID, receiver ID, amount, status, and timestamp

### Currency
All amounts are stored as integers in FCFA to avoid floating-point precision issues.

### Security
JWT tokens are issued on login and validated on every protected endpoint via a Spring Security filter chain. Passwords are hashed with BCrypt.

---

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

Launch the backend and MongoDB together in one command:
```bash
docker-compose up --build
```
This starts:
- MongoDB on port `27017`
- Spring Boot API on port `8080`

To stop:
```bash
docker-compose down
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

**Error responses:**
| Case | HTTP Code | Message |
|------|-----------|---------|
| Insufficient balance | `400` | `"Insufficient balance"` |
| Self-transfer | `400` | `"Cannot transfer to yourself"` |
| Amount ≤ 0 | `400` | `"Amount must be positive"` |
| Recipient not found | `404` | `"Receiver not found"` |

---

### GET /api/transfers/history
Get the full transaction history of the authenticated user (sent and received), sorted by most recent first.

**Response `200 OK`:**
```json
[
  {
    "id": "664f...",
    "senderId": "664f...",
    "receiverId": "664f...",
    "amount": 2500,
    "status": "SUCCESS",
    "createdAt": "2026-06-25T10:30:00"
  }
]
```

---

## Known Limits & Unfinished Features

- Failed transfers (rejected by business rules) are not saved to the `transactions` collection — only successful transfers are persisted. This is a deliberate design choice to keep the history clean, and is documented here for transparency.
- The app targets Android only; iOS was not tested.
- No automated tests (unit or integration) were written due to time constraints.
- Docker support is provided but was not the primary focus.

---

## Approximate Time Spent

| Phase | Time |
|-------|------|
| Backend (API, security, business logic) | ~3 days |
| Flutter (screens, navigation, API integration) | ~2 days |
| Debugging (CORS, balance update, emulator) | ~1 day |
| README & cleanup | ~2 hours |
| **Total** | **~6 days** |

---

## Project Structure

```
minitransfer/
├── backend/                  # Spring Boot project
│   ├── src/main/java/com/minitransfer/backend/
│   │   ├── config/           # Security & CORS configuration
│   │   ├── controller/       # REST controllers
│   │   ├── dto/              # Request/Response DTOs
│   │   ├── model/            # MongoDB documents (User, Transaction)
│   │   ├── repository/       # Spring Data repositories
│   │   ├── security/         # JWT filter & utilities
│   │   └── service/          # Business logic
│   ├── Dockerfile
│   └── pom.xml
├── mobile/                   # Flutter project
│   ├── lib/
│   │   ├── screens/          # Login, Register, Home, Transfer, History
│   │   ├── services/         # API service (HTTP calls)
│   │   └── main.dart
│   └── pubspec.yaml
├── docker-compose.yml
└── README.md
```

---

*Developed by Jorel — TGB Solutions SARL Technical Test — June 2026*
