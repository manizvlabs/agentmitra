import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { authApi } from './services/authApi';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Box, CircularProgress } from '@mui/material';
import { QueryClient, QueryClientProvider } from 'react-query';
import { ErrorBoundary } from 'react-error-boundary';

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

// Protected Route Component
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);

  useEffect(() => {
    const checkAuth = () => {
      const authStatus = authApi.isAuthenticated();
      setIsAuthenticated(authStatus);
      
      // If not authenticated, ensure we redirect
      if (!authStatus) {
        // Small delay to ensure state is set before redirect
        setTimeout(() => {
          window.location.href = '/login';
        }, 100);
      }
    };

    checkAuth();
  }, []);

  if (isAuthenticated === null) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
};

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
          <Router
            future={{
              v7_startTransition: true,
              v7_relativeSplatPath: true,
            }}
          >
            <Routes>
              <Route path="/login" element={<Login />} />
              <Route path="/" element={
                <ProtectedRoute>
                  <Layout />
                </ProtectedRoute>
              }>
                <Route index element={<Navigate to="/dashboard" replace />} />
                <Route path="dashboard" element={<Dashboard />} />
                <Route path="data-import" element={<DataImport />} />
                <Route path="data-import-progress" element={<DataImportProgress />} />
                <Route path="import-errors" element={<ImportErrors />} />
                <Route path="import-success" element={<ImportSuccess />} />
                <Route path="excel-template" element={<ExcelTemplate />} />
                <Route path="settings" element={<Settings />} />
                <Route path="campaigns" element={<CampaignManagement />} />
                <Route path="callbacks" element={<CallbackManagement />} />
              </Route>
            </Routes>
          </Router>
        </ThemeProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}

export default App;
