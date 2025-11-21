import React from 'react';
import { Container, Typography, Box, Card, CardContent } from '@mui/material';
import { Description } from '@mui/icons-material';

const ExcelTemplate: React.FC = () => {
  return (
    <Container maxWidth="lg">
      <Typography variant="h4" component="h1" gutterBottom>
        Excel Template Configuration
      </Typography>

      <Card>
        <CardContent>
          <Box display="flex" alignItems="center" mb={2}>
            <Description sx={{ mr: 2, fontSize: 40, color: 'primary.main' }} />
            <Box>
              <Typography variant="h6">Configure Excel Templates</Typography>
              <Typography variant="body2" color="text.secondary">
                Set up and manage Excel templates for data import
              </Typography>
            </Box>
          </Box>

          <Typography variant="body1">
            Excel Template Configuration will be implemented here. This will include:
          </Typography>

          <Box component="ul" sx={{ mt: 1, pl: 3 }}>
            <li>Column mapping interface</li>
            <li>Data type selection and validation</li>
            <li>Template preview and management</li>
            <li>Save/load template configurations</li>
            <li>Bulk import processing setup</li>
          </Box>
        </CardContent>
      </Card>
    </Container>
  );
};

export default ExcelTemplate;
