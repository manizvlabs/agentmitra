import axios from 'axios';

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
  user: {
    user_id: string;
    phone_number?: string;
    email?: string;
    first_name?: string;
    last_name?: string;
    display_name?: string;
    role: string;
  };
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
  : (process.env.REACT_APP_API_URL || 'http://localhost:8012');

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

    // Add response interceptor for token refresh
    this.axiosInstance.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          // Token expired, try to refresh
          const refreshToken = localStorage.getItem('refresh_token');
          if (refreshToken) {
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
                throw new Error('Invalid refresh token response');
              }
            } catch (refreshError) {
              // Refresh failed, logout user
              this.logout();
              throw refreshError;
            }
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
    return response.data;
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

  // Utility methods
  isAuthenticated(): boolean {
    const token = localStorage.getItem('access_token');
    return !!token;
  }

  getCurrentUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  }

  setAuthData(authResponse: AuthResponse) {
    localStorage.setItem('access_token', authResponse.access_token);
    localStorage.setItem('refresh_token', authResponse.refresh_token);
    localStorage.setItem('user', JSON.stringify(authResponse.user));
  }
}

export const authApi = new AuthApiService();
