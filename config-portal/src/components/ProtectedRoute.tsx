import React, { useEffect } from 'react';
import { Navigate } from 'react-router-dom';
import { Box, CircularProgress, Alert } from '@mui/material';
import { useRBAC } from '../contexts/RBACContext';
import { UserRole } from '../types/rbac';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRoles?: UserRole[];
  requiredPermissions?: { resource: string; action: string }[];
  redirectTo?: string;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  requiredRoles,
  requiredPermissions,
  redirectTo = '/login',
}) => {
  const { user, isLoading, isAuthenticated, hasAnyRole, hasPermission } = useRBAC();

  // Show loading spinner while checking authentication
  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  // Redirect to login if not authenticated
  if (!isAuthenticated || !user) {
    return <Navigate to={redirectTo} replace />;
  }

  // Check role requirements
  if (requiredRoles && requiredRoles.length > 0) {
    const hasRequiredRole = hasAnyRole(requiredRoles);
    if (!hasRequiredRole) {
      return (
        <Box sx={{ p: 3 }}>
          <Alert severity="error">
            <strong>Access Denied</strong>
            <br />
            You don't have the required role to access this page.
            <br />
            <em>Required roles: {requiredRoles.join(', ')}</em>
            <br />
            <em>Your roles: {user.roles.join(', ')}</em>
          </Alert>
        </Box>
      );
    }
  }

  // Check permission requirements
  if (requiredPermissions && requiredPermissions.length > 0) {
    const hasAllPermissions = requiredPermissions.every(
      perm => hasPermission(perm.resource, perm.action)
    );

    if (!hasAllPermissions) {
      return (
        <Box sx={{ p: 3 }}>
          <Alert severity="error">
            <strong>Access Denied</strong>
            <br />
            You don't have the required permissions to access this page.
            <br />
            <em>Required permissions:</em>
            <ul style={{ margin: '8px 0', paddingLeft: '20px' }}>
              {requiredPermissions.map((perm, index) => (
                <li key={index}>
                  {perm.resource}: {perm.action}
                </li>
              ))}
            </ul>
          </Alert>
        </Box>
      );
    }
  }

  // All checks passed, render children
  return <>{children}</>;
};

export default ProtectedRoute;

