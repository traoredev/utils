# Local Development Services

A unified Docker Compose setup for local development with Elixir and Node.js projects.

## Services

| Service           | Port                    | Description                             |
| ----------------- | ----------------------- | --------------------------------------- |
| **PostgreSQL 18** | 5433                    | Custom build with pgvector (extensible) |
| **Redis 7**       | 6379                    | Cache, sessions, job queues             |
| **Mailpit**       | 8025 (UI) / 1025 (SMTP) | Email testing                           |
| **pgAdmin**       | 5050                    | PostgreSQL management (profile: admin)  |
| **RedisInsight**  | 5540                    | Redis management (profile: admin)       |
| **MinIO**         | 9001 (UI) / 9000 (API)  | S3-compatible storage (profile: s3)     |

## Quick Start

```bash
# Copy environment file
cp .env.example .env

# Build and start core services
docker compose build
docker compose up -d

# Start with admin UIs (pgAdmin, RedisInsight)
docker compose --profile admin up -d

# Start with S3 storage
docker compose --profile s3 up -d

# Start everything
docker compose --profile full up -d

# Stop all services
docker compose --profile full down
```

## Creating Databases

### Option 1: Edit init-db.sql (before first run)

Edit `docker/init-db.sql` to add your databases, then start the containers.

### Option 2: Create manually (after startup)

```bash
# Create a new database
docker exec -it dev_postgres psql -U postgres -c "CREATE DATABASE myproject;"

# Enable pgvector extension
docker exec -it dev_postgres psql -U postgres -d myproject -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

## Connecting from your projects

### Elixir/Phoenix (.env or config)

```elixir
# config/dev.exs
config :my_app, MyApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "my_elixir_app",
  port: 5433
```

### Node.js/NestJS (.env)

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5433/my_node_app
REDIS_HOST=localhost
REDIS_PORT=6379
```

### Payload CMS (.env)

```env
DATABASE_URI=postgresql://postgres:postgres@localhost:5433/payload_cms
```

## Creating S3 Buckets (MinIO)

A default `dev` bucket is created automatically. To add more:

```bash
# Create a new bucket
docker exec dev_minio mc mb local/my-bucket

# Or use the MinIO Console at http://localhost:9001
```

## Service URLs

| Service       | URL                   |
| ------------- | --------------------- |
| Mailpit       | http://localhost:8025 |
| pgAdmin       | http://localhost:5050 |
| RedisInsight  | http://localhost:5540 |
| MinIO Console | http://localhost:9001 |

## Data Persistence

Data is persisted in `./data/` directory:

- `data/postgres/` - PostgreSQL data
- `data/redis/` - Redis data
- `data/pgadmin/` - pgAdmin settings
- `data/redis_insight/` - RedisInsight settings
- `data/minio/` - MinIO objects

> **Note**: The `data/` directory is gitignored. To reset all data, simply delete it and restart containers.

## Job Queue Monitoring

- **BullMQ (Node.js)**: Use [Bull Board](https://github.com/felixmosh/bull-board) embedded in your app
- **Oban (Elixir)**: Query `oban_jobs` table in pgAdmin, or use [Oban Web](https://oban.pro/oban-web)
