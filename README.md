# Opine

A personal review aggregation app for rating **Places**, **Experiences**, and **Things** on a 1-6 scale.

## Features

- 🔐 **Authentication** — Devise with Google OAuth
- 📝 **Items** — Create and browse items across categories (Restaurants, Bars, Wine, Liquor, etc.)
- ⭐ **Reviews** — Rate items 1-6 with notes and photos *(coming soon)*
- 🤖 **AI Enrichment** — Auto-populate metadata via Gemini *(coming soon)*
- 📋 **Lists** — Curate personal lists of favorite items *(coming soon)*

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Rails 8.1, Ruby 4.0.1 |
| Database | PostgreSQL (UUIDv7 primary keys) |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS |
| Auth | Devise + OmniAuth (Google) |
| Authorization | Pundit |
| Background Jobs | Solid Queue |
| AI | Gemini 3 Flash |

## Getting Started

### Prerequisites

- Ruby 4.0.1 (recommend [mise](https://mise.jdx.dev/) for version management)
- PostgreSQL 14+
- Node.js (for Tailwind)

### Setup

```bash
# Install dependencies
bundle install

# Create database
bin/rails db:create db:migrate

# Start dev server (Rails + Tailwind watcher)
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000)

### Environment Variables

For Google OAuth (optional for local dev):

```bash
export GOOGLE_CLIENT_ID=your_client_id
export GOOGLE_CLIENT_SECRET=your_client_secret
```

## Testing

```bash
bundle exec rspec
```

## Project Structure

```
app/
├── controllers/
│   ├── items_controller.rb      # Items CRUD
│   └── users/
│       └── omniauth_callbacks_controller.rb
├── models/
│   ├── user.rb                  # Devise, roles, OAuth
│   └── item.rb                  # Categories, metadata
├── policies/
│   └── item_policy.rb           # Pundit authorization
└── views/
    └── items/                   # Tailwind-styled views
```

## License

Private — All rights reserved.
