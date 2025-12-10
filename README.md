# 🛒 Family Shopping

A collaborative shopping list management application for families. Keep track of what needs to be purchased, share lists with family members, and mark items as completed in real-time.

## 📱 Project Overview

**Family Shopping** is a full-stack application designed to simplify household shopping management. Family members can register, add items to shared shopping lists, and check them off as they're purchased. Everyone stays synchronized with real-time updates.

### Architecture

- **Backend**: Ruby on Rails 8.1 with PostgreSQL
- **Frontend**: Web interface with Slim templates and ViewComponents
- **API**: Grape API (planned) for mobile integration
- **Mobile**: React Native app (planned)
- **Authentication**: Devise + JWT for both web sessions and API tokens

## ✨ Features

- 🔐 **User Authentication**: Secure registration and login with Devise
- 👨‍👩‍👧‍👦 **Family Collaboration**: Multiple users can share shopping lists
- ✅ **Item Management**: Add, edit, and mark items as purchased
- 📱 **Cross-Platform**: Web interface ready, mobile API prepared
- 🔒 **Authorization**: Pundit-based access control
- 🚀 **API Ready**: JWT authentication for future React Native app

## 🛠 Tech Stack

### Backend
- **Ruby**: 3.4.7
- **Rails**: 8.1.1
- **Database**: PostgreSQL
- **Authentication**: Devise + Devise-JWT
- **Authorization**: Pundit
- **Testing**: RSpec, Capybara, FactoryBot

### Frontend
- **Templates**: Slim
- **Components**: ViewComponent
- **Styles**: SCSS with Dartsass
- **JavaScript**: Stimulus, Turbo

### Infrastructure
- **Web Server**: Puma
- **Deployment**: Kamal (Docker-based)
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable

## 🚀 Getting Started

### Prerequisites

- Ruby 3.4.7
- PostgreSQL 14+
- Node.js (for JavaScript dependencies)
- Docker (optional, for deployment)

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
   bin/rails db:create
   bin/rails db:migrate
   ```

4. **Configure credentials**
   ```bash
   bin/rails credentials:edit
   ```
   
   Add your JWT secret:
   ```yaml
   devise_jwt_secret_key: your_secret_key_here
   ```

5. **Start the server**
   ```bash
   bin/rails server
   ```

6. **Visit the app**
   Open [http://localhost:3000](http://localhost:3000) in your browser

## 📚 Documentation

- **[Authentication Guide](doc/AUTHENTICATION.md)** - Complete guide for web and API authentication
- **[API Examples](doc/API_EXAMPLES.md)** - API usage examples for React Native integration

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

## 🏗 Project Structure

```
app/
├── concepts/           # Domain concepts (components + operations)
│   ├── base/          # Base classes for components and operations
│   └── home/          # Home page concept
├── controllers/       # Controllers
│   ├── api/          # API controllers (JWT auth)
│   └── users/        # Devise controllers (custom)
├── models/           # ActiveRecord models
├── policies/         # Pundit authorization policies
├── serializers/      # JSON serializers for API
└── views/            # ERB/Slim templates

config/
├── initializers/     # Rails initializers
│   └── devise.rb    # Devise + JWT configuration
└── routes.rb        # Application routes

spec/
├── models/          # Model tests
├── requests/        # Request tests
├── support/         # Test helpers
└── factories/       # FactoryBot factories
```

## 🔐 Authentication

### Web Authentication

Traditional session-based authentication for web interface:

```ruby
# Login
POST /users/sign_in
# Logout
DELETE /users/sign_out
# Register
POST /users
```

## 🗺 Roadmap

### Phase 1: Core Features ✅
- [x] User authentication (web + API)
- [x] Authorization with Pundit
- [x] JWT token management
- [ ] Shopping list creation and management
- [ ] Item CRUD operations
- [ ] Mark items as purchased

### Phase 2: Family Features 🚧
- [ ] Family groups
- [ ] Invite family members
- [ ] Shared shopping lists
- [ ] Real-time updates with Action Cable

### Phase 3: Advanced Features 📋
- [ ] Item categories
- [ ] Recurring items
- [ ] Shopping history
- [ ] Price tracking
- [ ] Store locations

### Phase 4: Mobile App 📱
- [ ] Grape API endpoints
- [ ] React Native mobile app
- [ ] Push notifications
- [ ] Offline mode

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Ruby Style Guide
- Use RuboCop for linting: `bundle exec rubocop`
- Write tests for new features
- Keep test coverage above 90%

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Your Name** - *Initial work*

## 🙏 Acknowledgments

- Built with [Ruby on Rails](https://rubyonrails.org/)
- Authentication by [Devise](https://github.com/heartcombo/devise)
- JWT tokens by [devise-jwt](https://github.com/waiting-for-dev/devise-jwt)
- Authorization by [Pundit](https://github.com/varvet/pundit)

## 📞 Support

For questions or issues, please open an issue on GitHub or contact the maintainers.

---

**Happy Shopping! 🛒**
