# PharmaPulse — Digital Pharmacy & Healthcare Commerce Platform

**PharmaPulse** is a full-stack digital pharmacy management and ordering platform built with a **FastAPI** backend and a **Flutter** cross-platform frontend. The system bridges pharmaceutical inventory, digital prescription verification, multi-tier customer loyalty, and order fulfillment workflows.

Designed and developed with a strong emphasis on **GoF Design Patterns**, **SOLID / GRASP** principles, and clean **RESTful** architecture.

---

## Key Features

### Client Portal
* **Medicine Catalog & Filtering:** Browse medicines, vitamins, and healthcare products with instant search by name or manufacturer, filtering by stock availability and prescription requirements, and sorting by price (ascending/descending).
* **Shopping Cart & Checkout:** Manage item quantities, choose between courier delivery or pharmacy branch pickup, and preview real-time loyalty discounts before placing an order.
* **Personal Cabinet:**
  * **Profile & Virtual Loyalty Card:** View loyalty tier (`Standard`, `Social`, `Premium`) and accumulated cashback balance.
  * **Order History:** Inspect past orders, cancel pending orders, or reorder in one click via the **Repeat Order** action.
  * **Saved Prescriptions:** Track digital prescriptions, issuing doctors, expiry dates, and verification statuses.
  * **Notifications Center:** View alerts for stock restocks, recurring medication reminders, and seasonal promotions.

### Pharmacist / Admin Dashboard
* **Order Processing:** View incoming orders and update statuses (`Pending`, `Processing`, `Ready`, `Completed`, `Cancelled`), automatically triggering stock synchronization, cashback calculation, and customer notifications.
* **Catalog Management:** Add new medicines directly to the catalog with pricing, stock levels, active substance, and prescription flags.

---

## Architecture & Design Patterns

The backend follows a modular architecture where business logic is decoupled from API controllers and database models using five classic **Gang of Four (GoF)** patterns:

| Pattern | Module | Purpose |
| :--- | :--- | :--- |
| **Builder** | `backend/app/patterns/builder.py` | Step-by-step construction of `Order` objects, validating prescription requirements and applying pricing before persistence. |
| **Strategy** | `backend/app/patterns/strategy.py` | Pluggable loyalty discount and delivery fee algorithms (`StandardLoyalty`, `SocialLoyalty`, `PremiumLoyalty`) adhering to the Open/Closed Principle. |
| **Observer** | `backend/app/patterns/observer.py` | Event-driven reaction to order status changes (`PharmacyStockSynchronizer`, `BonusAccumulatorObserver`, `CustomerNotificationDispatcher`). |
| **Factory Method** | `backend/app/patterns/factory.py` | Decoupled instantiation of notification channels (`EmailNotificationFactory`, `SmsNotificationFactory`) via a shared `INotifier` interface. |
| **Singleton** | `backend/app/core/database.py` | Thread-safe `DatabaseConnection` managing a single SQLAlchemy engine and session factory across the application. |

On the client side, **Flutter** uses the **BLoC / Cubit** pattern (`AuthCubit`, `CatalogCubit`, `CartCubit`, `CabinetCubit`, `AdminCubit`) paired with a **Repository** layer to ensure strict separation of concerns between UI widgets and HTTP networking.

---

## Tech Stack

* **Backend:** Python 3, FastAPI, SQLAlchemy ORM, Pydantic
* **Database:** SQLite (`pharmapulse.db`)
* **Frontend:** Flutter, Dart, `flutter_bloc` (Cubit), `http`
* **API & Documentation:** RESTful API, OpenAPI (Swagger UI), PlantUML (Use Case, Class, ER diagrams)

---

## Project Structure

```text
pharmapulse-platform/
├── docs/
│   └── diagrams/                 # PlantUML sources & exported UML/ER diagrams
├── backend/
│   ├── app/
│   │   ├── api/                  # REST API routers
│   │   │   ├── catalog.py        # Medicines & pharmacy branches endpoints
│   │   │   ├── orders.py         # Order creation & status management
│   │   │   └── users.py          # User profiles, prescriptions & loyalty data
│   │   ├── core/
│   │   │   ├── config.py         # Application settings
│   │   │   └── database.py       # Singleton DB connection & session provider
│   │   ├── models/
│   │   │   └── entities.py       # SQLAlchemy ORM models
│   │   ├── patterns/
│   │   │   ├── builder.py        # OrderBuilder (Builder pattern)
│   │   │   ├── factory.py        # NotificationFactory (Factory Method)
│   │   │   ├── observer.py       # OrderEventManager & subscribers (Observer)
│   │   │   └── strategy.py       # Loyalty discount strategies (Strategy)
│   │   ├── schemas/              # Pydantic DTOs for request/response validation
│   │   │   ├── medicine.py
│   │   │   ├── order.py
│   │   │   ├── pharmacy.py
│   │   │   └── user.py
│   │   └── main.py               # FastAPI entry point & observer registration
│   ├── requirements.txt
│   └── seed.py                   # Database seeding script (demo users, meds, branches)
└── frontend/
    └── lib/
        ├── cubits/               # State management (Auth, Catalog, Cart, Cabinet, Admin)
        ├── models/               # Dart data models
        ├── repositories/         # REST API clients (User, Catalog, Order)
        ├── screens/              # UI screens (Role Selection, Catalog, Cart, Cabinet, Admin)
        └── main.dart             # Flutter application entry point
```

---

## Key API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/catalog/medicines` | Retrieve all medicines in the catalog |
| `POST` | `/catalog/medicines` | Add a new medicine to the catalog |
| `GET` | `/catalog/branches` | Retrieve available pharmacy pickup branches |
| `POST` | `/orders/` | Create a new order (invokes `OrderBuilder` & `ILoyaltyStrategy`) |
| `GET` | `/orders/` | List orders for admin/history views |
| `PATCH` | `/orders/{order_id}/status` | Update order status (triggers `OrderEventManager` observers) |
| `GET` | `/users/{user_id}` | Fetch user profile, loyalty tier, bonuses, and prescriptions |

Interactive API documentation is available via Swagger UI at `http://127.0.0.1:8000/docs` once the server is running.

---

## Getting Started

### Prerequisites
* **Python 3.10+**
* **Flutter SDK 3.x** (with Web/Chrome support enabled)

### 1. Clone the Repository
```bash
git clone [https://github.com/Art-Invis/pharmapulse-platform.git](https://github.com/Art-Invis/pharmapulse-platform.git)
cd pharmapulse-platform
```

### 2. Run the Backend (FastAPI)
```bash
cd backend

# Create and activate a virtual environment
python -m venv venv
# Windows:
venv\Scripts\activate
# macOS / Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# (Optional) Populate the SQLite database with initial demo data
python seed.py

# Start the development server
uvicorn app.main:app --reload
```
The API will be available at `http://127.0.0.1:8000` (Swagger UI at `http://127.0.0.1:8000/docs`).

### 3. Run the Frontend (Flutter Web)
Open a new terminal window:
```bash
cd frontend

# Install Dart/Flutter dependencies
flutter pub get

# Launch the web application in Chrome
flutter run -d chrome
```

---

## Architecture Diagrams

System design diagrams (Use Case, ER Diagram, and UML Class Diagram highlighting all five GoF patterns) are located in the `docs/diagrams/` directory.