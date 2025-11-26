import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Box,
  Tabs,
  Tab,
  CircularProgress,
  Alert,
  Menu,
  MenuItem,
} from '@mui/material';
import {
  Phone,
  Assignment,
  CheckCircle,
  Refresh,
  FilterList,
  MoreVert,
} from '@mui/icons-material';
import axios from 'axios';

interface CallbackRequest {
  callback_request_id: string;
  policyholder_id: string;
  agent_id?: string;
  request_type: string;
  description: string;
  priority: string;
  priority_score: number;
  status: string;
  customer_name: string;
  customer_phone: string;
  customer_email?: string;
  due_at?: string;
  created_at: string;
}

const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? ''
  : (process.env.REACT_APP_API_URL || 'https://localhost:8012');

const CallbackManagement: React.FC = () => {
  const [callbacks, setCallbacks] = useState<CallbackRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedTab, setSelectedTab] = useState(0);
  const [filterPriority, setFilterPriority] = useState<string>('all');
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [selectedCallback, setSelectedCallback] = useState<string | null>(null);

  useEffect(() => {
    loadCallbacks();
  }, [filterPriority, selectedTab]);

  const loadCallbacks = async () => {
    try {
      setLoading(true);
      setError(null);
      const token = localStorage.getItem('access_token') || localStorage.getItem('authToken');
      
      if (!token) {
        setError('Authentication required. Please login.');
        setLoading(false);
        return;
      }
      
      const params: any = {};
      
      if (filterPriority !== 'all') {
        params.priority = filterPriority;
      }
      
      const statusMap = ['all', 'pending', 'assigned', 'completed'];
      if (statusMap[selectedTab] !== 'all') {
        params.status = statusMap[selectedTab];
      }

      const response = await axios.get(`${API_BASE_URL}/api/v1/callbacks`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
        params,
      });

      if (response.data.success) {
        setCallbacks(response.data.data || []);
      } else {
        setError('Failed to load callback requests');
      }
    } catch (err: any) {
      const errorMessage = err.response?.data?.detail || err.response?.data?.message || 'Failed to load callback requests';
      setError(errorMessage);
      console.error('Error loading callbacks:', err);
      
      // If unauthorized, clear token and redirect to login
      if (err.response?.status === 401) {
        localStorage.removeItem('access_token');
        localStorage.removeItem('refresh_token');
        window.location.href = '/login';
      }
    } finally {
      setLoading(false);
    }
  };

  const handleAssign = async (callbackId: string) => {
    try {
      const token = localStorage.getItem('access_token') || localStorage.getItem('authToken');
      await axios.post(
        `${API_BASE_URL}/api/v1/callbacks/${callbackId}/assign`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      await loadCallbacks();
      handleCloseMenu();
    } catch (err: any) {
      alert(err.response?.data?.detail || 'Failed to assign callback');
    }
  };

  const handleComplete = async (callbackId: string) => {
    try {
      const token = localStorage.getItem('access_token') || localStorage.getItem('authToken');
      await axios.post(
        `${API_BASE_URL}/api/v1/callbacks/${callbackId}/complete`,
        {
          resolution: 'Completed via portal',
          resolution_category: 'resolved',
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      await loadCallbacks();
      handleCloseMenu();
    } catch (err: any) {
      alert(err.response?.data?.detail || 'Failed to complete callback');
    }
  };

  const handleUpdateStatus = async (callbackId: string, status: string) => {
    try {
      const token = localStorage.getItem('access_token') || localStorage.getItem('authToken');
      await axios.put(
        `${API_BASE_URL}/api/v1/callbacks/${callbackId}/status`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
          params: { status },
        }
      );
      await loadCallbacks();
      handleCloseMenu();
    } catch (err: any) {
      alert(err.response?.data?.detail || 'Failed to update status');
    }
  };

  const handleOpenMenu = (event: React.MouseEvent<HTMLElement>, callbackId: string) => {
    setAnchorEl(event.currentTarget);
    setSelectedCallback(callbackId);
  };

  const handleCloseMenu = () => {
    setAnchorEl(null);
    setSelectedCallback(null);
  };

  const getPriorityColor = (priority: string) => {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'error';
      case 'medium':
        return 'warning';
      case 'low':
        return 'success';
      default:
        return 'default';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'warning';
      case 'assigned':
        return 'info';
      case 'completed':
        return 'success';
      case 'cancelled':
        return 'error';
      default:
        return 'default';
    }
  };

  const stats = {
    total: callbacks.length,
    highPriority: callbacks.filter((c) => c.priority === 'high').length,
    pending: callbacks.filter((c) => c.status === 'pending').length,
    completed: callbacks.filter((c) => c.status === 'completed').length,
  };

  if (loading && callbacks.length === 0) {
    return (
      <Container maxWidth="lg">
        <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
          <CircularProgress />
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg">
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1">
          Callback Request Management
        </Typography>
        <Button
          variant="outlined"
          startIcon={<Refresh />}
          onClick={loadCallbacks}
          disabled={loading}
        >
          Refresh
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                Total Callbacks
              </Typography>
              <Typography variant="h4">{stats.total}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                High Priority
              </Typography>
              <Typography variant="h4" color="error">
                {stats.highPriority}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                Pending
              </Typography>
              <Typography variant="h4" color="warning.main">
                {stats.pending}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                Completed
              </Typography>
              <Typography variant="h4" color="success.main">
                {stats.completed}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Card sx={{ mb: 3 }}>
        <Tabs
          value={selectedTab}
          onChange={(_, newValue) => setSelectedTab(newValue)}
        >
          <Tab label="All" />
          <Tab label="Pending" />
          <Tab label="Assigned" />
          <Tab label="Completed" />
        </Tabs>
      </Card>

      <Box sx={{ mb: 2 }}>
        <Button
          startIcon={<FilterList />}
          onClick={() => {
            const priorities = ['all', 'high', 'medium', 'low'];
            const currentIndex = priorities.indexOf(filterPriority);
            const nextIndex = (currentIndex + 1) % priorities.length;
            setFilterPriority(priorities[nextIndex]);
          }}
        >
          Priority: {filterPriority.toUpperCase()}
        </Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Customer</TableCell>
              <TableCell>Request Type</TableCell>
              <TableCell>Priority</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Phone</TableCell>
              <TableCell>Due Date</TableCell>
              <TableCell>Created</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {callbacks.length === 0 ? (
              <TableRow>
                <TableCell colSpan={8} align="center">
                  <Typography variant="body2" color="text.secondary" sx={{ py: 4 }}>
                    No callback requests found
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              callbacks.map((callback) => (
                <TableRow key={callback.callback_request_id}>
                  <TableCell>
                    <Typography variant="body2" fontWeight="medium">
                      {callback.customer_name}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {callback.description.substring(0, 50)}...
                    </Typography>
                  </TableCell>
                  <TableCell>{callback.request_type}</TableCell>
                  <TableCell>
                    <Chip
                      label={callback.priority}
                      size="small"
                      color={getPriorityColor(callback.priority) as any}
                    />
                    <Typography variant="caption" display="block" color="text.secondary">
                      Score: {callback.priority_score.toFixed(1)}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={callback.status}
                      size="small"
                      color={getStatusColor(callback.status) as any}
                    />
                  </TableCell>
                  <TableCell>{callback.customer_phone}</TableCell>
                  <TableCell>
                    {callback.due_at
                      ? new Date(callback.due_at).toLocaleDateString()
                      : 'N/A'}
                  </TableCell>
                  <TableCell>
                    {new Date(callback.created_at).toLocaleDateString()}
                  </TableCell>
                  <TableCell align="right">
                    <IconButton
                      size="small"
                      title="Call"
                      onClick={() => window.open(`tel:${callback.customer_phone}`)}
                    >
                      <Phone fontSize="small" />
                    </IconButton>
                    {callback.status === 'pending' && (
                      <IconButton
                        size="small"
                        title="Assign"
                        onClick={() => handleAssign(callback.callback_request_id)}
                      >
                        <Assignment fontSize="small" />
                      </IconButton>
                    )}
                    {callback.status !== 'completed' && (
                      <IconButton
                        size="small"
                        title="Complete"
                        onClick={() => handleComplete(callback.callback_request_id)}
                      >
                        <CheckCircle fontSize="small" color="success" />
                      </IconButton>
                    )}
                    <IconButton
                      size="small"
                      onClick={(e) => handleOpenMenu(e, callback.callback_request_id)}
                    >
                      <MoreVert fontSize="small" />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleCloseMenu}
      >
        <MenuItem onClick={() => selectedCallback && handleAssign(selectedCallback)}>
          Assign to Me
        </MenuItem>
        <MenuItem onClick={() => selectedCallback && handleUpdateStatus(selectedCallback, 'assigned')}>
          Mark as Assigned
        </MenuItem>
        <MenuItem onClick={() => selectedCallback && handleComplete(selectedCallback)}>
          Mark as Completed
        </MenuItem>
      </Menu>
    </Container>
  );
};

export default CallbackManagement;

