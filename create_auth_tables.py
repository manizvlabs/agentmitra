import sys
sys.path.append('/app')
from app.core.database import get_db
from sqlalchemy import text

db = next(get_db())
try:
    # Create essential tables for authentication
    sql_statements = [
        # Roles table
        """
        CREATE TABLE IF NOT EXISTS lic_schema.roles (
            role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            role_name VARCHAR(100) UNIQUE NOT NULL,
            display_name VARCHAR(255),
            description TEXT,
            permissions JSONB DEFAULT '[]',
            is_system_role BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """,
        
        # User roles table
        """
        CREATE TABLE IF NOT EXISTS lic_schema.user_roles (
            user_role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
            role_id UUID NOT NULL REFERENCES lic_schema.roles(role_id) ON DELETE CASCADE,
            assigned_by UUID,
            assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, role_id)
        );
        """
    ]
    
    for i, sql in enumerate(sql_statements, 1):
        print(f'Creating table {i}...')
        db.execute(text(sql))
        print(f'✅ Table {i} created')
    
    db.commit()
    print('✅ Essential authentication tables created!')
    
    # Insert basic roles
    roles_sql = """
    INSERT INTO lic_schema.roles (role_name, display_name, description, permissions, is_system_role) VALUES
    ('super_admin', 'Super Administrator', 'Full system access', '["users:*", "roles:*", "permissions:*", "agents:*", "policies:*", "analytics:*", "reports:*", "settings:*", "admin:*", "system:*", "tenants:*"]', true),
    ('insurance_provider_admin', 'Insurance Provider Admin', 'Insurance provider management', '["users:read", "users:update", "agents:*", "policies:*", "analytics:read", "reports:read", "provider:*"]', true),
    ('regional_manager', 'Regional Manager', 'Regional operations management', '["users:read", "agents:read", "agents:update", "policies:read", "policies:update", "analytics:read", "reports:read", "regional:*"]', true),
    ('senior_agent', 'Senior Agent', 'Senior agent with extended permissions', '["users:read", "agents:read", "policies:*", "customers:*", "analytics:read", "agent:*"]', true),
    ('junior_agent', 'Junior Agent', 'Basic agent permissions', '["users:read", "policies:read", "policies:create", "customers:read", "agent:basic"]', true),
    ('policyholder', 'Policyholder', 'Policy holder access', '["policies:read", "profile:*", "support:read"]', true),
    ('support_staff', 'Support Staff', 'Customer support access', '["users:read", "policies:read", "customers:*", "support:*", "analytics:read"]', true)
    ON CONFLICT (role_name) DO NOTHING;
    """
    
    db.execute(text(roles_sql))
    db.commit()
    print('✅ System roles inserted!')
    
    # Now assign super_admin role to existing users
    assign_role_sql = """
    INSERT INTO lic_schema.user_roles (user_id, role_id, assigned_by)
    SELECT u.user_id, r.role_id, u.user_id
    FROM lic_schema.users u
    CROSS JOIN lic_schema.roles r
    WHERE u.role = 'super_admin' AND r.role_name = 'super_admin'
    ON CONFLICT (user_id, role_id) DO NOTHING;
    """
    
    db.execute(text(assign_role_sql))
    db.commit()
    print('✅ Super admin role assigned to existing super_admin users!')
    
except Exception as e:
    print(f'❌ Error: {e}')
    import traceback
    traceback.print_exc()
    db.rollback()
finally:
    db.close()
