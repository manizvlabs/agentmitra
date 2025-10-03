# Agent Mitra - Tutorial Video System Design

## 1. Video System Philosophy & Architecture

### 1.1 Core Design Principles
- **Agent-Driven Content**: Agents upload and manage their own educational videos
- **Smart Recommendations**: AI-powered video suggestions based on user queries and context
- **YouTube Integration**: Professional video hosting with Agent Mitra's branded channel
- **Multi-language Support**: Videos in English, Hindi, and Telugu with auto-translation
- **Progressive Learning**: Personalized learning paths based on user progress and needs
- **Feature Flag Control**: Video features controlled by configurable flags

### 1.2 Video System Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Video System Architecture                   │
├─────────────────────────────────────────────────────────┤
│  🎥 Agent Video Management                             │
│  ├── Video Upload & Processing                       │
│  ├── Thumbnail Generation & Optimization             │
│  ├── Video Categorization & Tagging                  │
│  └── Agent Content Analytics                         │
├─────────────────────────────────────────────────────────┤
│  🤖 Smart Recommendation Engine                        │
│  ├── Intent-Based Video Matching                     │
│  ├── User Learning History Analysis                  │
│  ├── Policy Context Relevance                        │
│  └── Personalized Learning Paths                     │
├─────────────────────────────────────────────────────────┤
│  📺 YouTube Integration                                │
│  ├── Professional Video Hosting                      │
│  ├── Branded Channel Management                      │
│  ├── Video Analytics & Insights                      │
│  └── Multi-language Caption Support                  │
├─────────────────────────────────────────────────────────┤
│  📊 Video Performance Analytics                        │
│  ├── View Tracking & Engagement Metrics              │
│  ├── Learning Outcome Assessment                     │
│  ├── Agent Performance Insights                      │
│  └── Content Effectiveness Analysis                  │
├─────────────────────────────────────────────────────────┤
│  🔒 Security & Compliance                              │
│  ├── Content Moderation & Review                     │
│  ├── Copyright Protection                            │
│  ├── IRDAI Compliance for Educational Content        │
│  └── DPDP Compliance for User Data                    │
└─────────────────────────────────────────────────────────┘
```

## 2. Agent Video Upload & Management System

### 2.1 Agent Video Upload Interface

#### Video Upload Flow
```
┌─────────────────────────────────────────────────────────┐
│  🎥 AGENT VIDEO UPLOAD - AGENT MITRA                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👋 Welcome, Rajesh! Upload educational content   │   │
│  │ 📚 Help your customers learn about insurance     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📹 Video Upload Interface                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📁 Select Video File (Drag & Drop)              │   │
│  │ 🎬 Supported: MP4, MOV, AVI (Max 100MB)         │   │
│  │ ⏱️ Duration: 2-15 minutes recommended           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📝 Video Metadata Form                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📝 Video Title: [Required]                      │   │
│  │   "How to Pay Premium Online"                   │   │
│  │ 📂 Category: [Policy Management]                │   │
│  │ 🏷️ Tags: payment, online, tutorial, premium     │   │
│  │ 📝 Description: [Rich Text Editor]              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Targeting & Visibility                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👥 Target Audience: [All Customers]             │   │
│  │ 📋 Policy Types: [LIC Jeevan Anand, Money Back] │   │
│  │ 🌐 Languages: [English, Hindi]                  │   │
│  │ 👁️ Visibility: [Public to All Customers]        │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎬 Video Processing Status                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⏳ Processing: 45% Complete                      │   │
│  │ 📋 Steps: Upload → Thumbnail → Transcription    │   │
│  │ 🎯 Estimated Time: 2-3 minutes                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Upload Actions                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ ⬆️ Upload   │ │ 👁️ Preview  │ │ 💾 Save      │      │
│  │   Video      │ │             │ │   Draft      │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- video_upload_enabled (Agent video upload capability)
- content_management_enabled (Content management features)
- agent_content_enabled (Agent-specific content creation)
- video_processing_enabled (Video processing pipeline)
```

### 2.2 Video Categories & Taxonomy

#### Content Category Structure
```
📚 VIDEO CONTENT CATEGORIES

🎓 Insurance Fundamentals (Core Concepts)
├── What is Life Insurance? (15 videos)
├── Types of Insurance Plans (12 videos)
├── Understanding Premium Payments (18 videos)
├── Policy Maturity & Claims Process (14 videos)
└── Tax Benefits of Insurance (8 videos)

📋 Policy Management (Operational Guides)
├── How to Check Policy Status Online (22 videos)
├── Premium Payment Methods & Procedures (28 videos)
├── Policy Document Download & Management (16 videos)
├── Nominee Update Process (10 videos)
└── Claim Filing Step-by-Step (24 videos)

💰 Financial Planning (Investment Education)
├── Investment vs Insurance (12 videos)
├── Retirement Planning Strategies (16 videos)
├── Tax Saving Through Insurance (14 videos)
├── Risk Assessment & Management (10 videos)
└── Portfolio Diversification (8 videos)

🛠️ Technical Support (App & Service Help)
├── Agent Mitra App Navigation (20 videos)
├── Account Security & Privacy (12 videos)
├── Payment Troubleshooting (18 videos)
├── Document Access & Sharing (14 videos)
└── Feature Requests & Feedback (6 videos)

🆕 Product-Specific Content (Agent-Created)
├── LIC Jeevan Anand Deep Dive (Rajesh Kumar - 8 videos)
├── LIC Money Back Plan Benefits (Priya Patel - 12 videos)
├── ULIP Investment Strategies (Amit Sharma - 15 videos)
└── Term Insurance Explained (Sneha Reddy - 10 videos)
```

#### Video Tagging System
```json
{
  "video_metadata": {
    "video_id": "vid_123456",
    "title": "How to Pay Premium Online",
    "duration": "5:32",
    "category": "policy_management",
    "subcategory": "premium_payments",
    "tags": [
      "premium_payment",
      "online_payment",
      "upi",
      "credit_card",
      "net_banking",
      "tutorial",
      "step_by_step"
    ],
    "difficulty_level": "beginner",
    "target_audience": ["new_customers", "payment_issues"],
    "policy_types": ["LIC_jeevan_anand", "LIC_money_back"],
    "languages": ["en", "hi"],
    "agent_id": "agent_789",
    "agent_name": "Rajesh Kumar",
    "upload_date": "2024-02-15",
    "last_updated": "2024-02-15",
    "view_count": 2543,
    "avg_watch_time": "4:12",
    "completion_rate": 78,
    "rating": 4.8,
    "thumbnail_url": "https://youtube.com/thumbnail/vid_123456",
    "video_url": "https://youtube.com/watch?v=abc123def456"
  }
}
```

### 2.3 Video Processing & Optimization

#### Automated Video Processing Pipeline
```
🎬 VIDEO PROCESSING WORKFLOW

📤 Upload Stage
├── File Validation (Format, Size, Duration)
├── Virus Scanning & Security Check
├── Metadata Extraction (Duration, Resolution)
└── Duplicate Detection & Prevention

🎨 Thumbnail Generation
├── Auto-Generated Thumbnails (Multiple Options)
├── Custom Thumbnail Upload (Agent Option)
├── Thumbnail Optimization (WebP, Responsive)
└── Accessibility Alt Text Generation

📝 Content Analysis
├── Automatic Transcription (Multi-language)
├── Keyword Extraction & Tagging
├── Chapter Detection & Timestamps
└── Sentiment & Complexity Analysis

🎯 YouTube Integration
├── Professional Channel Upload
├── SEO-Optimized Titles & Descriptions
├── Multi-language Captions
└── Analytics Integration
```

#### Video Quality Standards
```
📋 VIDEO QUALITY GUIDELINES

🎬 Technical Specifications:
├── Resolution: 1080p HD minimum (1920x1080)
├── Format: MP4 (H.264 codec recommended)
├── File Size: 50-100MB for 5-10 minute videos
├── Audio: Clear, noise-free (48kHz, 128kbps)
└── Duration: 2-15 minutes (Optimal engagement)

📝 Content Standards:
├── Clear, professional presentation
├── Step-by-step instructions with visuals
├── Agent branding and contact information
├── Call-to-action for further assistance
└── Multi-language subtitle support

♿ Accessibility Requirements:
├── Captions in multiple languages
├── Audio descriptions for visual content
├── High contrast for text overlays
└── Keyboard navigation support
```

## 3. Smart Video Recommendation Engine

### 3.1 Recommendation Algorithm Design

#### Multi-Factor Recommendation System
```
🎯 VIDEO RECOMMENDATION ALGORITHM

📊 Weighted Scoring Factors:
├── Query Intent Match (35% weight)
│   • "premium payment" → 95% match for "Premium Payment Tutorial"
│   • "policy details" → 85% match for "Understanding Your Policy"
│   • "claim process" → 90% match for "Claim Filing Guide"
├── User Learning History (25% weight)
│   • Previously watched videos (+15% boost)
│   • Watch completion rates (+10% boost)
│   • User ratings and feedback (+5% boost)
├── Policy Context Relevance (20% weight)
│   • Current policy type match (+10% boost)
│   • Policy stage relevance (+5% boost)
│   • Agent relationship (+5% boost)
├── Agent Expertise & Performance (15% weight)
│   • Agent video quality scores (+8% boost)
│   • Agent customer satisfaction (+5% boost)
│   • Agent specialization areas (+2% boost)
└── Content Freshness & Popularity (5% weight)
    • Recent uploads (+3% boost)
    • High engagement rates (+2% boost)
```

#### Personalized Learning Paths
```dart
// Personalized learning path generation
class LearningPathService {
  Future<List<VideoRecommendation>> generateLearningPath(User user) async {
    // 1. Analyze user profile and policy portfolio
    final userProfile = await UserProfileService.getProfile(user.id);
    final policyContext = await PolicyService.getUserPolicies(user.id);

    // 2. Identify knowledge gaps and learning needs
    final knowledgeGaps = await KnowledgeGapAnalysis.analyze(
      userProfile,
      policyContext
    );

    // 3. Match with available content
    final relevantVideos = await VideoMatchingService.findVideosForGaps(
      knowledgeGaps,
      userProfile.preferredLanguage
    );

    // 4. Create progressive learning sequence
    final learningPath = await LearningPathBuilder.createSequence(
      relevantVideos,
      userProfile.learningStyle,
      policyContext.urgencyLevel
    );

    return learningPath;
  }
}
```

### 3.2 Video Discovery & Search

#### Smart Search Interface
```
🔍 ADVANCED VIDEO SEARCH - AGENT MITRA

┌─────────────────────────────────────────────────────────┐
│ 🔍 Smart Video Search                                 │
│ ┌─────────────────────────────────────────────────┐   │
│ │ Search videos, tutorials, guides...              │   │
│ │ 💡 Suggestions: "premium payment", "claim process" │   │
│ └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│ 🔽 Advanced Filters                                   │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│ │ 📂 Category │ │ ⏱️ Duration │ │ 🌐 Language  │      │
│ │   Filter    │ │   Range     │ │   Filter     │      │
│ └─────────────┘ └─────────────┘ └─────────────┘      │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│ │ 👤 Agent    │ │ ⭐ Rating   │ │ 📅 Upload    │      │
│ │   Filter    │ │   Filter    │ │   Date       │      │
│ └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│ 🎯 Search Results (Smart Sorted)                      │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 🎥 "How to Pay Premium Online" (Best Match)     │   │
│ │ 👤 Rajesh Kumar • ⏱️ 5:32 • ⭐ 4.8 • 👁️ 2,543  │   │
│ │ 📝 "Step-by-step guide for online payments"     │   │
│ └─────────────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 🎥 "Premium Payment Methods Explained"          │   │
│ │ 👤 Priya Patel • ⏱️ 8:15 • ⭐ 4.7 • 👁️ 1,890   │   │
│ │ 📝 "Different ways to pay your insurance premium"│   │
│ └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│ 📈 Search Analytics                                   │
│ • Search Query: "premium payment"                   │
│ • Results Found: 47 videos                          │
│ • Most Relevant: Premium Payment Tutorial (95%)     │
└─────────────────────────────────────────────────────────┘
```

#### Contextual Video Suggestions
```
💡 CONTEXTUAL VIDEO RECOMMENDATIONS

🎯 Based on Current Activity:
├── Dashboard View → "Getting Started with Agent Mitra"
├── Policy Details → "Understanding Your Policy Benefits"
├── Payment Screen → "Premium Payment Tutorial"
├── Chat Conversation → "Related Topic Explanations"
└── Learning Center → "Next Steps in Your Learning Journey"

👤 Based on User Profile:
├── New Customer → "Insurance Basics for Beginners"
├── Premium Issues → "Troubleshooting Payment Problems"
├── Claim Questions → "Claim Process Step-by-Step"
└── Advanced User → "Advanced Investment Strategies"

📋 Based on Policy Portfolio:
├── Endowment Policy → "Maximizing Endowment Benefits"
├── ULIP Investment → "ULIP Investment Management"
├── Term Insurance → "Term Insurance Explained"
└── Money Back Plan → "Money Back Plan Features"
```

## 4. YouTube Integration & Content Management

### 4.1 YouTube Channel Management

#### Agent Mitra YouTube Channel Structure
```
📺 AGENT MITRA YOUTUBE CHANNEL

🏠 Channel Branding:
├── Channel Name: "Agent Mitra - Insurance Education"
├── Channel Description: "Educational content for insurance policyholders"
├── Channel Icon: Agent Mitra Logo
├── Channel Banner: "Learn • Manage • Grow"
└── Featured Channels: Partner insurance companies

📂 Organized Playlists:
├── 🎓 Insurance Fundamentals (47 videos)
├── 📋 Policy Management (89 videos)
├── 💰 Financial Planning (34 videos)
├── 🛠️ Technical Support (28 videos)
├── 👤 Agent Spotlight (Agent-specific content)
└── 🌟 Customer Success Stories (Testimonials)

📊 Channel Analytics:
├── Total Subscribers: 15,240
├── Total Views: 2.4M
├── Average Watch Time: 6:23 minutes
├── Top Performing Video: "Premium Payment Guide" (245K views)
└── Engagement Rate: 8.7% (Above industry average)
```

### 4.2 Video Analytics & Performance Tracking

#### Comprehensive Video Analytics
```
📊 VIDEO PERFORMANCE DASHBOARD

🎯 Key Performance Indicators:
├── Total Videos: 247 across all categories
├── Total Views: 2,450,000 (All-time)
├── Average Watch Time: 6:23 minutes
├── Completion Rate: 78% (Above industry standard)
├── Subscriber Growth: +15% month-over-month

📈 Top Performing Content:
┌─────────────────────────────────────────────────┐
│ 🥇 Premium Payment Tutorial (Rajesh Kumar)       │
│   • Views: 245,000 • Watch Time: 8:12 min        │
│   • Completion: 89% • Engagement: 9.2%           │
│   • Conversion: 34% payment rate increase        │
├─────────────────────────────────────────────────┤
│ 🥈 Understanding Your Policy (Priya Patel)       │
│   • Views: 189,000 • Watch Time: 7:45 min        │
│   • Completion: 82% • Engagement: 8.7%           │
│   • Conversion: 28% support query reduction      │
├─────────────────────────────────────────────────┤
│ 🥉 Claim Process Guide (Amit Sharma)             │
│   • Views: 156,000 • Watch Time: 9:03 min        │
│   • Completion: 91% • Engagement: 9.8%           │
│   • Conversion: 45% claim filing success rate    │
└─────────────────────────────────────────────────┘

💡 Agent Performance Insights:
├── Rajesh Kumar: 92% customer satisfaction, 15 videos
├── Priya Patel: 89% engagement rate, 23 videos
├── Amit Sharma: 94% completion rate, 18 videos
└── Sneha Reddy: 87% watch time, 12 videos
```

#### Agent Content Analytics
```
📊 AGENT CONTENT PERFORMANCE - RAJESH KUMAR

🎥 Video Portfolio Overview:
├── Total Videos: 15 • Total Views: 445,000
├── Average Performance: 4.8/5.0 rating
├── Total Watch Time: 28,500 hours
├── Subscriber Impact: +2,340 new subscribers

📈 Individual Video Performance:
┌─────────────────────────────────────────────────┐
│ 🎬 Premium Payment Guide                          │
│ • Views: 245K • Rating: 4.9 • Watch Time: 8:12   │
│ • Completion: 89% • Engagement: 9.2%             │
│ • Business Impact: 34% payment increase          │
├─────────────────────────────────────────────────┤
│ 🎬 Policy Status Check                            │
│ • Views: 89K • Rating: 4.7 • Watch Time: 4:23    │
│ • Completion: 76% • Engagement: 7.8%             │
│ • Business Impact: 22% support reduction         │
├─────────────────────────────────────────────────┤
│ 🎬 Claim Filing Process                           │
│ • Views: 67K • Rating: 4.8 • Watch Time: 9:03    │
│ • Completion: 91% • Engagement: 9.8%             │
│ • Business Impact: 45% claim success rate        │
└─────────────────────────────────────────────────┘

💼 Business Impact Metrics:
├── Customer Engagement: +28% increase
├── Support Queries: -32% reduction
├── Policy Renewals: +15% improvement
├── New Policy Sales: +23% increase
└── Customer Satisfaction: 4.6/5.0 average
```

## 5. Video Tutorial Integration with Chatbot

### 5.1 Chatbot-Video Recommendation Integration

#### Intelligent Video Suggestions in Chat
```
🤖 SMART ASSISTANT - VIDEO INTEGRATION

💬 Customer Query: "How do I pay my premium online?"

🤖 Chatbot Response:
"Here's how to pay your premium online. I recommend watching this helpful video tutorial from your agent Rajesh Kumar:"

🎥 RECOMMENDED VIDEO CARD
┌─────────────────────────────────────────────────┐
│ 🎬 "How to Pay Premium Online"                   │
│ 👤 By: Rajesh Kumar (Your Agent)                 │
│ ⏱️ 5:32 min • 👁️ 2,543 views • ⭐ 4.8 rating    │
│ 📝 "Step-by-step guide for online payments"     │
├─────────────────────────────────────────────────┤
│ ▶️ WATCH VIDEO (Primary CTA)                      │
│ 📚 VIEW ALL TUTORIALS (Secondary)                 │
└─────────────────────────────────────────────────┘

💡 Why This Video?
• Matches your query: "premium payment" (95% relevance)
• From your agent: Rajesh Kumar (Trust & familiarity)
• High engagement: 89% completion rate
• Recent upload: 2 weeks ago (Current & relevant)
```

#### Video Learning Progress Tracking
```
📊 VIDEO LEARNING PROGRESS - AMIT SHARMA

🎯 Current Learning Path:
├── ✅ Insurance Basics (Completed: 5/5 videos)
├── 🔄 Policy Management (In Progress: 3/8 videos)
│   ├── ✅ Premium Payment Tutorial (Watched: 5:32/5:32)
│   ├── 🔄 Policy Status Check (Watched: 2:15/4:23)
│   ├── ⏳ Claim Process Guide (Not started)
│   └── 📋 Document Management (Not started)
└── ⏳ Financial Planning (Not started: 0/6 videos)

📈 Learning Analytics:
├── Total Videos Watched: 15
├── Total Watch Time: 8.5 hours
├── Average Completion Rate: 78%
├── Learning Streak: 7 days
├── Most Engaging Category: Policy Management (4.8/5.0)

💡 Personalized Recommendations:
├── Next Video: "Policy Status Check" (Based on partial watch)
├── Suggested Path: Complete Policy Management series
├── Agent Content: Rajesh Kumar's "Advanced Payment Methods"
└── Trending: "Tax Benefits of Insurance" (Seasonal relevance)
```

### 5.2 Video Tutorial Categories for Chatbot

#### Query-to-Video Mapping
```json
{
  "intent_video_mapping": {
    "premium_payment": [
      {
        "video_id": "vid_premium_001",
        "title": "How to Pay Premium Online",
        "relevance_score": 95,
        "agent_id": "agent_789",
        "language": "en",
        "difficulty": "beginner"
      },
      {
        "video_id": "vid_premium_002",
        "title": "Premium Payment Methods Explained",
        "relevance_score": 87,
        "agent_id": "agent_456",
        "language": "hi",
        "difficulty": "intermediate"
      }
    ],
    "policy_inquiry": [
      {
        "video_id": "vid_policy_001",
        "title": "Understanding Your Policy Benefits",
        "relevance_score": 92,
        "agent_id": "agent_789",
        "language": "en",
        "difficulty": "beginner"
      }
    ],
    "claim_process": [
      {
        "video_id": "vid_claim_001",
        "title": "Claim Filing Process Step-by-Step",
        "relevance_score": 94,
        "agent_id": "agent_123",
        "language": "en",
        "difficulty": "intermediate"
      }
    ]
  }
}
```

## 6. Multi-Language Video Support

### 6.1 Multi-Language Video Strategy

#### Language-Specific Content Creation
```
🌐 MULTI-LANGUAGE VIDEO STRATEGY

📝 Content Localization Approach:
├── English Content (Primary)
│   • Professional presentation
│   • Standard insurance terminology
│   • Clear pronunciation and pacing
│   └── Comprehensive coverage of topics
├── Hindi Content (Regional)
│   • Culturally relevant examples
│   • Local market context
│   • Conversational tone
│   └── Community-focused approach
└── Telugu Content (Regional)
    • Local language expertise
    • Regional market insights
    • Community engagement focus
    └── Personalized service emphasis

🎯 Translation & Localization:
├── Automatic Subtitles (AI-powered)
├── Manual Review & Cultural Adaptation
├── Voice-over Options (Professional narrators)
└── Community Translation Contributions
```

#### Video Language Analytics
```
📊 MULTI-LANGUAGE VIDEO PERFORMANCE

🌐 Language Performance Comparison:
┌─────────────────────────────────────────────────┐
│ 🌐 English Videos                                   │
│ • Total Videos: 150 • Views: 1,450,000            │
│ • Avg Watch Time: 6:45 min • Completion: 82%      │
│ • Engagement Rate: 8.9% • Rating: 4.7/5.0        │
├─────────────────────────────────────────────────┤
│ हिन्दी Hindi Videos                                 │
│ • Total Videos: 67 • Views: 780,000               │
│ • Avg Watch Time: 7:12 min • Completion: 85%      │
│ • Engagement Rate: 9.2% • Rating: 4.8/5.0        │
├─────────────────────────────────────────────────┤
│ తెలుగు Telugu Videos                               │
│ • Total Videos: 30 • Views: 220,000               │
│ • Avg Watch Time: 8:03 min • Completion: 89%      │
│ • Engagement Rate: 9.8% • Rating: 4.9/5.0        │
└─────────────────────────────────────────────────┘

💡 Language Insights:
• Telugu content shows highest engagement (9.8% rate)
• Hindi content has best completion rates (85%)
• English content reaches widest audience (1.45M views)
• Regional content drives 40% more conversions
```

## 7. Environment Variables & Feature Flags

### 7.1 Video System Configuration

#### Video Upload & Processing
```bash
# Video Upload Configuration
VIDEO_MAX_FILE_SIZE=104857600  # 100MB in bytes
VIDEO_ALLOWED_FORMATS=mp4,mov,avi,webm
VIDEO_MAX_DURATION_SECONDS=900  # 15 minutes
VIDEO_MIN_DURATION_SECONDS=120  # 2 minutes

# Video Processing
VIDEO_PROCESSING_QUEUE=redis_queue
VIDEO_THUMBNAIL_GENERATION=true
VIDEO_TRANSCRIPTION_AUTO=true
VIDEO_LANGUAGE_DETECTION=true

# Content Moderation
VIDEO_CONTENT_MODERATION_ENABLED=true
VIDEO_PROFANITY_FILTER=true
VIDEO_COPYRIGHT_CHECK=true
VIDEO_QUALITY_MINIMUM=720p

# Agent Video Management
AGENT_VIDEO_UPLOAD_LIMIT=50  # Videos per agent per month
AGENT_VIDEO_EDITING=true
AGENT_VIDEO_ANALYTICS=true
AGENT_VIDEO_MONETIZATION=false  # Future feature
```

#### YouTube Integration Configuration
```bash
# YouTube API Configuration
YOUTUBE_API_KEY=your_youtube_api_key
YOUTUBE_CHANNEL_ID=UC_your_channel_id
YOUTUBE_CLIENT_ID=your_oauth_client_id
YOUTUBE_CLIENT_SECRET=your_oauth_client_secret

# YouTube Upload Settings
YOUTUBE_DEFAULT_PRIVACY=unlisted
YOUTUBE_AUTO_PUBLISH=true
YOUTUBE_CATEGORY_ID=27  # Education category
YOUTUBE_TAGS_AUTO_GENERATE=true

# YouTube Analytics
YOUTUBE_ANALYTICS_ENABLED=true
YOUTUBE_REALTIME_METRICS=true
YOUTUBE_DEMOGRAPHIC_DATA=true
YOUTUBE_TRAFFIC_SOURCES=true
```

## 8. Implementation Recommendations

### 8.1 Development Phases

#### Phase 1: Basic Video Upload (MVP)
- Agent video upload interface
- Basic categorization and tagging
- Simple YouTube integration
- Basic video recommendations

#### Phase 2: Advanced Video Features (Growth)
- Smart recommendation engine
- Multi-language support
- Advanced video analytics
- Chatbot integration
- Video learning paths

#### Phase 3: AI-Powered Video Intelligence (Scale)
- Predictive content recommendations
- Automated video generation (future)
- Advanced personalization
- Real-time video performance optimization
- Community content moderation

### 8.2 Technology Stack Integration

#### Backend (Python)
- **FastAPI**: Video upload and processing APIs
- **Celery**: Background video processing tasks
- **OpenCV/Pillow**: Video thumbnail generation
- **Speech Recognition**: Automatic transcription
- **YouTube Data API**: Video hosting and analytics

#### Frontend (Flutter)
- **Video Player**: Flutter video_player package
- **File Picker**: Video file selection and upload
- **Image Picker**: Thumbnail selection
- **WebView**: YouTube video embedding
- **Charts**: Video analytics visualization

#### AI/ML Services
- **OpenAI Whisper**: Automatic video transcription
- **Google Cloud Vision**: Content analysis and tagging
- **Custom ML Models**: Video recommendation algorithms
- **YouTube Analytics API**: Performance metrics

#### Infrastructure
- **AWS S3**: Video file storage and CDN delivery
- **AWS Transcribe**: Audio transcription services
- **Redis**: Video processing queue and caching
- **PostgreSQL**: Video metadata and analytics storage

This tutorial video system design provides a comprehensive, intelligent, and user-friendly educational platform for Agent Mitra, enabling agents to create valuable content while providing customers with personalized learning experiences that drive engagement and business outcomes.

**Ready for your review! Please let me know if you'd like me to proceed with the remaining deliverables or make any adjustments to this video tutorial system design.**
