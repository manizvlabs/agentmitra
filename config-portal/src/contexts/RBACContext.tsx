import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { RBACUser, UserRole, Permission, hasPermission, hasRole, hasAnyRole, canAccessFeature, getAccessibleRoutes } from '../types/rbac';
import { authApi } from '../services/authApi';
import { rbacApi } from '../services/rbacApi';

interface RBACContextType {
  user: RBACUser | null;
  availableRoles: string[];
  availablePermissions: string[];
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (user: RBACUser) => void;
  logout: () => void;
  hasRole: (role: string) => boolean;
  hasAnyRole: (roles: string[]) => boolean;
  hasPermission: (resource: string, action: string) => boolean;
  canAccessFeature: (featurePath: string) => boolean;
  getAccessibleRoutes: () => string[];
  refreshUser: () => void;
  refreshRBACData: () => Promise<void>;
}

const RBACContext = createContext<RBACContextType | undefined>(undefined);

interface RBACProviderProps {
  children: ReactNode;
}

export const RBACProvider: React.FC<RBACProviderProps> = ({ children }) => {
  const [user, setUser] = useState<RBACUser | null>(null);
  const [availableRoles, setAvailableRoles] = useState<string[]>([]);
  const [availablePermissions, setAvailablePermissions] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const refreshRBACData = async () => {
    try {
      // Load available roles and permissions from backend
      const [rolesData, permissionsData] = await Promise.all([
        rbacApi.getRoles(),
        rbacApi.getAllPermissions(),
      ]);

      setAvailableRoles(rolesData.map(role => role.role_name));
      setAvailablePermissions(permissionsData);
    } catch (error) {
      console.warn('Failed to load RBAC data from backend, using fallback:', error);
      // Set empty arrays as fallback - don't throw error
      setAvailableRoles([]);
      setAvailablePermissions([]);
      // Don't re-throw the error so the login can continue
    }
  };

  useEffect(() => {
    // Check authentication status on mount
    const initializeAuth = async () => {
      const currentUser = authApi.getCurrentUser();
      const authenticated = authApi.isAuthenticated();

      if (authenticated && currentUser) {
        setUser(currentUser);
        // Only load RBAC data when user is authenticated (don't fail if it doesn't work)
        try {
          await refreshRBACData();
        } catch (error) {
          console.warn('Failed to load RBAC data, continuing with basic permissions:', error);
          // Set empty arrays as fallback
          setAvailableRoles([]);
          setAvailablePermissions([]);
        }
      } else {
        setUser(null);
        // Clear RBAC data when not authenticated
        setAvailableRoles([]);
        setAvailablePermissions([]);
      }

      setIsLoading(false);
    };

    initializeAuth();

    // Listen for storage changes (for multi-tab logout)
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === 'access_token' && !e.newValue) {
        setUser(null);
        // Clear RBAC data when logged out
        setAvailableRoles([]);
        setAvailablePermissions([]);
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, []);

  const login = (userData: RBACUser) => {
    setUser(userData);
  };

  const logout = async () => {
    try {
      await authApi.logout();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      setUser(null);
    }
  };

  const refreshUser = () => {
    const currentUser = authApi.getCurrentUser();
    const authenticated = authApi.isAuthenticated();

    if (authenticated && currentUser) {
      setUser(currentUser);
    } else {
      setUser(null);
    }
  };

  const value: RBACContextType = {
    user,
    availableRoles,
    availablePermissions,
    isLoading,
    isAuthenticated: !!user,
    login,
    logout,
    hasRole: (role: string) => hasRole(user, role),
    hasAnyRole: (roles: string[]) => hasAnyRole(user, roles),
    hasPermission: (resource: string, action: string) => hasPermission(user, resource, action),
    canAccessFeature: (featurePath: string) => canAccessFeature(user, featurePath),
    getAccessibleRoutes: () => getAccessibleRoutes(user),
    refreshUser,
    refreshRBACData,
  };

  return (
    <RBACContext.Provider value={value}>
      {children}
    </RBACContext.Provider>
  );
};

export const useRBAC = (): RBACContextType => {
  const context = useContext(RBACContext);
  if (context === undefined) {
    throw new Error('useRBAC must be used within an RBACProvider');
  }
  return context;
};

// Higher-order component for route protection
export const withRBAC = (
  WrappedComponent: React.ComponentType<any>,
  requiredRoles?: UserRole[],
  requiredPermissions?: { resource: string; action: string }[]
) => {
  return (props: any) => {
    const { user, isLoading, hasAnyRole, hasPermission } = useRBAC();

    if (isLoading) {
      return (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
          Loading...
        </div>
      );
    }

    if (!user) {
      window.location.href = '/login';
      return null;
    }

    // Check role requirements
    if (requiredRoles && requiredRoles.length > 0 && !hasAnyRole(requiredRoles)) {
      return (
        <div style={{ padding: '20px', textAlign: 'center' }}>
          <h2>Access Denied</h2>
          <p>You don't have the required role to access this page.</p>
          <p>Required roles: {requiredRoles.join(', ')}</p>
        </div>
      );
    }

    // Check permission requirements
    if (requiredPermissions && requiredPermissions.length > 0) {
      const hasAllPermissions = requiredPermissions.every(
        perm => hasPermission(perm.resource, perm.action)
      );

      if (!hasAllPermissions) {
        return (
          <div style={{ padding: '20px', textAlign: 'center' }}>
            <h2>Access Denied</h2>
            <p>You don't have the required permissions to access this page.</p>
          </div>
        );
      }
    }

    return <WrappedComponent {...props} />;
  };
};

