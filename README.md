# AI Image Editor - Flutter Web + FastAPI

## 🎨 Project Overview

A complete, production-ready AI image editing web application built with Flutter Web (frontend) and Python FastAPI (backend), powered by fal.ai's image editing models.

### ✨ Key Features

#### Required Features ✅
- **Image Upload**: Drag-and-drop or click-to-upload interface
- **Prompt-Based Editing**: Text input for describing desired edits
- **AI Processing**: Integration with fal.ai (FLUX dev model)
- **Result Display**: View edited images in high quality
- **Download**: Save edited images locally
- **Job Management**: Track status of editing jobs
- **RESTful API**: Well-structured backend endpoints
- **Database Persistence**: SQLite for job history

#### Bonus Features ✅
- **Version History**: See all previous edits with metadata
- **Before/After Slider**: Interactive comparison tool
- **Real-time Status**: Live job status updates with polling
- **Responsive Design**: Works on desktop and tablets
- **Error Handling**: Comprehensive error messages and recovery

## 🏗️ Architecture

```
Voltran/
├── Core/                    # Backend (Python/FastAPI)
│   ├── main.py             # FastAPI application
│   ├── models.py           # Database models & schemas
│   ├── database.py         # Database configuration
│   ├── routes/
│   │   └── jobs.py         # API endpoints
│   ├── services/
│   │   └── fal_service.py  # fal.ai integration
│   ├── uploads/            # Uploaded images
│   ├── requirements.txt    # Python dependencies
│   └── .env               # Environment variables
│
└── Web/                    # Frontend (Flutter Web)
    ├── lib/
    │   ├── main.dart       # App entry point
    │   ├── models/
    │   │   └── job.dart    # Job data models
    │   ├── services/
    │   │   └── api_service.dart  # HTTP client
    │   ├── screens/
    │   │   └── home_screen.dart  # Main UI
    │   └── widgets/
    │       ├── image_upload_widget.dart
    │       ├── job_history_widget.dart
    │       └── before_after_slider.dart
    └── pubspec.yaml        # Flutter dependencies
```

## 🚀 Local Setup

### Backend Setup

1. **Navigate to Core directory**
```bash
cd Core
```

2. **Create virtual environment**
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your fal.ai API key (already configured)
```

5. **Run the server**
```bash
python main.py
```

Backend will be available at: `http://localhost:8000`
API documentation: `http://localhost:8000/docs`

### Frontend Setup

1. **Navigate to Web directory**
```bash
cd Web
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run -d chrome --web-port 3000
```

Frontend will be available at: `http://localhost:3000`

## 📡 API Endpoints

### POST /api/jobs
Create a new image editing job
- **Request**: multipart/form-data
  - `image`: File (required)
  - `prompt`: String (required)
- **Response**: Job object with job_id

### GET /api/jobs/{job_id}
Get job status and result
- **Response**: Job details with status and result URL

### GET /api/jobs
List all jobs (with version history)
- **Query params**: skip, limit
- **Response**: Array of jobs with pagination

### DELETE /api/jobs/{job_id}
Delete a job and its associated files

## 🤖 fal.ai Integration

**Model Used**: `fal-ai/flux/dev/image-to-image`

This model provides high-quality image-to-image transformations based on text prompts. The implementation:

1. Converts uploaded images to base64 for API transmission
2. Submits async jobs to fal.ai
3. Polls for completion status
4. Stores result URLs in database
5. Provides download functionality

**Alternative Models** (configured but not used):
- `fal-ai/seedream-v4`: For faster processing
- `fal-ai/nano-banana`: For lightweight edits

## 🔧 Tech Stack

### Backend
- **FastAPI**: Modern Python web framework
- **SQLAlchemy**: ORM for database operations
- **SQLite**: Lightweight database for job persistence
- **fal-client**: Official fal.ai Python SDK
- **Uvicorn**: ASGI server
- **Pillow**: Image processing utilities

### Frontend
- **Flutter Web**: Cross-platform UI framework
- **http**: HTTP client for API calls
- **file_picker**: File upload functionality
- **flutter_spinkit**: Loading animations
- **universal_html**: Web-specific utilities

## 🌐 Deployment

### Backend Deployment (Render.com)

1. Create a new Web Service on Render.com
2. Connect your GitHub repository
3. Configure:
   - **Build Command**: `pip install -r Core/requirements.txt`
   - **Start Command**: `cd Core && uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Root Directory**: Leave empty or set to `Core`
4. Add environment variables:
   - `FAL_API_KEY`: Your fal.ai API key
   - `DATABASE_URL`: `sqlite:///./jobs.db`
   - `ALLOWED_ORIGINS`: Your frontend URL

### Frontend Deployment (Firebase Hosting)

1. Build Flutter Web
```bash
cd Web
flutter build web
```

2. Install Firebase CLI
```bash
npm install -g firebase-tools
```

3. Initialize Firebase
```bash
firebase init hosting
# Select web/build/web as public directory
```

4. Deploy
```bash
firebase deploy
```

**Alternative: Vercel Deployment**
```bash
cd Web
flutter build web
vercel --prod
```

## 🎯 Usage Examples

1. **Upload an image** by clicking or dragging
2. **Enter a prompt**: 
   - "Add a sunset background"
   - "Make it look like an oil painting"
   - "Change the color scheme to blue tones"
   - "Add dramatic lighting"
3. **Click Generate Edit** and wait for AI processing
4. **View results** with before/after comparison
5. **Download** the edited image
6. **Check history** to see all previous edits

## 🧪 Testing

### Test Backend API
```bash
# Health check
curl http://localhost:8000/health

# Create a job (replace with actual file)
curl -X POST http://localhost:8000/api/jobs \
  -F "image=@test_image.jpg" \
  -F "prompt=Add a sunset background"

# Get job status
curl http://localhost:8000/api/jobs/{job_id}

# List all jobs
curl http://localhost:8000/api/jobs
```

## 🤖 AI Tools Usage

This project was developed with assistance from **GitHub Copilot** in the following ways:

### Code Generation
- **Boilerplate Creation**: FastAPI routes, database models, Flutter widgets
- **API Integration**: HTTP client setup, async/await patterns
- **Error Handling**: Try-catch blocks, validation logic

### Problem Solving
- **CORS Configuration**: Proper middleware setup for web access
- **File Upload**: Multipart form handling in both backend and frontend
- **State Management**: Flutter state updates and async operations
- **Image Processing**: Base64 encoding for API transmission

### Documentation
- **README Structure**: Comprehensive documentation template
- **Code Comments**: Inline documentation for complex logic
- **API Documentation**: OpenAPI/Swagger integration

### Workflow Enhancement
- **Iterative Development**: Quick prototyping and testing
- **Bug Fixes**: Identifying and resolving issues faster
- **Best Practices**: Following framework conventions

## 📝 Known Issues & Trade-offs

### Current Limitations
1. **File Storage**: Images stored locally (would use S3/CDN in production)
2. **Job Polling**: Client-side polling (would use WebSockets in production)
3. **Authentication**: No user authentication (would add JWT/OAuth)
4. **Rate Limiting**: No API rate limiting implemented
5. **Image Size**: Large images may take longer to process

### Production Considerations
- Add caching layer (Redis) for frequent queries
- Implement queue system (Celery) for job processing
- Use object storage (S3) for images
- Add monitoring and logging (Sentry, DataDog)
- Implement user authentication and quotas
- Add CDN for faster image delivery

## 🔐 Security Notes

- **API Key**: Stored in `.env` file (never commit to version control)
- **CORS**: Configured for localhost (update for production domains)
- **File Validation**: Image type validation in backend
- **SQL Injection**: Protected by SQLAlchemy ORM
- **XSS**: Protected by Flutter's rendering engine

## 📄 License

MIT License - Feel free to use this project for learning or commercial purposes.

## 🙏 Acknowledgments

- **fal.ai**: For providing the AI image editing API
- **FastAPI**: For the excellent Python web framework
- **Flutter**: For the powerful cross-platform UI framework
- **GitHub Copilot**: For AI-assisted development

## 📧 Contact

For questions or issues, please open an issue on GitHub.

---

**Built with ❤️ using Flutter, FastAPI, and fal.ai**
