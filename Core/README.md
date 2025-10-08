# AI Image Editing Backend (FastAPI)

## Overview
This is the backend service for the AI Image Editing Web Application. It provides REST API endpoints for managing image editing jobs using fal.ai's AI models.

## Features
- ✅ Image upload and processing
- ✅ fal.ai API integration (seedream-v4 / nano-banana)
- ✅ Async job processing with status tracking
- ✅ SQLite database for job persistence
- ✅ Version history support
- ✅ CORS enabled for web access

## Tech Stack
- **Framework**: FastAPI
- **Database**: SQLite (SQLAlchemy ORM)
- **AI Service**: fal.ai
- **Deployment**: Render.com

## API Endpoints

### Create New Job
```
POST /api/jobs
Content-Type: multipart/form-data

Parameters:
- image: File (required)
- prompt: String (required)

Response: Job object with job_id
```

### Get Job Status
```
GET /api/jobs/{job_id}

Response: Job details with status and result URL
```

### List All Jobs
```
GET /api/jobs

Response: Array of all jobs
```

## Setup Instructions

### Prerequisites
- Python 3.9+
- pip

### Installation

1. Clone the repository
```bash
cd Core
```

2. Create virtual environment
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies
```bash
pip install -r requirements.txt
```

4. Configure environment variables
```bash
cp .env.example .env
# Edit .env and add your fal.ai API key
```

5. Run the server
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`
API documentation at `http://localhost:8000/docs`

## Project Structure
```
Core/
├── main.py              # FastAPI application entry point
├── models.py            # SQLAlchemy database models
├── database.py          # Database configuration
├── routes/
│   └── jobs.py         # Job endpoints
├── services/
│   └── fal_service.py  # fal.ai integration
├── requirements.txt     # Python dependencies
├── .env                # Environment variables
└── README.md           # This file
```

## Environment Variables
- `FAL_API_KEY`: Your fal.ai API key
- `HOST`: Server host (default: 0.0.0.0)
- `PORT`: Server port (default: 8000)
- `DATABASE_URL`: SQLite database path
- `ALLOWED_ORIGINS`: CORS allowed origins

## Deployment
This backend is designed to be deployed on Render.com (free tier available).

See deployment instructions in the root README.md

## AI Tools Usage
This project was developed with assistance from GitHub Copilot for:
- Code completion and boilerplate generation
- API endpoint structure
- Error handling patterns
- Database schema design

## License
MIT
