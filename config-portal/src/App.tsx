import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { QueryClient, QueryClientProvider } from 'react-query';
import { ErrorBoundary } from 'react-error-boundary';
import { RBACProvider } from './contexts/RBACContext';
import ProtectedRoute from './components/ProtectedRoute';
import { UserRole } from './types/rbac';

// Layout Components
import Layout from './components/Layout';

// Pages
import Dashboard from './pages/Dashboard';
import DataImport from './pages/DataImport';
import DataImportProgress from './pages/DataImportProgress';
import ImportErrors from './pages/ImportErrors';
import ImportSuccess from './pages/ImportSuccess';
import ExcelTemplate from './pages/ExcelTemplate';
import Settings from './pages/Settings';
import Login from './pages/Login';
import CampaignManagement from './pages/CampaignManagement';
import CallbackManagement from './pages/CallbackManagement';
import CustomerManagement from './pages/CustomerManagement';
import ReportingDashboard from './pages/ReportingDashboard';
import UserManagement from './pages/UserManagement';

// Theme configuration
const theme = createTheme({
  palette: {
    primary: {
      main: '#1a237e',
    },
    secondary: {
      main: '#ff4081',
    },
    background: {
      default: '#f5f5f5',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h4: {
      fontWeight: 600,
    },
    h5: {
      fontWeight: 600,
    },
    h6: {
      fontWeight: 600,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: 'none',
          fontWeight: 600,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: 8,
          },
        },
      },
    },
  },
});

// Query client for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 5 * 60 * 1000, // 5 minutes
    },
  },
});

// Error boundary fallback component
const ErrorFallback = ({ error, resetErrorBoundary }: any) => (
  <div style={{ padding: '20px', textAlign: 'center' }}>
    <h2>Something went wrong</h2>
    <p>{error.message}</p>
    <button onClick={resetErrorBoundary}>Try again</button>
  </div>
);

function App() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          <RBACProvider>
            <Router
              future={{
                v7_startTransition: true,
                v7_relativeSplatPath: true,
              }}
            >
              <Routes>
                {/* Public routes */}
                <Route path="/login" element={<Login />} />

                {/* Protected routes with RBAC */}
                <Route path="/" element={
                  <ProtectedRoute>
                    <Layout />
                  </ProtectedRoute>
                }>
                  <Route index element={<Navigate to="/dashboard" replace />} />

                  {/* Dashboard - accessible to all authenticated users */}
                  <Route path="dashboard" element={
                    <ProtectedRoute>
                      <Dashboard />
                    </ProtectedRoute>
                  } />

                  {/* Data Import - requires data_import.create permission */}
                  <Route path="data-import" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'data_import', action: 'create' }]}>
                      <DataImport />
                    </ProtectedRoute>
                  } />
                  <Route path="data-import-progress" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'data_import', action: 'create' }]}>
                      <DataImportProgress />
                    </ProtectedRoute>
                  } />
                  <Route path="import-errors" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'data_import', action: 'create' }]}>
                      <ImportErrors />
                    </ProtectedRoute>
                  } />
                  <Route path="import-success" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'data_import', action: 'create' }]}>
                      <ImportSuccess />
                    </ProtectedRoute>
                  } />
                  <Route path="excel-template" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'templates', action: 'read' }]}>
                      <ExcelTemplate />
                    </ProtectedRoute>
                  } />

                  {/* Customer Management - requires agents.read permission */}
                  <Route path="customers" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'agents', action: 'read' }]}>
                      <CustomerManagement />
                    </ProtectedRoute>
                  } />

                  {/* Reporting - requires reports.generate permission */}
                  <Route path="reporting" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'reports', action: 'generate' }]}>
                      <ReportingDashboard />
                    </ProtectedRoute>
                  } />

                  {/* User Management - requires users.read permission */}
                  <Route path="users" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'users', action: 'read' }]}>
                      <UserManagement />
                    </ProtectedRoute>
                  } />

                  {/* Settings - all authenticated users */}
                  <Route path="settings" element={
                    <ProtectedRoute>
                      <Settings />
                    </ProtectedRoute>
                  } />

                  {/* Campaigns - requires campaigns.read permission */}
                  <Route path="campaigns" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'campaigns', action: 'read' }]}>
                      <CampaignManagement />
                    </ProtectedRoute>
                  } />

                  {/* Callbacks - requires agents.read permission */}
                  <Route path="callbacks" element={
                    <ProtectedRoute requiredPermissions={[{ resource: 'agents', action: 'read' }]}>
                      <CallbackManagement />
                    </ProtectedRoute>
                  } />
                </Route>

                {/* Catch all - redirect to dashboard for authenticated users, login for others */}
                <Route path="*" element={
                  <ProtectedRoute redirectTo="/login">
                    <Navigate to="/dashboard" replace />
                  </ProtectedRoute>
                } />
              </Routes>
            </Router>
          </RBACProvider>
        </ThemeProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}

export default App;
