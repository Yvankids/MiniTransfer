# MiniTransfer

A simplified mobile money transfer platform built as part of the TGB Solutions SARL technical test (Ref. TGB-TT-STG-FSJ-2026-001).

MiniTransfer allows users to register, log in, check their wallet balance, send money to other users, and view their transaction history — all from a Flutter mobile app backed by a Java/Spring Boot REST API and a MongoDB database.

---

## Technical Choices

### State Management — Flutter
ValueNotifier and ValueListenableBuilder were used for state management. This approach provides a lightweight, reactive way to handle global states like Theme and Language without the overhead of external libraries.

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

From the repository root, run:
```bash
docker-compose up --build
```

This composes:
- MongoDB on port `27017`
- Spring Boot API on port `8080`

The backend image is built from `backend/backend/Dockerfile`.
The Flutter mobile app is not containerized, so continue running it locally with `flutter run`.

To stop the containers:
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

---

### GET /api/transfers/history
Get the full transaction history of the authenticated user (sent and received), sorted by most recent first.

---

## Project Structure

```text
MiniTransfer/
├── README (1).md             # This file
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
