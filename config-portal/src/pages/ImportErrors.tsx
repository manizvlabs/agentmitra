import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  TextField,
  InputAdornment,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Alert,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material';
import {
  ArrowBack,
  Search,
  FilterList,
  Error,
  Warning,
  Info,
  Download,
  SkipNext,
  Build,
  CheckCircle,
} from '@mui/icons-material';

interface ImportError {
  id: number;
  row: number;
  field: string;
  errorType: 'missing' | 'invalid' | 'duplicate' | 'format' | 'other';
  errorMessage: string;
  suggestedFix?: string;
  severity: 'critical' | 'warning' | 'info';
}

const ImportErrors: React.FC = () => {
  const navigate = useNavigate();

  // Mock error data
  const [errors] = useState<ImportError[]>([
    {
      id: 1,
      row: 125,
      field: 'phone_number',
      errorType: 'invalid',
      errorMessage: 'Invalid phone number format',
      suggestedFix: 'Ensure phone number starts with +91 and contains 10 digits',
      severity: 'critical',
    },
    {
      id: 2,
      row: 234,
      field: 'policy_number',
      errorType: 'duplicate',
      errorMessage: 'Policy number already exists',
      suggestedFix: 'Check for duplicate entries in the data',
      severity: 'critical',
    },
    {
      id: 3,
      row: 345,
      field: 'email',
      errorType: 'missing',
      errorMessage: 'Email address is missing',
      suggestedFix: 'Optional field - can be left blank',
      severity: 'warning',
    },
    {
      id: 4,
      row: 456,
      field: 'date_of_birth',
      errorType: 'format',
      errorMessage: 'Invalid date format',
      suggestedFix: 'Use DD/MM/YYYY format',
      severity: 'critical',
    },
    {
      id: 5,
      row: 567,
      field: 'premium_amount',
      errorType: 'invalid',
      errorMessage: 'Premium amount cannot be negative',
      suggestedFix: 'Ensure all premium amounts are positive numbers',
      severity: 'critical',
    },
  ]);

  const [searchTerm, setSearchTerm] = useState('');
  const [severityFilter, setSeverityFilter] = useState<string>('all');
  const [typeFilter, setTypeFilter] = useState<string>('all');
  const [showSkipDialog, setShowSkipDialog] = useState(false);

  // Filter and search errors
  const filteredErrors = useMemo(() => {
    return errors.filter(error => {
      const matchesSearch = error.errorMessage.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          error.field.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesSeverity = severityFilter === 'all' || error.severity === severityFilter;
      const matchesType = typeFilter === 'all' || error.errorType === typeFilter;

      return matchesSearch && matchesSeverity && matchesType;
    });
  }, [errors, searchTerm, severityFilter, typeFilter]);

  // Error statistics
  const errorStats = useMemo(() => {
    const totalErrors = errors.length;
    const criticalErrors = errors.filter(e => e.severity === 'critical').length;
    const warningErrors = errors.filter(e => e.severity === 'warning').length;
    const infoErrors = errors.filter(e => e.severity === 'info').length;

    const commonError = errors.reduce((acc, error) => {
      acc[error.errorType] = (acc[error.errorType] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const mostCommonError = Object.entries(commonError).reduce((a, b) =>
      commonError[a[0]] > commonError[b[0]] ? a : b
    )[0];

    return {
      totalErrors,
      criticalErrors,
      warningErrors,
      infoErrors,
      mostCommonError,
    };
  }, [errors]);

  const handleDownloadReport = () => {
    // Mock download functionality
    const csvContent = [
      'Row,Field,Error Type,Severity,Message,Suggested Fix',
      ...filteredErrors.map(error =>
        `${error.row},${error.field},${error.errorType},${error.severity},"${error.errorMessage}","${error.suggestedFix || ''}"`
      )
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'import_errors_report.csv';
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const handleSkipErrors = () => {
    setShowSkipDialog(true);
  };

  const confirmSkipErrors = () => {
    setShowSkipDialog(false);
    navigate('/import-success');
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'critical': return 'error';
      case 'warning': return 'warning';
      case 'info': return 'info';
      default: return 'default';
    }
  };

  const getErrorTypeColor = (type: string) => {
    switch (type) {
      case 'missing': return '#ff9800';
      case 'invalid': return '#f44336';
      case 'duplicate': return '#9c27b0';
      case 'format': return '#2196f3';
      default: return '#757575';
    }
  };

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#f5f5f5', p: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <Button
          startIcon={<ArrowBack />}
          onClick={() => navigate('/data-import-progress')}
          sx={{ mr: 2 }}
        >
          Back to Progress
        </Button>
        <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold' }}>
          Import Errors - Review & Resolve
        </Typography>
      </Box>

      {/* Error Summary */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Error Summary
          </Typography>

          <Box sx={{ mb: 2 }}>
            <Typography variant="body1" color="error">
              ❌ Total Errors: {errorStats.totalErrors} ({((errorStats.totalErrors / 1250) * 100).toFixed(1)}% of records)
            </Typography>
            <Typography variant="body2" color="text.secondary">
              📋 Most Common: {errorStats.mostCommonError.replace('_', ' ')} errors
            </Typography>
            <Typography variant="body2" color="error">
              ⚠️ Critical: {errorStats.criticalErrors} errors require immediate attention
            </Typography>
          </Box>

          <Alert severity="warning">
            Errors found during import. Review the issues below and choose a resolution method.
          </Alert>
        </CardContent>
      </Card>

      {/* Filters and Search */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center' }}>
            <TextField
              placeholder="Search errors..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Search />
                  </InputAdornment>
                ),
              }}
              sx={{ minWidth: 250 }}
            />

            <FormControl sx={{ minWidth: 150 }}>
              <InputLabel>Severity</InputLabel>
              <Select
                value={severityFilter}
                label="Severity"
                onChange={(e) => setSeverityFilter(e.target.value)}
              >
                <MenuItem value="all">All Severities</MenuItem>
                <MenuItem value="critical">Critical</MenuItem>
                <MenuItem value="warning">Warning</MenuItem>
                <MenuItem value="info">Info</MenuItem>
              </Select>
            </FormControl>

            <FormControl sx={{ minWidth: 150 }}>
              <InputLabel>Error Type</InputLabel>
              <Select
                value={typeFilter}
                label="Error Type"
                onChange={(e) => setTypeFilter(e.target.value)}
              >
                <MenuItem value="all">All Types</MenuItem>
                <MenuItem value="missing">Missing</MenuItem>
                <MenuItem value="invalid">Invalid</MenuItem>
                <MenuItem value="duplicate">Duplicate</MenuItem>
                <MenuItem value="format">Format</MenuItem>
              </Select>
            </FormControl>

            <Chip
              label={`${filteredErrors.length} errors shown`}
              color="primary"
              variant="outlined"
            />
          </Box>
        </CardContent>
      </Card>

      {/* Error Details Table */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Error Details
          </Typography>

          <TableContainer component={Paper} sx={{ maxHeight: 400 }}>
            <Table stickyHeader>
              <TableHead>
                <TableRow>
                  <TableCell>Row</TableCell>
                  <TableCell>Field</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell>Severity</TableCell>
                  <TableCell>Message</TableCell>
                  <TableCell>Suggested Fix</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredErrors.map((error) => (
                  <TableRow key={error.id} hover>
                    <TableCell>
                      <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
                        {error.row}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={error.field}
                        size="small"
                        sx={{ bgcolor: getErrorTypeColor(error.errorType), color: 'white' }}
                      />
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={error.errorType}
                        size="small"
                        sx={{
                          bgcolor: getErrorTypeColor(error.errorType),
                          color: 'white',
                          textTransform: 'capitalize'
                        }}
                      />
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={error.severity}
                        size="small"
                        color={getSeverityColor(error.severity) as any}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell sx={{ maxWidth: 200 }}>
                      <Typography variant="body2" sx={{ wordWrap: 'break-word' }}>
                        {error.errorMessage}
                      </Typography>
                    </TableCell>
                    <TableCell sx={{ maxWidth: 200 }}>
                      <Typography variant="body2" sx={{ wordWrap: 'break-word' }}>
                        {error.suggestedFix || 'No suggestion available'}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>

      {/* Resolution Options */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Resolution Options
          </Typography>

          <List>
            <ListItem>
              <ListItemIcon>
                <Build color="primary" />
              </ListItemIcon>
              <ListItemText
                primary="Fix Errors in Excel & Re-upload"
                secondary="Download the error report, fix issues in your Excel file, and upload again"
              />
            </ListItem>

            <ListItem>
              <ListItemIcon>
                <SkipNext color="warning" />
              </ListItemIcon>
              <ListItemText
                primary="Skip Errors & Continue Import"
                secondary="Import only valid records and generate a report of skipped items"
              />
            </ListItem>

            <ListItem>
              <ListItemIcon>
                <Download color="info" />
              </ListItemIcon>
              <ListItemText
                primary="Download Error Report"
                secondary="Export detailed error information for offline analysis"
              />
            </ListItem>
          </List>
        </CardContent>
      </Card>

      {/* Impact Assessment */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Impact Assessment
          </Typography>

          <Box sx={{ mb: 2 }}>
            <Typography variant="body1">
              📈 If errors are fixed: {1250 - errorStats.totalErrors} records will import successfully
            </Typography>
            <Typography variant="body2" color="text.secondary">
              ⚠️ If errors are skipped: {1250 - errorStats.totalErrors} records will import, but data quality may be affected
            </Typography>
            <Typography variant="body2" color="primary" sx={{ fontWeight: 'bold' }}>
              💡 Recommendation: Fix critical errors first, then review warnings
            </Typography>
          </Box>
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
        <Button
          variant="contained"
          startIcon={<Build />}
          onClick={() => navigate('/data-import')}
          color="primary"
        >
          Fix in Excel & Re-upload
        </Button>

        <Button
          variant="outlined"
          startIcon={<SkipNext />}
          onClick={handleSkipErrors}
          color="warning"
        >
          Skip Errors & Continue
        </Button>

        <Button
          variant="outlined"
          startIcon={<Download />}
          onClick={handleDownloadReport}
          color="info"
        >
          Download Error Report
        </Button>
      </Box>

      {/* Skip Errors Confirmation Dialog */}
      <Dialog open={showSkipDialog} onClose={() => setShowSkipDialog(false)}>
        <DialogTitle>Skip Errors & Continue</DialogTitle>
        <DialogContent>
          <Typography gutterBottom>
            Are you sure you want to skip the {errorStats.totalErrors} errors and continue with the import?
          </Typography>

          <List dense>
            <ListItem>
              <ListItemIcon>
                <CheckCircle color="success" />
              </ListItemIcon>
              <ListItemText
                primary={`${1250 - errorStats.totalErrors} valid records will be imported`}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <Error color="error" />
              </ListItemIcon>
              <ListItemText
                primary={`${errorStats.totalErrors} records will be skipped`}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <Info color="info" />
              </ListItemIcon>
              <ListItemText
                primary="An error report will be available for review"
              />
            </ListItem>
          </List>

          <Alert severity="warning" sx={{ mt: 2 }}>
            Skipping errors may result in incomplete customer data. Consider fixing critical errors first.
          </Alert>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowSkipDialog(false)}>Cancel</Button>
          <Button onClick={confirmSkipErrors} color="warning">
            Skip & Continue
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ImportErrors;
