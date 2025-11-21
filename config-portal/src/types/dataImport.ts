// Data Import Types for Agent Configuration Portal

export interface ImportTemplate {
  id: string;
  name: string;
  description: string;
  entityType: 'customers' | 'policies' | 'agents' | 'claims';
  columnMappings: ColumnMapping[];
  validationRules: ValidationRule[];
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
}

export interface ColumnMapping {
  sourceColumn: string;
  targetField: string;
  dataType: DataType;
  required: boolean;
  defaultValue?: any;
  transformation?: string;
}

export type DataType =
  | 'string'
  | 'number'
  | 'date'
  | 'boolean'
  | 'email'
  | 'phone'
  | 'currency';

export interface ValidationRule {
  field: string;
  rule: ValidationType;
  value?: any;
  message: string;
}

export type ValidationType =
  | 'required'
  | 'email'
  | 'phone'
  | 'minLength'
  | 'maxLength'
  | 'min'
  | 'max'
  | 'pattern'
  | 'unique'
  | 'exists';

export interface ImportFile {
  id: string;
  name: string;
  size: number;
  type: string;
  data: any[][];
  headers: string[];
  preview: any[][];
  uploadTime: Date;
  status: ImportStatus;
  template?: ImportTemplate;
}

export type ImportStatus =
  | 'uploading'
  | 'uploaded'
  | 'validating'
  | 'validated'
  | 'importing'
  | 'completed'
  | 'failed';

export interface ImportResult {
  id: string;
  fileId: string;
  templateId?: string;
  totalRows: number;
  validRows: number;
  invalidRows: number;
  importedRows: number;
  errors: ImportError[];
  status: ImportStatus;
  startTime: Date;
  endTime?: Date;
  duration?: number;
}

export interface ImportError {
  row: number;
  column?: string;
  field?: string;
  value: any;
  error: string;
  suggestion?: string;
}

export interface ImportProgress {
  stage: 'uploading' | 'validating' | 'importing';
  progress: number; // 0-100
  message: string;
  currentRow?: number;
  totalRows?: number;
}

export interface DataImportRequest {
  fileId: string;
  templateId?: string;
  data: any[][];
  headers: string[];
  mappings?: ColumnMapping[];
  validationRules?: ValidationRule[];
}

export interface DataImportResponse {
  importId: string;
  status: ImportStatus;
  results: ImportResult;
  errors: ImportError[];
}

// Excel/CSV Processing Types
export interface ExcelSheet {
  name: string;
  data: any[][];
  headers: string[];
}

export interface CSVOptions {
  delimiter: ',' | ';' | '\t' | '|';
  hasHeaders: boolean;
  encoding: string;
  skipRows: number;
}

export interface ExcelOptions {
  sheetName?: string;
  hasHeaders: boolean;
  skipRows: number;
  range?: string;
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

// Form Types
export interface ImportFormData {
  file: File | null;
  templateId: string | null;
  entityType: string;
  hasHeaders: boolean;
  skipRows: number;
  delimiter?: string;
}

// Template Configuration Types
export interface TemplateFormData {
  name: string;
  description: string;
  entityType: string;
  mappings: ColumnMapping[];
  validationRules: ValidationRule[];
}

// Entity Field Definitions
export interface EntityField {
  name: string;
  label: string;
  type: DataType;
  required: boolean;
  description?: string;
  validation?: ValidationRule[];
}

export interface EntityDefinition {
  name: string;
  label: string;
  fields: EntityField[];
  sampleData: any[][];
}

// Import History Types
export interface ImportHistoryItem {
  id: string;
  fileName: string;
  templateName?: string;
  entityType: string;
  status: ImportStatus;
  totalRows: number;
  importedRows: number;
  errorCount: number;
  startTime: Date;
  endTime?: Date;
  duration?: number;
  uploadedBy: string;
}
