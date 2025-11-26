import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  Button,
  Grid,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Alert,
  Tabs,
  Tab,
  Switch,
  FormControlLabel,
  LinearProgress,
  IconButton,
} from '@mui/material';
import {
  Assessment,
  Download,
  Schedule,
  Delete,
  Refresh,
  GetApp,
  CalendarToday,
} from '@mui/icons-material';
import { useForm, Controller } from 'react-hook-form';
import { reportingApi, Report, ReportType, ScheduledReport, ScheduleConfig } from '../services/reportingApi';

interface ReportFormData {
  reportType: ReportType;
  dateFrom?: string;
  dateTo?: string;
  agentCode?: string;
  status?: string;
  format: 'pdf' | 'excel' | 'csv';
}

interface ScheduledReportFormData extends ReportFormData {
  name: string;
  frequency: 'daily' | 'weekly' | 'monthly';
  dayOfWeek?: number;
  dayOfMonth?: number;
  time: string;
  recipients: string[];
  isActive: boolean;
}

const ReportingDashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState(0);
  const [reports, setReports] = useState<Report[]>([]);
  const [scheduledReports, setScheduledReports] = useState<ScheduledReport[]>([]);
  const [reportTypes, setReportTypes] = useState<{ type: ReportType; name: string; description: string }[]>([]);
  const [loading, setLoading] = useState(false);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showScheduleDialog, setShowScheduleDialog] = useState(false);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);

  const { control, handleSubmit, reset, watch, formState: { errors } } = useForm<ReportFormData>({
    defaultValues: {
      reportType: 'customer_summary',
      format: 'pdf',
    },
  });

  const scheduleForm = useForm<ScheduledReportFormData>({
    defaultValues: {
      reportType: 'customer_summary',
      format: 'pdf',
      frequency: 'daily',
      time: '09:00',
      recipients: [],
      isActive: true,
    },
  });

  const frequency = scheduleForm.watch('frequency');

  useEffect(() => {
    loadReportHistory();
    loadScheduledReports();
    loadReportTypes();
  }, [page]);

  const loadReportHistory = async () => {
    try {
      setLoading(true);
      const response = await reportingApi.getReportHistory(page, 20);
      setReports(response.data);
      setTotal(response.total);
    } catch (err: any) {
      setError(err?.message || 'Failed to load report history');
    } finally {
      setLoading(false);
    }
  };

  const loadScheduledReports = async () => {
    try {
      const scheduled = await reportingApi.getScheduledReports();
      setScheduledReports(scheduled);
    } catch (err: any) {
      console.error('Failed to load scheduled reports:', err);
    }
  };

  const loadReportTypes = async () => {
    try {
      const types = await reportingApi.getReportTypes();
      setReportTypes(types);
    } catch (err: any) {
      console.error('Failed to load report types:', err);
    }
  };

  const handleGenerateReport = async (data: ReportFormData) => {
    try {
      setGenerating(true);
      setError(null);
      const filters: any = {};
      if (data.dateFrom) filters.dateFrom = data.dateFrom;
      if (data.dateTo) filters.dateTo = data.dateTo;
      if (data.agentCode) filters.agentCode = data.agentCode;
      if (data.status) filters.status = data.status;

      const report = await reportingApi.generateReport(data.reportType, filters, data.format);
      if (report) {
        setSuccess('Report generation started. Check report history for status.');
        setTimeout(() => {
          setSuccess(null);
          loadReportHistory();
        }, 3000);
        reset();
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to generate report');
    } finally {
      setGenerating(false);
    }
  };

  const handleDownloadReport = async (reportId: string) => {
    try {
      setLoading(true);
      const blob = await reportingApi.downloadReport(reportId);
      if (blob) {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `report_${reportId}.pdf`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
        setSuccess('Report downloaded successfully');
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to download report');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateScheduledReport = async (data: ScheduledReportFormData) => {
    try {
      setLoading(true);
      const schedule: ScheduleConfig = {
        frequency: data.frequency,
        time: data.time,
        dayOfWeek: data.dayOfWeek,
        dayOfMonth: data.dayOfMonth,
      };

      const filters: any = {};
      if (data.dateFrom) filters.dateFrom = data.dateFrom;
      if (data.dateTo) filters.dateTo = data.dateTo;
      if (data.agentCode) filters.agentCode = data.agentCode;
      if (data.status) filters.status = data.status;

      const scheduledReport: Partial<ScheduledReport> = {
        name: data.name,
        reportType: data.reportType,
        schedule,
        filters,
        format: data.format,
        recipients: data.recipients,
        isActive: data.isActive,
      };

      const created = await reportingApi.createScheduledReport(scheduledReport);
      if (created) {
        setSuccess('Scheduled report created successfully');
        setShowScheduleDialog(false);
        scheduleForm.reset();
        loadScheduledReports();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to create scheduled report');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteScheduledReport = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this scheduled report?')) return;

    try {
      setLoading(true);
      const success = await reportingApi.deleteScheduledReport(id);
      if (success) {
        setSuccess('Scheduled report deleted successfully');
        loadScheduledReports();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to delete scheduled report');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'success';
      case 'processing':
        return 'warning';
      case 'failed':
        return 'error';
      default:
        return 'default';
    }
  };

  return (
    <Container maxWidth="xl">
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1">
          Reporting Dashboard
        </Typography>
        <Button
          variant="contained"
          startIcon={<Schedule />}
          onClick={() => {
            scheduleForm.reset();
            setShowScheduleDialog(true);
          }}
        >
          Schedule Report
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 3 }} onClose={() => setSuccess(null)}>
          {success}
        </Alert>
      )}

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Generate Report
          </Typography>
          <form onSubmit={handleSubmit(handleGenerateReport)}>
            <Grid container spacing={2}>
              <Grid item xs={12} sm={6} md={3}>
                <Controller
                  name="reportType"
                  control={control}
                  rules={{ required: 'Report type is required' }}
                  render={({ field }) => (
                    <FormControl fullWidth error={!!errors.reportType}>
                      <InputLabel>Report Type</InputLabel>
                      <Select {...field} label="Report Type">
                        {reportTypes.map((type) => (
                          <MenuItem key={type.type} value={type.type}>
                            {type.name}
                          </MenuItem>
                        ))}
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={6} md={2}>
                <Controller
                  name="dateFrom"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Date From"
                      type="date"
                      fullWidth
                      InputLabelProps={{ shrink: true }}
                    />
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={6} md={2}>
                <Controller
                  name="dateTo"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Date To"
                      type="date"
                      fullWidth
                      InputLabelProps={{ shrink: true }}
                    />
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={6} md={2}>
                <Controller
                  name="format"
                  control={control}
                  render={({ field }) => (
                    <FormControl fullWidth>
                      <InputLabel>Format</InputLabel>
                      <Select {...field} label="Format">
                        <MenuItem value="pdf">PDF</MenuItem>
                        <MenuItem value="excel">Excel</MenuItem>
                        <MenuItem value="csv">CSV</MenuItem>
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={6} md={3}>
                <Button
                  type="submit"
                  variant="contained"
                  fullWidth
                  disabled={generating}
                  startIcon={generating ? <Refresh /> : <Assessment />}
                  sx={{ height: '56px' }}
                >
                  {generating ? 'Generating...' : 'Generate Report'}
                </Button>
              </Grid>
            </Grid>
          </form>
        </CardContent>
      </Card>

      <Card>
        <Tabs value={activeTab} onChange={(e, v) => setActiveTab(v)}>
          <Tab label="Report History" />
          <Tab label="Scheduled Reports" />
        </Tabs>

        {activeTab === 0 && (
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Report Name</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell>Format</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Created</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={6}>
                      <LinearProgress />
                    </TableCell>
                  </TableRow>
                ) : reports.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} align="center">
                      <Typography color="text.secondary">No reports found</Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  reports.map((report) => (
                    <TableRow key={report.id} hover>
                      <TableCell>{report.name || `${report.type} Report`}</TableCell>
                      <TableCell>
                        {reportTypes.find(t => t.type === report.type)?.name || report.type}
                      </TableCell>
                      <TableCell>{report.format.toUpperCase()}</TableCell>
                      <TableCell>
                        <Chip
                          label={report.status}
                          color={getStatusColor(report.status) as any}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        {new Date(report.createdAt).toLocaleString()}
                      </TableCell>
                      <TableCell align="right">
                        {report.status === 'completed' && report.downloadUrl && (
                          <IconButton
                            size="small"
                            onClick={() => handleDownloadReport(report.id)}
                            title="Download"
                          >
                            <GetApp />
                          </IconButton>
                        )}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        {activeTab === 1 && (
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Name</TableCell>
                  <TableCell>Report Type</TableCell>
                  <TableCell>Schedule</TableCell>
                  <TableCell>Format</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Next Run</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {scheduledReports.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7} align="center">
                      <Typography color="text.secondary">No scheduled reports</Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  scheduledReports.map((scheduled) => (
                    <TableRow key={scheduled.id} hover>
                      <TableCell>{scheduled.name}</TableCell>
                      <TableCell>
                        {reportTypes.find(t => t.type === scheduled.reportType)?.name || scheduled.reportType}
                      </TableCell>
                      <TableCell>
                        {scheduled.schedule.frequency} at {scheduled.schedule.time}
                      </TableCell>
                      <TableCell>{scheduled.format.toUpperCase()}</TableCell>
                      <TableCell>
                        <Chip
                          label={scheduled.isActive ? 'Active' : 'Inactive'}
                          color={scheduled.isActive ? 'success' : 'default'}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        {scheduled.nextRun ? new Date(scheduled.nextRun).toLocaleString() : '-'}
                      </TableCell>
                      <TableCell align="right">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDeleteScheduledReport(scheduled.id)}
                        >
                          <Delete />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Card>

      {/* Schedule Report Dialog */}
      <Dialog open={showScheduleDialog} onClose={() => setShowScheduleDialog(false)} maxWidth="md" fullWidth>
        <form onSubmit={scheduleForm.handleSubmit(handleCreateScheduledReport)}>
          <DialogTitle>Schedule Report</DialogTitle>
          <DialogContent>
            <Grid container spacing={2} sx={{ mt: 1 }}>
              <Grid item xs={12}>
                <Controller
                  name="name"
                  control={scheduleForm.control}
                  rules={{ required: 'Name is required' }}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Report Name"
                      fullWidth
                      error={!!scheduleForm.formState.errors.name}
                      helperText={scheduleForm.formState.errors.name?.message}
                    />
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <Controller
                  name="reportType"
                  control={scheduleForm.control}
                  rules={{ required: 'Report type is required' }}
                  render={({ field }) => (
                    <FormControl fullWidth error={!!scheduleForm.formState.errors.reportType}>
                      <InputLabel>Report Type</InputLabel>
                      <Select {...field} label="Report Type">
                        {reportTypes.map((type) => (
                          <MenuItem key={type.type} value={type.type}>
                            {type.name}
                          </MenuItem>
                        ))}
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <Controller
                  name="format"
                  control={scheduleForm.control}
                  render={({ field }) => (
                    <FormControl fullWidth>
                      <InputLabel>Format</InputLabel>
                      <Select {...field} label="Format">
                        <MenuItem value="pdf">PDF</MenuItem>
                        <MenuItem value="excel">Excel</MenuItem>
                        <MenuItem value="csv">CSV</MenuItem>
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={4}>
                <Controller
                  name="frequency"
                  control={scheduleForm.control}
                  render={({ field }) => (
                    <FormControl fullWidth>
                      <InputLabel>Frequency</InputLabel>
                      <Select {...field} label="Frequency">
                        <MenuItem value="daily">Daily</MenuItem>
                        <MenuItem value="weekly">Weekly</MenuItem>
                        <MenuItem value="monthly">Monthly</MenuItem>
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>
              {scheduleForm.watch('frequency') === 'weekly' && (
                <Grid item xs={12} sm={4}>
                  <Controller
                    name="dayOfWeek"
                    control={scheduleForm.control}
                    render={({ field }) => (
                      <FormControl fullWidth>
                        <InputLabel>Day of Week</InputLabel>
                        <Select {...field} label="Day of Week">
                          <MenuItem value={0}>Sunday</MenuItem>
                          <MenuItem value={1}>Monday</MenuItem>
                          <MenuItem value={2}>Tuesday</MenuItem>
                          <MenuItem value={3}>Wednesday</MenuItem>
                          <MenuItem value={4}>Thursday</MenuItem>
                          <MenuItem value={5}>Friday</MenuItem>
                          <MenuItem value={6}>Saturday</MenuItem>
                        </Select>
                      </FormControl>
                    )}
                  />
                </Grid>
              )}
              {scheduleForm.watch('frequency') === 'monthly' && (
                <Grid item xs={12} sm={4}>
                  <Controller
                    name="dayOfMonth"
                    control={scheduleForm.control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        label="Day of Month"
                        type="number"
                        fullWidth
                        inputProps={{ min: 1, max: 31 }}
                        onChange={(e) => field.onChange(parseInt(e.target.value) || 1)}
                      />
                    )}
                  />
                </Grid>
              )}
              <Grid item xs={12} sm={4}>
                <Controller
                  name="time"
                  control={scheduleForm.control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Time"
                      type="time"
                      fullWidth
                      InputLabelProps={{ shrink: true }}
                    />
                  )}
                />
              </Grid>
              <Grid item xs={12}>
                <Controller
                  name="isActive"
                  control={scheduleForm.control}
                  render={({ field }) => (
                    <FormControlLabel
                      control={<Switch {...field} checked={field.value} />}
                      label="Active"
                    />
                  )}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setShowScheduleDialog(false)}>Cancel</Button>
            <Button type="submit" variant="contained" disabled={loading}>
              {loading ? 'Creating...' : 'Create Schedule'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Container>
  );
};

export default ReportingDashboard;

