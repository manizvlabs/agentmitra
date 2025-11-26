// RBAC Types for Agent Mitra Configuration Portal
// Based on backend API responses - NO HARDCODING

export type UserRole = string; // Dynamic from backend

export interface Permission {
  resource: string;
  actions: string[];
}

export interface RBACUser {
  user_id: string;
  phone_number?: string;
  email?: string;
  first_name?: string;
  last_name?: string;
  display_name?: string;
  role: string; // Primary role from backend
  roles: string[]; // Array of all roles from JWT
  permissions: Permission[] | string[]; // Array of permission objects or strings from JWT
  tenant_id?: string;
  agent_code?: string;
  is_active: boolean;
  last_login_at?: string;
  // Additional fields from backend
  trial_status?: any;
  feature_flags?: Record<string, any>;
}

export interface RoleDefinition {
  role_id: string;
  role_name: string;
  description?: string;
  is_system_role: boolean;
}

export interface FeatureFlag {
  flag_id: string;
  flag_name: string;
  is_enabled: boolean;
  tenant_id?: string;
  created_at: string;
  updated_at: string;
}

export interface FeatureFlag {
  name: string;
  enabled: boolean;
  tenant_id?: string;
  user_role?: UserRole;
}

// Dynamic permission checking functions

// Helper functions for permission checking based on backend data
export const hasPermission = (
  user: RBACUser | null,
  resource: string,
  action: string
): boolean => {
  if (!user) return false;

  // Super admin has all permissions
  if (user.roles.includes('super_admin')) return true;

  // Check permissions array from JWT (these are strings like "users.read", "policies.create")
  const requiredPermission = `${resource}.${action}`;

  // Handle both string[] and Permission[] types
  if (Array.isArray(user.permissions)) {
    return user.permissions.some(perm => {
      if (typeof perm === 'string') {
        return perm === requiredPermission || perm === '*';
      } else {
        return perm.resource === resource && perm.actions.includes(action);
      }
    });
  }

  return false;
};

export const hasAnyRole = (user: RBACUser | null, roles: string[]): boolean => {
  if (!user) return false;
  return user.roles.some(role => roles.includes(role));
};

export const hasRole = (user: RBACUser | null, role: string): boolean => {
  if (!user) return false;
  return user.roles.includes(role);
};

export const canAccessFeature = (
  user: RBACUser | null,
  featurePath: string
): boolean => {
  if (!user) return false;

  // Super admin has access to everything
  if (user.roles.includes('super_admin')) return true;

  // Map feature paths to required permissions
  const featurePermissionMap: Record<string, string[]> = {
    // Customer Portal Features
    'customerPortal.dashboard': ['profile.read'],
    'customerPortal.policyManagement': ['policies.read', 'policies.update'],
    'customerPortal.premiumPayments': ['policies.update'],
    'customerPortal.documentAccess': ['policies.read'],
    'customerPortal.communicationTools': ['profile.read'],
    'customerPortal.learningCenter': ['profile.read'],
    'customerPortal.profileManagement': ['profile.update'],

    // Agent Portal Features
    'agentPortal.customerManagement': ['agents.read', 'agents.update'],
    'agentPortal.marketingCampaigns': ['campaigns.read', 'campaigns.create'],
    'agentPortal.contentManagement': ['content.read', 'content.create'],
    'agentPortal.roiAnalytics': ['analytics.read'],
    'agentPortal.commissionTracking': ['analytics.read'],
    'agentPortal.leadManagement': ['leads.read', 'leads.update'],

    // Administrative Features
    'administration.userManagement': ['users.read', 'users.create', 'users.update'],
    'administration.featureFlagControl': ['feature_flags.update'],
    'administration.systemConfiguration': ['system.config'],
    'administration.auditCompliance': ['audit.read'],
    'administration.financialManagement': ['financial.read'],
    'administration.tenantManagement': ['tenants.read', 'tenants.update'],
    'administration.providerAdministration': ['providers.read', 'providers.update'],

    // Data Import Features
    'dataImport.excelImport': ['data_import.create'],
    'dataImport.licApiSync': ['lic_api.sync'],
    'dataImport.bulkUpdate': ['data_import.update'],
    'dataImport.templateManagement': ['templates.read', 'templates.create'],

    // Reporting Features
    'reporting.generateReports': ['reports.generate'],
    'reporting.scheduledReports': ['reports.schedule'],
    'reporting.exportData': ['reports.export'],
  };

  const requiredPermissions = featurePermissionMap[featurePath];
  if (!requiredPermissions) return false;

  // Check if user has any of the required permissions
  if (Array.isArray(user.permissions)) {
    return requiredPermissions.some(requiredPerm =>
      user.permissions.some(userPerm => {
        if (typeof userPerm === 'string') {
          return userPerm === requiredPerm || userPerm === '*';
        } else {
          return userPerm.resource === requiredPerm.split('.')[0] &&
                 userPerm.actions.includes(requiredPerm.split('.')[1]);
        }
      })
    );
  }

  return false;
};

// Route protection helpers
export const getAccessibleRoutes = (user: RBACUser | null): string[] => {
  if (!user) return ['/login'];

  const routes: string[] = [];

  // Dashboard - accessible to all authenticated users
  routes.push('/dashboard');

  // Data Import - agent roles and above
  if (canAccessFeature(user, 'dataImport.excelImport')) {
    routes.push('/data-import', '/excel-template');
  }

  // Customer Management - agent roles and above
  if (canAccessFeature(user, 'agentPortal.customerManagement')) {
    routes.push('/customers');
  }

  // Reporting - various roles
  if (canAccessFeature(user, 'reporting.generateReports')) {
    routes.push('/reporting');
  }

  // User Management - admin roles
  if (canAccessFeature(user, 'administration.userManagement')) {
    routes.push('/users');
  }

  // Campaigns - agent roles
  if (canAccessFeature(user, 'agentPortal.marketingCampaigns')) {
    routes.push('/campaigns');
  }

  // Callbacks - agent roles
  if (canAccessFeature(user, 'agentPortal.customerManagement')) {
    routes.push('/callbacks');
  }

  // Settings - all authenticated users
  routes.push('/settings');

  return routes;
};

// Page access helpers for specific pages
export const canAccessPage = (user: RBACUser | null, page: string): boolean => {
  if (!user) return false;

  const accessibleRoutes = getAccessibleRoutes(user);
  return accessibleRoutes.includes(page);
};

