# MiniTransfer 🚀

Une plateforme simplifiée de transfert d'argent mobile construite dans le cadre du test technique TGB Solutions SARL (Réf. TGB-TT-STG-FSJ-2026-001).

MiniTransfer permet aux utilisateurs de s'inscrire, de se connecter, de consulter le solde de leur portefeuille, d'envoyer de l'argent à d'autres utilisateurs et de consulter leur historique de transactions — le tout depuis une application mobile Flutter premium, propulsée par une API REST Java/Spring Boot et une base de données MongoDB.

---

## Choix Techniques

### Gestion d'État — Flutter
`ValueNotifier` et `ValueListenableBuilder` ont été utilisés pour la gestion d'état. Cette approche offre un moyen léger et réactif de gérer les états globaux comme le Thème et la Langue sans la complexité de bibliothèques externes.

### Modélisation MongoDB
Le solde est stocké directement dans le document `users` (pas de collection `wallets` séparée). Cela simplifie les lectures — la récupération du solde d'un utilisateur nécessite une seule recherche de document. Les mises à jour du solde sont effectuées à l'aide de l'opérateur atomique `$inc` de MongoDB via `MongoTemplate` pour éviter les conditions de concurrence et garantir qu'aucun argent n'est créé ou perdu lors de transferts simultanés.

Deux collections sont utilisées :
- `users` — stocke le nom, l'email, le téléphone, le mot de passe haché et le solde (en FCFA en tant que `Long`)
- `transactions` — stocke l'ID de l'expéditeur, l'ID du destinataire, le montant, le statut et l'horodatage

### Devise
Tous les montants sont stockés sous forme d'entiers en FCFA pour éviter les problèmes de précision liés aux nombres à virgule flottante.

### Sécurité
Des jetons JWT sont émis lors de la connexion et validés sur chaque point de terminaison protégé via une chaîne de filtres Spring Security. Les mots de passe sont hachés avec BCrypt.

---

## Prérequis

| Outil | Version Minimale |
|-------|------------------|
| Java (JDK) | 17 |
| Maven | 3.8+ |
| Flutter SDK | 3.10+ |
| MongoDB | 6.0+ |
| Docker & Docker Compose | 24+ (optionnel) |

---

## Installation & Lancement

### Option A — Sans Docker

#### 1. MongoDB
Assurez-vous que MongoDB fonctionne localement sur le port par défaut :
```bash
mongod --port 27017
```

#### 2. Backend (Spring Boot)
```bash
cd backend
./mvnw spring-boot:run
```
L'API sera disponible sur `http://localhost:8080`.

#### 3. Application Flutter
```bash
cd mobile
flutter pub get
flutter run
```
Assurez-vous qu'un émulateur Android est en cours d'exécution ou qu'un appareil physique est connecté.

---

### Option B — Avec Docker (Bonus)

Lancez le backend et MongoDB ensemble avec une seule commande :
```bash
docker-compose up --build
```
Cela démarre :
- MongoDB sur le port `27017`
- API Spring Boot sur le port `8080`

Pour arrêter :
```bash
docker-compose down
```

---

## Points de terminaison API (Endpoints)

URL de base : `http://localhost:8080`

Tous les points de terminaison, sauf `/api/auth/**`, nécessitent l'en-tête :
```
Authorization: Bearer <token>
```

---

### POST /api/auth/register
Enregistrer un nouvel utilisateur. Un portefeuille avec 10 000 FCFA est créé automatiquement.

**Requête :**
```json
{
  "name": "Jorel Nguemo",
  "email": "jorel@example.com",
  "phone": "699000000",
  "password": "secret123"
}
```

**Réponse `201 Created` :**
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
S'authentifier et recevoir un jeton JWT.

**Requête :**
```json
{
  "email": "jorel@example.com",
  "password": "secret123"
}
```

**Réponse `200 OK` :**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### GET /api/wallet/balance
Obtenir le solde actuel de l'utilisateur authentifié.

**Réponse `200 OK` :**
```json
{
  "balance": 10000
}
```

---

### POST /api/transfers
Envoyer de l'argent à un autre utilisateur (identifié par email ou numéro de téléphone).

**Requête :**
```json
{
  "senderEmail": "jorel@example.com",
  "receiverEmail": "alice@example.com",
  "amount": 2500
}
```

**Réponse `200 OK` :**
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
Obtenir l'historique complet des transactions de l'utilisateur authentifié (envoyées et reçues), trié par date décroissante.

---

## Structure du Projet

```text
minitransfer/
├── backend/                  # Projet Spring Boot
│   ├── src/main/java/com/minitransfer/backend/
│   │   ├── config/           # Configuration Sécurité & CORS
│   │   ├── controller/       # Contrôleurs REST (Auth, Wallet, Transfer)
│   │   ├── dto/              # Objets de Transfert de Données (DTO)
│   │   ├── model/            # Documents MongoDB (User, Transaction)
│   │   ├── repository/       # Répertoires Spring Data MongoDB
│   │   ├── security/         # Filtre JWT & utilitaires
│   │   └── service/          # Services de logique métier
│   ├── Dockerfile
│   └── pom.xml
├── mobile/                   # Application Mobile Flutter
│   ├── lib/
│   │   ├── config/           # Constantes et configuration statique
│   │   ├── models/           # Modèles de données (User, Transaction, etc.)
│   │   ├── screens/          # Écrans UI (Welcome, Login, Home, etc.)
│   │   ├── services/         # Services API, Langue, Thème et Portefeuille
│   │   ├── storage/          # Persistance locale (TokenStorage)
│   │   ├── widgets/          # Composants UI réutilisables & Logo redessiné
│   │   └── main.dart         # Point d'entrée & fournisseurs de Thème/Locale
│   └── pubspec.yaml
├── docker-compose.yml
└── README.md
```

---

*Développé par OMBANG Yvan Jorel — Test Technique TGB Solutions SARL — Juin 2026*
