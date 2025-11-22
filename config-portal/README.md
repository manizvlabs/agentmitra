# Agent Mitra Configuration Portal

A React/TypeScript web application for agents to configure and manage customer data, Excel templates, and portal settings.

## Features

- **Data Import Dashboard**: Upload and manage customer data via Excel/CSV files
- **Excel Template Configuration**: Set up column mappings and validation rules
- **Agent Dashboard**: Overview of imports, templates, and performance metrics
- **Settings Management**: Configure portal preferences and system settings

## Tech Stack

- **Frontend**: React 18 with TypeScript
- **UI Library**: Material-UI (MUI) v5
- **Routing**: React Router v6
- **State Management**: React Query for server state
- **Styling**: Emotion (built into MUI)
- **Forms**: React Hook Form
- **File Upload**: React Dropzone
- **Excel Processing**: xlsx library

## Getting Started

### Prerequisites

- Node.js 16+ and npm
- Backend API running on `http://localhost:8012`

### Installation

1. **Navigate to the portal directory:**
   ```bash
   cd config-portal
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the development server:**
   ```bash
   npm start
   ```

   The portal will be available at `http://localhost:3013`

### Build for Production

```bash
npm run build
```

This creates an optimized production build in the `build/` directory.

## Project Structure

```
config-portal/
├── public/                    # Static assets
│   ├── index.html            # HTML template
│   └── manifest.json         # PWA manifest
├── src/
│   ├── components/           # Reusable UI components
│   │   └── Layout.tsx        # Main layout with sidebar
│   ├── pages/                # Page components
│   │   ├── Dashboard.tsx     # Main dashboard
│   │   ├── DataImport.tsx    # Data import interface
│   │   ├── ExcelTemplate.tsx # Template configuration
│   │   ├── Login.tsx         # Authentication
│   │   └── Settings.tsx      # Portal settings
│   ├── hooks/                # Custom React hooks
│   ├── services/             # API services
│   ├── utils/                # Utility functions
│   ├── types/                # TypeScript type definitions
│   ├── App.tsx               # Main app component
│   └── index.tsx             # App entry point
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
└── README.md                 # This file
```

## API Integration

The portal connects to the Agent Mitra backend API running on port 8012. Key endpoints used:

- `GET /api/v1/agents/{id}/profile` - Agent profile data
- `POST /api/v1/agents/{id}/upload` - File uploads
- `GET /api/v1/imports` - Import history
- `POST /api/v1/templates` - Template management

## Development Guidelines

### Code Style

- Use TypeScript for all new code
- Follow React best practices and hooks
- Use Material-UI components for consistent UI
- Implement proper error handling and loading states

### State Management

- Use React Query for server state (API data)
- Use local component state for UI state
- Avoid prop drilling with context when needed

### File Upload

- Support Excel (.xlsx, .xls) and CSV files
- Validate file size and type on client-side
- Show upload progress and handle errors gracefully

## Available Scripts

- `npm start` - Start development server
- `npm run build` - Create production build
- `npm test` - Run tests
- `npm run type-check` - Run TypeScript type checking

## Deployment

The portal can be deployed as a static site to any web server or CDN. The production build is located in the `build/` directory.

### Environment Variables

Create a `.env` file in the root directory:

```env
REACT_APP_API_BASE_URL=http://localhost:8012
REACT_APP_ENVIRONMENT=development
```

## Contributing

1. Follow the established project structure
2. Write clear, concise commit messages
3. Add TypeScript types for new data structures
4. Test your changes thoroughly
5. Update documentation as needed

## License

This project is part of the Agent Mitra platform.
