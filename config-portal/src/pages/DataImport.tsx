import React, { useState, useCallback, useMemo } from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  Button,
  Grid,
  LinearProgress,
  Alert,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  TextField,
  Stepper,
  Step,
  StepLabel,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  IconButton,
  Tooltip,
} from '@mui/material';
import {
  CloudUpload,
  CheckCircle,
  Error,
  Warning,
  ExpandMore,
  Download,
  Refresh,
  Clear,
} from '@mui/icons-material';
import { useDropzone } from 'react-dropzone';
import { useTable } from 'react-table';
import { dataImportApi } from '../services/dataImportApi';
import { FileProcessor } from '../services/fileProcessor';
import {
  ImportFile,
  ImportResult,
  ImportProgress,
  ImportTemplate,
  ImportError,
  ImportStatus,
} from '../types/dataImport';

const DataImport: React.FC = () => {
  const [activeStep, setActiveStep] = useState(0);
  const [uploadedFile, setUploadedFile] = useState<ImportFile | null>(null);
  const [selectedTemplate, setSelectedTemplate] = useState<ImportTemplate | null>(null);
  const [templates, setTemplates] = useState<ImportTemplate[]>([]);
  const [validationResult, setValidationResult] = useState<ImportResult | null>(null);
  const [importProgress, setImportProgress] = useState<ImportProgress | null>(null);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
  const [isImporting, setIsImporting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showPreview, setShowPreview] = useState(false);

  // Load templates on component mount
  React.useEffect(() => {
    loadTemplates();
  }, []);

  const loadTemplates = async () => {
    try {
      const loadedTemplates = await dataImportApi.getTemplates();
      setTemplates(loadedTemplates);
    } catch (err) {
      console.error('Failed to load templates:', err);
    }
  };

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    if (acceptedFiles.length === 0) return;

    const file = acceptedFiles[0];
    setError(null);

    try {
      // Process the file
      const processedFile = await FileProcessor.processFile(file, {
        hasHeaders: true,
        skipRows: 0,
      });

      setUploadedFile(processedFile);
      setActiveStep(1);
    } catch (err: any) {
      setError(err?.message || 'Failed to process file');
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': ['.xlsx'],
      'application/vnd.ms-excel': ['.xls'],
      'text/csv': ['.csv'],
    },
    multiple: false,
  });

  const handleTemplateSelect = (templateId: string) => {
    const template = templates.find(t => t.id === templateId);
    setSelectedTemplate(template || null);
  };

  const handleValidate = async () => {
    if (!uploadedFile) return;

    setImportProgress({ stage: 'validating', progress: 0, message: 'Starting validation...' });

    try {
      // Validate locally first
      const localValidation = FileProcessor.validateData(
        uploadedFile.data,
        uploadedFile.headers,
        selectedTemplate?.validationRules || []
      );

      // Create validation result
      const result: ImportResult = {
        id: `import_${Date.now()}`,
        fileId: uploadedFile.id,
        templateId: selectedTemplate?.id,
        totalRows: uploadedFile.data.length,
        validRows: uploadedFile.data.length - localValidation.errors.length,
        invalidRows: localValidation.errors.length,
        importedRows: 0,
        errors: localValidation.errors,
        status: localValidation.isValid ? 'validated' : 'failed',
        startTime: new Date(),
      };

      setValidationResult(result);
      setActiveStep(2);
    } catch (err: any) {
      setError(err?.message || 'Validation failed');
    } finally {
      setImportProgress(null);
    }
  };

  const handleImport = async () => {
    if (!uploadedFile || !validationResult) return;

    setIsImporting(true);
    setImportProgress({ stage: 'importing', progress: 0, message: 'Starting import...' });

    try {
      // Simulate import progress
      const progressInterval = setInterval(() => {
        setImportProgress(prev => {
          if (!prev) return null;
          const newProgress = Math.min(prev.progress + 10, 90);
          return {
            ...prev,
            progress: newProgress,
            message: `Importing... ${newProgress}% complete`,
          };
        });
      }, 500);

      // Perform the import
      const importRequest = {
        fileId: uploadedFile.id,
        templateId: selectedTemplate?.id,
        data: uploadedFile.data,
        headers: uploadedFile.headers,
        mappings: selectedTemplate?.columnMappings,
        validationRules: selectedTemplate?.validationRules,
      };

      const response = await dataImportApi.importData(importRequest);

      clearInterval(progressInterval);
      setImportProgress({ stage: 'importing', progress: 100, message: 'Import completed!' });

      if (response) {
        setImportResult(response.results);
        setActiveStep(3);
      }
    } catch (err: any) {
      setError(err?.message || 'Import failed');
    } finally {
      setIsImporting(false);
      setTimeout(() => setImportProgress(null), 2000);
    }
  };

  const handleReset = () => {
    setUploadedFile(null);
    setSelectedTemplate(null);
    setValidationResult(null);
    setImportResult(null);
    setImportProgress(null);
    setError(null);
    setActiveStep(0);
    setShowPreview(false);
  };

  const steps = ['Upload File', 'Select Template', 'Validate Data', 'Import Data'];

  const renderFilePreview = () => {
    if (!uploadedFile || !showPreview) return null;

    const columns = uploadedFile.headers.map(header => ({
      Header: header,
      accessor: header,
    }));

    const data = uploadedFile.preview.map(row =>
      uploadedFile.headers.reduce((acc, header, index) => ({
        ...acc,
        [header]: row[index] || '',
      }), {})
    );

    return (
      <Dialog open={showPreview} onClose={() => setShowPreview(false)} maxWidth="lg" fullWidth>
        <DialogTitle>Data Preview</DialogTitle>
        <DialogContent>
          <TableContainer component={Paper}>
            <Table size="small">
              <TableHead>
                <TableRow>
                  {uploadedFile.headers.map((header, index) => (
                    <TableCell key={index} sx={{ fontWeight: 'bold' }}>
                      {header}
                    </TableCell>
                  ))}
                </TableRow>
              </TableHead>
              <TableBody>
                {uploadedFile.preview.slice(0, 5).map((row, rowIndex) => (
                  <TableRow key={rowIndex}>
                    {row.map((cell: any, cellIndex: number) => (
                      <TableCell key={cellIndex}>{String(cell || '')}</TableCell>
                    ))}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <Typography variant="body2" sx={{ mt: 2, color: 'text.secondary' }}>
            Showing first 5 rows of {uploadedFile.data.length} total rows
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowPreview(false)}>Close</Button>
        </DialogActions>
      </Dialog>
    );
  };

  const renderErrorSummary = () => {
    if (!validationResult || validationResult.errors.length === 0) return null;

    return (
      <Accordion>
        <AccordionSummary expandIcon={<ExpandMore />}>
          <Box display="flex" alignItems="center">
            <Warning color="warning" sx={{ mr: 1 }} />
            <Typography>
              {validationResult.errors.length} Validation Errors Found
            </Typography>
          </Box>
        </AccordionSummary>
        <AccordionDetails>
          <TableContainer component={Paper} sx={{ maxHeight: 300 }}>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Row</TableCell>
                  <TableCell>Field</TableCell>
                  <TableCell>Error</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {validationResult.errors.slice(0, 10).map((error, index) => (
                  <TableRow key={index}>
                    <TableCell>{error.row}</TableCell>
                    <TableCell>{error.field || error.column}</TableCell>
                    <TableCell>{error.error}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          {validationResult.errors.length > 10 && (
            <Typography variant="body2" sx={{ mt: 1, color: 'text.secondary' }}>
              And {validationResult.errors.length - 10} more errors...
            </Typography>
          )}
        </AccordionDetails>
      </Accordion>
    );
  };

  return (
    <Container maxWidth="lg">
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1">
          Data Import Dashboard
        </Typography>
        <Button
          variant="outlined"
          startIcon={<Refresh />}
          onClick={handleReset}
          disabled={activeStep === 0}
        >
          Start New Import
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Stepper activeStep={activeStep} sx={{ mb: 3 }}>
            {steps.map((label) => (
              <Step key={label}>
                <StepLabel>{label}</StepLabel>
              </Step>
            ))}
          </Stepper>

          {/* Step 1: File Upload */}
          {activeStep === 0 && (
            <Box>
              <Box
                {...getRootProps()}
                sx={{
                  border: '2px dashed',
                  borderColor: isDragActive ? 'primary.main' : 'grey.300',
                  borderRadius: 2,
                  p: 4,
                  textAlign: 'center',
                  cursor: 'pointer',
                  backgroundColor: isDragActive ? 'primary.50' : 'grey.50',
                  transition: 'all 0.3s ease',
                  '&:hover': {
                    borderColor: 'primary.main',
                    backgroundColor: 'primary.50',
                  },
                }}
              >
                <input {...getInputProps()} />
                <CloudUpload sx={{ fontSize: 48, color: 'primary.main', mb: 2 }} />
                <Typography variant="h6" gutterBottom>
                  {isDragActive ? 'Drop the file here' : 'Drag & drop a file here, or click to select'}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Supports Excel (.xlsx, .xls) and CSV files
                </Typography>
              </Box>
            </Box>
          )}

          {/* Step 2: Template Selection */}
          {activeStep === 1 && uploadedFile && (
            <Box>
              <Typography variant="h6" gutterBottom>
                File Uploaded Successfully
              </Typography>
              <Box display="flex" alignItems="center" mb={3}>
                <CheckCircle color="success" sx={{ mr: 1 }} />
                <Typography>
                  {uploadedFile.name} ({(uploadedFile.size / 1024).toFixed(1)} KB) - {uploadedFile.data.length} rows
                </Typography>
                <Button
                  variant="outlined"
                  size="small"
                  sx={{ ml: 2 }}
                  onClick={() => setShowPreview(true)}
                >
                  Preview Data
                </Button>
              </Box>

              <FormControl fullWidth sx={{ mb: 3 }}>
                <InputLabel>Select Import Template</InputLabel>
                <Select
                  value={selectedTemplate?.id || ''}
                  onChange={(e) => handleTemplateSelect(e.target.value)}
                  label="Select Import Template"
                >
                  <MenuItem value="">
                    <em>No template (manual mapping)</em>
                  </MenuItem>
                  {templates.map((template) => (
                    <MenuItem key={template.id} value={template.id}>
                      {template.name} - {template.entityType}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>

              <Box display="flex" gap={2}>
                <Button
                  variant="contained"
                  onClick={handleValidate}
                  disabled={!uploadedFile}
                >
                  Validate Data
                </Button>
                <Button onClick={() => setActiveStep(0)}>
                  Back
                </Button>
              </Box>
            </Box>
          )}

          {/* Step 3: Validation Results */}
          {activeStep === 2 && validationResult && (
            <Box>
              <Typography variant="h6" gutterBottom>
                Data Validation Results
              </Typography>

              <Grid container spacing={3} sx={{ mb: 3 }}>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color="primary">
                        {validationResult.totalRows}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Total Rows
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color="success.main">
                        {validationResult.validRows}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Valid Rows
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color="error.main">
                        {validationResult.invalidRows}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Invalid Rows
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color={
                        validationResult.status === 'validated' ? 'success.main' :
                        validationResult.status === 'failed' ? 'error.main' : 'warning.main'
                      }>
                        {validationResult.status === 'validated' ? '✓' :
                         validationResult.status === 'failed' ? '✗' : '⚠'}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Status
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
              </Grid>

              {renderErrorSummary()}

              <Box display="flex" gap={2} sx={{ mt: 3 }}>
                <Button
                  variant="contained"
                  onClick={handleImport}
                  disabled={validationResult.invalidRows > 0 || isImporting}
                >
                  {isImporting ? 'Importing...' : 'Start Import'}
                </Button>
                <Button onClick={() => setActiveStep(1)}>
                  Back
                </Button>
              </Box>
            </Box>
          )}

          {/* Step 4: Import Progress & Results */}
          {activeStep === 3 && importResult && (
            <Box>
              <Typography variant="h6" gutterBottom>
                Import Completed
              </Typography>

              <Alert
                severity={importResult.status === 'completed' ? 'success' : 'warning'}
                sx={{ mb: 3 }}
              >
                {importResult.status === 'completed'
                  ? `Successfully imported ${importResult.importedRows} of ${importResult.totalRows} rows`
                  : `Import completed with issues. ${importResult.importedRows} of ${importResult.totalRows} rows imported.`
                }
              </Alert>

              <Grid container spacing={3} sx={{ mb: 3 }}>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color="primary">
                        {importResult.totalRows}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Total Processed
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color="success.main">
                        {importResult.importedRows}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Successfully Imported
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color="error.main">
                        {importResult.errors.length}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Errors
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Card variant="outlined">
                    <CardContent sx={{ textAlign: 'center' }}>
                      <Typography variant="h4" color="info.main">
                        {importResult.duration ? `${importResult.duration}s` : 'N/A'}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Duration
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
              </Grid>

              <Box display="flex" gap={2}>
                <Button variant="contained" onClick={handleReset}>
                  Import Another File
                </Button>
                <Button
                  variant="outlined"
                  startIcon={<Download />}
                  onClick={() => {
                    // TODO: Download import results
                  }}
                >
                  Download Report
                </Button>
              </Box>
            </Box>
          )}
        </CardContent>
      </Card>

      {/* Progress Indicator */}
      {importProgress && (
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="h6" gutterBottom>
              {importProgress.stage === 'uploading' ? 'Uploading File' :
               importProgress.stage === 'validating' ? 'Validating Data' :
               'Importing Data'}
            </Typography>
            <LinearProgress
              variant="determinate"
              value={importProgress.progress}
              sx={{ mb: 2 }}
            />
            <Typography variant="body2" color="text.secondary">
              {importProgress.message}
            </Typography>
          </CardContent>
        </Card>
      )}

      {renderFilePreview()}
    </Container>
  );
};

export default DataImport;
