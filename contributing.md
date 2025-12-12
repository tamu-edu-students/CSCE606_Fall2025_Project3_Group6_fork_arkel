# Contributing to Cinematico

Thanks for helping build Cinematico. This guide walks you from local setup through deploying the app to Heroku.

## How We Work
- Create a feature branch from `main`; open a PR once tests and linters are green.
- Keep changes small and include tests for new behavior or bug fixes.
- Run RuboCop, RSpec, and Cucumber before pushing.
- Never commit secrets; use `.env` locally and Heroku config vars in production.

## Local Development Setup

### Prerequisites
- Ruby 3.4.1 (see `.ruby-version`) and Bundler (`gem install bundler`)
- PostgreSQL 9.3+ with a local role `cinematico` / password `cinematico`
- Redis 6+ running locally (caching and background jobs)
- Node.js 18+ (only if you add npm packages; the app ships with importmap)
- TMDb API access token
- Sendgrid API key
- Git; Heroku CLI if you plan to deploy

### Install Heroku CLI
- **macOS (Homebrew)**  
  ```bash
  brew tap heroku/brew
  brew install heroku
  ```
- **Ubuntu/Debian**  
  ```bash
  curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
  ```

### Install PostgreSQL and Redis
- **macOS (Homebrew)**  
  ```bash
  brew install postgresql@16 redis
  brew services start postgresql@16
  brew services start redis
  ```
- **Ubuntu/Debian**  
  ```bash
  sudo apt update
  sudo apt install -y postgresql postgresql-contrib libpq-dev redis-server
  sudo systemctl enable --now postgresql
  sudo systemctl enable --now redis-server
  ```

### First-Time Setup
```bash
git clone https://github.com/tamu-edu-students/CSCE606_Fall2025_Project3_Group6.git
cd CSCE606_Fall2025_Project3_Group6

# Dependencies
bundle install

# Postgres role + databases (adjust if you already have them)
# If your OS user is not a Postgres superuser, first run:
# sudo -u postgres createuser -s $USER

createuser -s cinematico || true
psql -c "ALTER USER cinematico WITH PASSWORD 'cinematico';" postgres
createdb cinematico_development || true
createdb cinematico_test || true

# Environment variables (create .env in the repo root)
cat >> .env <<'EOF'
TMDB_ACCESS_TOKEN=your_tmdb_access_token
SENDGRID_API_KEY=your_sendgrid_api_key
EOF
```

> For quick local testing, you can temporarily use the shared `.env` at https://drive.google.com/file/d/17z6UlPH7lNqYanb4OL_17roc3dOccqpy/view?usp=sharing. Do **not** commit that file or any secrets.

Start Redis (`redis-server --daemonize yes` or your service manager), then prepare the app:

```bash
bin/rails db:prepare   # creates and migrates both dev/test
bin/rails db:seed      # optional sample data
```

### Running the App
- `bin/dev` (uses `Procfile.dev` to start Rails and Tailwind watcher)
- Or `bin/rails server` if you just need the API/UI without the watcher

### Quality Gates
- Tests: `bundle exec rspec`, `bundle exec cucumber`
- Coverage: `COVERAGE=true bundle exec rspec`
- Lint/Security: `bundle exec rubocop`, `bundle exec brakeman`

### Opening a PR
- Rebase on `main` before pushing to keep the history clean.
- Include a short summary, test notes, and any deployment or migration impacts in your PR description.

## Deploying to Heroku

> The repo includes a `Procfile` with `release`, `web`, and `worker` processes. Migrations run during the release phase; rerun manually if needed.

1) **Prerequisites**
   - Heroku account + CLI (`heroku --version`)
   - Heroku Postgres add-on (required) and Heroku Redis (recommended because production caching uses Redis)

2) **Create the app**
   ```bash
   heroku login
   heroku create your-app-name
   heroku buildpacks:set heroku/ruby
   heroku addons:create heroku-postgresql:essential-0
    # Provision Postgres before your first deploy so DATABASE_URL exists during assets:precompile
   heroku addons:create heroku-redis:mini 
   ```

3) **Set config vars**
   ```bash
   heroku config:set TMDB_ACCESS_TOKEN=... SENDGRID_API_KEY=...
   # Optional tuning
   heroku config:set RAILS_LOG_LEVEL=info
   ```

4) **Deploy**
   ```bash
   git push heroku main   # or your branch if configured
   # Release phase runs db:migrate; rerun manually if needed:
   heroku run rails db:migrate
   ```

5) **Scale processes**
   ```bash
   heroku ps:scale web=1 worker=1   # worker runs Solid Queue
   # If you cannot run a worker, set SOLID_QUEUE_IN_PUMA=true and keep worker=0,
   # but a dedicated worker dyno is preferred.
   ```

6) **Verify**
   ```bash
   heroku open
   heroku logs --tail
   heroku run rails about
   ```

## Common Issues
- **Webpack/Tailwind not updating**: Ensure `bin/dev` is running (uses `Procfile.dev`) so the Tailwind watcher rebuilds CSS.
- **Cannot connect to Postgres/Redis locally**: Verify services are running (`psql -d postgres`, `redis-cli ping`) and `REDIS_URL` points to the correct DB index.
- **TMDb requests failing**: Confirm `TMDB_ACCESS_TOKEN` is present in `.env` and restart the server to pick up env changes.
- **Mailer links wrong host**: Set `APP_HOST=localhost:3000` locally (or your Heroku app domain in production) so mailer URLs are correct.
- **Heroku deploy fails on migrate**: Check `DATABASE_URL` is set by Heroku Postgres and rerun `heroku run rails db:migrate` after add-ons are provisioned.
- **Heroku assets:precompile connection refused**: Ensure the Postgres add-on is provisioned before the first `git push heroku main` so `DATABASE_URL` is available; then redeploy.
- **Emails not sending in production**: Ensure `SENDGRID_API_KEY` is set on Heroku and that the dyno has outbound mail allowed. Check `heroku logs --tail` for SMTP errors.
- **Background jobs not running**: Confirm the `worker` dyno is scaled (`heroku ps:scale worker=1`) or set `SOLID_QUEUE_IN_PUMA=true` if you must run jobs in web (not recommended for production load).
- **Asset precompile failures**: Run `bundle exec rake assets:precompile` locally to see the error; missing env vars or Tailwind config issues are common culprits.
- **Devise confirmation email missing**: In development, check server logs/console output; in production ensure the mailer SMTP settings and `APP_HOST` are correct.
