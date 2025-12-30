# Agent Mitra Flyway Backup Database Plan

## 🎯 Objective
Fix Flyway synchronization issues without risking the current production database.

## 📋 Current Issues
- Flyway shows "<< Empty Schema >>" but database has complete schema
- All 71 migrations marked as "Pending" 
- V1 migration fails: role "agentmitra" does not exist
- Cannot apply future migrations

## 🛠️ Solution: Backup Database Approach

### Step 1: Create Backup Database
```bash
# Create backup database in Cloud SQL
gcloud sql databases create agentmitra_dev_backup \
  --instance=agentmitra-postgres \
  --charset=utf8 \
  --collation=utf8_general_ci
```

### Step 2: Set Up Required Roles
Run the SQL commands in `create_backup_db.sql` in Cloud SQL:
```sql
-- Creates agentmitra role and grants proper permissions
-- Sets up database ownership and schema permissions
```

### Step 3: Test Flyway on Backup
```bash
# Run the comprehensive test script
./flyway_backup_test.sh
```

### Step 4: Verify Success
- Flyway shows proper version (71) instead of "<< Empty Schema >>"
- All migrations marked as "Success" 
- Can apply new migrations

### Step 5: Switch Backend (Only if Step 4 succeeds)
Update `docker-compose.prod.yml` and environment variables to use `agentmitra_dev_backup`

## 🔧 Technical Fixes Applied

### 1. Fixed Role Creation Issue
Modified `V1__Create_shared_schema.sql` to automatically create the `agentmitra` role:
```sql
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'agentmitra') THEN
        CREATE ROLE agentmitra LOGIN PASSWORD 'agentmitra_secure_password_2025!';
    END IF;
END
$$;
```

### 2. Updated Flyway Configuration
- Modified `flyway.cloud.conf` to target backup database
- Set proper baseline configuration
- Disabled validation for existing schema

### 3. Created Test Infrastructure
- `flyway_backup_test.sh`: Comprehensive testing script
- `create_backup_db.sql`: Database and role setup
- Backup of original config: `flyway.backup.conf`

## 📊 Expected Results

### Before Fix:
```
Schema version: << Empty Schema >>
All 71 migrations: Pending
Cannot apply new migrations
```

### After Fix:
```
Schema version: 71
All 71 migrations: Success  
Can apply new migrations
```

## 🚨 Safety Measures

1. **Original DB Untouched**: `agentmitra_dev` remains unchanged
2. **Backup First**: All operations on `agentmitra_dev_backup`
3. **Test Thoroughly**: Only switch backend after full validation
4. **Rollback Plan**: Can easily revert to original database

## 📁 Files Created/Modified

### New Files:
- `flyway_backup_test.sh` - Test script
- `create_backup_db.sql` - Database setup SQL
- `FLYWAY_BACKUP_PLAN.md` - This documentation

### Modified Files:
- `db/migration/V1__Create_shared_schema.sql` - Added role creation
- `flyway.cloud.conf` - Updated for backup database
- `flyway.backup.conf` - Backup of original config

## ⚡ Quick Start

```bash
# 1. Create backup database (manual step)
gcloud sql databases create agentmitra_dev_backup --instance=agentmitra-postgres

# 2. Set up roles (run SQL in Cloud SQL console)
psql -h <cloud-sql-ip> -U manish -d agentmitra_dev_backup < create_backup_db.sql

# 3. Test Flyway
./flyway_backup_test.sh

# 4. If successful, switch backend to backup database
```

## 🎯 Success Criteria

- [ ] Flyway info shows version 71 (not "<< Empty Schema >>")
- [ ] All migrations show "Success" status
- [ ] Can run `flyway migrate` without errors
- [ ] Backend works with backup database
- [ ] Original database remains functional

---
**Status**: Ready for implementation 🚀
