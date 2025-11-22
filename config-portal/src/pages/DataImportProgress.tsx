import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  LinearProgress,
  Card,
  CardContent,
  Grid,
  Chip,
  Button,
  Alert,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
} from '@mui/material';
import {
  ArrowBack,
  PlayArrow,
  Pause,
  Stop,
  CheckCircle,
  Error,
  Warning,
  Info,
  Sync,
} from '@mui/icons-material';

interface ImportStats {
  total: number;
  processed: number;
  successful: number;
  errors: number;
  pending: number;
}

interface ActivityLog {
  timestamp: string;
  type: 'info' | 'success' | 'error' | 'warning';
  message: string;
}

const DataImportProgress: React.FC = () => {
  const navigate = useNavigate();
  const [isImporting, setIsImporting] = useState(true);
  const [progress, setProgress] = useState(0);
  const [stats, setStats] = useState<ImportStats>({
    total: 1250,
    processed: 0,
    successful: 0,
    errors: 0,
    pending: 1250,
  });
  const [activityLog, setActivityLog] = useState<ActivityLog[]>([]);
  const [isPaused, setIsPaused] = useState(false);
  const [showCancelDialog, setShowCancelDialog] = useState(false);

  useEffect(() => {
    if (!isImporting || isPaused) return;

    const interval = setInterval(() => {
      setProgress(prev => {
        const newProgress = Math.min(prev + Math.random() * 3, 100);

        // Update stats based on progress
        const processed = Math.floor((newProgress / 100) * stats.total);
        const successful = Math.floor(processed * 0.95); // 95% success rate
        const errors = processed - successful;
        const pending = stats.total - processed;

        setStats({
          ...stats,
          processed,
          successful,
          errors,
          pending,
        });

        // Add activity log entries
        if (Math.random() > 0.7) {
          addActivityLog('info', `Processing customer record ${processed}/${stats.total}`);
        }

        // Simulate completion
        if (newProgress >= 100) {
          setIsImporting(false);
          addActivityLog('success', 'Import completed successfully');
          clearInterval(interval);
        }

        return newProgress;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [isImporting, isPaused, stats.total]);

  const addActivityLog = (type: ActivityLog['type'], message: string) => {
    const newLog: ActivityLog = {
      timestamp: new Date().toLocaleTimeString(),
      type,
      message,
    };
    setActivityLog(prev => [newLog, ...prev.slice(0, 9)]); // Keep last 10 entries
  };

  const handlePauseResume = () => {
    setIsPaused(!isPaused);
    addActivityLog(isPaused ? 'info' : 'warning', isPaused ? 'Import resumed' : 'Import paused');
  };

  const handleCancel = () => {
    setShowCancelDialog(true);
  };

  const confirmCancel = () => {
    setIsImporting(false);
    setShowCancelDialog(false);
    addActivityLog('error', 'Import cancelled by user');
  };

  const getProgressColor = () => {
    if (stats.errors > stats.successful * 0.1) return 'error';
    if (stats.errors > 0) return 'warning';
    return 'success';
  };

  const getActivityIcon = (type: ActivityLog['type']) => {
    switch (type) {
      case 'success': return <CheckCircle color="success" />;
      case 'error': return <Error color="error" />;
      case 'warning': return <Warning color="warning" />;
      default: return <Info color="info" />;
    }
  };

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#f5f5f5', p: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <IconButton onClick={() => navigate('/data-import')} sx={{ mr: 2 }}>
          <ArrowBack />
        </IconButton>
        <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold' }}>
          Data Import Progress
        </Typography>
      </Box>

      {/* Progress Overview */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Import Progress
          </Typography>

          <Box sx={{ mb: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="body2" color="text.secondary">
                Processing Records...
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {stats.processed}/{stats.total} ({Math.round(progress)}%)
              </Typography>
            </Box>
            <LinearProgress
              variant="determinate"
              value={progress}
              color={getProgressColor()}
              sx={{ height: 8, borderRadius: 4 }}
            />
          </Box>

          <Typography variant="body2" color="text.secondary">
            Estimated time remaining: {isImporting ? '8 minutes' : 'Complete'}
          </Typography>
        </CardContent>
      </Card>

      {/* Statistics Grid */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} md={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center' }}>
              <CheckCircle sx={{ fontSize: 48, color: 'success.main', mb: 1 }} />
              <Typography variant="h4" color="success.main" sx={{ fontWeight: 'bold' }}>
                {stats.successful}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Successful
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center' }}>
              <Error sx={{ fontSize: 48, color: 'error.main', mb: 1 }} />
              <Typography variant="h4" color="error.main" sx={{ fontWeight: 'bold' }}>
                {stats.errors}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Errors
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center' }}>
              <Sync sx={{ fontSize: 48, color: 'warning.main', mb: 1 }} />
              <Typography variant="h4" color="warning.main" sx={{ fontWeight: 'bold' }}>
                {stats.pending}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Pending
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center' }}>
              <Info sx={{ fontSize: 48, color: 'info.main', mb: 1 }} />
              <Typography variant="h4" color="info.main" sx={{ fontWeight: 'bold' }}>
                {stats.total}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Total
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Grid container spacing={3}>
        {/* Current Activity */}
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Current Activity
              </Typography>

              <List>
                {activityLog.length === 0 ? (
                  <ListItem>
                    <ListItemText
                      primary="Starting import process..."
                      secondary="Preparing to process customer data"
                    />
                  </ListItem>
                ) : (
                  activityLog.map((log, index) => (
                    <ListItem key={index}>
                      <ListItemIcon>
                        {getActivityIcon(log.type)}
                      </ListItemIcon>
                      <ListItemText
                        primary={log.message}
                        secondary={log.timestamp}
                      />
                    </ListItem>
                  ))
                )}
              </List>
            </CardContent>
          </Card>
        </Grid>

        {/* Import Controls */}
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Import Controls
              </Typography>

              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Button
                  variant="outlined"
                  startIcon={isPaused ? <PlayArrow /> : <Pause />}
                  onClick={handlePauseResume}
                  disabled={!isImporting}
                  fullWidth
                >
                  {isPaused ? 'Resume Import' : 'Pause Import'}
                </Button>

                <Button
                  variant="outlined"
                  startIcon={<Stop />}
                  onClick={handleCancel}
                  disabled={!isImporting}
                  color="error"
                  fullWidth
                >
                  Cancel Import
                </Button>

                {stats.errors > 0 && (
                  <Button
                    variant="contained"
                    onClick={() => navigate('/import-errors')}
                    color="warning"
                    fullWidth
                  >
                    Review Errors ({stats.errors})
                  </Button>
                )}

                {!isImporting && stats.errors === 0 && (
                  <Button
                    variant="contained"
                    onClick={() => navigate('/import-success')}
                    color="success"
                    fullWidth
                  >
                    View Results
                  </Button>
                )}
              </Box>
            </CardContent>
          </Card>

          {/* Status Alert */}
          {stats.errors > 0 && (
            <Alert severity="warning" sx={{ mt: 2 }}>
              {stats.errors} records failed to import. Review errors for details.
            </Alert>
          )}

          {isPaused && (
            <Alert severity="info" sx={{ mt: 2 }}>
              Import is paused. Click Resume to continue.
            </Alert>
          )}
        </Grid>
      </Grid>

      {/* Cancel Confirmation Dialog */}
      <Dialog open={showCancelDialog} onClose={() => setShowCancelDialog(false)}>
        <DialogTitle>Cancel Import</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to cancel the import? This action cannot be undone.
            {stats.processed > 0 && ` ${stats.successful} records have been successfully imported so far.`}
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowCancelDialog(false)}>Continue Import</Button>
          <Button onClick={confirmCancel} color="error">
            Cancel Import
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default DataImportProgress;
