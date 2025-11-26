import axios from 'axios';

// Use relative URLs for production (when served through Nginx), absolute URLs for development
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? '' // Use relative URLs for production (served through Nginx /api/ proxy)
  : (process.env.REACT_APP_API_URL || 'http://localhost:8012');

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone?: string;
  role: UserRole;
  agentCode?: string;
  isActive: boolean;
  lastLoginAt?: string;
  createdAt: string;
  updatedAt: string;
  permissions?: Permission[];
}

export type UserRole =
  | 'super_admin'
  | 'insurance_provider_admin'
  | 'regional_manager'
  | 'senior_agent'
  | 'junior_agent'
  | 'support_staff';

export interface Permission {
  resource: string;
  actions: string[];
}

export interface UserFilters {
  search?: string;
  role?: UserRole;
  isActive?: boolean;
  agentCode?: string;
}

export interface UserActivityLog {
  id: string;
  userId: string;
  userName: string;
  action: string;
  resource: string;
  resourceId?: string;
  details?: any;
  ipAddress?: string;
  userAgent?: string;
  timestamp: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

class UserApiService {
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
        const token = localStorage.getItem('authToken');
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
          localStorage.removeItem('authToken');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Get users with filters and pagination
  async getUsers(
    page: number = 1,
    pageSize: number = 20,
    filters?: UserFilters
  ): Promise<PaginatedResponse<User>> {
    try {
      const response = await this.axiosInstance.get('/api/v1/users', {
        params: { page, pageSize, ...filters },
      });
      return response.data;
    } catch (error) {
      console.error('Failed to fetch users:', error);
      return {
        data: [],
        total: 0,
        page,
        pageSize,
        totalPages: 0,
      };
    }
  }

  // Get single user by ID
  async getUser(id: string): Promise<User | null> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/users/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('Failed to fetch user:', error);
      return null;
    }
  }

  // Create new user
  async createUser(user: Partial<User> & { password: string }): Promise<User | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/users', user);
      return response.data.data;
    } catch (error) {
      console.error('Failed to create user:', error);
      throw error;
    }
  }

  // Update user
  async updateUser(id: string, user: Partial<User>): Promise<User | null> {
    try {
      const response = await this.axiosInstance.put(`/api/v1/users/${id}`, user);
      return response.data.data;
    } catch (error) {
      console.error('Failed to update user:', error);
      throw error;
    }
  }

  // Delete user
  async deleteUser(id: string): Promise<boolean> {
    try {
      await this.axiosInstance.delete(`/api/v1/users/${id}`);
      return true;
    } catch (error) {
      console.error('Failed to delete user:', error);
      return false;
    }
  }

  // Update user permissions
  async updateUserPermissions(id: string, permissions: Permission[]): Promise<User | null> {
    try {
      const response = await this.axiosInstance.put(`/api/v1/users/${id}/permissions`, { permissions });
      return response.data.data;
    } catch (error) {
      console.error('Failed to update user permissions:', error);
      throw error;
    }
  }

  // Get user activity logs
  async getUserActivityLogs(
    userId?: string,
    page: number = 1,
    pageSize: number = 50
  ): Promise<PaginatedResponse<UserActivityLog>> {
    try {
      const response = await this.axiosInstance.get('/api/v1/users/activity-logs', {
        params: { userId, page, pageSize },
      });
      return response.data;
    } catch (error) {
      console.error('Failed to fetch activity logs:', error);
      return {
        data: [],
        total: 0,
        page,
        pageSize,
        totalPages: 0,
      };
    }
  }

  // Get available roles
  async getRoles(): Promise<{ role: UserRole; name: string; description: string }[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/users/roles');
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch roles:', error);
      return [];
    }
  }

  // Reset user password
  async resetPassword(id: string, newPassword: string): Promise<boolean> {
    try {
      await this.axiosInstance.post(`/api/v1/users/${id}/reset-password`, { password: newPassword });
      return true;
    } catch (error) {
      console.error('Failed to reset password:', error);
      return false;
    }
  }
}

export const userApi = new UserApiService();

