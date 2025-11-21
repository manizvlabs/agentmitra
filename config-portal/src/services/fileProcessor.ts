import * as XLSX from 'xlsx';
import { ImportFile, ExcelSheet, CSVOptions, ExcelOptions } from '../types/dataImport';

export class FileProcessor {
  /**
   * Process Excel file and extract data
   */
  static async processExcelFile(
    file: File,
    options: ExcelOptions = { hasHeaders: true, skipRows: 0 }
  ): Promise<ImportFile> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();

      reader.onload = (e) => {
        try {
          const data = new Uint8Array(e.target?.result as ArrayBuffer);
          const workbook = XLSX.read(data, { type: 'array' });

          // Get the first sheet or specified sheet
          const sheetName = options.sheetName || workbook.SheetNames[0];
          const worksheet = workbook.Sheets[sheetName];

          if (!worksheet) {
            throw new Error(`Sheet "${sheetName}" not found in the Excel file`);
          }

          // Convert to array of arrays
          const rawData = XLSX.utils.sheet_to_json(worksheet, {
            header: 1,
            defval: '',
            blankrows: false,
          }) as any[][];

          // Skip rows if specified
          let processedData = rawData;
          if (options.skipRows > 0) {
            processedData = rawData.slice(options.skipRows);
          }

          // Extract headers
          let headers: string[] = [];
          let dataRows: any[][] = [];

          if (options.hasHeaders && processedData.length > 0) {
            headers = processedData[0].map((header: any) => String(header || '').trim());
            dataRows = processedData.slice(1);
          } else {
            // Generate column headers if no headers
            if (processedData.length > 0) {
              headers = processedData[0].map((_: any, index: number) => `Column ${index + 1}`);
              dataRows = processedData;
            }
          }

          // Create preview (first 10 rows)
          const preview = dataRows.slice(0, 10);

          const importFile: ImportFile = {
            id: `file_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            name: file.name,
            size: file.size,
            type: file.type,
            data: dataRows,
            headers,
            preview,
            uploadTime: new Date(),
            status: 'uploaded',
          };

          resolve(importFile);
        } catch (error) {
          reject(new Error(`Failed to process Excel file: ${error.message}`));
        }
      };

      reader.onerror = () => {
        reject(new Error('Failed to read the Excel file'));
      };

      reader.readAsArrayBuffer(file);
    });
  }

  /**
   * Process CSV file and extract data
   */
  static async processCSVFile(
    file: File,
    options: CSVOptions = {
      delimiter: ',',
      hasHeaders: true,
      encoding: 'utf-8',
      skipRows: 0
    }
  ): Promise<ImportFile> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();

      reader.onload = (e) => {
        try {
          const csvText = e.target?.result as string;

          // Parse CSV
          const lines = csvText.split('\n').filter(line => line.trim() !== '');

          if (lines.length === 0) {
            throw new Error('CSV file is empty');
          }

          // Skip rows if specified
          let processedLines = lines;
          if (options.skipRows > 0) {
            processedLines = lines.slice(options.skipRows);
          }

          // Parse each line
          const data: any[][] = processedLines.map(line => {
            const result: any[] = [];
            let current = '';
            let inQuotes = false;

            for (let i = 0; i < line.length; i++) {
              const char = line[i];

              if (char === '"') {
                if (inQuotes && line[i + 1] === '"') {
                  // Escaped quote
                  current += '"';
                  i++; // Skip next quote
                } else {
                  // Toggle quote state
                  inQuotes = !inQuotes;
                }
              } else if (char === options.delimiter && !inQuotes) {
                // Field separator
                result.push(current.trim());
                current = '';
              } else {
                current += char;
              }
            }

            // Add the last field
            result.push(current.trim());

            return result;
          });

          // Extract headers
          let headers: string[] = [];
          let dataRows: any[][] = [];

          if (options.hasHeaders && data.length > 0) {
            headers = data[0].map((header: any) => String(header || '').trim());
            dataRows = data.slice(1);
          } else {
            // Generate column headers if no headers
            if (data.length > 0) {
              headers = data[0].map((_: any, index: number) => `Column ${index + 1}`);
              dataRows = data;
            }
          }

          // Create preview (first 10 rows)
          const preview = dataRows.slice(0, 10);

          const importFile: ImportFile = {
            id: `file_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            name: file.name,
            size: file.size,
            type: file.type,
            data: dataRows,
            headers,
            preview,
            uploadTime: new Date(),
            status: 'uploaded',
          };

          resolve(importFile);
        } catch (error) {
          reject(new Error(`Failed to process CSV file: ${error.message}`));
        }
      };

      reader.onerror = () => {
        reject(new Error('Failed to read the CSV file'));
      };

      reader.readAsText(file, options.encoding);
    });
  }

  /**
   * Auto-detect file type and process accordingly
   */
  static async processFile(file: File, options?: ExcelOptions | CSVOptions): Promise<ImportFile> {
    const fileExtension = file.name.toLowerCase().split('.').pop();

    if (fileExtension === 'xlsx' || fileExtension === 'xls') {
      return this.processExcelFile(file, options as ExcelOptions);
    } else if (fileExtension === 'csv') {
      return this.processCSVFile(file, options as CSVOptions);
    } else {
      throw new Error(`Unsupported file type: ${fileExtension}`);
    }
  }

  /**
   * Validate data against template rules
   */
  static validateData(
    data: any[][],
    headers: string[],
    rules: any[] = []
  ): { isValid: boolean; errors: any[] } {
    const errors: any[] = [];

    // Basic validation - check required fields
    rules.forEach(rule => {
      if (rule.rule === 'required') {
        const columnIndex = headers.indexOf(rule.field);
        if (columnIndex !== -1) {
          data.forEach((row, rowIndex) => {
            if (!row[columnIndex] || String(row[columnIndex]).trim() === '') {
              errors.push({
                row: rowIndex + 1,
                column: rule.field,
                error: rule.message || `${rule.field} is required`,
              });
            }
          });
        }
      }
    });

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  /**
   * Generate sample data for templates
   */
  static generateSampleData(entityType: string): any[][] {
    switch (entityType) {
      case 'customers':
        return [
          ['John Doe', 'john@example.com', '+91-9876543210', '1990-01-01', 'Male', 'Engineer', '50000'],
          ['Jane Smith', 'jane@example.com', '+91-9876543211', '1985-05-15', 'Female', 'Doctor', '75000'],
          ['Bob Johnson', 'bob@example.com', '+91-9876543212', '1978-12-20', 'Male', 'Teacher', '45000'],
        ];
      case 'policies':
        return [
          ['POL001', 'LIC Jeevan Anand', 'John Doe', '2023-01-01', '2023-12-31', '5000', 'Active'],
          ['POL002', 'HDFC Life Plus', 'Jane Smith', '2023-02-01', '2024-01-31', '7500', 'Active'],
          ['POL003', 'ICICI Prudential', 'Bob Johnson', '2023-03-01', '2024-02-29', '4500', 'Active'],
        ];
      case 'agents':
        return [
          ['AGT001', 'Rajesh Kumar', 'rajesh@example.com', '+91-9876543213', '2022-01-01', 'Active'],
          ['AGT002', 'Priya Sharma', 'priya@example.com', '+91-9876543214', '2022-02-01', 'Active'],
          ['AGT003', 'Amit Singh', 'amit@example.com', '+91-9876543215', '2022-03-01', 'Active'],
        ];
      default:
        return [];
    }
  }

  /**
   * Export data to Excel file
   */
  static exportToExcel(data: any[][], headers: string[], fileName: string): void {
    const worksheet = XLSX.utils.aoa_to_sheet([headers, ...data]);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Data');
    XLSX.writeFile(workbook, fileName);
  }

  /**
   * Export data to CSV file
   */
  static exportToCSV(data: any[][], headers: string[], fileName: string): void {
    const csvContent = [
      headers.join(','),
      ...data.map(row => row.map(cell => `"${String(cell || '').replace(/"/g, '""')}"`).join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', fileName);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
}
