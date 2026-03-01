-- =============================================================================
-- PostgreSQL Init Script - Create Multiple Databases
-- =============================================================================
-- This script runs on first container initialization
-- Add your project databases here
-- =============================================================================

-- Enable pgvector extension on default database
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
-- -----------------------------------------------------------------------------
-- Example: Create additional databases for your projects
-- Uncomment and modify as needed
-- -----------------------------------------------------------------------------

-- Elixir Project Database
-- CREATE DATABASE elixir_app;
-- \c elixir_app
-- CREATE EXTENSION IF NOT EXISTS vector;

-- Node.js/NestJS Project Database
-- CREATE DATABASE nestjs_app;
-- \c nestjs_app
-- CREATE EXTENSION IF NOT EXISTS vector;

-- Payload CMS Database
-- CREATE DATABASE payload_cms;
-- \c payload_cms
-- CREATE EXTENSION IF NOT EXISTS vector;

-- Test Database (for running tests)
-- CREATE DATABASE test_db;
-- \c test_db
-- CREATE EXTENSION IF NOT EXISTS vector;

-- -----------------------------------------------------------------------------
-- Note: You can also create databases manually after startup:
--   docker exec -it dev_postgres psql -U postgres -c "CREATE DATABASE mydb;"
--   docker exec -it dev_postgres psql -U postgres -d mydb -c "CREATE EXTENSION vector;"
-- Check if extension is installed:
--   docker exec dev_postgres psql -U postgres -d mydb -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';"
-- -----------------------------------------------------------------------------
