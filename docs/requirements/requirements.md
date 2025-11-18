# Agent Mitra - Life Insurance Agent-Client Mobile Application Requirements

## App Overview

**Agent Mitra** consists of two interconnected mobile apps designed for life insurance agents and their clients:

- **Agent Mitra - Agent App**: A comprehensive tool for insurance agents to manage clients, send targeted presentations, track sales analytics, and provide personalized service
- **Agent Mitra - Client App**: A user-friendly interface for policyholders to view their insurance information, make premium payments, communicate with agents, and receive personalized content

The system creates a centralized hub for all client information while enabling efficient, targeted communication and sales support.

## Core Purpose

- **Centralized Client Information**: All client data, policies, family details, and interaction history in one accessible location
- **Targeted Communication**: Send presentations, quotes, and updates to specific client segments (age groups, professions, marital status, communities, etc.)
- **Sales Support**: Real-time policy data, calculators, and guidance tools to assist agents in selling policies
- **Client Engagement**: Automated reminders, payment processing, receipt storage, and direct communication channels
- **Analytics & Reporting**: Track client engagement, presentation effectiveness, and sales performance

---

## Agent App Requirements

### 1. Authentication & Security
- **Agent Code Login**: Login using unique Agent Code and password
- **Login Screen Design**:
  - App logo: Circular design with two hands (blue and green) forming a circle with white 'A' in center
  - Branding: "AGENT MITRA" text (AGENT in blue, MITRA in green)
  - Subtitle: "Sign in to continue with Agent"
  - Password visibility toggle (eye icon)
  - Large blue login button with rounded corners
- **Double-Tap Exit**: "Tap BACK again to exit" functionality throughout the app
- Two-step verification (OTP) - optional
- Password recovery system
- Session management and auto-logout

### 2. Client Management System
- **Client Database**: Complete client profiles including:
  - Personal information (name, contact, address, alternate mobile)
  - Email address
  - Gender
  - Date of Birth
  - Address Type (residential, commercial, etc.)
  - Profession
  - Marriage Date
  - Age, occupation, marital status
  - Family composition and dependents
  - Community and professional categorization
- **Profile Management**: 
  - Editable profile summary with form fields
  - Date picker integration for date fields (Date of Birth, Marriage Date)
  - Profile photo upload capability (camera icon in header)
  - Update functionality with validation
- **Client Segmentation**: Custom grouping by:
  - Age ranges (25-35, 35-45, 45-55, 55+)
  - Professional categories (employees, businessmen, entrepreneurs, professionals)
  - Marital status (married, unmarried)
  - Family status (with minor children, without children)
  - Community groups
  - Custom user-defined groups
- **Client Registration**: Comprehensive form for adding new clients with all categorization tags

### 3. Presentation & Marketing Tools
- **Presentation Library**: Upload, organize, and manage marketing materials (PDFs, videos, images)
- **Empty State Handling**: 
  - Display "No Presentation Available" message when library is empty
  - Database icon with magnifying glass visual representation
  - Centered layout for better UX
- **Floating Action Button**: Red circular information button (FAB) in bottom right corner
- **Targeted Broadcasting**: Send presentations to:
  - All clients simultaneously
  - Specific groups (age, profession, marital status, community)
  - Individual clients
- **Analytics Tracking**: Monitor presentation engagement (views, forwards, interest levels)
- **Content Categories**: Organize presentations by target audience type

### 4. Daily Quote System
- **Quote Creation**: Design and send daily motivational/life insurance related quotes
- **Screen Title**: "Daily Motivational" in header
- **Loading State**: Circular spinner when fetching or generating quotes
- **Branding Integration**: Include agent name and logo on quotes
- **Client Resharing**: Allow clients to edit and reshare quotes to their contacts
- **Tracking System**: Monitor quote forwards and recipient information
- **Template Library**: Pre-designed quote templates with customizable backgrounds

### 5. Communication Hub
- **Agent Chat Feature**: Direct messaging system accessible from side drawer
- **Chat Icon**: Blue speech bubble with three white dots
- **Notification Badges**: Red circular badges with unread message counts on chat tiles
- **Integrated Chat System**: Direct messaging with all clients
- **Attachment Support**: Send documents, presentations, and multimedia content
- **Quick Reply Templates**: Pre-written responses for common scenarios
- **Message History**: Complete conversation logs with search functionality

### 6. Sales Support & Analytics
- **Live Policy Data**: Real-time access to insurance company databases
- **Sales Calculators**: Premium calculators, benefit comparisons, ROI tools
- **Client Analytics**: Track engagement metrics, interest levels, interaction patterns
- **Chart & Data Visualization**: 
  - Analytics dashboard with chart visualizations
  - Empty state handling: "No chart data available" message when no data exists
  - Support for various chart types (bar charts, line graphs, pie charts)
- **Sales Reporting**: Performance dashboards with:
  - New policies sold
  - Client engagement rates
  - Quote forwarding statistics
  - Pending renewals tracking
- **Export Capabilities**: Generate PDF/Excel reports filtered by time periods and categories

### 7. Reminder & Notification System
- **Reminders Feature**: Accessible from side drawer and home dashboard
- **Reminder Icon**: Clock icon next to stack of papers/documents
- **Notification Badges**: Red circular badges with count (e.g., "1" for pending reminders)
- **Premium Calendar**: Dedicated calendar view for premium due dates (bar chart icon with upward arrow and dollar sign)
- **Automated Reminders**: Premium due date alerts synced with client schedules
- **Custom Notifications**: Configurable alerts for important events
- **Client Response Tracking**: Notifications when clients mark presentations as "Interested", "Not Interested", or request "More Information"

---

## Client App Requirements

### 1. Authentication & Onboarding
- **Policy-Based Login**: Access using policy number or registered phone number
- **OTP Verification**: Secure two-step authentication
- **Agent Association**: Automatic linking to assigned insurance agent
- **Welcome Experience**: Personalized onboarding with agent branding

### 2. Policy Management Dashboard
- **Policy Overview**: Complete list of all owned insurance policies
- **Detailed Policy View**: For each policy display:
  - Policy number and type
  - Coverage benefits and terms
  - Premium amount and frequency
  - Maturity date and value
  - Payment history and upcoming due dates
- **Family Coverage**: Display dependents and family member coverage details

### 3. Payment Processing System
- **Premium Payment Integration**: Secure payment gateway for premium payments
- **Payment Reminders**: Automated alerts with sufficient advance notice for planning
- **Receipt Management**: Automatic digital receipt generation and storage
- **Payment History**: Complete transaction history with downloadable receipts
- **Multiple Payment Methods**: Support for UPI, credit/debit cards, net banking, and wallet payments

### 4. Communication Features
- **Agent Chat Interface**: Direct messaging with assigned insurance agent
- **Multimedia Support**: Send/receive text, images, documents, and voice notes
- **Presentation Viewing**: Access and view marketing materials sent by agent
- **Response Actions**: Quick response buttons for presentations:
  - "Interested" - Express interest in the offering
  - "Not Interested" - Decline the offering
  - "More Information" - Request additional details

### 5. Daily Quote Experience
- **Quote Display**: Daily motivational quotes with agent's branding
- **Personalization**: Edit quotes and reshare to personal contacts
- **Branding Control**: Agent's name/logo automatically minimizes when client reshares
- **Sharing Analytics**: Track and report quote forwarding to agent

### 6. Family Information Management
- **Family Profile**: Add and manage family member details
- **Relationship Tracking**: Define relationships (spouse, children, parents)
- **Age and Demographic Data**: Maintain current family composition information
- **Auto-Sync**: Automatic synchronization with agent's client database

### 7. Notification System
- **Push Notifications**: Instant alerts for:
  - Upcoming premium payments
  - New presentations from agent
  - Daily quotes availability
  - Important policy updates
  - Agent messages
- **Customizable Preferences**: Allow users to configure notification types and timing

---

## Technical Architecture Requirements

### 1. Data Synchronization
- **Real-time Sync**: Live database synchronization between agent and all client apps
- **Event-Driven Updates**: Instant notifications when agent sends content or updates
- **Conflict Resolution**: Automatic handling of data conflicts between devices
- **Offline Support**: Basic functionality when internet connection is unavailable

### 2. Cloud Infrastructure
- **Secure Cloud Storage**: Encrypted storage for:
  - Client personal and policy data
  - Presentation materials and documents
  - Chat logs and communication history
  - Payment receipts and transaction records
  - Analytics and reporting data
- **Scalable Architecture**: Support for growing number of agents and clients
- **Data Backup**: Automated daily backups with disaster recovery capabilities

### 3. Security & Compliance
- **Role-Based Access Control**: Different permission levels for agents and clients
- **Data Encryption**: End-to-end encryption for sensitive information
- **GDPR Compliance**: Data privacy and user consent management
- **Audit Logging**: Complete activity logs for security monitoring
- **Secure Payment Processing**: PCI DSS compliant payment handling

### 4. Analytics Engine
- **Behavioral Analytics**: Track user interactions and engagement patterns
- **Sales Performance**: Monitor conversion rates and sales metrics
- **Content Effectiveness**: Measure presentation and quote performance
- **Client Segmentation Analytics**: Automated insights for better targeting
- **Reporting Dashboard**: Real-time and historical analytics visualization

---

## UI/UX Design Requirements

### Visual Design System

#### Color Scheme
- **Primary Color**: Red (#C62828 or similar) - Used for headers, buttons, and accent elements
- **Secondary Colors**: 
  - Blue - Used for "AGENT" text in logo and primary actions
  - Green - Used for "MITRA" text in logo
  - White - Background and text on red headers
  - Light Gray - Secondary backgrounds and empty states

#### Typography
- Headers: Bold white text on red background
- Body text: Dark gray/black on white/light gray backgrounds
- Button text: White, capitalized text

#### Logo Design
- Circular logo with two hands (one blue, one green) forming a circle
- White 'A' letter in the center
- Represents partnership and support

### Agent App Navigation Hierarchy

#### Authentication Flow
- Splash Screen → Login Screen (Agent Code + Password) → OTP Verification (if enabled) → Home Dashboard

#### Main Navigation Structure
- **Side Drawer Menu** (Hamburger menu):
  - **Header Section**: 
    - Agent name (e.g., "B.Sridhar")
    - Agent phone number (e.g., "9246883365")
    - Red background header
  - **Menu Items** (with icons):
    - Home (house icon with yellow roof and blue window)
    - Daily Quotes (fist holding lightbulb icon)
    - My Policies (interconnected purple circles/nodes icon)
    - Premium Calendar (bar chart with upward arrow and dollar sign)
    - Agent Chat (blue speech bubble with three white dots)
    - Reminders (clock icon next to stack of papers)
    - Presentations (megaphone/speaker icon with document)
    - Profile (person's bust icon with green circle and red tie)
  - **Footer**: Logout option (door icon with arrow)

#### Home Dashboard Layout
- **Top Header**: Red bar with hamburger menu icon, "Home" title, and notification icon
- **Banner Section**: 
  - Carousel/slider with promotional banners
  - Example: LIC (Life Insurance Corporation) branding with family imagery
  - Pagination dots indicator
- **Feature Tiles Grid** (2 rows × 3 columns):
  - **Row 1**: CALENDAR, CHAT, REMINDERS
  - **Row 2**: PRESENTATIONS, DAILY QUOTES, PROFILE
  - Each tile includes:
    - Icon representation
    - Label text in red
    - Notification badge (red circle with white number) when applicable
- **My Policies Section**: 
  - Red horizontal bar with "MY POLICIES" text
  - Right arrow icon for navigation
  - Loading indicator when fetching data

#### Screen-Specific UI Requirements

**Presentations Screen**:
- Red header with back arrow and "Presentations" title
- Empty state design:
  - Database icon with magnifying glass (light blue and gray)
  - "No Presentation Available" message in dark gray text
  - Centered layout
- Floating Action Button (FAB): Red circular button with white lowercase 'i' (information icon) in bottom right corner
- "Tap BACK again to exit" button

**Daily Motivational Quotes Screen**:
- Red header with back arrow and "Daily Motivational" title
- Loading spinner (circular gray indicator with red segment) when loading content
- "Tap BACK again to exit" button

**My Policies Screen**:
- Red header with back arrow and "My Policies" title
- Loading spinner in center when fetching policy data
- "Tap BACK again to exit" button

**Profile Screen**:
- Red header with back arrow, "Profile" title, and camera icon button (white circle with blue camera icon)
- **Profile Summary Card** (white card with rounded corners):
  - Title: "Profile Summary" with yellow edit icon (circular button with white pencil)
  - Form fields with labels and values:
    - Name (pre-filled, e.g., "B.Sridhar")
    - Phone (pre-filled, e.g., "9246883365")
    - Email (pre-filled, e.g., "bellamkondaraghu@gmail.com")
    - Gender (empty field)
    - Date of Birth (pre-filled, e.g., "19/09/1966") with blue calendar icon
    - Address (empty field)
    - Address Type (empty field)
    - Alternate Mobile (empty field)
    - Profession (empty field)
    - Select Marriage Date (placeholder: "Marriage Date") with blue calendar icon
  - Fields separated by thin gray lines
  - Large red "UPDATE" button at bottom with white text
- Field validation and date picker integration

**Chart/Analytics Screen**:
- Red header with hamburger menu and "Agent Mitra" title
- Empty state: "No chart data available" message in orange/golden-yellow color
- Support for various chart visualizations when data is available

#### Key User Flows
- **Client Management**: Side Drawer → My Policies → Policy List → Policy Details → Edit/Add Client
- **Presentation Flow**: Side Drawer → Presentations → (Empty state or List) → Select Presentation → Choose Recipients → Send → View Analytics
- **Quote Creation**: Side Drawer → Daily Quotes → Create/Edit Quote → Preview → Send → Track Forwards
- **Communication**: Side Drawer → Agent Chat → Chat Interface → Send Message/Attachment
- **Profile Management**: Side Drawer → Profile → Edit Profile Summary → Update Fields → Save Changes

### Client App Navigation Hierarchy

#### Authentication Flow
- Splash Screen → Login/Register (Policy Number or Phone) → OTP Verification → Home Dashboard

#### Main Navigation (Bottom Tabs)
- **Home**: Personalized dashboard
- **Policies**: Policy management and details
- **Messages**: Agent communication
- **Quotes**: Daily quote viewing and sharing
- **Settings**: Profile and preferences

#### Key User Flows
- **Policy Management**: Home → My Policies → Policy Details → Make Payment → Receipt Storage
- **Agent Communication**: Messages Tab → Agent Chat → View Presentation → Respond (Interested/Not Interested/More Info)
- **Quote Interaction**: Quotes Tab → View Quote → Edit & Share → Track Recipients

### Common UI Patterns

#### Loading States
- Circular loading spinner with gray background and red progress segment
- Centered placement on screen
- Used for: Policy data loading, Quote loading, Chart data loading

#### Empty States
- Icon representation (database with magnifying glass, etc.)
- Descriptive message in gray text
- Centered layout
- Examples: "No Presentation Available", "No chart data available"

#### Exit Functionality
- "Tap BACK again to exit" button/overlay
- Blue rectangular button with rounded corners
- White capitalized text
- Prevents accidental app closure

#### Navigation Patterns
- Red header bars with white text throughout the app
- Back arrow icon (left-pointing) on left side of headers
- Hamburger menu icon for side drawer access
- Consistent bottom navigation bar (system UI)

---

## Additional Features

### Multi-language Support
- Support for multiple regional languages
- Agent-configurable language preferences
- Automatic language detection based on device settings

### Branding Customization
- **App Logo**: Two-handed circular logo with 'A' in center (blue and green hands)
- **Color Scheme**: Red primary color for headers and accents, blue/green for branding
- Agent logo and branding integration in quotes and presentations
- Custom color schemes and themes
- Personalized quote templates and presentation signatures
- LIC (Life Insurance Corporation) branding support in banners and promotional content

### Integration Capabilities
- Insurance company API integration for live policy data
- CRM system connectivity for advanced client management
- Payment gateway integration for seamless transactions
- Analytics platform integration for advanced reporting

### Performance Requirements
- Fast loading times (< 2 seconds for screen transitions)
- Loading indicators for all async operations (policy fetching, quote loading, chart data)
- Offline functionality for critical features
- Push notification delivery within 5 seconds
- Real-time chat message delivery
- Automatic data synchronization every 15 minutes when online
- Graceful handling of empty states (no data scenarios)
- Smooth side drawer animations and transitions

---

## Success Metrics

- **User Adoption**: Target 80% of agent's clients using the client app within 6 months
- **Engagement Rate**: Minimum 70% monthly active users for both agent and client apps
- **Sales Conversion**: 25% improvement in policy sales conversion rates
- **Client Satisfaction**: Average 4.5/5 star rating from client feedback surveys
- **Data Accuracy**: 99.9% uptime for data synchronization services
