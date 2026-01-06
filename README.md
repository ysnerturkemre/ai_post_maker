# AI Post Maker

## Development Setup

### Requirements
- Ruby 3.4.x
- PostgreSQL
- Redis (for Sidekiq)

### Environment
Copy `.env.example` to `.env` and set at minimum:
- `DATABASE_URL` (development)
- `DATABASE_URL_TEST` (test)
- `REDIS_URL`

### Bootstrap
```bash
bundle install
bin/rails db:setup
```

### Run
```bash
bin/rails server
bundle exec sidekiq
```

ActiveStorage is configured for local disk in V1 (`storage/`).
