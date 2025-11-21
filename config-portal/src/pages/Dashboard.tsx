import React from 'react';
import {
  Container,
  Typography,
  Grid,
  Card,
  CardContent,
  Box,
  LinearProgress,
} from '@mui/material';
import {
  People,
  Description,
  TrendingUp,
  Warning,
} from '@mui/icons-material';

const Dashboard: React.FC = () => {
  // Mock data - replace with real API calls
  const stats = {
    totalCustomers: 1247,
    importedThisWeek: 89,
    templatesConfigured: 12,
    pendingValidations: 23,
  };

  const recentImports = [
    { id: 1, fileName: 'customers_q1_2024.xlsx', status: 'completed', records: 245 },
    { id: 2, fileName: 'agent_data_mar2024.csv', status: 'processing', records: 156 },
    { id: 3, fileName: 'policy_updates_feb.xlsx', status: 'failed', records: 0 },
  ];

  return (
    <Container maxWidth="lg">
      <Typography variant="h4" component="h1" gutterBottom sx={{ mb: 4 }}>
        Dashboard
      </Typography>

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <People color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6" component="div">
                  Total Customers
                </Typography>
              </Box>
              <Typography variant="h3" component="div" color="primary">
                {stats.totalCustomers.toLocaleString()}
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <TrendingUp color="success" sx={{ mr: 1 }} />
                <Typography variant="h6" component="div">
                  Imported This Week
                </Typography>
              </Box>
              <Typography variant="h3" component="div" color="success.main">
                {stats.importedThisWeek}
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <Description color="info" sx={{ mr: 1 }} />
                <Typography variant="h6" component="div">
                  Templates
                </Typography>
              </Box>
              <Typography variant="h3" component="div" color="info.main">
                {stats.templatesConfigured}
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <Warning color="warning" sx={{ mr: 1 }} />
                <Typography variant="h6" component="div">
                  Pending Validations
                </Typography>
              </Box>
              <Typography variant="h3" component="div" color="warning.main">
                {stats.pendingValidations}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Recent Activity */}
      <Card>
        <CardContent>
          <Typography variant="h6" component="h2" gutterBottom>
            Recent Data Imports
          </Typography>

          {recentImports.map((import_) => (
            <Box key={import_.id} sx={{ mb: 2 }}>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={1}>
                <Typography variant="body1" fontWeight="medium">
                  {import_.fileName}
                </Typography>
                <Box display="flex" alignItems="center">
                  <Typography
                    variant="body2"
                    color={
                      import_.status === 'completed' ? 'success.main' :
                      import_.status === 'processing' ? 'warning.main' : 'error.main'
                    }
                    sx={{ mr: 1 }}
                  >
                    {import_.status}
                  </Typography>
                  {import_.status === 'processing' && (
                    <LinearProgress sx={{ width: 60, height: 4 }} />
                  )}
                </Box>
              </Box>

              <Typography variant="body2" color="text.secondary">
                {import_.records} records • {new Date().toLocaleDateString()}
              </Typography>
            </Box>
          ))}
        </CardContent>
      </Card>
    </Container>
  );
};

export default Dashboard;
