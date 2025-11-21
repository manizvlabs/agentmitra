# Agent Mitra - Presentation Carousel Homepage Design

> **Note:** This document follows the [Separation of Concerns](../design/glossary.md#separation-of-concerns) principle, focusing on the Agent App's dynamic presentation carousel feature for insurance agents.

## 1. Overview

### 1.1 Purpose
The Presentation Carousel Homepage feature enables insurance agents to create, edit, and display dynamic promotional content directly on their app's home screen. This allows agents to:
- Create daily promotional presentations without app updates
- Customize slides with images, videos, and text
- Share personalized content with prospects and clients
- Maintain professional branding with agent-specific templates

### 1.2 Key Features
- **Dynamic Carousel Display**: Auto-playing slide carousel on home screen
- **In-App Editor**: Full-featured slide editor within the mobile app
- **Media Support**: Images and videos with custom layouts
- **Template System**: Pre-built templates for common insurance products
- **Offline Support**: Local caching for offline editing and viewing
- **Backend Sync**: Real-time synchronization with backend storage
- **Personal Branding**: Agent logo and contact CTA integration

## 2. Architecture Overview

### 2.1 System Architecture
```
┌─────────────────────────────────────────────────────────┐
│              PRESENTATION CAROUSEL ARCHITECTURE         │
├─────────────────────────────────────────────────────────┤
│  📱 Flutter Mobile App                                 │
│  ├── Home Screen Carousel Widget                       │
│  ├── Presentation Editor Module                        │
│  │   ├── Slide Editor                                 │
│  │   ├── Media Picker (Image/Video)                   │
│  │   ├── Layout Selector                              │
│  │   ├── Text Editor (Rich Text)                      │
│  │   └── Preview Mode                                 │
│  ├── Local Cache (Hive)                                │
│  └── Offline Mode Support                             │
├─────────────────────────────────────────────────────────┤
│  🐍 Python Backend                                     │
│  ├── Presentation API Endpoints                        │
│  ├── Media Storage (S3/CDN)                            │
│  ├── Slide Metadata Storage (PostgreSQL)              │
│  └── Template Management                               │
├─────────────────────────────────────────────────────────┤
│  🌐 Agent Config Portal (Optional)                    │
│  ├── Default Template Management                       │
│  └── Bulk Presentation Creation                        │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow
```
Agent Creates Slide → Local Cache → Backend API → Media Upload → CDN Storage
                                                              ↓
Home Screen ← Local Cache ← Backend Sync ← Published Presentation
```

## 3. Data Models

### 3.1 Slide Model
```json
{
  "id": "slide_001",
  "presentationId": "agent123_presentation_01",
  "order": 1,
  "type": "image",
  "mediaUrl": "https://cdn.agentmitra.com/presentations/slide1.png",
  "mediaType": "image",
  "thumbnailUrl": "https://cdn.agentmitra.com/presentations/thumb1.png",
  "title": "Secure Your Family's Future",
  "subtitle": "Get ₹1 Cr coverage at ₹20/day",
  "description": "Comprehensive term insurance for your loved ones",
  "textColor": "#FFFFFF",
  "backgroundColor": "#000000",
  "overlayOpacity": 0.5,
  "layout": "centered",
  "duration": 4,
  "ctaButton": {
    "enabled": true,
    "text": "Get Quote",
    "action": "navigate_to_quote",
    "backgroundColor": "#C62828",
    "textColor": "#FFFFFF"
  },
  "agentBranding": {
    "showLogo": true,
    "logoUrl": "https://cdn.agentmitra.com/agents/agent123/logo.png",
    "showContact": true,
    "contactText": "Talk to me"
  },
  "createdAt": 1731234567,
  "updatedAt": 1731234567
}
```

### 3.2 Presentation Model
```json
{
  "presentationId": "agent123_presentation_01",
  "agentId": "agent123",
  "name": "Daily Promotional - Term Insurance",
  "slides": [
    {
      "id": "slide_001",
      "order": 1,
      ...
    },
    {
      "id": "slide_002",
      "order": 2,
      ...
    }
  ],
  "status": "published",
  "isActive": true,
  "templateId": "term_insurance_template_01",
  "createdBy": "agent123",
  "createdAt": 1731234567,
  "lastUpdated": 1731234567,
  "publishedAt": 1731234567,
  "version": 1
}
```

### 3.3 Template Model
```json
{
  "templateId": "term_insurance_template_01",
  "name": "Term Insurance Promotional",
  "category": "term_insurance",
  "slides": [
    {
      "id": "template_slide_001",
      "type": "image",
      "layout": "centered",
      "title": "{{custom_title}}",
      "subtitle": "{{custom_subtitle}}",
      "backgroundColor": "#1a237e",
      "textColor": "#FFFFFF"
    }
  ],
  "isDefault": true,
  "isPublic": true,
  "createdBy": "system",
  "createdAt": 1731234567
}
```

## 4. Flutter Implementation

### 4.1 Carousel Widget Structure
```dart
lib/features/presentations/
├── presentation/
│   ├── widgets/
│   │   ├── presentation_carousel.dart      # Main carousel widget
│   │   ├── slide_view.dart                # Individual slide renderer
│   │   ├── slide_image_view.dart          # Image slide widget
│   │   ├── slide_video_view.dart          # Video slide widget
│   │   └── slide_text_overlay.dart        # Text overlay widget
│   ├── models/
│   │   ├── slide_model.dart               # Slide data model
│   │   ├── presentation_model.dart         # Presentation model
│   │   └── template_model.dart            # Template model
│   ├── services/
│   │   ├── presentation_service.dart      # API service
│   │   ├── presentation_cache_service.dart # Local cache
│   │   └── media_upload_service.dart      # Media upload
│   └── repositories/
│       └── presentation_repository.dart   # Data access layer
```

### 4.2 Carousel Widget Implementation
```dart
class PresentationCarousel extends StatefulWidget {
  final String agentId;
  final double height;
  final bool autoPlay;
  
  const PresentationCarousel({
    Key? key,
    required this.agentId,
    this.height = 220,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<PresentationCarousel> createState() => _PresentationCarouselState();
}

class _PresentationCarouselState extends State<PresentationCarousel> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;
  List<SlideModel> _slides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresentation();
  }

  Future<void> _loadPresentation() async {
    try {
      final presentation = await PresentationRepository()
          .getActivePresentation(widget.agentId);
      setState(() {
        _slides = presentation.slides;
        _isLoading = false;
      });
    } catch (e) {
      // Load from cache if offline
      final cached = await PresentationCacheService().getCachedPresentation();
      setState(() {
        _slides = cached?.slides ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_slides.isEmpty) {
      return _buildEmptyState();
    }

    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: _slides.length,
      options: CarouselOptions(
        height: widget.height,
        viewportFraction: 1.0,
        autoPlay: widget.autoPlay,
        autoPlayInterval: Duration(
          seconds: _slides[_currentIndex].duration ?? 4
        ),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      itemBuilder: (context, index, realIndex) {
        return SlideView(slide: _slides[index]);
      },
    );
  }
}
```

### 4.3 Slide View Renderer
```dart
class SlideView extends StatelessWidget {
  final SlideModel slide;

  const SlideView({Key? key, required this.slide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Media Background
        _buildMediaBackground(),
        
        // Overlay
        Container(
          color: HexColor(slide.backgroundColor)
              .withOpacity(slide.overlayOpacity ?? 0.5),
        ),
        
        // Content
        _buildContent(),
        
        // Agent Branding
        if (slide.agentBranding?.showLogo == true)
          _buildAgentBranding(),
      ],
    );
  }

  Widget _buildMediaBackground() {
    switch (slide.type) {
      case 'image':
        return Image.network(
          slide.mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.grey[300]);
          },
        );
      case 'video':
        return VideoPlayerWidget(url: slide.mediaUrl);
      default:
        return Container(color: HexColor(slide.backgroundColor));
    }
  }

  Widget _buildContent() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: _getAlignment(slide.layout),
        children: [
          if (slide.title != null)
            Text(
              slide.title!,
              style: TextStyle(
                color: HexColor(slide.textColor),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (slide.subtitle != null) ...[
            SizedBox(height: 8),
            Text(
              slide.subtitle!,
              style: TextStyle(
                color: HexColor(slide.textColor).withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
          if (slide.ctaButton?.enabled == true) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleCTAAction(slide.ctaButton!.action),
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor(slide.ctaButton!.backgroundColor),
                foregroundColor: HexColor(slide.ctaButton!.textColor),
              ),
              child: Text(slide.ctaButton!.text),
            ),
          ],
        ],
      ),
    );
  }
}
```

## 5. Presentation Editor

### 5.1 Editor Screen Structure
```
lib/features/presentations/
├── editor/
│   ├── pages/
│   │   ├── presentation_editor_page.dart    # Main editor screen
│   │   ├── slide_editor_page.dart           # Individual slide editor
│   │   └── template_selector_page.dart      # Template selection
│   ├── widgets/
│   │   ├── slide_list_view.dart             # Reorderable slide list
│   │   ├── media_picker_widget.dart         # Image/video picker
│   │   ├── text_editor_widget.dart          # Rich text editor
│   │   ├── layout_selector_widget.dart      # Layout options
│   │   ├── color_picker_widget.dart         # Color selection
│   │   └── preview_widget.dart              # Live preview
│   └── viewmodels/
│       ├── presentation_editor_viewmodel.dart
│       └── slide_editor_viewmodel.dart
```

### 5.2 Editor Features
- **Add Slide**: Create new slide with media picker
- **Edit Slide**: Modify existing slide content
- **Reorder Slides**: Drag and drop to reorder
- **Delete Slide**: Remove unwanted slides
- **Layout Selection**: Choose from centered, left-aligned, grid layouts
- **Color Customization**: Pick text and background colors
- **Rich Text Editing**: Format title and subtitle text
- **Media Upload**: Upload images/videos from gallery or camera
- **Preview Mode**: Real-time preview of carousel
- **Save Draft**: Save work in progress
- **Publish**: Make presentation live on home screen

### 5.3 Editor UI Wireframe
```
┌─────────────────────────────────────────────────────────┐
│  ✏️ PRESENTATION EDITOR                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back │ ✏️ Edit Presentation │ 💾 Save Draft  │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📋 Slide List (Reorderable)                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ☰ Slide 1: "Secure Your Family's Future"        │   │
│  │    🖼️ Image • 📝 Centered Layout • ⏱️ 4s        │   │
│  │    ✏️ Edit │ 🗑️ Delete │ ⬆️ ⬇️ Reorder          │   │
│  ├─────────────────────────────────────────────────┤   │
│  │ ☰ Slide 2: "Health Insurance Benefits"         │   │
│  │    🎥 Video • 📝 Left Aligned • ⏱️ 5s           │   │
│  │    ✏️ Edit │ 🗑️ Delete │ ⬆️ ⬇️ Reorder          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ➕ Add New Slide                                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ➕ Add Slide │ 📋 Use Template │ 📤 Import      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎨 Editor Panel (When slide selected)                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📝 Title: [Rich Text Editor]                    │   │
│  │ 📝 Subtitle: [Rich Text Editor]                 │   │
│  │ 🖼️ Media: [Image/Video Picker]                  │   │
│  │ 🎨 Layout: [Centered] [Left] [Grid]            │   │
│  │ 🎨 Text Color: [Color Picker]                   │   │
│  │ 🎨 Background: [Color Picker]                    │   │
│  │ ⏱️ Duration: [4] seconds                         │   │
│  │ 🔘 CTA Button: [Enable] [Text] [Action]         │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  👁️ Preview Mode                                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👁️ Preview │ ▶️ Play │ ⏸️ Pause │ 🔄 Refresh   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💾 Save Draft │ 🚀 Publish │ ❌ Cancel          │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 6. Backend API Design

### 6.1 API Endpoints

#### Get Active Presentation
```
GET /api/v1/presentations/{agentId}/active

Response:
{
  "presentationId": "agent123_presentation_01",
  "slides": [...],
  "status": "published",
  "lastUpdated": 1731234567
}
```

#### Get All Presentations
```
GET /api/v1/presentations/{agentId}

Query Parameters:
- status: draft|published|archived
- limit: number
- offset: number

Response:
{
  "presentations": [...],
  "total": 10,
  "limit": 20,
  "offset": 0
}
```

#### Create/Update Presentation
```
POST /api/v1/presentations/{agentId}
PUT /api/v1/presentations/{agentId}/{presentationId}

Request Body:
{
  "name": "Daily Promotional - Term Insurance",
  "slides": [...],
  "status": "draft|published",
  "templateId": "term_insurance_template_01"
}

Response:
{
  "presentationId": "agent123_presentation_01",
  "status": "published",
  "createdAt": 1731234567
}
```

#### Upload Media
```
POST /api/v1/presentations/media/upload

Request:
- multipart/form-data
- file: image/video file
- type: image|video

Response:
{
  "mediaUrl": "https://cdn.agentmitra.com/presentations/media123.png",
  "thumbnailUrl": "https://cdn.agentmitra.com/presentations/thumb123.png",
  "mediaId": "media123"
}
```

#### Get Templates
```
GET /api/v1/presentations/templates

Query Parameters:
- category: term_insurance|health_insurance|child_plans|retirement
- isPublic: true|false

Response:
{
  "templates": [...]
}
```

### 6.2 Database Schema

#### presentations Table
```sql
CREATE TABLE presentations (
    presentation_id VARCHAR(255) PRIMARY KEY,
    agent_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL, -- draft, published, archived
    template_id VARCHAR(255),
    is_active BOOLEAN DEFAULT false,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX idx_presentations_agent_status ON presentations(agent_id, status);
CREATE INDEX idx_presentations_active ON presentations(agent_id, is_active) WHERE is_active = true;
```

#### slides Table
```sql
CREATE TABLE slides (
    slide_id VARCHAR(255) PRIMARY KEY,
    presentation_id VARCHAR(255) NOT NULL,
    slide_order INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL, -- image, video, text
    media_url TEXT,
    media_type VARCHAR(50),
    thumbnail_url TEXT,
    title TEXT,
    subtitle TEXT,
    description TEXT,
    text_color VARCHAR(7),
    background_color VARCHAR(7),
    overlay_opacity DECIMAL(3,2) DEFAULT 0.5,
    layout VARCHAR(50) DEFAULT 'centered', -- centered, left, grid
    duration INTEGER DEFAULT 4,
    cta_button JSONB,
    agent_branding JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (presentation_id) REFERENCES presentations(presentation_id) ON DELETE CASCADE
);

CREATE INDEX idx_slides_presentation_order ON slides(presentation_id, slide_order);
```

#### presentation_templates Table
```sql
CREATE TABLE presentation_templates (
    template_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    slides JSONB NOT NULL,
    is_default BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_templates_category ON presentation_templates(category, is_public);
```

## 7. Advanced Features

### 7.1 Template System
- **Pre-built Templates**: Term Insurance, Health Insurance, Child Plans, Retirement Plans
- **Custom Templates**: Agents can save their own templates
- **Template Marketplace**: Share templates with other agents
- **AI-Generated Content**: Auto-generate headlines and benefit points

### 7.2 Offline Support
- **Local Caching**: Store presentations in Hive for offline access
- **Offline Editing**: Edit slides without internet connection
- **Sync on Reconnect**: Automatic sync when connection restored
- **Conflict Resolution**: Handle conflicts when multiple devices edit

### 7.3 Personal Branding
- **Agent Logo**: Auto-add agent logo to slides
- **Contact CTA**: "Talk to me" button with agent contact
- **Brand Colors**: Use agent's brand colors in templates
- **Profile Integration**: Link to agent profile from slides

### 7.4 Analytics & Tracking
- **View Tracking**: Track slide views and engagement
- **CTA Clicks**: Monitor CTA button clicks
- **Share Analytics**: Track when presentations are shared
- **Performance Metrics**: Identify best-performing slides

## 8. UI/UX Guidelines

### 8.1 Carousel Display
- **Height**: 220px on mobile, scalable for tablets
- **Auto-play**: Enabled by default, 4-5 seconds per slide
- **Indicators**: Dot indicators showing current slide
- **Swipe Navigation**: Users can swipe to navigate manually
- **Pause on Interaction**: Pause auto-play when user interacts

### 8.2 Editor Experience
- **Intuitive Interface**: Simple, touch-friendly controls
- **Live Preview**: Real-time preview of changes
- **Undo/Redo**: Support for undo/redo actions
- **Quick Actions**: Quick access to common actions
- **Help Tooltips**: Contextual help for complex features

### 8.3 Performance Optimization
- **Lazy Loading**: Load slides as needed
- **Image Optimization**: Compress images before upload
- **Video Streaming**: Stream videos instead of downloading
- **Cache Management**: Smart cache invalidation
- **Background Sync**: Sync in background without blocking UI

## 9. Security & Privacy

### 9.1 Access Control
- **Agent Isolation**: Agents can only access their own presentations
- **Role-Based Permissions**: Different permissions for agents vs admins
- **Media Access Control**: Secure media URLs with expiration
- **API Rate Limiting**: Prevent abuse of API endpoints

### 9.2 Data Protection
- **Media Encryption**: Encrypt media files at rest
- **Secure Upload**: Use signed URLs for media upload
- **Data Validation**: Validate all input data
- **Audit Logging**: Log all presentation changes

## 10. Testing Strategy

### 10.1 Unit Tests
- Slide model validation
- Presentation service logic
- Cache service operations
- Media upload handling

### 10.2 Widget Tests
- Carousel widget rendering
- Slide view display
- Editor widget interactions
- Preview mode functionality

### 10.3 Integration Tests
- End-to-end presentation creation flow
- Media upload and sync
- Offline mode operations
- Template application

### 10.4 Performance Tests
- Carousel rendering performance
- Large presentation handling
- Media loading optimization
- Cache efficiency

## 11. Feature Flags

### 11.1 Feature Flag Configuration
```dart
// Feature flags for presentation carousel
- presentation_carousel_enabled: true
- presentation_editor_enabled: true
- presentation_templates_enabled: true
- presentation_offline_mode_enabled: true
- presentation_ai_content_enabled: false
- presentation_analytics_enabled: true
- presentation_branding_enabled: true
```

## 12. Implementation Timeline

### Phase 1: Core Carousel (Week 1-2)
- Carousel widget implementation
- Slide view renderer
- Basic API integration
- Local caching

### Phase 2: Editor Module (Week 3-4)
- Editor UI implementation
- Media picker integration
- Text editor with rich formatting
- Layout selector

### Phase 3: Advanced Features (Week 5-6)
- Template system
- Offline mode support
- Personal branding
- Analytics integration

### Phase 4: Optimization (Week 7-8)
- Performance optimization
- UI/UX refinements
- Testing and bug fixes
- Documentation

---

**Document Status:** Complete
**Last Updated:** 2024-01-XX
**Related Documents:** 
- [Wireframes](../content/wireframes.md)
- [Pages Design](./pages-design.md)
- [Project Structure](./project-structure.md)
- [Project Plan](../implementation/project-plan.md)

