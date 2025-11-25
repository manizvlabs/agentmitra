# Database Migrations Guide

## Overview

**Agent Mitra uses Flyway for all database schema management.** SQLAlchemy models are **read-only** - they define the structure but do NOT create tables. All table creation, modifications, and schema changes must be done through Flyway migrations.

## ⚠️ Important Rules

1. **NEVER use SQLAlchemy's `create_all()`** in production code
2. **ALWAYS create tables via Flyway migrations**
3. **Test migrations** before applying to production
4. **Version control** all migration files

## Current Migration Status

- **Current Version:** 24
- **Last Migration:** V24__Seed_campaigns_and_callbacks_data.sql
- **Schema:** `lic_schema` (primary schema)

## Creating a New Migration

### Step 1: Determine the Next Version Number

Check the current highest version:

```bash
flyway -configFiles=flyway.conf info
```

The next migration should be **V25** (or the next sequential number).

### Step 2: Create the Migration File

Create a new SQL file in `db/migration/` with the naming convention:

```
V{version}__{Description}.sql
```

**Example:**
```bash
touch db/migration/V25__Create_new_feature_tables.sql
```

### Step 3: Write the Migration SQL

**Template:**

```sql
-- Agent Mitra - Migration V25: Create New Feature Tables
-- Description: Brief description of what this migration does

-- =====================================================
-- NEW TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS lic_schema.new_table (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_new_table_name ON lic_schema.new_table(name);

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE lic_schema.new_table IS 'Description of the table';
```

### Step 4: Best Practices

#### ✅ DO:
- Use `CREATE TABLE IF NOT EXISTS` to make migrations idempotent
- Always specify the schema: `lic_schema.table_name`
- Include indexes for foreign keys and frequently queried columns
- Add comments for documentation
- Use UUIDs for primary keys: `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
- Include `created_at` and `updated_at` timestamps
- Test migrations on a development database first

#### ❌ DON'T:
- Don't use `DROP TABLE` without careful consideration
- Don't modify existing migrations that have already been applied
- Don't create tables without indexes for foreign keys
- Don't forget to specify the schema name
- Don't use `CREATE TABLE` without `IF NOT EXISTS`

### Step 5: Update SQLAlchemy Models

After creating the migration, update your SQLAlchemy model in `backend/app/models/`:

```python
# backend/app/models/new_feature.py
from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from .base import Base, TimestampMixin

class NewTable(Base, TimestampMixin):
    """New table model"""
    __tablename__ = "new_table"
    __table_args__ = {"schema": "lic_schema"}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
```

**Important:** The model should match the migration exactly. The model is read-only and does NOT create the table.

### Step 6: Run the Migration

**Development:**
```bash
flyway -configFiles=flyway.conf migrate
```

**Verify:**
```bash
# Check migration status
flyway -configFiles=flyway.conf info

# Verify table exists
PGPASSWORD=agentmitra_dev psql -h localhost -U agentmitra -d agentmitra_dev -c "\dt lic_schema.new_table"
```

## Common Migration Patterns

### Adding a Column

```sql
-- Migration V25__Add_column_to_existing_table.sql
ALTER TABLE lic_schema.existing_table 
ADD COLUMN IF NOT EXISTS new_column VARCHAR(100);
```

### Creating Foreign Key

```sql
-- Migration V25__Add_foreign_key.sql
ALTER TABLE lic_schema.child_table
ADD CONSTRAINT fk_child_parent 
FOREIGN KEY (parent_id) 
REFERENCES lic_schema.parent_table(parent_id) 
ON DELETE CASCADE;
```

### Creating Index

```sql
-- Migration V25__Add_indexes.sql
CREATE INDEX IF NOT EXISTS idx_table_column 
ON lic_schema.table_name(column_name);
```

### Creating Enum Type

```sql
-- Migration V25__Create_enum_type.sql
CREATE TYPE lic_schema.status_enum AS ENUM (
    'active', 'inactive', 'pending'
);

-- Use in table
ALTER TABLE lic_schema.table_name
ADD COLUMN status lic_schema.status_enum DEFAULT 'pending';
```

## Migration Commands

### Check Migration Status
```bash
flyway -configFiles=flyway.conf info
```

### Apply Migrations
```bash
flyway -configFiles=flyway.conf migrate
```

### Validate Migrations (without applying)
```bash
flyway -configFiles=flyway.conf validate
```

### Repair Migration History (if corrupted)
```bash
flyway -configFiles=flyway.conf repair
```

### Clean Database (⚠️ DANGEROUS - drops all objects)
```bash
flyway -configFiles=flyway.conf clean
```

## Troubleshooting

### Migration Fails

1. **Check the error message** - Flyway will show the exact SQL error
2. **Verify SQL syntax** - Test the SQL in psql first
3. **Check dependencies** - Ensure referenced tables/columns exist
4. **Review migration history** - Check `flyway_schema_history` table

### Table Already Exists Error

If you get "relation already exists", use `CREATE TABLE IF NOT EXISTS` or check if the migration was partially applied.

### Foreign Key Constraint Error

Ensure:
- Referenced table exists
- Referenced column exists
- Data types match
- Schema name is correct

### Rollback Strategy

**Flyway does NOT support automatic rollbacks.** To rollback:

1. Create a new migration (V26) that reverses the changes
2. Or manually fix the database and mark the migration as repaired:
   ```bash
   flyway -configFiles=flyway.conf repair
   ```

## Migration File Structure

```
db/migration/
├── V1__Create_shared_schema.sql
├── V2__Create_tenant_schemas.sql
├── V3__Create_lic_schema_tables.sql
├── ...
├── V23__Create_campaigns_and_callback_tables.sql
├── V24__Seed_campaigns_and_callbacks_data.sql
└── V25__Create_new_feature_tables.sql  ← Your new migration
```

## Configuration

Migration configuration is in `flyway.conf`:

```properties
flyway.url=jdbc:postgresql://localhost:5432/agentmitra_dev
flyway.user=agentmitra
flyway.password=agentmitra_dev
flyway.schemas=lic_schema
flyway.locations=filesystem:db/migration
flyway.baselineOnMigrate=true
flyway.validateOnMigrate=true
```

## Example: Complete Migration Workflow

```bash
# 1. Check current version
flyway -configFiles=flyway.conf info

# 2. Create migration file
cat > db/migration/V25__Create_example_table.sql << 'EOF'
CREATE TABLE IF NOT EXISTS lic_schema.example_table (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_example_name ON lic_schema.example_table(name);
EOF

# 3. Validate migration
flyway -configFiles=flyway.conf validate

# 4. Apply migration
flyway -configFiles=flyway.conf migrate

# 5. Verify
flyway -configFiles=flyway.conf info
PGPASSWORD=agentmitra_dev psql -h localhost -U agentmitra -d agentmitra_dev -c "\dt lic_schema.example_table"
```

## Summary

✅ **Always use Flyway for schema changes**  
✅ **Test migrations before applying**  
✅ **Keep migrations small and focused**  
✅ **Document your migrations**  
✅ **Version control all migration files**  

❌ **Never use SQLAlchemy create_all() in production**  
❌ **Never modify applied migrations**  
❌ **Never skip migration version numbers**

---

**Last Updated:** 2025-01-XX  
**Current Migration Version:** 24

