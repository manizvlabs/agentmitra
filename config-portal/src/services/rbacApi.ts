import axios from 'axios';
import { RoleDefinition, FeatureFlag } from '../types/rbac';

// Use relative URLs for production (when served through Nginx), absolute URLs for development
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? '' // Use relative URLs for production (served through Nginx /api/ proxy)
  : (process.env.REACT_APP_API_URL || 'https://localhost:8012');

class RBACApiService {
  private axiosInstance = axios.create({
    baseURL: API_BASE_URL,
    timeout: 30000,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  constructor() {
    // Add request interceptor for authentication
    this.axiosInstance.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('access_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Add response interceptor for error handling
    this.axiosInstance.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          localStorage.removeItem('access_token');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Get all available roles
  async getRoles(): Promise<RoleDefinition[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/rbac/roles');
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch roles:', error);
      return [];
    }
  }

  // Get permissions for a specific role
  async getRolePermissions(roleName: string): Promise<string[]> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/rbac/roles/${roleName}/permissions`);
      return response.data.data || [];
    } catch (error) {
      console.error(`Failed to fetch permissions for role ${roleName}:`, error);
      return [];
    }
  }

  // Get all available permissions
  async getAllPermissions(): Promise<string[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/rbac/permissions');
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch all permissions:', error);
      return [];
    }
  }

  // Get feature flags
  async getFeatureFlags(): Promise<FeatureFlag[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/rbac/feature-flags');
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch feature flags:', error);
      return [];
    }
  }

  // Check if user has permission (server-side check)
  async checkPermission(resource: string, action: string): Promise<boolean> {
    try {
      const response = await this.axiosInstance.post('/api/v1/rbac/check-permission', {
        resource,
        action,
      });
      return response.data.hasPermission || false;
    } catch (error) {
      console.error('Failed to check permission:', error);
      return false;
    }
  }

  // Get user's effective permissions (server-side)
  async getUserEffectivePermissions(): Promise<string[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/rbac/user-permissions');
      return response.data.permissions || [];
    } catch (error) {
      console.error('Failed to fetch user permissions:', error);
      return [];
    }
  }

  // Role management (admin only)
  async createRole(roleData: Partial<RoleDefinition>): Promise<RoleDefinition | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/rbac/roles', roleData);
      return response.data.data;
    } catch (error) {
      console.error('Failed to create role:', error);
      throw error;
    }
  }

  async updateRole(roleId: string, roleData: Partial<RoleDefinition>): Promise<RoleDefinition | null> {
    try {
      const response = await this.axiosInstance.put(`/api/v1/rbac/roles/${roleId}`, roleData);
      return response.data.data;
    } catch (error) {
      console.error('Failed to update role:', error);
      throw error;
    }
  }

  async deleteRole(roleId: string): Promise<boolean> {
    try {
      await this.axiosInstance.delete(`/api/v1/rbac/roles/${roleId}`);
      return true;
    } catch (error) {
      console.error('Failed to delete role:', error);
      return false;
    }
  }

  async assignRoleToUser(userId: string, roleName: string): Promise<boolean> {
    try {
      await this.axiosInstance.post('/api/v1/rbac/users/assign-role', {
        user_id: userId,
        role_name: roleName,
      });
      return true;
    } catch (error) {
      console.error('Failed to assign role to user:', error);
      return false;
    }
  }

  async removeRoleFromUser(userId: string, roleName: string): Promise<boolean> {
    try {
      await this.axiosInstance.post('/api/v1/rbac/users/remove-role', {
        user_id: userId,
        role_name: roleName,
      });
      return true;
    } catch (error) {
      console.error('Failed to remove role from user:', error);
      return false;
    }
  }

  // Feature flag management
  async createFeatureFlag(flagData: Partial<FeatureFlag>): Promise<FeatureFlag | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/rbac/feature-flags', flagData);
      return response.data.data;
    } catch (error) {
      console.error('Failed to create feature flag:', error);
      throw error;
    }
  }

  async updateFeatureFlag(flagId: string, flagData: Partial<FeatureFlag>): Promise<FeatureFlag | null> {
    try {
      const response = await this.axiosInstance.put(`/api/v1/rbac/feature-flags/${flagId}`, flagData);
      return response.data.data;
    } catch (error) {
      console.error('Failed to update feature flag:', error);
      throw error;
    }
  }

  async deleteFeatureFlag(flagId: string): Promise<boolean> {
    try {
      await this.axiosInstance.delete(`/api/v1/rbac/feature-flags/${flagId}`);
      return true;
    } catch (error) {
      console.error('Failed to delete feature flag:', error);
      return false;
    }
  }
}

export const rbacApi = new RBACApiService();

