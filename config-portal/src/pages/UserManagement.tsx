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
  Alert,
  Pagination,
  InputAdornment,
  Tabs,
  Tab,
  Checkbox,
  FormControlLabel,
  List,
  ListItem,
  ListItemText,
  Divider,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Search,
  Refresh,
  Visibility,
  LockReset,
  History,
} from '@mui/icons-material';
import { useForm, Controller } from 'react-hook-form';
import { userApi, User, UserRole, UserFilters, UserActivityLog, Permission } from '../services/userApi';

interface UserFormData {
  email: string;
  firstName: string;
  lastName: string;
  phone?: string;
  role: UserRole;
  agentCode?: string;
  password?: string;
  isActive: boolean;
}

const UserManagement: React.FC = () => {
  const [activeTab, setActiveTab] = useState(0);
  const [users, setUsers] = useState<User[]>([]);
  const [activityLogs, setActivityLogs] = useState<UserActivityLog[]>([]);
  const [roles, setRoles] = useState<{ role: UserRole; name: string; description: string }[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [showEditDialog, setShowEditDialog] = useState(false);
  const [showDetailsDialog, setShowDetailsDialog] = useState(false);
  const [showPermissionsDialog, setShowPermissionsDialog] = useState(false);
  const [showActivityDialog, setShowActivityDialog] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [filters, setFilters] = useState<UserFilters>({});
  const [searchQuery, setSearchQuery] = useState('');
  const [page, setPage] = useState(1);
  const [pageSize] = useState(20);
  const [total, setTotal] = useState(0);
  const [activityPage, setActivityPage] = useState(1);
  const [activityTotal, setActivityTotal] = useState(0);

  const { control, handleSubmit, reset, formState: { errors } } = useForm<UserFormData>({
    defaultValues: {
      role: 'junior_agent',
      isActive: true,
    },
  });

  useEffect(() => {
    loadUsers();
    loadRoles();
  }, [page, filters]);

  useEffect(() => {
    if (activeTab === 1) {
      loadActivityLogs();
    }
  }, [activeTab, activityPage]);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const searchFilters = { ...filters };
      if (searchQuery) {
        searchFilters.search = searchQuery;
      }
      const response = await userApi.getUsers(page, pageSize, searchFilters);
      setUsers(response.data);
      setTotal(response.total);
    } catch (err: any) {
      setError(err?.message || 'Failed to load users');
    } finally {
      setLoading(false);
    }
  };

  const loadRoles = async () => {
    try {
      const loadedRoles = await userApi.getRoles();
      setRoles(loadedRoles);
    } catch (err: any) {
      console.error('Failed to load roles:', err);
    }
  };

  const loadActivityLogs = async () => {
    try {
      setLoading(true);
      const response = await userApi.getUserActivityLogs(undefined, activityPage, 50);
      setActivityLogs(response.data);
      setActivityTotal(response.total);
    } catch (err: any) {
      setError(err?.message || 'Failed to load activity logs');
    } finally {
      setLoading(false);
    }
  };

  const handleAddUser = async (data: UserFormData) => {
    if (!data.password) {
      setError('Password is required for new users');
      return;
    }

    try {
      setLoading(true);
      const newUser = await userApi.createUser({
        ...data,
        password: data.password!,
      });
      if (newUser) {
        setSuccess('User created successfully');
        setShowAddDialog(false);
        reset();
        loadUsers();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  const handleEditUser = async (data: UserFormData) => {
    if (!selectedUser) return;

    try {
      setLoading(true);
      const updateData: any = { ...data };
      if (!data.password) {
        delete updateData.password;
      }
      const updatedUser = await userApi.updateUser(selectedUser.id, updateData);
      if (updatedUser) {
        setSuccess('User updated successfully');
        setShowEditDialog(false);
        setSelectedUser(null);
        reset();
        loadUsers();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to update user');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this user?')) return;

    try {
      setLoading(true);
      const success = await userApi.deleteUser(id);
      if (success) {
        setSuccess('User deleted successfully');
        loadUsers();
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to delete user');
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async (userId: string) => {
    const newPassword = prompt('Enter new password:');
    if (!newPassword) return;

    try {
      setLoading(true);
      const success = await userApi.resetPassword(userId, newPassword);
      if (success) {
        setSuccess('Password reset successfully');
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to reset password');
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetails = async (userId: string) => {
    const user = await userApi.getUser(userId);
    if (user) {
      setSelectedUser(user);
      setShowDetailsDialog(true);
    }
  };

  const handleViewActivity = async (userId: string) => {
    setSelectedUser(users.find(u => u.id === userId) || null);
    try {
      setLoading(true);
      const response = await userApi.getUserActivityLogs(userId, 1, 50);
      setActivityLogs(response.data);
      setActivityTotal(response.total);
      setShowActivityDialog(true);
    } catch (err: any) {
      setError(err?.message || 'Failed to load activity logs');
    } finally {
      setLoading(false);
    }
  };

  const handleEditClick = (user: User) => {
    setSelectedUser(user);
    reset({
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      role: user.role,
      agentCode: user.agentCode,
      isActive: user.isActive,
    });
    setShowEditDialog(true);
  };

  const getRoleName = (role: UserRole) => {
    return roles.find(r => r.role === role)?.name || role;
  };

  const renderUserForm = (onSubmit: (data: UserFormData) => void, isEdit: boolean = false) => (
    <form onSubmit={handleSubmit(onSubmit)}>
      <DialogContent>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <Controller
              name="firstName"
              control={control}
              rules={{ required: 'First name is required' }}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="First Name"
                  fullWidth
                  error={!!errors.firstName}
                  helperText={errors.firstName?.message}
                />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="lastName"
              control={control}
              rules={{ required: 'Last name is required' }}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Last Name"
                  fullWidth
                  error={!!errors.lastName}
                  helperText={errors.lastName?.message}
                />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <Controller
              name="email"
              control={control}
              rules={{
                required: 'Email is required',
                pattern: { value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: 'Invalid email' },
              }}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Email"
                  fullWidth
                  type="email"
                  disabled={isEdit}
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
              render={({ field }) => (
                <TextField {...field} label="Phone" fullWidth />
              )}
            />
          </Grid>
          {!isEdit && (
            <Grid item xs={12} sm={6}>
              <Controller
                name="password"
                control={control}
                rules={{ required: !isEdit ? 'Password is required' : false }}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Password"
                    fullWidth
                    type="password"
                    error={!!errors.password}
                    helperText={errors.password?.message}
                  />
                )}
              />
            </Grid>
          )}
          <Grid item xs={12} sm={6}>
            <Controller
              name="role"
              control={control}
              rules={{ required: 'Role is required' }}
              render={({ field }) => (
                <FormControl fullWidth error={!!errors.role}>
                  <InputLabel>Role</InputLabel>
                  <Select {...field} label="Role">
                    {roles.map((role) => (
                      <MenuItem key={role.role} value={role.role}>
                        {role.name}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
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
              name="isActive"
              control={control}
              render={({ field }) => (
                <FormControlLabel
                  control={<Checkbox {...field} checked={field.value} />}
                  label="Active"
                />
              )}
            />
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={() => {
          if (isEdit) {
            setShowEditDialog(false);
            setSelectedUser(null);
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
          User Management
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => {
            reset();
            setShowAddDialog(true);
          }}
        >
          Add User
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

      {/* Search and Filters */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                placeholder="Search users..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    setPage(1);
                    loadUsers();
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
                <InputLabel>Role</InputLabel>
                <Select
                  value={filters.role || ''}
                  onChange={(e) => {
                    setFilters({ ...filters, role: e.target.value as UserRole || undefined });
                    setPage(1);
                  }}
                  label="Role"
                >
                  <MenuItem value="">All</MenuItem>
                  {roles.map((role) => (
                    <MenuItem key={role.role} value={role.role}>
                      {role.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} md={3}>
              <FormControl fullWidth>
                <InputLabel>Status</InputLabel>
                <Select
                  value={filters.isActive === undefined ? '' : filters.isActive ? 'active' : 'inactive'}
                  onChange={(e) => {
                    const value = e.target.value;
                    setFilters({
                      ...filters,
                      isActive: value === '' ? undefined : value === 'active',
                    });
                    setPage(1);
                  }}
                  label="Status"
                >
                  <MenuItem value="">All</MenuItem>
                  <MenuItem value="active">Active</MenuItem>
                  <MenuItem value="inactive">Inactive</MenuItem>
                </Select>
              </FormControl>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card>
        <Tabs value={activeTab} onChange={(e, v) => setActiveTab(v)}>
          <Tab label="Users" />
          <Tab label="Activity Logs" />
        </Tabs>

        {activeTab === 0 && (
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Name</TableCell>
                  <TableCell>Email</TableCell>
                  <TableCell>Role</TableCell>
                  <TableCell>Agent Code</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Last Login</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={7} align="center">
                      <Typography>Loading...</Typography>
                    </TableCell>
                  </TableRow>
                ) : users.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7} align="center">
                      <Typography color="text.secondary">No users found</Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  users.map((user) => (
                    <TableRow key={user.id} hover>
                      <TableCell>{user.firstName} {user.lastName}</TableCell>
                      <TableCell>{user.email}</TableCell>
                      <TableCell>
                        <Chip label={getRoleName(user.role)} size="small" />
                      </TableCell>
                      <TableCell>{user.agentCode || '-'}</TableCell>
                      <TableCell>
                        <Chip
                          label={user.isActive ? 'Active' : 'Inactive'}
                          color={user.isActive ? 'success' : 'default'}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        {user.lastLoginAt ? new Date(user.lastLoginAt).toLocaleString() : 'Never'}
                      </TableCell>
                      <TableCell align="right">
                        <IconButton
                          size="small"
                          onClick={() => handleViewDetails(user.id)}
                          title="View Details"
                        >
                          <Visibility />
                        </IconButton>
                        <IconButton
                          size="small"
                          onClick={() => handleEditClick(user)}
                          title="Edit"
                        >
                          <Edit />
                        </IconButton>
                        <IconButton
                          size="small"
                          onClick={() => handleResetPassword(user.id)}
                          title="Reset Password"
                        >
                          <LockReset />
                        </IconButton>
                        <IconButton
                          size="small"
                          onClick={() => handleViewActivity(user.id)}
                          title="View Activity"
                        >
                          <History />
                        </IconButton>
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDeleteUser(user.id)}
                          title="Delete"
                        >
                          <Delete />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
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
          </TableContainer>
        )}

        {activeTab === 1 && (
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>User</TableCell>
                  <TableCell>Action</TableCell>
                  <TableCell>Resource</TableCell>
                  <TableCell>Timestamp</TableCell>
                  <TableCell>IP Address</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={5} align="center">
                      <Typography>Loading...</Typography>
                    </TableCell>
                  </TableRow>
                ) : activityLogs.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} align="center">
                      <Typography color="text.secondary">No activity logs found</Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  activityLogs.map((log) => (
                    <TableRow key={log.id} hover>
                      <TableCell>{log.userName}</TableCell>
                      <TableCell>{log.action}</TableCell>
                      <TableCell>{log.resource}</TableCell>
                      <TableCell>{new Date(log.timestamp).toLocaleString()}</TableCell>
                      <TableCell>{log.ipAddress || '-'}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
            {activityTotal > 50 && (
              <Box display="flex" justifyContent="center" p={2}>
                <Pagination
                  count={Math.ceil(activityTotal / 50)}
                  page={activityPage}
                  onChange={(e, value) => setActivityPage(value)}
                  color="primary"
                />
              </Box>
            )}
          </TableContainer>
        )}
      </Card>

      {/* Add User Dialog */}
      <Dialog open={showAddDialog} onClose={() => setShowAddDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle>Add New User</DialogTitle>
        {renderUserForm(handleAddUser, false)}
      </Dialog>

      {/* Edit User Dialog */}
      <Dialog open={showEditDialog} onClose={() => {
        setShowEditDialog(false);
        setSelectedUser(null);
        reset();
      }} maxWidth="md" fullWidth>
        <DialogTitle>Edit User</DialogTitle>
        {renderUserForm(handleEditUser, true)}
      </Dialog>

      {/* User Details Dialog */}
      <Dialog open={showDetailsDialog} onClose={() => {
        setShowDetailsDialog(false);
        setSelectedUser(null);
      }} maxWidth="md" fullWidth>
        <DialogTitle>User Details</DialogTitle>
        <DialogContent>
          {selectedUser && (
            <Grid container spacing={2} sx={{ mt: 1 }}>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Name</Typography>
                <Typography variant="body1">{selectedUser.firstName} {selectedUser.lastName}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Email</Typography>
                <Typography variant="body1">{selectedUser.email}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Role</Typography>
                <Typography variant="body1">{getRoleName(selectedUser.role)}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">Status</Typography>
                <Chip
                  label={selectedUser.isActive ? 'Active' : 'Inactive'}
                  color={selectedUser.isActive ? 'success' : 'default'}
                  size="small"
                />
              </Grid>
              {selectedUser.agentCode && (
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Agent Code</Typography>
                  <Typography variant="body1">{selectedUser.agentCode}</Typography>
                </Grid>
              )}
              {selectedUser.lastLoginAt && (
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Last Login</Typography>
                  <Typography variant="body1">{new Date(selectedUser.lastLoginAt).toLocaleString()}</Typography>
                </Grid>
              )}
            </Grid>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => {
            setShowDetailsDialog(false);
            setSelectedUser(null);
          }}>
            Close
          </Button>
        </DialogActions>
      </Dialog>

      {/* Activity Logs Dialog */}
      <Dialog open={showActivityDialog} onClose={() => {
        setShowActivityDialog(false);
        setSelectedUser(null);
      }} maxWidth="lg" fullWidth>
        <DialogTitle>
          Activity Logs {selectedUser && `- ${selectedUser.firstName} ${selectedUser.lastName}`}
        </DialogTitle>
        <DialogContent>
          <List>
            {activityLogs.map((log, index) => (
              <React.Fragment key={log.id}>
                <ListItem>
                  <ListItemText
                    primary={`${log.action} - ${log.resource}`}
                    secondary={`${new Date(log.timestamp).toLocaleString()} • IP: ${log.ipAddress || 'N/A'}`}
                  />
                </ListItem>
                {index < activityLogs.length - 1 && <Divider />}
              </React.Fragment>
            ))}
          </List>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => {
            setShowActivityDialog(false);
            setSelectedUser(null);
          }}>
            Close
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default UserManagement;

