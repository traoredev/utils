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
| **RustFS**        | 9001 (UI) / 9000 (API)  | S3-compatible storage (profile: s3)     |

## Quick Start

```bash
# Copy environment file
cp .env.example .env

# Build and start core services
docker compose build
docker compose up -d

# Start with admin UIs (pgAdmin, RedisInsight)
docker compose --profile admin up -d

# Start with S3 storage (RustFS + bucket initialization)
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

## S3 Object Storage (RustFS)

A single shared RustFS instance serves every local project. Projects do **not**
run their own object-storage container - each one gets its own bucket:

```
One RustFS instance
├── project-a-dev
├── project-b-dev
├── insurance-dev
└── other-project-dev
```

| Endpoint       | URL                   |
| -------------- | --------------------- |
| S3 API         | http://localhost:9000 |
| RustFS Console | http://localhost:9001 |

Default local credentials are `rustfsadmin` / `rustfsadmin` (see `.env.example`).

### Creating buckets

Declare bucket names centrally in `.env` via `S3_BUCKETS` (space separated).
The `rustfs-init` service creates any that are missing on every startup, and is
idempotent - existing buckets and their contents are left alone.

```env
S3_BUCKETS=project-a-dev project-b-dev insurance-dev
```

```bash
# Apply after editing .env
docker compose --profile s3 up -d rustfs-init
```

Buckets are private by default. You can also create one ad hoc with any S3
client, or through the RustFS Console at http://localhost:9001.

```bash
aws --endpoint-url http://localhost:9000 s3 mb s3://my-bucket
```

### Connecting from your projects

Configure a standard S3 client - nothing in your application needs to know it
is talking to RustFS:

```env
S3_ENDPOINT=http://localhost:9000
S3_REGION=us-east-1
S3_ACCESS_KEY=rustfsadmin
S3_SECRET_KEY=rustfsadmin
S3_BUCKET=project-a-dev
S3_FORCE_PATH_STYLE=true
```

Because these are provider-neutral settings, the same storage abstraction runs
against RustFS locally, AWS S3 in production, or Cloudflare R2 - only the
endpoint, region, credentials and bucket change.

## Service URLs

| Service        | URL                   |
| -------------- | --------------------- |
| Mailpit        | http://localhost:8025 |
| pgAdmin        | http://localhost:5050 |
| RedisInsight   | http://localhost:5540 |
| RustFS Console | http://localhost:9001 |
| S3 API         | http://localhost:9000 |

### Connecting pgAdmin to PostgreSQL

Since pgAdmin runs inside Docker, use the **internal** Docker hostname and port:

| Field             | Value      |
| ----------------- | ---------- |
| Host name/address | `postgres` |
| Port              | `5432`     |
| Username          | `postgres` |
| Password          | `postgres` |

> **Note:** Use `postgres:5432` (Docker network), not `localhost:5433` (host mapping).

## Data Persistence

Data is persisted in `./data/` directory:

- `data/postgres/` - PostgreSQL data
- `data/redis/` - Redis data
- `data/pgadmin/` - pgAdmin settings
- `data/redis_insight/` - RedisInsight settings
- `data/rustfs/` - RustFS objects (all buckets)

> **Note**: The `data/` directory is gitignored. To reset all data, simply delete it and restart containers.

## Job Queue Monitoring

- **BullMQ (Node.js)**: Use [Bull Board](https://github.com/felixmosh/bull-board) embedded in your app
- **Oban (Elixir)**: Query `oban_jobs` table in pgAdmin, or use [Oban Web](https://oban.pro/oban-web)
