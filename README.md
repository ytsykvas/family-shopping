# 🛒 Family Shopping

A sophisticated collaborative shopping list and wishlist management application for families and friends. Designed with a modern architecture, it ensures seamless coordination for household needs and gift-giving.

## 📱 Project Overview

**Family Shopping** is a full-stack Rails application built for real-world family collaboration. It moves beyond simple lists, offering a robust friendship system, shared shopping lists with invitation workflows, and collaborative wishlists where users can "book" items they intend to gift.

### 🏗 Architecture & Design Patterns

The project follows a modern, component-based architecture to ensure maintainability and scalability:

- **Operations-Based Business Logic**: All business logic is encapsulated in **Operations** located in `app/concepts/*/operation`. This keeps models thin and controllers focused only on request/response handling.
- **ViewComponents & Slim**: The UI is built using **ViewComponents** and **Slim** templates, providing a clean, reusable, and testable frontend structure (`app/concepts/*/component`).
- **Grape API**: A dedicated, versioned API built with **Grape**, featuring automated documentation via Swagger.
- **Hybrid Authentication**: **Devise** for web sessions and **JWT** (via `devise-jwt`) for secure API access.

## ✨ Key Features

- 🔐 **Secure Authentication**: Traditional login and registration with nickname support and JWT tokens for mobile integration.
- 👨‍👩‍👧‍👦 **Friendship System**: Connect with family and friends. Send, accept, or manage friendship requests.
- 📋 **Collaborative Shopping Lists**:
    - Create and manage multiple lists.
    - Invite members via a formal invitation system.
    - Real-time item management (add, update, delete).
- 🎁 **Shared Wishlists**:
    - Personal wishlists shared with friends.
    - "I will gift" (booking) feature to coordinate gift-giving and avoid duplicates.
- 🔍 **User Discovery**: Search for family members by email or nickname.
- 📜 **API Documentation**: Interactive Swagger UI at `/api/docs`.

## 🛠 Tech Stack

### Backend
- **Ruby**: 3.4.7
- **Rails**: 8.1.2 (using Propshaft)
- **Database**: PostgreSQL
- **API**: Grape + Grape-Entity + Swagger
- **Authentication**: Devise + `devise-jwt`
- **Authorization**: Pundit

### Frontend
- **Templates**: Slim
- **Components**: `view_component`
- **Styles**: SCSS with `dartsass-rails`
- **JavaScript**: Stimulus, Turbo

### Infrastructure
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Deployment**: Kamal (Docker-based)
- **Web Server**: Puma + Thruster

## 🚀 Getting Started

### Prerequisites

- Ruby 3.4.7
- PostgreSQL 14+
- Redis (optional, for some configurations)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/family_shopping.git
   cd family_shopping
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   bin/rails db:prepare
   ```

4. **Environment Configuration**
   Create a `.env` file (see `.env.example` if available) or use Rails credentials:
   ```bash
   bin/rails credentials:edit
   ```
   *Note: Ensure `DEVISE_JWT_SECRET_KEY` is set.*

5. **Start the development server**
   ```bash
   bin/dev
   ```

6. **Access the application**
   - Web UI: [http://localhost:3000](http://localhost:3000)
   - API Docs: [http://localhost:3000/api/docs](http://localhost:3000/api/docs)

## 🏗 Project Structure (Concept-Based)

The application uses a directory structure organized by **domain concepts** rather than just Rails types:

```text
app/concepts/
├── [concept_name]/        # e.g., shopping_list, wishlist_items, friends
│   ├── component/         # ViewComponents and Slim templates
│   └── operation/         # Business logic (Service Objects / Operations)
├── shared/                # Common UI elements (navbar, modals)
└── base/                  # Base classes for Operations and Components
```

## 🧪 Testing

We use **RSpec** for comprehensive testing across the stack:

```bash
# Run all tests
bundle exec rspec

# Run with coverage (SimpleCov)
COVERAGE=true bundle exec rspec
```

---

**Happy Shopping! 🛒**
