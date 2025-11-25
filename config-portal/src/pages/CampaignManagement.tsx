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
  MenuItem,
  Box,
  Tabs,
  Tab,
  CircularProgress,
  Alert,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Launch,
  Analytics,
  Refresh,
  FilterList,
} from '@mui/icons-material';
import axios from 'axios';

interface Campaign {
  campaign_id: string;
  campaign_name: string;
  campaign_type: string;
  status: string;
  total_sent: number;
  total_converted: number;
  roi_percentage: number;
  created_at: string;
}

const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? ''
  : (process.env.REACT_APP_API_URL || 'http://localhost:8012');

const CampaignManagement: React.FC = () => {
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedTab, setSelectedTab] = useState(0);
  const [filterStatus, setFilterStatus] = useState<string>('all');

  useEffect(() => {
    loadCampaigns();
  }, [filterStatus]);

  const loadCampaigns = async () => {
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
      if (filterStatus !== 'all') {
        params.status = filterStatus;
      }

      const response = await axios.get(`${API_BASE_URL}/api/v1/campaigns`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
        params,
      });

      if (response.data.success) {
        setCampaigns(response.data.data || []);
      } else {
        setError('Failed to load campaigns');
      }
    } catch (err: any) {
      const errorMessage = err.response?.data?.detail || err.response?.data?.message || 'Failed to load campaigns';
      setError(errorMessage);
      console.error('Error loading campaigns:', err);
      
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

  const handleLaunchCampaign = async (campaignId: string) => {
    try {
      const token = localStorage.getItem('access_token') || localStorage.getItem('authToken');
      await axios.post(
        `${API_BASE_URL}/api/v1/campaigns/${campaignId}/launch`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      await loadCampaigns();
    } catch (err: any) {
      alert(err.response?.data?.detail || 'Failed to launch campaign');
    }
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'active':
        return 'success';
      case 'draft':
        return 'default';
      case 'completed':
        return 'info';
      case 'paused':
        return 'warning';
      default:
        return 'default';
    }
  };

  const getTypeColor = (type: string) => {
    switch (type.toLowerCase()) {
      case 'acquisition':
        return 'primary';
      case 'retention':
        return 'success';
      case 'upselling':
        return 'warning';
      case 'behavioral':
        return 'secondary';
      default:
        return 'default';
    }
  };

  if (loading && campaigns.length === 0) {
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
          Campaign Management
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => setOpenDialog(true)}
        >
          Create Campaign
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      <Card sx={{ mb: 3 }}>
        <Tabs
          value={selectedTab}
          onChange={(_, newValue) => {
            setSelectedTab(newValue);
            const statusMap = ['all', 'active', 'draft', 'completed'];
            setFilterStatus(statusMap[newValue] || 'all');
          }}
        >
          <Tab label="All Campaigns" />
          <Tab label="Active" />
          <Tab label="Draft" />
          <Tab label="Completed" />
        </Tabs>
      </Card>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Campaign Name</TableCell>
              <TableCell>Type</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Sent</TableCell>
              <TableCell align="right">Converted</TableCell>
              <TableCell align="right">ROI</TableCell>
              <TableCell>Created</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {campaigns.length === 0 ? (
              <TableRow>
                <TableCell colSpan={8} align="center">
                  <Typography variant="body2" color="text.secondary" sx={{ py: 4 }}>
                    No campaigns found
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              campaigns.map((campaign) => (
                <TableRow key={campaign.campaign_id}>
                  <TableCell>
                    <Typography variant="body2" fontWeight="medium">
                      {campaign.campaign_name}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={campaign.campaign_type}
                      size="small"
                      color={getTypeColor(campaign.campaign_type) as any}
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={campaign.status}
                      size="small"
                      color={getStatusColor(campaign.status) as any}
                    />
                  </TableCell>
                  <TableCell align="right">{campaign.total_sent}</TableCell>
                  <TableCell align="right">{campaign.total_converted}</TableCell>
                  <TableCell align="right">
                    {campaign.roi_percentage.toFixed(1)}%
                  </TableCell>
                  <TableCell>
                    {new Date(campaign.created_at).toLocaleDateString()}
                  </TableCell>
                  <TableCell align="right">
                    <IconButton
                      size="small"
                      onClick={() => handleLaunchCampaign(campaign.campaign_id)}
                      disabled={campaign.status === 'active'}
                      title="Launch Campaign"
                    >
                      <Launch fontSize="small" />
                    </IconButton>
                    <IconButton
                      size="small"
                      title="View Analytics"
                    >
                      <Analytics fontSize="small" />
                    </IconButton>
                    <IconButton size="small" title="Edit">
                      <Edit fontSize="small" />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      <Box display="flex" justifyContent="flex-end" mt={2}>
        <Button
          startIcon={<Refresh />}
          onClick={loadCampaigns}
          disabled={loading}
        >
          Refresh
        </Button>
      </Box>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle>Create New Campaign</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Campaign creation form will be implemented here. For now, please use the Flutter app
            to create campaigns.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Close</Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default CampaignManagement;

