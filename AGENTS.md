 CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Agent Instructions

After writing code, make sure to run tests and linting to ensure the code is correct and follows the project's coding standards.

If you've completed a task in DESIGN.md, update the file to mark it as done.
If you've made a structural change to the codebase or schema, update DESIGN.md to reflect the changes.
If this file, AGENTS.md, needs to be updated, update it to reflect the changes.

## Build & Development Commands

```bash
# Install dependencies
bundle install

# Database setup
bin/rails db:create db:migrate

# Start development server (Rails + Tailwind watcher)
bin/dev

# Run all tests
bundle exec rspec

# Run a single test file
bundle exec rspec spec/models/user_spec.rb

# Run a specific test by line number
bundle exec rspec spec/models/user_spec.rb:42

# Linting
bundle exec rubocop

# Security audit
bundle exec brakeman
bundle exec bundler-audit
```

## Architecture Overview

**Opine** is a Rails 8.1 monolith for rating Places, Experiences, and Things on a 1-6 scale.

### Core Domain Model

- **User** — Devise authentication with Google OAuth, roles (user/admin/superadmin)
- **Item** — The entity being reviewed, organized by category/subcategory with JSONB metadata
- **Review** — User's rating (1-6 score) on an item; one review per user per item

### Key Architectural Decisions

- **UUIDv7 primary keys** on all tables for better indexing
- **Pundit policies** for authorization (`app/policies/`)
- **Hotwire (Turbo + Stimulus)** for frontend interactivity
- **Solid Queue** for background jobs
- **Category/Subcategory validation** — Items must have valid subcategory for their category (see `Item::CATEGORY_MAP`)

### Category System

Categories are defined in `app/models/item.rb`:
- **Places**: Restaurants, Bars, Parks, Museums
- **Experiences**: Concerts, Festivals, Movies, Games
- **Things**: Beer, Wine, Liquor

These categories are not exhaustive and can be expanded in the future.

Each subcategory has specific metadata attributes defined in `Item::ATTRIBUTE_DEFINITIONS`.

### Authorization Rules

- Users can only edit/delete their own items (unless admin)
- Items with reviews cannot be deleted by regular users
- Admins can edit/delete any content
- Superadmins can manage user roles

## Environment Variables

Required for Google OAuth:
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`