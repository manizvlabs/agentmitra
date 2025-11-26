import axios from 'axios';
import {
  ImportTemplate,
  ImportFile,
  ImportResult,
  DataImportRequest,
  DataImportResponse,
  ApiResponse,
  PaginatedResponse,
  ImportHistoryItem,
} from '../types/dataImport';

// Use relative URLs for production (when served through Nginx), absolute URLs for development
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? '' // Use relative URLs for production (served through Nginx /api/ proxy)
  : (process.env.REACT_APP_API_URL || 'https://localhost:8012');

class DataImportApiService {
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
          // Handle unauthorized access
          localStorage.removeItem('authToken');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Template Management
  async getTemplates(): Promise<ImportTemplate[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/import/templates');
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch templates:', error);
      return [];
    }
  }

  async createTemplate(template: Partial<ImportTemplate>): Promise<ImportTemplate | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/import/templates', template);
      return response.data.data;
    } catch (error) {
      console.error('Failed to create template:', error);
      throw error;
    }
  }

  async updateTemplate(id: string, template: Partial<ImportTemplate>): Promise<ImportTemplate | null> {
    try {
      const response = await this.axiosInstance.put(`/api/v1/import/templates/${id}`, template);
      return response.data.data;
    } catch (error) {
      console.error('Failed to update template:', error);
      throw error;
    }
  }

  async deleteTemplate(id: string): Promise<boolean> {
    try {
      await this.axiosInstance.delete(`/api/v1/import/templates/${id}`);
      return true;
    } catch (error) {
      console.error('Failed to delete template:', error);
      return false;
    }
  }

  // File Upload and Processing
  async uploadFile(file: File, options?: any): Promise<ImportFile | null> {
    try {
      const formData = new FormData();
      formData.append('file', file);

      if (options) {
        formData.append('options', JSON.stringify(options));
      }

      const response = await this.axiosInstance.post('/api/v1/import/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      return response.data.data;
    } catch (error) {
      console.error('Failed to upload file:', error);
      throw error;
    }
  }

  async processFile(fileId: string, templateId?: string): Promise<ImportFile | null> {
    try {
      const response = await this.axiosInstance.post(`/api/v1/import/process/${fileId}`, {
        templateId,
      });
      return response.data.data;
    } catch (error) {
      console.error('Failed to process file:', error);
      throw error;
    }
  }

  async validateFile(fileId: string, templateId?: string): Promise<ImportResult | null> {
    try {
      const response = await this.axiosInstance.post(`/api/v1/import/validate/${fileId}`, {
        templateId,
      });
      return response.data.data;
    } catch (error) {
      console.error('Failed to validate file:', error);
      throw error;
    }
  }

  // Data Import
  async importData(request: DataImportRequest): Promise<DataImportResponse | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/import/data', request);
      return response.data.data;
    } catch (error) {
      console.error('Failed to import data:', error);
      throw error;
    }
  }

  async getImportStatus(importId: string): Promise<ImportResult | null> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/import/status/${importId}`);
      return response.data.data;
    } catch (error) {
      console.error('Failed to get import status:', error);
      return null;
    }
  }

  // Import History
  async getImportHistory(
    page: number = 1,
    pageSize: number = 10
  ): Promise<PaginatedResponse<ImportHistoryItem>> {
    try {
      const response = await this.axiosInstance.get('/api/v1/import/history', {
        params: { page, pageSize },
      });
      return response.data;
    } catch (error) {
      console.error('Failed to fetch import history:', error);
      return {
        data: [],
        total: 0,
        page,
        pageSize,
        totalPages: 0,
      };
    }
  }

  // Utility Methods
  async getEntityFields(entityType: string): Promise<any[]> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/import/entity-fields/${entityType}`);
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch entity fields:', error);
      return [];
    }
  }

  async getSampleData(entityType: string): Promise<any[][]> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/import/sample-data/${entityType}`);
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch sample data:', error);
      return [];
    }
  }

  // File Download
  async downloadTemplate(entityType: string): Promise<Blob | null> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/import/templates/${entityType}/download`, {
        responseType: 'blob',
      });
      return response.data;
    } catch (error) {
      console.error('Failed to download template:', error);
      return null;
    }
  }

  async downloadImportResults(importId: string): Promise<Blob | null> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/import/results/${importId}/download`, {
        responseType: 'blob',
      });
      return response.data;
    } catch (error) {
      console.error('Failed to download import results:', error);
      return null;
    }
  }
}

export const dataImportApi = new DataImportApiService();
