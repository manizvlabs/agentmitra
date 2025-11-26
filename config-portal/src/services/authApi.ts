import axios from 'axios';
// @ts-ignore
import { jwtDecode } from 'jwt-decode';
import { RBACUser, UserRole, Permission } from '../types/rbac';

export interface JWTToken {
  sub: string; // user_id
  roles: UserRole[]; // Array of roles
  permissions: Permission[]; // Array of permissions
  tenant_id?: string;
  exp: number;
  iat: number;
}

export interface LoginRequest {
  phone_number?: string;
  password?: string;
  agent_code?: string;
}

export interface OTPRequest {
  phone_number: string;
}

export interface OTPVerifyRequest {
  phone_number: string;
  otp: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  user: RBACUser;
  permissions?: string[]; // From backend response
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

// Use relative URLs for production (when served through Nginx), absolute URLs for development
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? '' // Use relative URLs for production (served through Nginx /api/ proxy)
  : (process.env.REACT_APP_API_URL || 'https://localhost:8012');

class AuthApiService {
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

    // Add response interceptor for token refresh and error handling
    this.axiosInstance.interceptors.response.use(
      (response) => response,
      async (error) => {
        // Handle network errors
        if (!error.response) {
          console.error('Network error:', error.message);
          throw new Error('Unable to connect to server. Please check your connection.');
        }

        if (error.response?.status === 401) {
          // Token expired, try to refresh (but not for auth endpoints)
          const isAuthEndpoint = error.config?.url?.includes('/auth/');
          const refreshToken = localStorage.getItem('refresh_token');
          
          if (!isAuthEndpoint && refreshToken) {
            try {
              const refreshResponse = await this.refreshToken(refreshToken);
              // Check if response data exists and has required fields
              if (refreshResponse && refreshResponse.data && refreshResponse.data.access_token && refreshResponse.data.refresh_token) {
                localStorage.setItem('access_token', refreshResponse.data.access_token);
                localStorage.setItem('refresh_token', refreshResponse.data.refresh_token);

                // Retry the original request
                if (error.config && error.config.headers) {
                  error.config.headers.Authorization = `Bearer ${refreshResponse.data.access_token}`;
                  return this.axiosInstance(error.config);
                }
              } else {
                // Invalid refresh response, logout user
                this.logout();
                throw new Error('Session expired. Please login again.');
              }
            } catch (refreshError) {
              // Refresh failed, logout user
              this.logout();
              throw refreshError;
            }
          } else {
            // No refresh token or auth endpoint - logout
            this.logout();
          }
        }
        return Promise.reject(error);
      }
    );
  }

  // Authentication methods
  async login(credentials: LoginRequest): Promise<ApiResponse<AuthResponse>> {
    const response = await this.axiosInstance.post('/api/v1/auth/login', credentials);
    return response.data;
  }

  async sendOtp(phoneNumber: string): Promise<ApiResponse<any>> {
    const response = await this.axiosInstance.post('/api/v1/auth/send-otp', {
      phone_number: phoneNumber
    });
    return response.data;
  }

  async verifyOtp(phoneNumber: string, otp: string): Promise<ApiResponse<AuthResponse>> {
    const response = await this.axiosInstance.post('/api/v1/auth/verify-otp', {
      phone_number: phoneNumber,
      otp: otp
    });
    // Backend returns TokenResponse directly, wrap it in ApiResponse format
    const tokenResponse = response.data;
    return {
      success: true,
      data: {
        access_token: tokenResponse.access_token,
        refresh_token: tokenResponse.refresh_token,
        token_type: tokenResponse.token_type || 'bearer',
        user: tokenResponse.user
      }
    };
  }

  async refreshToken(refreshToken: string): Promise<ApiResponse<AuthResponse>> {
    const response = await this.axiosInstance.post('/api/v1/auth/refresh', {
      refresh_token: refreshToken
    });
    return response.data;
  }

  async logout(): Promise<void> {
    try {
      await this.axiosInstance.post('/api/v1/auth/logout');
    } catch (error) {
      // Ignore logout errors
    } finally {
      // Clear local storage
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
      localStorage.removeItem('user');
    }
  }

  // JWT Token decoding
  private decodeJWT(token: string): JWTToken | null {
    try {
      // @ts-ignore
      const decoded = jwtDecode(token) as JWTToken;
      return decoded;
    } catch (error) {
      console.error('Failed to decode JWT:', error);
      return null;
    }
  }

  private getUserFromToken(token: string): RBACUser | null {
    const decoded = this.decodeJWT(token);
    if (!decoded) return null;

    // Get user data from localStorage (set during login)
    const userStr = localStorage.getItem('user');
    const userData = userStr ? JSON.parse(userStr) : {};

    // Merge JWT data with user data
    return {
      ...userData,
      user_id: decoded.sub,
      roles: decoded.roles || [], // Array of roles from JWT
      permissions: decoded.permissions || [], // Array of permissions from JWT (string[])
      tenant_id: decoded.tenant_id,
    };
  }

  // Utility methods
  isAuthenticated(): boolean {
    const token = localStorage.getItem('access_token');
    if (!token) return false;

    try {
      const decoded = this.decodeJWT(token);
      if (!decoded) return false;

      // Check if token is expired
      const currentTime = Date.now() / 1000;
      return decoded.exp > currentTime;
    } catch (error) {
      return false;
    }
  }

  getCurrentUser(): RBACUser | null {
    const token = localStorage.getItem('access_token');
    if (!token) return null;

    return this.getUserFromToken(token);
  }

  getUserRoles(): UserRole[] {
    const user = this.getCurrentUser();
    return user?.roles || [];
  }

  getUserPermissions(): string[] | Permission[] {
    const user = this.getCurrentUser();
    return user?.permissions || [];
  }

  hasRole(role: UserRole): boolean {
    const roles = this.getUserRoles();
    return roles.includes(role);
  }

  hasPermission(resource: string, action: string): boolean {
    const permissions = this.getUserPermissions();
    const requiredPermission = `${resource}.${action}`;

    return permissions.some(perm => {
      if (typeof perm === 'string') {
        return perm === requiredPermission || perm === '*';
      } else {
        return perm.resource === resource && perm.actions.includes(action);
      }
    });
  }

  hasAnyRole(roles: UserRole[]): boolean {
    const userRoles = this.getUserRoles();
    return userRoles.some(role => roles.includes(role));
  }

  setAuthData(authResponse: AuthResponse) {
    localStorage.setItem('access_token', authResponse.access_token);
    localStorage.setItem('refresh_token', authResponse.refresh_token);
    localStorage.setItem('user', JSON.stringify(authResponse.user));
  }
}

export const authApi = new AuthApiService();
