import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert,
  Stepper,
  Step,
  StepLabel,
} from '@mui/material';
import { authApi } from '../services/authApi';

const Login: React.FC = () => {
  const [activeStep, setActiveStep] = useState(0);
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();

  const steps = ['Enter Phone Number', 'Verify OTP'];

  const handleSendOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      const response = await authApi.sendOtp(phoneNumber);
      if (response.success) {
        setSuccess(response.message || 'OTP sent successfully!');
        setActiveStep(1);
      } else {
        setError(response.message || 'Failed to send OTP. Please try again.');
      }
    } catch (err: any) {
      // Handle different error response formats
      const errorMessage = err.response?.data?.detail || 
                          err.response?.data?.message || 
                          err.message || 
                          'Failed to send OTP. Please try again.';
      setError(errorMessage);
      console.error('Send OTP error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await authApi.verifyOtp(phoneNumber, otp);
      if (response.success && response.data) {
        authApi.setAuthData(response.data);
        navigate('/dashboard');
      } else {
        setError(response.message || 'Invalid OTP. Please try again.');
      }
    } catch (err: any) {
      // Handle different error response formats
      const errorMessage = err.response?.data?.detail || 
                          err.response?.data?.message || 
                          err.message || 
                          'OTP verification failed. Please try again.';
      setError(errorMessage);
      console.error('OTP verification error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleBack = () => {
    setActiveStep(0);
    setError('');
    setSuccess('');
  };

  return (
    <Container component="main" maxWidth="sm">
      <Box
        sx={{
          marginTop: 8,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <Paper elevation={3} sx={{ padding: 4, width: '100%' }}>
          <Typography component="h1" variant="h4" align="center" gutterBottom>
            Agent Mitra Portal
          </Typography>

          <Typography variant="body1" align="center" color="text.secondary" sx={{ mb: 3 }}>
            Sign in to access your agent configuration dashboard
          </Typography>

          <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
            {steps.map((label) => (
              <Step key={label}>
                <StepLabel>{label}</StepLabel>
              </Step>
            ))}
          </Stepper>

          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          {success && (
            <Alert severity="success" sx={{ mb: 2 }}>
              {success}
            </Alert>
          )}

          {activeStep === 0 ? (
            // Phone Number Step
            <Box component="form" onSubmit={handleSendOtp} sx={{ mt: 1 }}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="phoneNumber"
                label="Phone Number"
                name="phoneNumber"
                autoComplete="tel"
                autoFocus
                placeholder="+91 9876543210"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
              />

              <Button
                type="submit"
                fullWidth
                variant="contained"
                sx={{ mt: 3, mb: 2, py: 1.5 }}
                disabled={loading || !phoneNumber}
              >
                {loading ? 'Sending OTP...' : 'Send OTP'}
              </Button>
            </Box>
          ) : (
            // OTP Verification Step
            <Box component="form" onSubmit={handleVerifyOtp} sx={{ mt: 1 }}>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                We sent an OTP to {phoneNumber}
              </Typography>

              <TextField
                margin="normal"
                required
                fullWidth
                id="otp"
                label="Enter OTP"
                name="otp"
                autoComplete="one-time-code"
                autoFocus
                value={otp}
                onChange={(e) => setOtp(e.target.value)}
                inputProps={{ maxLength: 6 }}
              />

              <Box sx={{ display: 'flex', gap: 2, mt: 3 }}>
                <Button
                  fullWidth
                  variant="outlined"
                  onClick={handleBack}
                  disabled={loading}
                >
                  Back
                </Button>
                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  disabled={loading || !otp}
                >
                  {loading ? 'Verifying...' : 'Verify OTP'}
                </Button>
              </Box>
            </Box>
          )}
        </Paper>
      </Box>
    </Container>
  );
};

export default Login;
