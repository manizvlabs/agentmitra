# Agent Configuration Portal

A dedicated web service for insurance agent configuration, onboarding, and administrative functions.

## Features

- **Agent Onboarding**: Register and configure new insurance agents
- **Profile Management**: Update agent profiles and credentials
- **Data Import**: Bulk upload customer and policy data via Excel/CSV
- **Callback Management**: Handle customer inquiries and escalations
- **Content Management**: Upload and manage training materials
- **Dashboard**: Administrative overview and analytics
- **Authentication**: Secure JWT-based authentication

## Architecture

The portal service is a separate FastAPI application that:
- Runs on port 3013 (configurable)
- Shares the same database as the main API service
- Provides web interface for administrative functions
- Communicates with the main API for business logic

## Quick Start

1. **Install dependencies:**
   ```bash
   cd portal_service
   pip install -r requirements.txt
   ```

2. **Set environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Run the service:**
   ```bash
   python main.py
   ```

4. **Access the portal:**
   - Web interface: http://localhost:3013
   - API documentation: http://localhost:3013/docs

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORTAL_HOST` | Server host | `0.0.0.0` |
| `PORTAL_PORT` | Server port | `3013` |
| `DATABASE_URL` | PostgreSQL connection URL | Required |
| `REDIS_URL` | Redis connection URL | `redis://localhost:6379` |
| `PORTAL_JWT_SECRET_KEY` | JWT secret key | Required in production |
| `MAIN_API_URL` | Main API service URL | `http://localhost:8012` |

### Key Features

#### Agent Management
- Agent registration and onboarding
- Profile updates and credential management
- Status management (active, inactive, pending approval)
- Role-based access control

#### Data Import
- Excel/CSV file upload
- Bulk data processing
- Import job tracking and status monitoring
- Error reporting and validation

#### Callback System
- Customer inquiry management
- Priority-based escalation
- SLA tracking and monitoring
- Agent assignment and resolution tracking

#### Content Management
- Video and document upload
- Content categorization and tagging
- Access control and sharing
- Training material organization

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - Agent login
- `POST /api/v1/auth/register` - Agent registration
- `GET /api/v1/auth/me` - Get current user profile

### Agents
- `GET /api/v1/agents/` - List agents
- `GET /api/v1/agents/{agent_id}` - Get agent details
- `PUT /api/v1/agents/{agent_id}` - Update agent profile
- `PUT /api/v1/agents/{agent_id}/status` - Update agent status

### Dashboard
- `GET /api/v1/dashboard/overview` - Portal overview
- `GET /api/v1/dashboard/agents/summary` - Agents summary
- `GET /api/v1/dashboard/imports/summary` - Imports summary
- `GET /api/v1/dashboard/callbacks/summary` - Callbacks summary

### Data Import
- `POST /api/v1/import/upload` - Upload data file
- `GET /api/v1/import/jobs` - List import jobs
- `GET /api/v1/import/jobs/{job_id}` - Get import job status

### Callbacks
- `GET /api/v1/callbacks/` - List callback requests
- `POST /api/v1/callbacks/{callback_id}/assign` - Assign callback
- `POST /api/v1/callbacks/{callback_id}/complete` - Complete callback

### Content
- `POST /api/v1/content/upload` - Upload content
- `GET /api/v1/content/` - List content

## Development

### Project Structure
```
portal_service/
├── app/
│   ├── api/v1/           # API endpoints
│   ├── core/             # Core functionality
│   ├── models/           # Database models
│   ├── repositories/     # Data access layer
│   └── services/         # Business logic (future)
├── main.py               # Application entry point
├── requirements.txt      # Python dependencies
├── Dockerfile           # Container definition
└── README.md           # This file
```

### Adding New Features

1. Create API endpoints in `app/api/v1/`
2. Add business logic in `app/services/`
3. Create database models in `app/models/`
4. Add data access in `app/repositories/`

### Testing

```bash
# Run tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html
```

## Deployment

### Docker

```bash
# Build image
docker build -t agent-portal .

# Run container
docker run -p 3013:3013 --env-file .env agent-portal
```

### Kubernetes

The portal service can be deployed as a separate deployment in Kubernetes with its own service and ingress.

## Security

- JWT-based authentication
- Role-based access control
- Input validation and sanitization
- HTTPS enforcement in production
- Secure password hashing

## Monitoring

- Health check endpoints
- Structured logging
- Performance metrics (future)
- Error tracking (future)
