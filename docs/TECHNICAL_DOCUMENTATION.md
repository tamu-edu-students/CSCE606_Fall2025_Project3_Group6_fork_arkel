# Technical Documentation

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Diagrams](#architecture-diagrams)
   - [System Architecture](#system-architecture)
   - [Class Diagram](#class-diagram)
   - [Database Schema](#database-schema)
3. [Getting Started from Zero](#getting-started-from-zero)
4. [Development Setup](#development-setup)
5. [Production Deployment](#production-deployment)
6. [Configuration](#configuration)
7. [Dependencies](#dependencies)

---

## System Overview

**Cinematico** is a Rails 8.0.3 web application for movie tracking, reviews, and social interaction. The application integrates with The Movie Database (TMDb) API to fetch movie metadata and provides features for users to:

- Track watched movies with watchlists and watch history
- Write and manage movie reviews
- Follow other users and view activity feeds
- View personalized statistics and recommendations
- Earn achievements and XP through gamification

### Technology Stack

- **Framework**: Ruby on Rails 8.0.3
- **Database**: PostgreSQL
- **Web Server**: Puma with Thruster
- **Frontend**: Tailwind CSS
- **Deployment**: Heroku
- **External API**: The Movie Database (TMDb) API v3
- **Authentication**: Devise
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache (PostgreSQL-backed)

---

## Architecture Diagrams

### System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Browser                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    Kamal Proxy (SSL/TLS)                        │
│                    (Let's Encrypt)                               │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    Rails Application Container                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Puma Web Server (with Thruster)                          │  │
│  │  - Handles HTTP requests                                  │  │
│  │  - Serves static assets                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Rails Application                                        │  │
│  │  - Controllers (MVC)                                      │  │
│  │  - Services (TmdbService, StatsService)                  │  │
│  │  - Background Jobs (Solid Queue)                          │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
┌───────────────▼──┐  ┌──────▼──────┐  ┌─▼──────────────────┐
│   PostgreSQL     │  │   Redis     │  │   TMDb API         │
│   - Primary DB   │  │   (Optional)│  │   (External)       │
│   - Cache        │  │             │  │                    │
│   - Queue        │  │             │  │                    │
│   - Cable        │  │             │  │                    │
└──────────────────┘  └─────────────┘  └────────────────────┘
```

### Class Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Application Layer                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Controllers:                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ MoviesCtrl   │  │ UsersCtrl    │  │ ReviewsCtrl  │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                 │                  │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐          │
│  │ Watchlists   │  │ StatsCtrl    │  │ Notifications│          │
│  │ Controller   │  │              │  │ Controller   │          │
│  └─────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ uses
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Service Layer                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐         ┌──────────────────┐              │
│  │  TmdbService     │         │  StatsService    │              │
│  │                  │         │                  │              │
│  │  +search_movies  │         │  +calculate_    │              │
│  │  +movie_details  │         │    overview     │              │
│  │  +similar_movies │         │  +calculate_top_│              │
│  │  +trending_movies│         │    contributors │              │
│  │  +genres         │         │  +calculate_    │              │
│  └──────────────────┘         │    trend_data    │              │
│                               └──────────────────┘              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ uses
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Model Layer                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐              │
│  │   User   │      │  Movie   │      │  Review  │              │
│  │          │      │          │      │          │              │
│  │ -email   │      │ -tmdb_id │      │ -body    │              │
│  │ -username│      │ -title   │      │ -rating  │              │
│  │ -xp      │      │ -overview│      │          │              │
│  └────┬─────┘      └────┬─────┘      └────┬─────┘              │
│       │                │                  │                    │
│       │ has_many       │ has_many         │ belongs_to         │
│       │                │                  │                    │
│  ┌────▼─────────────────▼──────────────────▼─────┐            │
│  │  Watchlist  │  WatchLog  │  Log  │  Vote     │            │
│  └─────────────┴─────────────┴───────┴───────────┘            │
│                                                                  │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐              │
│  │  Follow  │      │   List   │      │  Tag     │              │
│  │          │      │          │      │          │              │
│  │ -follower│      │ -name    │      │ -name    │              │
│  │ -followed│      │ -public  │      │          │              │
│  └──────────┘      └──────────┘      └──────────┘              │
│                                                                  │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐              │
│  │ Notification│    │Achievement│    │UserStat  │              │
│  │            │    │          │    │          │              │
│  │ -type     │    │ -code    │    │ -total_  │              │
│  │ -read     │    │ -name    │    │   movies │              │
│  └──────────┘      └──────────┘      └──────────┘              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Database Schema

```
┌─────────────────────────────────────────────────────────────────┐
│                         Core Tables                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  users                    movies                                 │
│  ├─ id (PK)              ├─ id (PK)                             │
│  ├─ email (UNIQUE)       ├─ tmdb_id (UNIQUE)                    │
│  ├─ username (UNIQUE)    ├─ title                               │
│  ├─ encrypted_password    ├─ overview                            │
│  ├─ profile_public        ├─ poster_path                        │
│  ├─ xp                    ├─ release_date                       │
│  └─ banned                ├─ runtime                            │
│                           └─ cached_at                           │
│                                                                  │
│  reviews                  watchlists                            │
│  ├─ id (PK)              ├─ id (PK)                             │
│  ├─ user_id (FK)         ├─ user_id (FK)                        │
│  ├─ movie_id (FK)        └─ ...                                 │
│  ├─ body                 │                                       │
│  ├─ rating               watchlist_items                        │
│  ├─ reported             ├─ id (PK)                             │
│  └─ cached_score         ├─ watchlist_id (FK)                  │
│                           ├─ movie_id (FK)                      │
│  votes                    └─ UNIQUE(watchlist_id, movie_id)     │
│  ├─ id (PK)              │                                       │
│  ├─ user_id (FK)         watch_histories                        │
│  ├─ review_id (FK)       ├─ id (PK)                             │
│  └─ value                ├─ user_id (FK, UNIQUE)                  │
│                          └─ ...                                 │
│                          │                                       │
│                          watch_logs                             │
│                          ├─ id (PK)                             │
│                          ├─ user_id (FK)                        │
│                          ├─ movie_id (FK)                       │
│                          ├─ watched_on                         │
│                          └─ watch_history_id (FK)               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Social & Community Tables                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  follows                  lists                                 │
│  ├─ id (PK)              ├─ id (PK)                             │
│  ├─ follower_id (FK)     ├─ user_id (FK)                        │
│  ├─ followed_id (FK)     ├─ name                                │
│  └─ UNIQUE(follower,      ├─ description                         │
│      followed)           └─ public                              │
│                           │                                       │
│  notifications            list_items                            │
│  ├─ id (PK)              ├─ id (PK)                             │
│  ├─ user_id (FK)         ├─ list_id (FK)                        │
│  ├─ actor_id (FK)        ├─ movie_id (FK)                       │
│  ├─ notification_type     └─ position                            │
│  ├─ notifiable_type                                             │
│  ├─ notifiable_id                                              │
│  ├─ read                                                         │
│  └─ body                                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Metadata & Stats Tables                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  genres                  people                                 │
│  ├─ id (PK)              ├─ id (PK)                             │
│  ├─ name                 ├─ tmdb_id                            │
│  └─ tmdb_id              ├─ name                                │
│                          └─ profile_path                         │
│  movie_genres            movie_people                           │
│  ├─ id (PK)              ├─ id (PK)                             │
│  ├─ movie_id (FK)        ├─ movie_id (FK)                       │
│  └─ genre_id (FK)        ├─ person_id (FK)                      │
│                           ├─ role                                │
│  tags                    └─ character                           │
│  ├─ id (PK)              │                                       │
│  └─ name                 logs                                   │
│                          ├─ id (PK)                             │
│  log_tags                ├─ user_id (FK)                        │
│  ├─ id (PK)              ├─ movie_id (FK)                       │
│  ├─ log_id (FK)          ├─ watched_on                          │
│  └─ tag_id (FK)          ├─ rating                              │
│                          ├─ review_text                         │
│                          └─ rewatch                             │
│                                                                  │
│  user_stats              achievements                           │
│  ├─ id (PK)              ├─ id (PK)                             │
│  ├─ user_id (FK)         ├─ code                                │
│  ├─ total_movies         ├─ name                                │
│  ├─ total_hours          ├─ description                         │
│  ├─ total_reviews        └─ icon_url                            │
│  ├─ total_rewatches                                             │
│  ├─ top_genres_json      user_achievements                      │
│  ├─ top_actors_json      ├─ id (PK)                             │
│  ├─ top_directors_json   ├─ user_id (FK)                        │
│  └─ heatmap_json         ├─ achievement_id (FK)                  │
│                          └─ earned_at                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Getting Started from Zero

This section provides step-by-step instructions to get the application running from a fresh clone/fork.

### Prerequisites

Before starting, ensure you have the following installed:

- **Ruby 3.4.1** (check with `ruby -v`)
- **PostgreSQL 9.3+** (check with `psql --version`)
- **redis-server** (check with `redis-server -v`)

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/tamu-edu-students/CSCE606_Fall2025_Project3_Group6.git
cd CSCE606_Fall2025_Project3_Group6

# Or if forking:
# git clone https://github.com/YOUR_USERNAME/CSCE606_Fall2025_Project3_Group6.git
```

### Step 2: Install Ruby Dependencies

```bash
# Install Bundler if not already installed
gem install bundler

# Install all Ruby gems
bundle install
```

### Step 3: Set Up PostgreSQL Database

```bash
# Create PostgreSQL user and database (if not exists)
# On macOS with Homebrew:
createuser -s cinematico
createdb cinematico_development
createdb cinematico_test

# Or using psql:
psql postgres
CREATE USER cinematico WITH PASSWORD 'cinematico';
CREATE DATABASE cinematico_development OWNER cinematico;
CREATE DATABASE cinematico_test OWNER cinematico;
\q
```

### Step 4: Configure Environment Variables

```bash
# Copy the example environment file (if exists) or create .env file
# Create .env file in the root directory
touch .env

# Add the following to .env:
SENDGRID_API_KEY=<sendgrid-api>
TMDB_ACCESS_TOKEN=<tmdb-access-token>
```

**To get a TMDb Access Token:**
1. Visit https://www.themoviedb.org/
2. Create an account
3. Setup an api key and obtain the TMDb access token
4. Set TMDB_ACCESS_TOKEN in .env as the access token obtained

**To get Sendgrid API KEY:**
1. Visit https://www.twilio.com/en-us/products/email-api
2. Create an account
3. Create an API Key and get the API key secret
4. Set SENDGRID_API_KEY .env as the secret obtained


### Step 5: Set Up the Database

```bash
# Create database tables
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed the database with initial data
rails db:seed
```


### Step 6: Precompile Assets (Development)

```bash
# Precompile assets for development
rails assets:precompile
```

### Step 7: Start the Development Server

```bash
# Use bin/dev to start the server, this will compile the tailwind css before running the server
bin/dev
```

The application should now be available at `http://localhost:3000`

---

## Development Setup

### Confirming an account without confirmation email
#### Using confirmation email provided in console
On creation of a user the contents of the confirmation email should be pasted in the console containing the confirmation link.

#### Through console
```bash
# Open rails console
rails c

# Get the user object of the user you want to confirm
user = User.find_by(usename: "<username>")

# Confrim the user
user.confirm
```

### Running Tests

```bash
# Run all RSpec tests
bundle exec rspec

# Run rspec test on specific test file
bundle exec rspec <specific-file.rb>

# Run Cucumber acceptance tests
bundle exec cucumber

# Run Cucumber test on a speciifc file
bundle exec cucumber<specific-file.rb>
```

### Database Management

```bash
# Create a new migration
rails generate migration MigrationName

# Rollback last migration
rails db:rollback

# Reset database (WARNING: deletes all data)
rails db:reset

# Open database console
rails dbconsole
```

### Code Quality

```bash
# Run RuboCop (code style checker)
rubocop -A

# Run Brakeman (security scanner)
bundle exec brakeman
```

### Development Tools

```bash
# Open Rails console
rails console

# View routes
rails routes

# Check environment
rails about
```

---

## Production Deployment

Heroku is the quickest path to validate a production-like environment (mirrors the steps in `contributing.md`):
- Prereqs: Heroku CLI, TMDb access token, SendGrid API key.
- Create app/add-ons:
  ```bash
  heroku login
  heroku create your-app-name
  heroku buildpacks:set heroku/ruby
  heroku addons:create heroku-postgresql:mini
  heroku addons:create heroku-redis:mini
  heroku addons:create sendgrid:starter
  ```
- Config vars:
  ```bash
  heroku config:set TMDB_ACCESS_TOKEN=... SENDGRID_API_KEY=... APP_HOST=your-app-name.herokuapp.com
  heroku config:set RAILS_LOG_LEVEL=info   # optional
  ```
- Deploy and migrate:
  ```bash
  git push heroku main
  heroku run rails db:migrate    # release phase also migrates
  ```
- Scale/verify:
  ```bash
  heroku ps:scale web=1 worker=1   # Solid Queue worker
  heroku open
  heroku logs --tail
  ```
---

## Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `TMDB_ACCESS_TOKEN` | TMDb API access token | Yes | - |
| `SENDGRID_API_KEY` | SendGrid API key for SMTP delivery | Yes (production email) | - |
| `APP_HOST` | Host used in mailer links (e.g., `localhost:3000` or Heroku domain) | Recommended | `localhost:3000` |
| `REDIS_URL` | Redis connection string for cache/queue | Yes (cache/queue) | `redis://localhost:6379/1` |
| `DATABASE_URL` | PostgreSQL connection string | Production | - |
| `RAILS_ENV` | Rails environment | No | `development` |
| `RAILS_LOG_LEVEL` | Log level | No | `info` |
| `SOLID_QUEUE_IN_PUMA` | Run jobs in Puma process | No | `true` |

### Database Configuration

Database settings are in `config/database.yml`:

- **Development**: Uses local PostgreSQL with user `cinematico`
- **Test**: Uses separate test database
- **Production**: Uses `DATABASE_URL` environment variable

### TMDb API Configuration

The application caches TMDb API responses to reduce API calls:

- Search results: 1 hour cache
- Movie details: 24 hours cache
- Similar movies: 24 hours cache
- Trending movies: 2 hours cache

Cache is stored in PostgreSQL (Solid Cache) in production, or in-memory in development.

### Email Configuration

Email is configured via Action Mailer. Update `config/environments/production.rb` for SMTP settings:

```ruby
config.action_mailer.smtp_settings = {
  address: "smtp.sendgrid.net",
  port: 587,
  domain: ENV.fetch("APP_HOST", "cinematico.app"),
  user_name: "apikey",                 # literal string
  password: ENV["SENDGRID_API_KEY"],   # provided by SendGrid
  authentication: :plain,
  enable_starttls_auto: true
}
```

---

## Dependencies

### Core Gems

- **rails** (~> 8.0.3): Web framework
- **pg** (~> 1.1): PostgreSQL adapter
- **puma** (>= 5.0): Web server
- **devise**: Authentication
- **faraday**: HTTP client for TMDb API
- **redis**: Caching (optional)

### Development/Test Gems

- **rspec-rails**: Testing framework
- **factory_bot_rails**: Test data factories
- **cucumber-rails**: Acceptance testing
- **capybara**: Integration testing
- **simplecov**: Code coverage
- **rubocop-rails-omakase**: Code style
- **brakeman**: Security scanner

### Deployment

- **kamal**: Docker-based deployment
- **thruster**: HTTP acceleration for Puma

### Frontend

- **tailwindcss-rails**: CSS framework
- **stimulus-rails**: JavaScript framework
- **turbo-rails**: SPA-like page acceleration
- **importmap-rails**: JavaScript module management

---

## Additional Resources

### API Documentation

- TMDb API: https://developer.themoviedb.org/docs
- TMDb API v3 Reference: https://developer.themoviedb.org/reference/intro/getting-started

### Rails Documentation

- Rails Guides: https://guides.rubyonrails.org/
- Rails API: https://api.rubyonrails.org/

### Deployment Documentation

- Kamal Documentation: https://kamal-deploy.org/
- Docker Documentation: https://docs.docker.com/

---

## Support

For issues or questions:

1. Check existing GitHub issues
2. Review application logs: `kamal app logs`
3. Check Rails logs: `tail -f log/production.log` (on server)
4. Open a new GitHub issue with:
   - Error messages
   - Steps to reproduce
   - Environment details

---

## Codebase Overview (Quick Reference)
- `app/controllers/*`: HTTP endpoints; each controller coordinates models/services and renders `app/views/*` templates.
- `app/models/*`: Active Record models (users, movies, reviews, lists, follows, stats, notifications) plus associations/validations.
- `app/services/tmdb_service.rb`: TMDb API client (search, details, trending, genres, similar).
- `app/services/stats_service.rb`: Aggregates user/movie stats for dashboards.
- `app/services/notification_creator.rb`: Builds notifications for user events.
- `app/jobs/*`: Background jobs run via Solid Queue (see queue database).
- `app/assets/*` and `app/javascript/*`: Tailwind CSS, Stimulus/Turbo controllers, importmap configuration and front-end behavior.
- `app/mailers/*`: Outbound email classes and templates.
- `config/database.yml`: PostgreSQL settings for dev/test/prod; production uses `DATABASE_URL`.
- `config/environments/*.rb`: Environment-specific configuration (cache, mailer, logging).
- `config/puma.rb`: Puma web server configuration and Solid Queue plugin toggle.
- `config/deploy.yml`: Kamal deployment config (service, registry, env, accessories).
- `Procfile` / `Procfile.dev`: Process definitions for Heroku (web/worker/release) and local `bin/dev`.
- `bin/setup`: Idempotent environment setup (bundle, db:prepare, log/tmp clear, optional server start).
- `bin/dev`: Local entrypoint that runs processes from `Procfile.dev`.
- `docs/TECHNICAL_DOCUMENTATION.md`, `contributing.md`: Architecture, setup, deployment, and contributor workflow guides.

## File-by-File Detail

**Controllers**
- `app/controllers/application_controller.rb`: Base controller that enforces authentication, configures Devise params (username), and sends users to root after sign-in/out.  
  Sets the default browser allowance and provides common behavior to all controllers.
- `app/controllers/home_controller.rb`: Landing page that builds an activity feed from followed users within a time window.  
  Also shows a simple trending sidebar for guests and signed-in users.
- `app/controllers/movies_controller.rb`: Handles search/discovery via TMDb with filters, sorting, and caching/syncing to local DB.  
  Renders movie detail pages with reviews, similar movies, and background syncing.
- `app/controllers/reviews_controller.rb`: Creates, updates, destroys, and reports reviews; manages votes and ties reviews to movies/users.  
  Applies ordering scopes for score/date and surfaces errors to the UI.
- `app/controllers/watchlists_controller.rb`: Ensures a user watchlist exists, loads items, and renders the watchlist view.  
  Acts as the container controller for watchlist interactions.
- `app/controllers/watchlist_items_controller.rb`: Adds/removes/restores movies to a watchlist, creating Movie records from TMDb IDs when needed.  
  Provides undo-friendly removal and graceful fallbacks if items are missing.
- `app/controllers/watch_histories_controller.rb`: Manages watch history records and associated logs for a user.  
  Coordinates creation and display of watch history timelines.
- `app/controllers/list_items_controller.rb`: Adds or removes movies from custom lists, ensuring the list/movie join is kept consistent.  
  Handles idempotent adds to avoid duplicates.
- `app/controllers/lists_controller.rb`: CRUD for user-created lists with public/private visibility.  
  Loads list contents and manages ownership/authorization.
- `app/controllers/follows_controller.rb`: Follow/unfollow endpoints that manage follower/followed relationships.  
  Keeps relationship integrity and redirects appropriately.
- `app/controllers/users_controller.rb`: Profile display/edit routes with privacy enforcement; renders lists/reviews for a user.  
  Supports public profile routes by username and user settings pages.
- `app/controllers/stats_controller.rb`: Builds private and public stats dashboards via `StatsService`, selecting appropriate years and datasets.  
  Shares rendering between private and public views.
- `app/controllers/notifications_controller.rb`: Lists notifications and marks them as read for the current user.  
  Loads associated records for display context.
- `app/controllers/notification_preferences_controller.rb`: Manages per-user notification preferences and saves channel settings.  
  Ensures only the owner can update their preferences.

**Helpers**
- `app/helpers/application_helper.rb`: Shared view helpers for formatting, layout tweaks, and common UI helpers.  
  Used across multiple views.
- `app/helpers/home_helper.rb`: Helper methods specific to the home/feed templates.  
  Keeps view logic tidy for activity lists.
- `app/helpers/watchlist_items_helper.rb`: Helpers for watchlist item rendering and messaging.  
  Supports the watchlist views and partials.

**Models**
- `app/models/application_record.rb`: Rails base model superclass providing shared behavior for all models.  
  Inherits Active Record and common helpers.
- `app/models/user.rb`: Devise-backed user with profiles, follows, lists, reviews, stats, and notification preferences.  
  Manages authentication hooks and privacy flags.
- `app/models/movie.rb`: TMDb-backed movie cache with associations to reviews, logs, genres, and people.  
  Provides find-or-create helpers for syncing API data.
- `app/models/review.rb`: User reviews with ratings, body text, and scopes for ordering by score/date.  
  Connects to votes and movies, includes validations.
- `app/models/vote.rb`: Up/down votes on reviews with uniqueness per user/review pair.  
  Aggregates vote values for review scores.
- `app/models/watchlist.rb` / `watchlist_item.rb`: Watchlist container per user and join table to movies.  
  Enforces uniqueness of movies in a watchlist.
- `app/models/watch_history.rb` / `watch_log.rb`: User watch histories and individual watch entries with timestamps.  
  Supports aggregation for stats and recommendations.
- `app/models/list.rb` / `list_item.rb`: Custom user-curated lists (public/private) and their movie entries.  
  Enforces ownership and visibility rules.
- `app/models/follow.rb`: Follower/followed relationships between users with validations.  
  Powers social feed queries.
- `app/models/notification.rb`: Persisted notifications with type/payload and read state.  
  Belongs to a user and can be marked read.
- `app/models/notification_preference.rb` / `email_preference.rb`: Stores per-user notification/email channel settings.  
  Used to filter which notifications get sent.
- `app/models/achievement.rb` / `user_achievement.rb`: Achievement definitions and earned instances per user.  
  Tracks unlocks and badge metadata.
- `app/models/user_stat.rb`: Aggregated stats per user (counts, heatmaps, top lists).  
  Populated by `StatsService`.
- `app/models/genre.rb`, `tag.rb`, `log_tag.rb`: Taxonomy/tagging around movies and watch logs.  
  Supports filtering and categorization.
- `app/models/movie_genre.rb`, `movie_person.rb`, `person.rb`: Join models and people records linked to movies.  
  Capture many-to-many relationships with cast/crew and genres.
- `app/models/log.rb`: Base log data for watch histories, providing shared fields.  
  Supports audit of watch events.

**Services**
- `app/services/tmdb_service.rb`: TMDb HTTP client with caching for search, details (with credits/videos), trending, top-rated, similar, and genres.  
  Handles rate limits, fallbacks, and error responses gracefully.
- `app/services/stats_service.rb`: Computes user stats, top contributors, trends, most-watched movies, and heatmap datasets.  
  Provides year selection helpers and aggregation queries.
- `app/services/notification_creator.rb`: Builds and persists notifications for user events.  
  Encapsulates notification formatting in one place.

**Jobs**
- `app/jobs/application_job.rb`: Base Active Job configured for Solid Queue.  
  Central point to set queue adapter defaults.

**Mailers**
- `app/mailers/application_mailer.rb`: Base mailer with default from/reply-to and layout.  
  Parent for all project mailers.
- `app/mailers/devise_mailer.rb`: Devise mailer subclass inheriting application defaults.  
  Hook to customize Devise emails if needed.
- `app/mailers/notification_mailer.rb`: Generic notification email with optional CTA URL.  
  Used for sending user-facing alerts.

**JavaScript / Frontend**
- `app/javascript/application.js`: Importmap entry point; loads Turbo, Stimulus controllers, and custom behaviors (password toggle, copy feedback).  
  Ensures shared JS is available across pages.
- `app/javascript/password_toggle.js`: Toggles password input visibility and updates button text.  
  Hooks to elements via `data-toggle-password`.
- `app/javascript/copy_feedback.js`: Copies text from a target element to the clipboard and flashes a “Copied!” message.  
  Activated via `data-copy-target` attributes.

**Views and Assets**
- `app/views/**/*`: ERB templates for home/feed, movies, reviews, profiles, lists/watchlists/histories, notifications, and mailers.  
  Organized by controller for clarity.
- `app/assets/*`: Tailwind stylesheets and static assets.  
  Includes CSS entry points compiled in dev/prod.

**Config**
- `config/application.rb`: Core Rails application configuration and framework defaults.  
  Loads initializers and global settings.
- `config/boot.rb`: Bundler bootstrap to load gems and set up the environment.  
  Required before Rails boots.
- `config/environment.rb`: Initializes the Rails application and loads env-specific configs.  
  Entrypoint for `rails` commands.
- `config/environments/*.rb`: Environment-specific settings (mailer, cache, logging, hosts).  
  Tailors behavior for development/test/production.
- `config/database.yml`: PostgreSQL connections for dev/test/prod, including cache/queue/cable roles in production.  
  Uses `DATABASE_URL` in production.
- `config/routes.rb`: Routing table, Devise mappings, and resource definitions.  
  Connects URLs to controllers/actions.
- `config/puma.rb`: Puma server thread/port config and Solid Queue plugin toggle.  
  Reads ENV for concurrency.
- `config/deploy.yml`: Kamal deploy settings (service name, registry, servers, env, accessories).  
  Defines secrets and accessory containers like Postgres/Redis.
- `config/importmap.rb`: Import map entries for JavaScript modules.  
  Declares front-end dependencies loaded via importmap.
- `config/queue.yml`, `config/recurring.yml`: Solid Queue and recurring job configuration.  
  Defines queues, priorities, and schedules.
- `config/cable.yml`, `config/cache.yml`, `config/storage.yml`: Action Cable, cache store, and Active Storage adapters per environment.  
  Choose Redis/Postgres/file storage backends.
- `config/cucumber.yml`: Cucumber CLI profiles.  
  Sets tags/formatters for BDD runs.
- `config/tailwind.config.js`: Tailwind CSS build configuration.  
  Controls theme, plugins, and content paths.
- `config/credentials.yml.enc` / `config/master.key`: Encrypted credentials store and its key (keep private).  
  Used for secrets in production.

**Root / Process / Scripts**
- `config.ru`: Rack entrypoint that boots the Rails application for the web server.  
  Used by Puma and other Rack servers.
- `Procfile`: Process types for production (release migrate, web, worker, assets precompile).  
  Guides Heroku/Foreman process formation.
- `Procfile.dev`: Local dev processes for `bin/dev` (Rails server + Tailwind watcher).  
  Enables one-command development startup.
- `Rakefile`: Loads Rails tasks and custom rake tasks.  
  Required for `rake`/`rails` command discovery.
- `bin/setup`: Bootstrap script (bundle, db:prepare, clear logs/tmp; optional server start).  
  Safe to rerun for consistent dev environments.
- `bin/dev`: Runs the dev process supervisor using `Procfile.dev`.  
  Convenience wrapper around Foreman/Procodile-style launchers.
- `bin/rails`, `bin/rake`: Standard Rails executables for commands and tasks.  
  Binstubs ensure correct Ruby/Gem versions.
- `bin/kamal`, `bin/importmap`, `bin/thrust`, `bin/jobs`: Binstubs for deployment, importmap management, Thruster, and job tooling.  
  Match project gem versions when invoked.
- `lib/tasks/cucumber.rake`: Adds Cucumber Rake tasks for BDD specs.  
  Integrates cucumber into the Rails task set.
- `Gemfile` / `Gemfile.lock`: Ruby dependency definitions and locked versions.  
  Gemfile declares intent; lockfile pins versions.
- `.env` (local only): Environment variables for development/testing.  
  Not committed; used for secrets and service URLs.

---

**Last Updated**: December 2025
**Version**: 1.0.0
