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
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Checkbox,
  FormControlLabel,
  Alert,
  Pagination,
  InputAdornment,
  Menu,
  MenuList,
  ListItemIcon,
  ListItemText,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Search,
  MoreVert,
  Download,
  FilterList,
  Refresh,
  Visibility,
} from '@mui/icons-material';
import { useForm, Controller } from 'react-hook-form';
import { customerApi, Customer, CustomerFilters } from '../services/customerApi';

interface CustomerFormData {
  fullName: string;
  email: string;
  phone: string;
  dateOfBirth?: string;
  gender?: string;
  occupation?: string;
  annualIncome?: number;
  address?: string;
  city?: string;
  state?: string;
  pincode?: string;
  agentCode?: string;
  status: 'active' | 'inactive' | 'pending';
}

const CustomerManagement: React.FC = () => {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [showEditDialog, setShowEditDialog] = useState(false);
  const [showDetailsDialog, setShowDetailsDialog] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
  const [selectedRows, setSelectedRows] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [exportAnchorEl, setExportAnchorEl] = useState<null | HTMLElement>(null);
  const [menuCustomerId, setMenuCustomerId] = useState<string | null>(null);
  
  // Filters and pagination
  const [filters, setFilters] = useState<CustomerFilters>({});
  const [searchQuery, setSearchQuery] = useState('');
  const [page, setPage] = useState(1);
  const [pageSize] = useState(20);
  const [total, setTotal] = useState(0);

  const { control, handleSubmit, reset, formState: { errors } } = useForm<CustomerFormData>({
    defaultValues: {
      status: 'active',
    },
  });

  useEffect(() => {
    loadCustomers();
  }, [page, filters]);

  const loadCustomers = async () => {
    try {
      setLoading(true);
      const searchFilters = { ...filters };
      if (searchQuery) {
        searchFilters.search = searchQuery;
      }
      const response = await customerApi.getCustomers(page, pageSize, searchFilters);
      setCustomers(response.data);
      setTotal(response.total);
    } catch (err: any) {
      setError(err?.message || 'Failed to load customers');
    } finally {
      setLoading(false);
    }
  };

  const handleAddCustomer = async (data: CustomerFormData) => {
    try {
      setLoading(true);
      const newCustomer = await customerApi.createCustomer(data);
      if (newCustomer) {
        setSuccess('Customer created successfully');
        setShowAddDialog(false);
        reset();
        loadCustomers();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to create customer');
    } finally {
      setLoading(false);
    }
  };

  const handleEditCustomer = async (data: CustomerFormData) => {
    if (!selectedCustomer) return;

    try {
      setLoading(true);
      const updatedCustomer = await customerApi.updateCustomer(selectedCustomer.id, data);
      if (updatedCustomer) {
        setSuccess('Customer updated successfully');
        setShowEditDialog(false);
        setSelectedCustomer(null);
        reset();
        loadCustomers();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to update customer');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteCustomer = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this customer?')) return;

    try {
      setLoading(true);
      const success = await customerApi.deleteCustomer(id);
      if (success) {
        setSuccess('Customer deleted successfully');
        loadCustomers();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to delete customer');
    } finally {
      setLoading(false);
    }
  };

  const handleBulkDelete = async () => {
    if (selectedRows.length === 0) return;
    if (!window.confirm(`Are you sure you want to delete ${selectedRows.length} customers?`)) return;

    try {
      setLoading(true);
      const success = await customerApi.bulkDelete(selectedRows);
      if (success) {
        setSuccess(`${selectedRows.length} customers deleted successfully`);
        setSelectedRows([]);
        loadCustomers();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to delete customers');
    } finally {
      setLoading(false);
    }
  };

  const handleExport = async (format: 'csv' | 'excel' | 'pdf') => {
    try {
      setLoading(true);
      const blob = await customerApi.exportCustomers(format, filters);
      if (blob) {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `customers_export.${format === 'excel' ? 'xlsx' : format}`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
        setSuccess(`Export completed successfully`);
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to export customers');
    } finally {
      setLoading(false);
    }
  };

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, customerId: string) => {
    setAnchorEl(event.currentTarget);
    setMenuCustomerId(customerId);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setMenuCustomerId(null);
  };

  const handleViewDetails = async (customerId: string) => {
    const customer = await customerApi.getCustomer(customerId);
    if (customer) {
      setSelectedCustomer(customer);
      setShowDetailsDialog(true);
    }
    handleMenuClose();
  };

  const handleEditClick = (customer: Customer) => {
    setSelectedCustomer(customer);
    reset({
      fullName: customer.fullName,
      email: customer.email,
      phone: customer.phone,
      dateOfBirth: customer.dateOfBirth,
      gender: customer.gender as any,
      occupation: customer.occupation,
      annualIncome: customer.annualIncome,
      address: customer.address,
      city: customer.city,
      state: customer.state,
      pincode: customer.pincode,
      agentCode: customer.agentCode,
      status: customer.status,
    });
    setShowEditDialog(true);
    handleMenuClose();
  };

  const handleDeleteClick = (customerId: string) => {
    handleDeleteCustomer(customerId);
    handleMenuClose();
  };

  const renderCustomerForm = (onSubmit: (data: CustomerFormData) => void, isEdit: boolean = false) => (
    <form onSubmit={handleSubmit(onSubmit)}>
      <DialogContent>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <Controller
              name="fullName"
              control={control}
              rules={{ required: 'Full name is required' }}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Full Name"
                  fullWidth
                  error={!!errors.fullName}
                  helperText={errors.fullName?.message}
                />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="email"
              control={control}
              rules={{ required: 'Email is required', pattern: { value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: 'Invalid email' } }}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Email"
                  fullWidth
                  type="email"
                  error={!!errors.email}
                  helperText={errors.email?.message}
                />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="phone"
              control={control}
              rules={{ required: 'Phone is required' }}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Phone"
                  fullWidth
                  error={!!errors.phone}
                  helperText={errors.phone?.message}
                />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="dateOfBirth"
              control={control}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Date of Birth"
                  fullWidth
                  type="date"
                  InputLabelProps={{ shrink: true }}
                />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="gender"
              control={control}
              render={({ field }) => (
                <FormControl fullWidth>
                  <InputLabel>Gender</InputLabel>
                  <Select {...field} label="Gender">
                    <MenuItem value="male">Male</MenuItem>
                    <MenuItem value="female">Female</MenuItem>
                    <MenuItem value="other">Other</MenuItem>
                  </Select>
                </FormControl>
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="occupation"
              control={control}
              render={({ field }) => (
                <TextField {...field} label="Occupation" fullWidth />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="annualIncome"
              control={control}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Annual Income"
                  fullWidth
                  type="number"
                  onChange={(e) => field.onChange(parseFloat(e.target.value) || 0)}
                />
              )}
            />
          </Grid>
          <Grid item xs={12}>
            <Controller
              name="address"
              control={control}
              render={({ field }) => (
                <TextField {...field} label="Address" fullWidth multiline rows={2} />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={4}>
            <Controller
              name="city"
              control={control}
              render={({ field }) => (
                <TextField {...field} label="City" fullWidth />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={4}>
            <Controller
              name="state"
              control={control}
              render={({ field }) => (
                <TextField {...field} label="State" fullWidth />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={4}>
            <Controller
              name="pincode"
              control={control}
              render={({ field }) => (
                <TextField {...field} label="Pincode" fullWidth />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="agentCode"
              control={control}
              render={({ field }) => (
                <TextField {...field} label="Agent Code" fullWidth />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="status"
              control={control}
              render={({ field }) => (
                <FormControl fullWidth>
                  <InputLabel>Status</InputLabel>
                  <Select {...field} label="Status">
                    <MenuItem value="active">Active</MenuItem>
                    <MenuItem value="inactive">Inactive</MenuItem>
                    <MenuItem value="pending">Pending</MenuItem>
                  </Select>
                </FormControl>
              )}
            />
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={() => {
          if (isEdit) {
            setShowEditDialog(false);
            setSelectedCustomer(null);
          } else {
            setShowAddDialog(false);
          }
          reset();
        }}>
          Cancel
        </Button>
        <Button type="submit" variant="contained" disabled={loading}>
          {loading ? 'Saving...' : isEdit ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </form>
  );

  return (
    <Container maxWidth="xl">
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1">
          Customer Data Management
        </Typography>
        <Box display="flex" gap={2}>
          {selectedRows.length > 0 && (
            <Button
              variant="outlined"
              color="error"
              startIcon={<Delete />}
              onClick={handleBulkDelete}
            >
              Delete Selected ({selectedRows.length})
            </Button>
          )}
          <Button
            variant="outlined"
            startIcon={<Download />}
            onClick={(e) => setExportAnchorEl(e.currentTarget)}
          >
            Export
          </Button>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => {
              reset();
              setShowAddDialog(true);
            }}
          >
            Add Customer
          </Button>
        </Box>
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

      {/* Search and Filters */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                placeholder="Search customers..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    setPage(1);
                    loadCustomers();
                  }
                }}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Search />
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
            <Grid item xs={12} md={3}>
              <FormControl fullWidth>
                <InputLabel>Status</InputLabel>
                <Select
                  value={filters.status || ''}
                  onChange={(e) => {
                    setFilters({ ...filters, status: e.target.value || undefined });
                    setPage(1);
                  }}
                  label="Status"
                >
                  <MenuItem value="">All</MenuItem>
                  <MenuItem value="active">Active</MenuItem>
                  <MenuItem value="inactive">Inactive</MenuItem>
                  <MenuItem value="pending">Pending</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} md={3}>
              <Button
                fullWidth
                variant="outlined"
                startIcon={<Refresh />}
                onClick={loadCustomers}
              >
                Refresh
              </Button>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Customers Table */}
      <Card>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell padding="checkbox">
                  <Checkbox
                    checked={selectedRows.length === customers.length && customers.length > 0}
                    indeterminate={selectedRows.length > 0 && selectedRows.length < customers.length}
                    onChange={(e) => {
                      if (e.target.checked) {
                        setSelectedRows(customers.map(c => c.id));
                      } else {
                        setSelectedRows([]);
                      }
                    }}
                  />
                </TableCell>
                <TableCell>Name</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Phone</TableCell>
                <TableCell>City</TableCell>
                <TableCell>Agent Code</TableCell>
                <TableCell>Status</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={8} align="center">
                    <Typography>Loading...</Typography>
                  </TableCell>
                </TableRow>
              ) : customers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} align="center">
                    <Typography color="text.secondary">No customers found</Typography>
                  </TableCell>
                </TableRow>
              ) : (
                customers.map((customer) => (
                  <TableRow key={customer.id} hover>
                    <TableCell padding="checkbox">
                      <Checkbox
                        checked={selectedRows.includes(customer.id)}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedRows([...selectedRows, customer.id]);
                          } else {
                            setSelectedRows(selectedRows.filter(id => id !== customer.id));
                          }
                        }}
                      />
                    </TableCell>
                    <TableCell>{customer.fullName}</TableCell>
                    <TableCell>{customer.email}</TableCell>
                    <TableCell>{customer.phone}</TableCell>
                    <TableCell>{customer.city || '-'}</TableCell>
                    <TableCell>{customer.agentCode || '-'}</TableCell>
                    <TableCell>
                      <Chip
                        label={customer.status}
                        color={
                          customer.status === 'active' ? 'success' :
                          customer.status === 'inactive' ? 'default' : 'warning'
                        }
                        size="small"
                      />
                    </TableCell>
                    <TableCell align="right">
                      <IconButton
                        size="small"
                        onClick={(e) => handleMenuOpen(e, customer.id)}
                      >
                        <MoreVert />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
        {total > pageSize && (
          <Box display="flex" justifyContent="center" p={2}>
            <Pagination
              count={Math.ceil(total / pageSize)}
              page={page}
              onChange={(e, value) => setPage(value)}
              color="primary"
            />
          </Box>
        )}
      </Card>

      {/* Add Customer Dialog */}
      <Dialog open={showAddDialog} onClose={() => setShowAddDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle>Add New Customer</DialogTitle>
        {renderCustomerForm(handleAddCustomer, false)}
      </Dialog>

      {/* Edit Customer Dialog */}
      <Dialog open={showEditDialog} onClose={() => {
        setShowEditDialog(false);
        setSelectedCustomer(null);
        reset();
      }} maxWidth="md" fullWidth>
        <DialogTitle>Edit Customer</DialogTitle>
        {renderCustomerForm(handleEditCustomer, true)}
      </Dialog>

      {/* Customer Details Dialog */}
      <Dialog open={showDetailsDialog} onClose={() => {
        setShowDetailsDialog(false);
        setSelectedCustomer(null);
      }} maxWidth="md" fullWidth>
        <DialogTitle>Customer Details</DialogTitle>
        <DialogContent>
          {selectedCustomer && (
            <Grid container spacing={2} sx={{ mt: 1 }}>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Full Name</Typography>
                <Typography variant="body1">{selectedCustomer.fullName}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Email</Typography>
                <Typography variant="body1">{selectedCustomer.email}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Phone</Typography>
                <Typography variant="body1">{selectedCustomer.phone}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Status</Typography>
                <Chip
                  label={selectedCustomer.status}
                  color={selectedCustomer.status === 'active' ? 'success' : 'default'}
                  size="small"
                />
              </Grid>
              {selectedCustomer.address && (
                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">Address</Typography>
                  <Typography variant="body1">{selectedCustomer.address}</Typography>
                </Grid>
              )}
              {selectedCustomer.city && (
                <Grid item xs={12} sm={4}>
                  <Typography variant="body2" color="text.secondary">City</Typography>
                  <Typography variant="body1">{selectedCustomer.city}</Typography>
                </Grid>
              )}
              {selectedCustomer.state && (
                <Grid item xs={12} sm={4}>
                  <Typography variant="body2" color="text.secondary">State</Typography>
                  <Typography variant="body1">{selectedCustomer.state}</Typography>
                </Grid>
              )}
              {selectedCustomer.pincode && (
                <Grid item xs={12} sm={4}>
                  <Typography variant="body2" color="text.secondary">Pincode</Typography>
                  <Typography variant="body1">{selectedCustomer.pincode}</Typography>
                </Grid>
              )}
            </Grid>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => {
            setShowDetailsDialog(false);
            setSelectedCustomer(null);
          }}>
            Close
          </Button>
        </DialogActions>
      </Dialog>

      {/* Actions Menu */}
      <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={handleMenuClose}>
        <MenuList>
          <MenuItem onClick={() => menuCustomerId && handleViewDetails(menuCustomerId)}>
            <ListItemIcon><Visibility fontSize="small" /></ListItemIcon>
            <ListItemText>View Details</ListItemText>
          </MenuItem>
          <MenuItem onClick={() => menuCustomerId && handleEditClick(customers.find(c => c.id === menuCustomerId)!)}>
            <ListItemIcon><Edit fontSize="small" /></ListItemIcon>
            <ListItemText>Edit</ListItemText>
          </MenuItem>
          <MenuItem onClick={() => menuCustomerId && handleDeleteClick(menuCustomerId)}>
            <ListItemIcon><Delete fontSize="small" /></ListItemIcon>
            <ListItemText>Delete</ListItemText>
          </MenuItem>
        </MenuList>
      </Menu>

      {/* Export menu */}
      <Menu
        anchorEl={exportAnchorEl}
        open={Boolean(exportAnchorEl)}
        onClose={() => setExportAnchorEl(null)}
      >
        <MenuItem onClick={() => {
          handleExport('csv');
          setExportAnchorEl(null);
        }}>
          Export as CSV
        </MenuItem>
        <MenuItem onClick={() => {
          handleExport('excel');
          setExportAnchorEl(null);
        }}>
          Export as Excel
        </MenuItem>
        <MenuItem onClick={() => {
          handleExport('pdf');
          setExportAnchorEl(null);
        }}>
          Export as PDF
        </MenuItem>
      </Menu>
    </Container>
  );
};

export default CustomerManagement;

