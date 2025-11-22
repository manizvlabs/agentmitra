import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Button,
  Chip,
  LinearProgress,
  Alert,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Divider,
  Avatar,
} from '@mui/material';
import {
  ArrowBack,
  CheckCircle,
  People,
  Policy,
  TrendingUp,
  Sync,
  Download,
  Analytics,
  Phone,
  Email,
  Upload,
} from '@mui/icons-material';

const ImportSuccess: React.FC = () => {
  const navigate = useNavigate();
  const [syncProgress, setSyncProgress] = useState(0);
  const [isSyncing, setIsSyncing] = useState(true);

  // Mock import results
  const importResults = {
    totalRecords: 1215,
    newCustomers: 234,
    updatedPolicies: 981,
    processingTime: '12 minutes',
    dataQuality: {
      accuracy: 97.2,
      updates: 85,
      issues: 2.8,
    },
  };

  useEffect(() => {
    // Simulate mobile app sync
    const syncInterval = setInterval(() => {
      setSyncProgress(prev => {
        const newProgress = Math.min(prev + 15, 100);
        if (newProgress >= 100) {
          setIsSyncing(false);
          clearInterval(syncInterval);
        }
        return newProgress;
      });
    }, 1000);

    return () => clearInterval(syncInterval);
  }, []);

  const handleDownloadReport = () => {
    // Mock download functionality
    const reportData = {
      summary: importResults,
      timestamp: new Date().toISOString(),
      status: 'completed',
    };

    const blob = new Blob([JSON.stringify(reportData, null, 2)], { type: 'application/json' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'import_success_report.json';
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const handleContactCustomers = () => {
    // Mock bulk communication
    alert('Bulk communication feature would open here');
  };

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#f5f5f5', p: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <Button
          startIcon={<ArrowBack />}
          onClick={() => navigate('/dashboard')}
          sx={{ mr: 2 }}
        >
          Back to Dashboard
        </Button>
        <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold', color: 'success.main' }}>
          ✅ Import Completed Successfully
        </Typography>
      </Box>

      {/* Success Header Card */}
      <Card sx={{ mb: 3, border: '2px solid #4caf50' }}>
        <CardContent sx={{ textAlign: 'center', py: 4 }}>
          <Avatar sx={{ width: 80, height: 80, bgcolor: 'success.main', mx: 'auto', mb: 2 }}>
            <CheckCircle sx={{ fontSize: 48, color: 'white' }} />
          </Avatar>

          <Typography variant="h5" gutterBottom color="success.main" sx={{ fontWeight: 'bold' }}>
            Data Import Successful!
          </Typography>

          <Typography variant="body1" color="text.secondary">
            Customer data has been successfully imported and is now available in the system
          </Typography>

          <Box sx={{ mt: 2, display: 'flex', justifyContent: 'center', gap: 2 }}>
            <Chip
              label={`${importResults.totalRecords} records imported`}
              color="success"
              variant="outlined"
            />
            <Chip
              label={`Processed in ${importResults.processingTime}`}
              color="info"
              variant="outlined"
            />
          </Box>
        </CardContent>
      </Card>

      {/* Success Summary */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            🎉 Success Summary
          </Typography>

          <Grid container spacing={3}>
            <Grid item xs={12} md={4}>
              <Box sx={{ textAlign: 'center', p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                <People sx={{ fontSize: 48, color: 'primary.main', mb: 1 }} />
                <Typography variant="h4" color="primary.main" sx={{ fontWeight: 'bold' }}>
                  {importResults.totalRecords}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Total Records Imported
                </Typography>
              </Box>
            </Grid>

            <Grid item xs={12} md={4}>
              <Box sx={{ textAlign: 'center', p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                <Policy sx={{ fontSize: 48, color: 'success.main', mb: 1 }} />
                <Typography variant="h4" color="success.main" sx={{ fontWeight: 'bold' }}>
                  {importResults.newCustomers}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  New Customers
                </Typography>
              </Box>
            </Grid>

            <Grid item xs={12} md={4}>
              <Box sx={{ textAlign: 'center', p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                <TrendingUp sx={{ fontSize: 48, color: 'info.main', mb: 1 }} />
                <Typography variant="h4" color="info.main" sx={{ fontWeight: 'bold' }}>
                  {importResults.updatedPolicies}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Updated Policies
                </Typography>
              </Box>
            </Grid>
          </Grid>

          <Divider sx={{ my: 3 }} />

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Box>
              <Typography variant="body1">
                ⏱️ Processing Time: {importResults.processingTime}
              </Typography>
            </Box>
            <Chip
              label="Import Completed"
              color="success"
              icon={<CheckCircle />}
            />
          </Box>
        </CardContent>
      </Card>

      {/* Data Quality Metrics */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            📊 Data Quality Metrics
          </Typography>

          <Grid container spacing={2}>
            <Grid item xs={12} md={4}>
              <Box sx={{ p: 2, bgcolor: 'success.light', borderRadius: 2, textAlign: 'center' }}>
                <Typography variant="h5" sx={{ fontWeight: 'bold', color: 'success.dark' }}>
                  {importResults.dataQuality.accuracy}%
                </Typography>
                <Typography variant="body2" color="success.dark">
                  Accuracy
                </Typography>
              </Box>
            </Grid>

            <Grid item xs={12} md={4}>
              <Box sx={{ p: 2, bgcolor: 'info.light', borderRadius: 2, textAlign: 'center' }}>
                <Typography variant="h5" sx={{ fontWeight: 'bold', color: 'info.dark' }}>
                  {importResults.dataQuality.updates}%
                </Typography>
                <Typography variant="body2" color="info.dark">
                  Updates
                </Typography>
              </Box>
            </Grid>

            <Grid item xs={12} md={4}>
              <Box sx={{ p: 2, bgcolor: 'warning.light', borderRadius: 2, textAlign: 'center' }}>
                <Typography variant="h5" sx={{ fontWeight: 'bold', color: 'warning.dark' }}>
                  {importResults.dataQuality.issues}%
                </Typography>
                <Typography variant="body2" color="warning.dark">
                  Issues
                </Typography>
              </Box>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Mobile App Sync Status */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            📱 Mobile App Sync Status
          </Typography>

          <Box sx={{ mb: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="body2" color="text.secondary">
                Syncing data to customer mobile apps...
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {syncProgress}%
              </Typography>
            </Box>
            <LinearProgress
              variant="determinate"
              value={syncProgress}
              color={syncProgress === 100 ? 'success' : 'primary'}
              sx={{ height: 8, borderRadius: 4 }}
            />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mt: 2 }}>
            <Sync color={isSyncing ? 'primary' : 'success'} />
            <Typography variant="body2">
              {isSyncing
                ? `👥 ${importResults.totalRecords} customers will receive notifications`
                : '✅ Data sync completed successfully'
              }
            </Typography>
          </Box>

          {!isSyncing && (
            <Alert severity="success" sx={{ mt: 2 }}>
              📱 Data available in mobile apps within 5 minutes
            </Alert>
          )}
        </CardContent>
      </Card>

      {/* Next Steps */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            🎯 Next Steps
          </Typography>

          <List>
            <ListItem>
              <ListItemIcon>
                <Analytics color="primary" />
              </ListItemIcon>
              <ListItemText
                primary="View import analytics"
                secondary="Review detailed import statistics and performance metrics"
              />
            </ListItem>

            <ListItem>
              <ListItemIcon>
                <Download color="info" />
              </ListItemIcon>
              <ListItemText
                primary="Download success report"
                secondary="Export comprehensive import report for records"
              />
            </ListItem>

            <ListItem>
              <ListItemIcon>
                <Phone color="success" />
              </ListItemIcon>
              <ListItemText
                primary="Contact customers about new data"
                secondary="Notify customers that their data is now available"
              />
            </ListItem>

            <ListItem>
              <ListItemIcon>
                <Upload color="secondary" />
              </ListItemIcon>
              <ListItemText
                primary="Upload more customer data"
                secondary="Continue importing additional customer batches"
              />
            </ListItem>
          </List>
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
        <Button
          variant="contained"
          startIcon={<Analytics />}
          onClick={() => navigate('/dashboard')}
          color="primary"
        >
          View Analytics
        </Button>

        <Button
          variant="outlined"
          startIcon={<Download />}
          onClick={handleDownloadReport}
          color="info"
        >
          Download Report
        </Button>

        <Button
          variant="outlined"
          startIcon={<Phone />}
          onClick={handleContactCustomers}
          color="success"
        >
          Contact Customers
        </Button>

        <Button
          variant="outlined"
          startIcon={<Upload />}
          onClick={() => navigate('/data-import')}
          color="secondary"
        >
          Upload More Data
        </Button>
      </Box>

      {/* Success Message */}
      <Alert severity="success" sx={{ mt: 3 }}>
        🎉 Import operation completed successfully! All customer data has been processed and is now available in the Agent Mitra system.
      </Alert>
    </Box>
  );
};

export default ImportSuccess;
