import axios from 'axios';

// Use relative URLs for production (when served through Nginx), absolute URLs for development
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? '' // Use relative URLs for production (served through Nginx /api/ proxy)
  : (process.env.REACT_APP_API_URL || 'http://localhost:8012');

export interface Report {
  id: string;
  name: string;
  type: ReportType;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  filters: ReportFilters;
  format: 'pdf' | 'excel' | 'csv';
  createdAt: string;
  completedAt?: string;
  downloadUrl?: string;
  error?: string;
}

export type ReportType =
  | 'customer_summary'
  | 'policy_summary'
  | 'agent_performance'
  | 'revenue_analysis'
  | 'import_statistics'
  | 'custom';

export interface ReportFilters {
  dateFrom?: string;
  dateTo?: string;
  agentCode?: string;
  status?: string;
  [key: string]: any;
}

export interface ScheduledReport {
  id: string;
  reportType: ReportType;
  name: string;
  schedule: ScheduleConfig;
  filters: ReportFilters;
  format: 'pdf' | 'excel' | 'csv';
  recipients: string[];
  isActive: boolean;
  lastRun?: string;
  nextRun?: string;
}

export interface ScheduleConfig {
  frequency: 'daily' | 'weekly' | 'monthly';
  dayOfWeek?: number; // 0-6 for weekly
  dayOfMonth?: number; // 1-31 for monthly
  time: string; // HH:mm format
}

class ReportingApiService {
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

  // Generate report
  async generateReport(
    reportType: ReportType,
    filters: ReportFilters,
    format: 'pdf' | 'excel' | 'csv' = 'pdf'
  ): Promise<Report | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/reports/generate', {
        type: reportType,
        filters,
        format,
      });
      return response.data.data;
    } catch (error) {
      console.error('Failed to generate report:', error);
      throw error;
    }
  }

  // Get report status
  async getReportStatus(reportId: string): Promise<Report | null> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/reports/${reportId}`);
      return response.data.data;
    } catch (error) {
      console.error('Failed to get report status:', error);
      return null;
    }
  }

  // Get report history
  async getReportHistory(
    page: number = 1,
    pageSize: number = 20
  ): Promise<{ data: Report[]; total: number; page: number; pageSize: number; totalPages: number }> {
    try {
      const response = await this.axiosInstance.get('/api/v1/reports/history', {
        params: { page, pageSize },
      });
      return response.data;
    } catch (error) {
      console.error('Failed to fetch report history:', error);
      return {
        data: [],
        total: 0,
        page,
        pageSize,
        totalPages: 0,
      };
    }
  }

  // Download report
  async downloadReport(reportId: string): Promise<Blob | null> {
    try {
      const response = await this.axiosInstance.get(`/api/v1/reports/${reportId}/download`, {
        responseType: 'blob',
      });
      return response.data;
    } catch (error) {
      console.error('Failed to download report:', error);
      return null;
    }
  }

  // Scheduled reports
  async getScheduledReports(): Promise<ScheduledReport[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/reports/scheduled');
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch scheduled reports:', error);
      return [];
    }
  }

  async createScheduledReport(scheduledReport: Partial<ScheduledReport>): Promise<ScheduledReport | null> {
    try {
      const response = await this.axiosInstance.post('/api/v1/reports/scheduled', scheduledReport);
      return response.data.data;
    } catch (error) {
      console.error('Failed to create scheduled report:', error);
      throw error;
    }
  }

  async updateScheduledReport(id: string, scheduledReport: Partial<ScheduledReport>): Promise<ScheduledReport | null> {
    try {
      const response = await this.axiosInstance.put(`/api/v1/reports/scheduled/${id}`, scheduledReport);
      return response.data.data;
    } catch (error) {
      console.error('Failed to update scheduled report:', error);
      throw error;
    }
  }

  async deleteScheduledReport(id: string): Promise<boolean> {
    try {
      await this.axiosInstance.delete(`/api/v1/reports/scheduled/${id}`);
      return true;
    } catch (error) {
      console.error('Failed to delete scheduled report:', error);
      return false;
    }
  }

  // Get available report types
  async getReportTypes(): Promise<{ type: ReportType; name: string; description: string }[]> {
    try {
      const response = await this.axiosInstance.get('/api/v1/reports/types');
      return response.data.data || [];
    } catch (error) {
      console.error('Failed to fetch report types:', error);
      return [];
    }
  }
}

export const reportingApi = new ReportingApiService();

