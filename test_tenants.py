#!/usr/bin/env python3
import sys
sys.path.append('/Users/manish/Documents/GitHub/zero/agentmitra/backend')

from app.core.database import SessionLocal
from app.models.shared import Tenant

def test_tenants():
    try:
        session = SessionLocal()
        tenants = session.query(Tenant).all()
        print(f'Found {len(tenants)} tenants in database')

        for tenant in tenants[:5]:
            print(f'ID: {tenant.tenant_id}, Name: {tenant.tenant_name}, Code: {tenant.tenant_code}')

        session.close()
        return True
    except Exception as e:
        print(f'Error: {e}')
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    test_tenants()
