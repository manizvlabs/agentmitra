import React, { useState, useEffect } from 'react';
import { Outlet, useNavigate, useLocation, Link } from 'react-router-dom';
import { useRBAC } from '../contexts/RBACContext';
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  List,
  Typography,
  Divider,
  IconButton,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Avatar,
  Menu,
  MenuItem,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Dashboard,
  CloudUpload,
  Description,
  Settings,
  AccountCircle,
  Logout,
  Campaign,
  PhoneCallback,
  People,
  Assessment,
  ManageAccounts,
} from '@mui/icons-material';

const drawerWidth = 280;

interface NavigationItem {
  text: string;
  icon: React.ReactNode;
  path: string;
  requiredRoles?: string[];
  requiredPermissions?: { resource: string; action: string }[];
}

const allNavigationItems: NavigationItem[] = [
  {
    text: 'Dashboard',
    icon: <Dashboard />,
    path: '/dashboard',
    // Accessible to all authenticated users
  },
  {
    text: 'Data Import',
    icon: <CloudUpload />,
    path: '/data-import',
    requiredPermissions: [{ resource: 'data_import', action: 'create' }],
  },
  {
    text: 'Customer Management',
    icon: <People />,
    path: '/customers',
    requiredPermissions: [{ resource: 'agents', action: 'read' }],
  },
  {
    text: 'Reporting',
    icon: <Assessment />,
    path: '/reporting',
    requiredPermissions: [{ resource: 'reports', action: 'generate' }],
  },
  {
    text: 'User Management',
    icon: <ManageAccounts />,
    path: '/users',
    requiredPermissions: [{ resource: 'users', action: 'read' }],
  },
  {
    text: 'Campaigns',
    icon: <Campaign />,
    path: '/campaigns',
    requiredPermissions: [{ resource: 'campaigns', action: 'read' }],
  },
  {
    text: 'Callbacks',
    icon: <PhoneCallback />,
    path: '/callbacks',
    requiredPermissions: [{ resource: 'agents', action: 'read' }],
  },
  {
    text: 'Excel Template',
    icon: <Description />,
    path: '/excel-template',
    requiredPermissions: [{ resource: 'templates', action: 'read' }],
  },
  {
    text: 'Settings',
    icon: <Settings />,
    path: '/settings',
    // Accessible to all authenticated users
  },
];

const Layout: React.FC = () => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const navigate = useNavigate();
  const location = useLocation();
  const { user, hasAnyRole, hasPermission, logout, isAuthenticated } = useRBAC();

  // Filter navigation items based on user permissions
  const navigationItems = allNavigationItems.filter(item => {
    // If no permission requirements, item is accessible to all authenticated users
    if (!item.requiredPermissions) {
      return isAuthenticated;
    }

    // Check permission requirements - user needs at least one of the required permissions
    if (item.requiredPermissions && item.requiredPermissions.length > 0) {
      return item.requiredPermissions.some(
        perm => hasPermission(perm.resource, perm.action)
      );
    }

    return false;
  });

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleProfileMenuClose = () => {
    setAnchorEl(null);
  };


  const handleNavigation = (path: string) => {
    navigate(path);
    if (mobileOpen) {
      setMobileOpen(false);
    }
  };

  const drawer = (
    <div>
      {/* Logo/Brand */}
      <Box sx={{ p: 2, display: 'flex', alignItems: 'center' }}>
        <Typography variant="h6" noWrap component="div" sx={{ color: 'primary.main', fontWeight: 'bold' }}>
          Agent Mitra
        </Typography>
        <Typography variant="caption" sx={{ ml: 1, color: 'text.secondary' }}>
          Portal
        </Typography>
      </Box>

      <Divider />

      {/* Navigation Menu */}
      <List>
        {navigationItems.map((item) => (
          <ListItem key={item.text} disablePadding>
            <ListItemButton
              selected={location.pathname === item.path}
              component={Link}
              to={item.path}
              sx={{
                '&.Mui-selected': {
                  backgroundColor: 'primary.main',
                  color: 'primary.contrastText',
                  '&:hover': {
                    backgroundColor: 'primary.dark',
                  },
                  '& .MuiListItemIcon-root': {
                    color: 'primary.contrastText',
                  },
                },
              }}
            >
              <ListItemIcon
                sx={{
                  color: location.pathname === item.path ? 'inherit' : 'action.active',
                }}
              >
                {item.icon}
              </ListItemIcon>
              <ListItemText primary={item.text} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </div>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      {/* App Bar */}
      <AppBar
        position="fixed"
        sx={{
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          ml: { sm: `${drawerWidth}px` },
          backgroundColor: 'background.paper',
          color: 'text.primary',
          boxShadow: 1,
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: 'none' } }}
          >
            <MenuIcon />
          </IconButton>

          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            Agent Configuration Portal
          </Typography>

          {/* Profile Menu */}
          <IconButton
            size="large"
            aria-label="account of current user"
            aria-controls="profile-menu"
            aria-haspopup="true"
            onClick={handleProfileMenuOpen}
            color="inherit"
          >
            <Avatar sx={{ width: 32, height: 32 }}>
              <AccountCircle />
            </Avatar>
          </IconButton>

        <Menu
          id="profile-menu"
          anchorEl={anchorEl}
          anchorOrigin={{
            vertical: 'top',
            horizontal: 'right',
          }}
          keepMounted
          transformOrigin={{
            vertical: 'top',
            horizontal: 'right',
          }}
          open={Boolean(anchorEl)}
          onClose={handleProfileMenuClose}
        >
          <MenuItem onClick={handleProfileMenuClose}>
            <ListItemIcon>
              <AccountCircle fontSize="small" />
            </ListItemIcon>
            Profile
          </MenuItem>
          <MenuItem onClick={handleProfileMenuClose}>
            <ListItemIcon>
              <Settings fontSize="small" />
            </ListItemIcon>
            Settings
          </MenuItem>
          <Divider />
          <MenuItem onClick={() => {
            handleProfileMenuClose();
            logout();
          }}>
            <ListItemIcon>
              <Logout fontSize="small" />
            </ListItemIcon>
            Logout
          </MenuItem>
        </Menu>
        </Toolbar>
      </AppBar>

      {/* Sidebar Drawer */}
      <Box
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
        aria-label="navigation menu"
      >
        {/* Mobile drawer */}
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true, // Better open performance on mobile.
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: drawerWidth,
            },
          }}
        >
          {drawer}
        </Drawer>

        {/* Desktop drawer */}
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: drawerWidth,
            },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>

      {/* Main Content */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          minHeight: '100vh',
          backgroundColor: 'background.default',
        }}
      >
        <Toolbar /> {/* Spacer for AppBar */}
        <Outlet key={location.pathname} />
      </Box>
    </Box>
  );
};

export default Layout;
