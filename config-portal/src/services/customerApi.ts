import axios from 'axios';

// Use relative URLs for production (when served through Nginx), absolute URLs for development
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? '' // Use relative URLs for production (served through Nginx /api/ proxy)
  : (process.env.REACT_APP_API_URL || 'https://localhost:8012');

export interface Customer {
  id: string;
  fullName: string;
  email: string;
  phone: string;
  dateOfBirth?: string;
  gender?: string;
  occupation?: string;
  annualIncome?: number;
  address?: string;
  city?: string;
  state?: string;
  pincode?: string;
  agentCode?: string;
  status: 'active' | 'inactive' | 'pending';
  createdAt: string;
  updatedAt: string;
}

export interface CustomerFilters {
  search?: string;
  status?: string;
  agentCode?: string;
  city?: string;
  state?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

class CustomerApiService {
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

  // Get customers with filters and pagination
  async getCustomers(
    page: number = 1,
    pageSize: number = 20,
    filters?: CustomerFilters
  ): Promise<PaginatedResponse<Customer>> {
    try {
      const response = await this.axiosInstance.get('/api/v1/customers', {
        params: { page, pageSize, ...filters },
      });
      return response.data;
    } catch (error) {
      console.error('Failed to fetch customers:', error);
      return {
        data: [],
        total: 0,
        page,
        pageSize,
        totalPages: 0,
      };
    }
  }

  // Get single customer by ID
  async getCustomer(id: string): Promise<Customer | null> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/customers/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('Failed to fetch customer:', error);
      return null;
    }
  }

  // Create new customer
  async createCustomer(customer: Partial<Customer>): Promise<Customer | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/customers', customer);
      return response.data.data;
    } catch (error) {
      console.error('Failed to create customer:', error);
      throw error;
    }
  }

  // Update customer
  async updateCustomer(id: string, customer: Partial<Customer>): Promise<Customer | null> {
    try {
      const response = await this.axiosInstance.put(`/api/v1/customers/${id}`, customer);
      return response.data.data;
    } catch (error) {
      console.error('Failed to update customer:', error);
      throw error;
    }
  }

  // Delete customer
  async deleteCustomer(id: string): Promise<boolean> {
    try {
      await this.axiosInstance.delete(`/api/v1/customers/${id}`);
      return true;
    } catch (error) {
      console.error('Failed to delete customer:', error);
      return false;
    }
  }

  // Bulk operations
  async bulkDelete(ids: string[]): Promise<boolean> {
    try {
      await this.axiosInstance.post('/api/v1/customers/bulk/delete', { ids });
      return true;
    } catch (error) {
      console.error('Failed to bulk delete customers:', error);
      return false;
    }
  }

  async bulkUpdate(ids: string[], updates: Partial<Customer>): Promise<boolean> {
    try {
      await this.axiosInstance.post('/api/v1/customers/bulk/update', { ids, updates });
      return true;
    } catch (error) {
      console.error('Failed to bulk update customers:', error);
      return false;
    }
  }

  // Export customers
  async exportCustomers(format: 'csv' | 'excel' | 'pdf', filters?: CustomerFilters): Promise<Blob | null> {
    try {
      const response = await this.axiosInstance.get('/api/v1/customers/export', {
        params: { format, ...filters },
        responseType: 'blob',
      });
      return response.data;
    } catch (error) {
      console.error('Failed to export customers:', error);
      return null;
    }
  }
}

export const customerApi = new CustomerApiService();

