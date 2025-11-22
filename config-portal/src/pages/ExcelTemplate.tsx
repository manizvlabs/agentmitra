import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  Button,
  Grid,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Chip,
  Alert,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
} from '@mui/material';
import {
  Description,
  Add,
  Edit,
  Delete,
  Download,
  Upload,
  ExpandMore,
  CheckCircle,
  Error,
} from '@mui/icons-material';
import { useForm, Controller } from 'react-hook-form';
import { dataImportApi } from '../services/dataImportApi';
import { FileProcessor } from '../services/fileProcessor';
import {
  ImportTemplate,
  ColumnMapping,
  ValidationRule,
  DataType,
  EntityDefinition,
} from '../types/dataImport';

interface TemplateFormData {
  name: string;
  description: string;
  entityType: string;
}

const ExcelTemplate: React.FC = () => {
  const [templates, setTemplates] = useState<ImportTemplate[]>([]);
  const [selectedTemplate, setSelectedTemplate] = useState<ImportTemplate | null>(null);
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [showMappingDialog, setShowMappingDialog] = useState(false);
  const [entityDefinitions, setEntityDefinitions] = useState<EntityDefinition[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const { control, handleSubmit, reset, formState: { errors } } = useForm<TemplateFormData>();

  useEffect(() => {
    loadTemplates();
    loadEntityDefinitions();
  }, []);

  const loadTemplates = async () => {
    try {
      setLoading(true);
      const loadedTemplates = await dataImportApi.getTemplates();
      setTemplates(loadedTemplates);
    } catch (err) {
      setError('Failed to load templates');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const loadEntityDefinitions = async () => {
    // Mock entity definitions - in real app, fetch from API
    const mockEntities: EntityDefinition[] = [
      {
        name: 'customers',
        label: 'Customers',
        fields: [
          { name: 'fullName', label: 'Full Name', type: 'string', required: true },
          { name: 'email', label: 'Email', type: 'email', required: true },
          { name: 'phone', label: 'Phone', type: 'phone', required: true },
          { name: 'dateOfBirth', label: 'Date of Birth', type: 'date', required: false },
          { name: 'gender', label: 'Gender', type: 'string', required: false },
          { name: 'occupation', label: 'Occupation', type: 'string', required: false },
          { name: 'annualIncome', label: 'Annual Income', type: 'currency', required: false },
        ],
        sampleData: FileProcessor.generateSampleData('customers'),
      },
      {
        name: 'policies',
        label: 'Insurance Policies',
        fields: [
          { name: 'policyNumber', label: 'Policy Number', type: 'string', required: true },
          { name: 'policyType', label: 'Policy Type', type: 'string', required: true },
          { name: 'customerName', label: 'Customer Name', type: 'string', required: true },
          { name: 'startDate', label: 'Start Date', type: 'date', required: true },
          { name: 'endDate', label: 'End Date', type: 'date', required: true },
          { name: 'premiumAmount', label: 'Premium Amount', type: 'currency', required: true },
          { name: 'status', label: 'Status', type: 'string', required: true },
        ],
        sampleData: FileProcessor.generateSampleData('policies'),
      },
      {
        name: 'agents',
        label: 'Insurance Agents',
        fields: [
          { name: 'agentCode', label: 'Agent Code', type: 'string', required: true },
          { name: 'fullName', label: 'Full Name', type: 'string', required: true },
          { name: 'email', label: 'Email', type: 'email', required: true },
          { name: 'phone', label: 'Phone', type: 'phone', required: true },
          { name: 'joinDate', label: 'Join Date', type: 'date', required: true },
          { name: 'status', label: 'Status', type: 'string', required: true },
        ],
        sampleData: FileProcessor.generateSampleData('agents'),
      },
    ];

    setEntityDefinitions(mockEntities);
  };

  const handleCreateTemplate = async (data: TemplateFormData) => {
    try {
      setLoading(true);
      const entityDef = entityDefinitions.find(e => e.name === data.entityType);
      if (!entityDef) {
        throw 'Invalid entity type';
      }

      const newTemplate: Partial<ImportTemplate> = {
        name: data.name,
        description: data.description,
        entityType: data.entityType as any,
        columnMappings: entityDef.fields.map(field => ({
          sourceColumn: field.label,
          targetField: field.name,
          dataType: field.type,
          required: field.required,
        })),
        validationRules: entityDef.fields
          .filter(field => field.required)
          .map(field => ({
            field: field.name,
            rule: 'required' as const,
            message: `${field.label} is required`,
          })),
      };

      const createdTemplate = await dataImportApi.createTemplate(newTemplate);
      if (createdTemplate) {
        setTemplates([...templates, createdTemplate]);
        setShowCreateDialog(false);
        reset();
        setSuccess('Template created successfully');
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to create template');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteTemplate = async (templateId: string) => {
    if (!window.confirm('Are you sure you want to delete this template?')) return;

    try {
      setLoading(true);
      const success = await dataImportApi.deleteTemplate(templateId);
      if (success) {
        setTemplates(templates.filter(t => t.id !== templateId));
        setSuccess('Template deleted successfully');
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err) {
      setError('Failed to delete template');
    } finally {
      setLoading(false);
    }
  };

  const handleDownloadTemplate = async (template: ImportTemplate) => {
    try {
      const entityDef = entityDefinitions.find(e => e.name === template.entityType);
      if (entityDef) {
        FileProcessor.exportToExcel(
          entityDef.sampleData,
          entityDef.fields.map(f => f.label),
          `${template.name}_template.xlsx`
        );
      }
    } catch (err) {
      setError('Failed to download template');
    }
  };

  const handleEditMappings = (template: ImportTemplate) => {
    setSelectedTemplate(template);
    setShowMappingDialog(true);
  };

  const renderTemplateCard = (template: ImportTemplate) => (
    <Card key={template.id} sx={{ mb: 2 }}>
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start">
          <Box flex={1}>
            <Typography variant="h6" gutterBottom>
              {template.name}
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              {template.description}
            </Typography>
            <Box display="flex" gap={1} mb={2}>
              <Chip
                label={template.entityType}
                color="primary"
                size="small"
              />
              <Chip
                label={`${template.columnMappings.length} columns`}
                variant="outlined"
                size="small"
              />
            </Box>
          </Box>

          <Box display="flex" gap={1}>
            <IconButton
              size="small"
              onClick={() => handleEditMappings(template)}
              title="Edit Column Mappings"
            >
              <Edit />
            </IconButton>
            <IconButton
              size="small"
              onClick={() => handleDownloadTemplate(template)}
              title="Download Template"
            >
              <Download />
            </IconButton>
            <IconButton
              size="small"
              color="error"
              onClick={() => handleDeleteTemplate(template.id)}
              title="Delete Template"
            >
              <Delete />
            </IconButton>
          </Box>
        </Box>

        <Accordion>
          <AccordionSummary expandIcon={<ExpandMore />}>
            <Typography variant="body2" fontWeight="bold">
              Column Mappings ({template.columnMappings.length})
            </Typography>
          </AccordionSummary>
          <AccordionDetails>
            <TableContainer component={Paper}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Source Column</TableCell>
                    <TableCell>Target Field</TableCell>
                    <TableCell>Data Type</TableCell>
                    <TableCell>Required</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {template.columnMappings.map((mapping, index) => (
                    <TableRow key={index}>
                      <TableCell>{mapping.sourceColumn}</TableCell>
                      <TableCell>{mapping.targetField}</TableCell>
                      <TableCell>
                        <Chip
                          label={mapping.dataType}
                          size="small"
                          color={
                            mapping.dataType === 'string' ? 'default' :
                            mapping.dataType === 'number' ? 'primary' :
                            mapping.dataType === 'email' ? 'secondary' :
                            'info'
                          }
                        />
                      </TableCell>
                      <TableCell>
                        {mapping.required ? (
                          <CheckCircle color="success" fontSize="small" />
                        ) : (
                          <Error color="disabled" fontSize="small" />
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </AccordionDetails>
        </Accordion>

        {template.validationRules.length > 0 && (
          <Accordion>
            <AccordionSummary expandIcon={<ExpandMore />}>
              <Typography variant="body2" fontWeight="bold">
                Validation Rules ({template.validationRules.length})
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              <List dense>
                {template.validationRules.map((rule, index) => (
                  <ListItem key={index}>
                    <ListItemText
                      primary={`${rule.field}: ${rule.rule}`}
                      secondary={rule.message}
                    />
                  </ListItem>
                ))}
              </List>
            </AccordionDetails>
          </Accordion>
        )}
      </CardContent>
    </Card>
  );

  return (
    <Container maxWidth="lg">
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1">
          Excel Template Configuration
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => setShowCreateDialog(true)}
        >
          Create Template
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 3 }} onClose={() => setSuccess(null)}>
          {success}
        </Alert>
      )}

      {loading ? (
        <Card>
          <CardContent>
            <Typography>Loading templates...</Typography>
          </CardContent>
        </Card>
      ) : templates.length === 0 ? (
        <Card>
          <CardContent sx={{ textAlign: 'center', py: 6 }}>
            <Description sx={{ fontSize: 64, color: 'grey.300', mb: 2 }} />
            <Typography variant="h6" color="text.secondary" gutterBottom>
              No Templates Created Yet
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
              Create your first Excel import template to get started
            </Typography>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={() => setShowCreateDialog(true)}
            >
              Create First Template
            </Button>
          </CardContent>
        </Card>
      ) : (
        templates.map(renderTemplateCard)
      )}

      {/* Create Template Dialog */}
      <Dialog open={showCreateDialog} onClose={() => setShowCreateDialog(false)} maxWidth="sm" fullWidth>
        <form onSubmit={handleSubmit(handleCreateTemplate)}>
          <DialogTitle>Create New Template</DialogTitle>
          <DialogContent>
            <Controller
              name="name"
              control={control}
              defaultValue=""
              rules={{ required: 'Template name is required' }}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Template Name"
                  fullWidth
                  margin="normal"
                  error={!!errors.name}
                  helperText={errors.name?.message}
                />
              )}
            />

            <Controller
              name="description"
              control={control}
              defaultValue=""
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Description"
                  fullWidth
                  margin="normal"
                  multiline
                  rows={3}
                />
              )}
            />

            <Controller
              name="entityType"
              control={control}
              defaultValue=""
              rules={{ required: 'Entity type is required' }}
              render={({ field }) => (
                <FormControl fullWidth margin="normal" error={!!errors.entityType}>
                  <InputLabel>Entity Type</InputLabel>
                  <Select {...field} label="Entity Type">
                    {entityDefinitions.map((entity) => (
                      <MenuItem key={entity.name} value={entity.name}>
                        {entity.label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              )}
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setShowCreateDialog(false)}>Cancel</Button>
            <Button type="submit" variant="contained" disabled={loading}>
              {loading ? 'Creating...' : 'Create Template'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Column Mapping Dialog */}
      <Dialog
        open={showMappingDialog}
        onClose={() => setShowMappingDialog(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>Edit Column Mappings</DialogTitle>
        <DialogContent>
          {selectedTemplate && (
            <Box>
              <Typography variant="h6" gutterBottom>
                {selectedTemplate.name} - Column Mappings
              </Typography>

              <TableContainer component={Paper}>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Source Column</TableCell>
                      <TableCell>Target Field</TableCell>
                      <TableCell>Data Type</TableCell>
                      <TableCell>Required</TableCell>
                      <TableCell>Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {selectedTemplate.columnMappings.map((mapping, index) => (
                      <TableRow key={index}>
                        <TableCell>{mapping.sourceColumn}</TableCell>
                        <TableCell>{mapping.targetField}</TableCell>
                        <TableCell>{mapping.dataType}</TableCell>
                        <TableCell>
                          {mapping.required ? 'Yes' : 'No'}
                        </TableCell>
                        <TableCell>
                          {/* TODO: Add edit/delete actions */}
                          <Typography variant="body2" color="text.secondary">
                            Edit
                          </Typography>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowMappingDialog(false)}>Close</Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default ExcelTemplate;
