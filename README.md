# Voltran - AI Image Editor

**🌐 Live Demo:** https://voltran-ai-image-editor.web.app/  
**🔗 Backend API:** https://voltran-ai-image-editor.onrender.com

## 🎨 Project Overview

A complete, production-ready AI image editing web application built with Flutter Web (frontend) and Python FastAPI (backend), powered by fal.ai's image editing models.

### ✨ Key Features

#### Core Features ✅
- **Image Upload**: Drag-and-drop or click-to-upload interface
- **Prompt-Based Editing**: Text input for describing desired edits
- **Image Processing**: Integration with fal.ai (Seedream V4, Nano Banana, FLUX Dev models)
- **Result Display**: View edited images in high quality
- **Download**: Save edited images locally
- **Job Management**: Track status of editing jobs
- **RESTful API**: Well-structured backend endpoints
- **Database Persistence**: SQLite for job history

#### Bonus Features ✅
- **Dark/Light Theme**: Toggle between dark and light modes
- **Multi-language Support**: Turkish and English localization
- **AI Model Selection**: Choose between Seedream V4, Nano Banana, or FLUX Dev
- **Private History**: Session-based job history (localStorage, device-specific)
- **Version History**: See all previous edits with metadata
- **Before/After Slider**: Interactive comparison tool
- **Real-time Status**: Live job status updates with polling
- **Auto-scroll**: Smooth navigation to results when selecting from history
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Error Handling**: Comprehensive error messages and recovery
- **CI/CD Pipeline**: Automated deployment with GitHub Actions

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
    │   ├── providers/
    │   │   ├── theme_provider.dart    # Theme management
    │   │   └── locale_provider.dart   # Localization
    │   ├── services/
    │   │   ├── api_service.dart       # HTTP client
    │   │   └── storage_service.dart   # localStorage for job history
    │   ├── screens/
    │   │   └── home_screen.dart  # Main UI
    │   └── widgets/
    │       ├── image_upload_widget.dart
    │       ├── job_history_widget.dart
    │       └── before_after_slider.dart
    └── pubspec.yaml        # Flutter dependencies
```

## 🌐 Live Deployment

### Production URLs
- **Frontend (Flutter Web)**: https://voltran-ai-image-editor.web.app/
- **Backend API**: https://voltran-ai-image-editor.onrender.com
- **API Documentation**: https://voltran-ai-image-editor.onrender.com/docs

### Deployment Stack
- **Frontend**: Firebase Hosting with GitHub Actions CI/CD
- **Backend**: Render.com free tier
- **Database**: SQLite (ephemeral on Render.com)
- **AI Models**: fal.ai (Seedream V4, Nano Banana, FLUX Dev)

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
# Edit .env with your fal.ai API key
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
  - `model`: String (optional, default: "seedream") - Options: "seedream", "nano_banana", "flux_dev"
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

**Models Available**:
1. **Seedream V4** (Default): `fal-ai/bytedance/seedream/v4/edit` - Fast and efficient image editing
2. **Nano Banana**: `fal-ai/nano-banana/edit` - Quick edits with smaller model
3. **FLUX Dev**: `fal-ai/flux/dev/image-to-image` - Advanced image-to-image transformation

The implementation:

1. Converts uploaded images to base64 for API transmission
2. Submits async jobs to fal.ai with selected model
3. Polls for completion status
4. Stores result URLs in database
5. Provides download functionality

**Model Selection**: Users can choose their preferred AI model from the frontend interface with localized descriptions in English and Turkish.

## 🔧 Tech Stack

### Backend
- **FastAPI**: Modern Python web framework
- **SQLAlchemy**: ORM for database operations
- **SQLite**: Lightweight database for job persistence
- **fal-client**: Official fal.ai Python SDK
- **Uvicorn**: ASGI server
- **Pillow**: Image processing utilities
- **python-dotenv**: Environment variable management

### Frontend
- **Flutter Web**: Cross-platform UI framework (v3.35.1, Dart 3.9.0)
- **Provider**: State management for theme and locale
- **http**: HTTP client for API calls
- **file_picker**: File upload functionality
- **flutter_spinkit**: Loading animations
- **universal_html**: Web-specific utilities and download handling
- **url_launcher**: Open external links (GitHub profile)

### DevOps
- **GitHub Actions**: CI/CD pipeline for automated deployment
- **Firebase Hosting**: Frontend hosting with global CDN
- **Render.com**: Backend hosting with automatic SSL
- **Git**: Version control

## 🌐 Deployment

### Backend Deployment (Render.com) ✅ Deployed

**Live URL**: https://voltran-ai-image-editor.onrender.com

The backend is automatically deployed from the `main` branch using `render.yaml` configuration.

**Configuration**:
- **Root Directory**: `Core/`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
- **Environment Variables**:
  - `FAL_API_KEY`: Your fal.ai API key
  - `ALLOWED_ORIGINS`: Production domains (configured for Firebase Hosting)

**Health Check**: https://voltran-ai-image-editor.onrender.com/health

### Frontend Deployment (Firebase Hosting) ✅ Deployed

**Live URL**: https://voltran-ai-image-editor.web.app/

The frontend is automatically deployed via GitHub Actions on every push to `main`.

**GitHub Actions Workflow**:
```yaml
# Automatically triggered on push to main
- Flutter 3.35.1 setup
- Dependencies installation (flutter pub get)
- Production build (flutter build web --release)
- Firebase Hosting deployment
```

**Manual Deployment** (if needed):
```bash
cd Web
flutter build web --release
firebase deploy --only hosting
```

## 🎯 Usage Examples

1. **Select AI Model**: Choose between Seedream V4 (fast), Nano Banana (quick), or FLUX Dev (advanced)
2. **Upload an image** by clicking or dragging
3. **Enter a prompt**: 
   - "Add a sunset background"
   - "Make it look like an oil painting"
   - "Change the color scheme to blue tones"
   - "Add dramatic lighting"
4. **Click Generate Edit** and wait for AI processing
5. **View results** with before/after comparison (auto-scrolls to result)
6. **Download** the edited image
7. **Check history** to see your previous edits (private to your device)

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
3. **Authentication**: No user authentication (session-based via localStorage currently)
4. **Rate Limiting**: No API rate limiting implemented
5. **Image Size**: Large images may take longer to process
6. **History Persistence**: Job history is device-specific (would add cloud sync with auth)

### Production Considerations
- Add caching layer (Redis) for frequent queries
- Implement queue system (Celery) for job processing
- Use object storage (S3) for images
- Add monitoring and logging (Sentry, DataDog)
- Implement user authentication and quotas
- Add CDN for faster image delivery

## 🔐 Security Notes

- **API Key**: Stored in `.env` file (never commit to version control)
- **CORS**: Configured for production Firebase Hosting domain
- **Private History**: Job history stored locally in browser (localStorage)
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
