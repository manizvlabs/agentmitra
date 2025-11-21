"""
Agent Mitra - FastAPI Backend Application
Main entry point for the backend API server
"""

"""
Agent Mitra - FastAPI Backend Application
Main entry point for the backend API server
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import api_router
import uvicorn
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv("../.env.local")

# Create FastAPI app
app = FastAPI(
    title="Agent Mitra API",
    description="Agent Mitra Backend API - Insurance Agent Management Platform",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(api_router)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Agent Mitra API",
        "version": "0.1.0",
        "status": "running",
        "docs": "/docs",
        "api": "/api/v1"
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "agent-mitra-backend",
        "version": "0.1.0"
    }


@app.get("/api/v1/health")
async def api_health():
    """API health check endpoint"""
    return {
        "status": "healthy",
        "api_version": "v1",
        "service": "agent-mitra-backend"
    }


if __name__ == "__main__":
    # Get port from environment or default to 8012
    port = int(os.getenv("API_PORT", "8012"))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=True
    )

