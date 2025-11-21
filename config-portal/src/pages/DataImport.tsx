import React from 'react';
import { Container, Typography, Box, Card, CardContent } from '@mui/material';
import { CloudUpload } from '@mui/icons-material';

const DataImport: React.FC = () => {
  return (
    <Container maxWidth="lg">
      <Typography variant="h4" component="h1" gutterBottom>
        Data Import Dashboard
      </Typography>

      <Card>
        <CardContent>
          <Box display="flex" alignItems="center" mb={2}>
            <CloudUpload sx={{ mr: 2, fontSize: 40, color: 'primary.main' }} />
            <Box>
              <Typography variant="h6">Import Customer Data</Typography>
              <Typography variant="body2" color="text.secondary">
                Upload Excel or CSV files to import customer and policy data
              </Typography>
            </Box>
          </Box>

          <Typography variant="body1">
            Data Import functionality will be implemented here. This will include:
          </Typography>

          <Box component="ul" sx={{ mt: 1, pl: 3 }}>
            <li>Drag & drop file upload</li>
            <li>Data validation and preview</li>
            <li>Import progress tracking</li>
            <li>Error handling and correction</li>
            <li>Import history and audit trail</li>
          </Box>
        </CardContent>
      </Card>
    </Container>
  );
};

export default DataImport;
