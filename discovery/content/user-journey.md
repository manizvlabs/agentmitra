# Agent Mitra - Comprehensive User Journey Flow Diagrams

## 1. User Journey Overview

### 1.1 Journey Philosophy & Design Principles

#### User-Centric Design Approach
```
🎯 USER JOURNEY DESIGN PHILOSOPHY

🎨 Core Principles:
├── Simplicity First: Intuitive flows for non-tech-savvy users
├── Progressive Disclosure: Show only relevant information
├── Contextual Help: AI assistance at every step
├── Error Prevention: Guide users away from mistakes
├── Emotional Design: Build trust and confidence
└── Accessibility: Inclusive design for all users

📊 Success Metrics:
├── Task Completion Rate: >85%
├── User Satisfaction Score: >4.2/5
├── Error Rate: <5%
├── Support Ticket Reduction: 60%
└── Feature Adoption Rate: >70%
```

#### Multi-User Persona Framework
```
👥 USER PERSONAS & JOURNEYS

🎭 Primary Personas:
├── 👴 Senior Citizens (40%): Simple, large text, voice assistance
├── 👨‍💼 Working Professionals (30%): Quick actions, mobile-optimized
├── 🏘️ Rural Users (20%): Low bandwidth, offline capabilities
├── 👩‍💻 Young Adults (10%): Feature exploration, social sharing
└── 🧑‍🤝‍🧑 Agents (100%): Business tools, analytics, efficiency

📈 Journey Stages:
├── Awareness → Consideration → Purchase → Retention → Advocacy
├── Onboarding → Habit Building → Feature Discovery → Power User
├── Problem → Search → Evaluation → Selection → Usage → Loyalty
└── Need Recognition → Information Search → Evaluation → Purchase → Post-Purchase
```

## 2. Customer Journey Flows

### 2.1 Customer Onboarding & Registration

#### New User Discovery & Download
```mermaid
flowchart TD
    A[User Discovers App] --> B{How did they find it?}
    B -->|App Store Search| C[Search 'LIC Agent' or 'Insurance']
    B -->|Agent Referral| D[Receive WhatsApp link from Agent]
    B -->|Social Media| E[See Facebook/Instagram ads]
    B -->|Word of Mouth| F[Friend/Family recommendation]

    C --> G[Find Agent Mitra in results]
    D --> G
    E --> G
    F --> G

    G --> H[Read app description & reviews]
    H --> I{Does it meet needs?}
    I -->|Yes| J[Download App]
    I -->|No| K[Continue searching]

    J --> L[App downloads successfully]
    L --> M[User opens app for first time]
    M --> N[Splash screen with Agent Mitra branding]
    N --> O[Language selection: English/Hindi/Telugu]
    O --> P[Welcome screen with key benefits]
```

#### Registration & Profile Setup Journey

**Sub-Journey 1: Customer Acquisition & Initial Setup**
```mermaid
flowchart TD
    A[Welcome Screen] --> B[Click 'Get Started']
    B --> C[Phone Number Input]
    C --> D{Valid phone number?}
    D -->|No| E[Show error message & help]
    D -->|Yes| F[Send OTP via SMS]

    F --> G[OTP Input Screen]
    G --> H[User enters 6-digit OTP]
    H --> I{OTP correct?}
    I -->|No| J[Show error, allow retry]
    J --> H
    I -->|Yes| K[Phone verification successful]

    K --> L[Basic Profile Setup]
    L --> M[Enter full name]
    M --> N[Select user type: Policyholder/Agent]
    N --> O{Selected Policyholder?}
    O -->|Yes| P[→ Continue to Sub-Journey 2]
    O -->|No| Q[→ Agent Onboarding Flow]
```

**Sub-Journey 2: Agent Relationship Establishment**
```mermaid
flowchart TD
    A[← From Sub-Journey 1] --> B{How did customer get app?}
    B -->|Agent referral link| C[Check agent database]
    B -->|Direct download| D[→ Agent Discovery Flow]
    B -->|Unknown source| E[→ Agent Discovery Flow]

    C --> F{Agent relationship found?}
    F -->|Yes| G[Auto-populate profile data]
    F -->|No| H[Show 'Contact agent' CTA]

    G --> I[Show pre-filled profile]
    I --> J[Verify/correct details]
    J --> K{Details correct?}
    K -->|Yes| L[→ Continue to Sub-Journey 3]
    K -->|No| M[Edit profile details]
    M --> L

    H --> N[Agent uploads customer data]
    N --> O[Background job processes data]
    O --> P[Customer data becomes available]
    P --> Q[Resume onboarding flow]
    Q --> L

    D --> R[Agent Discovery Methods]
    R --> S[Check policy document]
    R --> T[Contact LIC customer care]
    R --> U[Search online directories]
    R --> V[Ask other policyholders]

    S --> W[Look for agent code/name]
    T --> X[Call LIC helpline]
    U --> Y[Search agent directory]
    V --> Z[Ask fellow customers]

    W --> AA[Found agent information]
    X --> AA
    Y --> AA
    Z --> AA

    AA --> BB[Add agent in settings]
    BB --> CC[Enter agent details]
    CC --> DD[Agent code, name, contact]
    DD --> EE[Verify agent identity]
    EE --> FF{Agent verified?}
    FF -->|No| GG[Try different agent]
    FF -->|Yes| HH[Send notification to agent]
    HH --> II[Agent receives data request]
    II --> JJ[Agent verifies customer identity]
    JJ --> KK{Identity confirmed?}
    KK -->|No| LL[Request additional verification]
    LL --> MM[Customer provides docs]
    MM --> JJ
    KK -->|Yes| NN[Agent uploads data to portal]
    NN --> OO[Background processing]
    OO --> PP{Import successful?}
    PP -->|Yes| QQ[Data becomes available]
    PP -->|No| RR[Agent corrects data]
    RR --> NN
    QQ --> SS[Mobile app sync notification]
    SS --> TT[Customer sees data available]
    TT --> L

    GG --> UU[Show contact support option]
    UU --> VV[Onboarding blocked temporarily]
    VV --> WW[Show limited functionality]
    WW --> XX[Periodic agent contact reminders]
```

**Sub-Journey 3: Profile Completion & Verification**
```mermaid
flowchart TD
    A[← From Sub-Journey 2] --> B[Profile data available]
    B --> C{Policy data available?}
    C -->|Yes| D[Show policy summary]
    C -->|No| E[Show data loading status]
    E --> F[Periodic data check]
    F --> G{Data now available?}
    G -->|Yes| D
    G -->|No| H[Show loading animation]
    H --> I[Retry after delay]
    I --> F

    D --> J[Set user preferences]
    J --> K[Language, notifications, theme]
    K --> L[Security setup]
    L --> M[Biometric/PIN setup]
    M --> N[Onboarding complete]
    N --> O[Dashboard tour starts]

    O --> P[Document verification required]
    P --> Q[Choose document type]
    Q --> R{Government ID}
    R --> S[Aadhaar Card]
    R --> T[Voter ID]
    R --> U[Driving License]
    R --> V[Passport]

    S --> W[Upload document]
    T --> W
    U --> W
    V --> W

    W --> X[OCR processing]
    X --> Y{OCR successful?}
    Y -->|Yes| Z[Auto-fill details]
    Y -->|No| AA[Manual entry required]

    Z --> BB[Address verification]
    AA --> BB
    BB --> CC[Current address]
    CC --> DD{Permanent address same?}
    DD -->|Yes| EE[Auto-copy address]
    DD -->|No| FF[Enter permanent address]

    EE --> GG[Bank details setup]
    FF --> GG
    GG --> HH[Bank account number]
    HH --> II[IFSC code]
    II --> JJ[UPI ID optional]

    JJ --> KK[Emergency contact]
    KK --> LL[Relationship & phone]
    LL --> MM[KYC verification starts]

    MM --> NN[Manual review queue]
    NN --> OO{Approved?}
    OO -->|Yes| PP[Full app access unlocked]
    OO -->|No| QQ[Rejection reason sent]
    QQ --> RR[Re-upload corrected documents]

    PP --> SS[Welcome email sent]
    SS --> TT[Push notification]
    TT --> UU[Complete onboarding flow]
```

#### Agent Configuration Portal - Data Upload Process
```mermaid
flowchart TD
    A[Agent logs into Configuration Portal] --> B[Dashboard overview]
    B --> C[Customer data management section]
    C --> D[View existing customer data]
    D --> E[Check data sync status]
    E --> F{New customer onboarding?}
    F -->|Yes| G[Export data from LIC portal]
    F -->|No| H[Regular data sync]

    G --> I[LIC Agent Policy Portal Login]
    I --> J[Navigate to customer reports]
    J --> K[Select customers to export]
    K --> L[Generate Excel report]
    L --> M[Download Excel file]
    M --> N[Return to Agent Mitra Config Portal]

    N --> O[Data Upload section]
    O --> P[Select file upload]
    P --> Q[Choose Excel file]
    Q --> R[File validation]
    R --> S{Valid format?}
    S -->|No| T[Show validation errors]
    T --> Q
    S -->|Yes| U[Upload file to server]

    U --> V[File processing starts]
    V --> W[Parse Excel data]
    W --> X[Validate data integrity]
    X --> Y{Data valid?}
    Y -->|No| Z[Show processing errors]
    Z --> AA[Request file correction]
    AA --> Q

    Y -->|Yes| BB[Map data to database schema]
    BB --> CC[Preview data before import]
    CC --> DD[Show import summary]
    DD --> EE{Confirm import?}
    EE -->|No| FF[Cancel import]
    FF --> O
    EE -->|Yes| GG[Start background import job]

    GG --> HH[Job queued for processing]
    HH --> II[Asynchronous data processing]
    II --> JJ[Create/update customer records]
    JJ --> KK[Create/update policy records]
    KK --> LL[Update agent relationships]
    LL --> MM[Send success notification]

    MM --> NN[Update sync status]
    NN --> OO[Trigger mobile app data refresh]
    OO --> PP[Customer sees data in mobile app]

    H --> QQ[Check for data updates]
    QQ --> RR{Updates available?}
    RR -->|Yes| SS[Download latest data]
    SS --> TT[Process incremental updates]
    TT --> MM

    RR -->|No| UU[No action required]
    UU --> VV[Schedule next sync check]
```

### Excel Template Definition for Agent Data Import

#### TODO: Create Comprehensive Excel Template Specification

**📋 Task Title:** Define Excel Template for LIC Agent Data Import to Agent Mitra Configuration Portal

**🎯 Objective:** Create a standardized, user-friendly Excel template that agents can use to import customer and policy data from the official LIC Agent Mobile App to the Agent Mitra Configuration Portal.

**⏰ Priority:** High
**👥 Owner:** Product Manager + Data Analyst
**📅 Due Date:** Sprint 2, Week 1
**🔗 Dependencies:** Database schema finalized, Agent Configuration Portal UI designed

#### 📋 Detailed Checklist

**✅ 1. Template Structure Analysis**
- [ ] Review LIC Agent Mobile App export capabilities
- [ ] Analyze existing customer data fields in LIC systems
- [ ] Map LIC data fields to Agent Mitra database schema
- [ ] Identify mandatory vs optional fields
- [ ] Define data validation rules for each field

**✅ 2. Excel Template Design**
- [ ] Create multiple worksheet structure:
  - [ ] Customer Information sheet
  - [ ] Policy Details sheet
  - [ ] Contact History sheet (optional)
  - [ ] Instructions sheet
- [ ] Design column headers with clear naming conventions
- [ ] Add data type indicators (Text, Number, Date, etc.)
- [ ] Include field descriptions and examples
- [ ] Create dropdown lists for categorical fields (Policy Type, Gender, etc.)

**✅ 3. Data Validation Rules**
- [ ] Implement Excel data validation for:
  - [ ] Phone number format validation
  - [ ] Email format validation
  - [ ] Date format validation (DD/MM/YYYY)
  - [ ] Policy number format validation
  - [ ] Required field indicators
  - [ ] Data range validation (age, premium amounts)
- [ ] Add conditional formatting for data quality indicators
- [ ] Create error highlighting for invalid data

**✅ 4. Template Features**
- [ ] Add data entry guidelines and examples
- [ ] Include sample data rows for reference
- [ ] Create macro-free template (for security)
- [ ] Add version control information
- [ ] Include template update notification system

**✅ 5. Field Mapping Specification**

**Customer Information Sheet:**
```
Column A: Customer_ID (Text, Max 50 chars) - LIC Customer ID
Column B: Full_Name (Text, Max 255 chars) - Customer Full Name *
Column C: Phone_Number (Text, Format: +91XXXXXXXXXX) - Primary Phone *
Column D: Alternate_Phone (Text, Optional) - Secondary Phone
Column E: Email (Text, Valid email format) - Email Address
Column F: Date_of_Birth (Date, DD/MM/YYYY) - DOB *
Column G: Gender (Dropdown: Male/Female/Other) - Gender
Column H: Address_Line1 (Text, Max 500 chars) - Address Line 1 *
Column I: Address_Line2 (Text, Max 500 chars) - Address Line 2
Column J: City (Text, Max 100 chars) - City *
Column K: State (Text, Max 100 chars) - State *
Column L: Pincode (Number, 6 digits) - PIN Code *
Column M: Occupation (Text, Max 100 chars) - Occupation
Column N: Annual_Income (Number, INR) - Annual Income
Column O: Marital_Status (Dropdown: Single/Married/Divorced/Widowed)
Column P: Nominee_Name (Text, Max 255 chars) - Policy Nominee
Column Q: Nominee_Relationship (Text, Max 50 chars) - Relationship to Nominee
Column R: Emergency_Contact_Name (Text, Max 255 chars)
Column S: Emergency_Contact_Phone (Text, Format: +91XXXXXXXXXX)
```

**Policy Details Sheet:**
```
Column A: Policy_Number (Text, Max 50 chars) - LIC Policy Number *
Column B: Customer_ID (Text) - Link to Customer *
Column C: Policy_Type (Dropdown: Term/Whole_Life/ULIP/Endowment/Other) *
Column D: Plan_Name (Text, Max 255 chars) - LIC Plan Name *
Column E: Sum_Assured (Number, INR) - Sum Assured Amount *
Column F: Premium_Amount (Number, INR) - Regular Premium *
Column G: Premium_Frequency (Dropdown: Monthly/Quarterly/Half-Yearly/Yearly) *
Column H: Premium_Mode (Dropdown: Regular/Single_Pay/Limited_Pay)
Column I: Issue_Date (Date, DD/MM/YYYY) - Policy Issue Date *
Column J: Maturity_Date (Date, DD/MM/YYYY) - Maturity Date
Column K: Next_Premium_Due (Date, DD/MM/YYYY) - Next Due Date
Column L: Policy_Status (Dropdown: Active/Lapsed/Surrendered/Matured/Claimed)
Column M: Agent_Code (Text, Max 20 chars) - LIC Agent Code *
Column N: Branch_Code (Text, Max 10 chars) - LIC Branch Code
Column O: Rider_Details (Text, Max 1000 chars) - Additional Riders
Column P: Last_Premium_Paid (Date, DD/MM/YYYY) - Last Payment Date
Column Q: Outstanding_Amount (Number, INR) - Due Amount
```

**✅ 6. Import Processing Logic**
- [ ] Define data transformation rules
- [ ] Create field mapping configuration
- [ ] Implement data quality checks
- [ ] Design error reporting format
- [ ] Create duplicate detection logic

**✅ 7. Testing & Validation**
- [ ] Test template with real LIC data samples
- [ ] Validate import processing for all field types
- [ ] Test error handling and reporting
- [ ] Performance test with large datasets (1000+ records)
- [ ] Cross-browser compatibility testing

**✅ 8. Documentation & Training**
- [ ] Create template usage guide for agents
- [ ] Develop video tutorial for data import process
- [ ] Create troubleshooting guide for common issues
- [ ] Design in-app help system for template usage

**✅ 9. Deployment & Support**
- [ ] Deploy template to Agent Configuration Portal
- [ ] Set up template version control
- [ ] Create template update mechanism
- [ ] Establish support channels for template issues

#### 📊 Success Metrics
- **Template Adoption Rate:** >90% of agents use the standardized template
- **Import Success Rate:** >95% of valid imports succeed without errors
- **Data Accuracy:** >98% of imported data matches source accuracy
- **Agent Satisfaction:** >4.5/5 rating for template usability
- **Import Time:** <5 minutes for 100 customer records

#### 🔗 Related Deliverables
- [ ] Agent Configuration Portal UI updates
- [ ] Backend data import service enhancements
- [ ] Agent training materials
- [ ] Support documentation updates
- [ ] API documentation for template integration

### 2.2 Policy Management Journey

#### Policy Discovery & Data Availability
```mermaid
flowchart TD
    A[User logs in] --> B[Dashboard loads]
    B --> C[Check data availability status]
    C --> D{Data uploaded by agent?}
    D -->|Yes| E[Show policy overview widget]
    D -->|No| F[Show data pending screen]

    E --> G[Display policy summary]
    G --> H[Active policies count]
    H --> I[Next premium due dates]
    I --> J[Total coverage amount]
    J --> K[Full policy management access]

    F --> L[Data upload pending message]
    L --> M[Explain agent upload process]
    M --> N[Show agent contact options]
    N --> O{User contacts agent?}
    O -->|Yes| P[Agent receives notification]
    O -->|No| Q[Show periodic reminders]

    P --> R[Agent logs into config portal]
    R --> S[Uploads customer Excel data]
    S --> T[Background processing job]
    T --> U[Data validation & import]
    U --> V{Import successful?}
    V -->|Yes| W[Customer data becomes available]
    V -->|No| X[Show import errors to agent]
    X --> Y[Agent corrects data]
    Y --> S

    W --> Z[Mobile app data refresh]
    Z --> AA[Push notification sent]
    AA --> BB[User sees data available]
    BB --> CC[Resume normal app usage]

    Q --> DD[Daily reminder notifications]
    DD --> EE[Weekly agent contact prompts]
    EE --> FF[Gradual onboarding limitations]
    FF --> GG[Limited app functionality]
    GG --> HH[Basic features only]
    HH --> II[Full access after data upload]

    K --> JJ[Policy management features]
    JJ --> KK[Premium payments]
    KK --> LL[Claims processing]
    LL --> MM[Document access]
    MM --> NN[Agent communication]

    CC --> JJ
```

#### Policy Details Exploration
```mermaid
flowchart TD
    A[User views policy card] --> B[Tap on policy]
    B --> C[Policy details screen loads]
    C --> D[Policy header with status badge]
    D --> E[Coverage amount & plan details]
    E --> F[Premium information]
    F --> G[Next due date & amount]

    G --> H[Tab navigation]
    H --> I{Which tab?}
    I -->|Overview| J[Policy summary]
    I -->|Coverage| K[Coverage details]
    I -->|Premium| L[Payment history]
    I -->|Documents| M[Policy documents]
    I -->|Claims| N[Claim history]

    J --> O[Key policy information]
    O --> P[Nominee details]
    P --> Q[Agent contact info]

    K --> R[Coverage breakdown]
    R --> S[Sum assured details]
    S --> T[Rider benefits]
    T --> U[Exclusion list]

    L --> V[Payment history table]
    V --> W[Filter by date/status]
    W --> X[Download receipts]
    X --> Y[Payment method insights]

    M --> Z[Document list]
    Z --> AA[Policy PDF download]
    AA --> BB[ID proof copies]
    BB --> CC[Medical reports]

    N --> DD[Claim history]
    DD --> EE[Claim status tracking]
    EE --> FF[Claim document uploads]
    FF --> GG[Claim amount details]
```

### 2.3 Payment Processing Journey

#### Premium Payment Flow
```mermaid
flowchart TD
    A[Payment reminder received] --> B[User taps reminder]
    B --> C[Payment screen opens]
    C --> D[Show outstanding amount]
    D --> E[Policy details summary]
    E --> F[Due date information]

    F --> G[Payment method selection]
    G --> H{Available methods}
    H -->|UPI| I[UPI payment flow]
    H -->|Credit Card| J[Card payment flow]
    H -->|Net Banking| K[Net banking flow]
    H -->|Wallet| L[Wallet payment flow]

    I --> M[Show UPI apps]
    M --> N[User selects app]
    N --> O[Redirect to UPI app]
    O --> P[UPI transaction]

    J --> Q[Card details form]
    Q --> R[Card number input]
    R --> S[Expiry & CVV]
    S --> T[Card holder name]

    K --> U[Bank selection]
    U --> V[User ID & password]
    V --> W[Bank authentication]

    L --> X[Wallet selection]
    X --> Y[Wallet balance check]
    Y --> Z{P Sufficient balance?}
    Z -->|Yes| AA[Proceed to payment]
    Z -->|No| BB[Low balance error]

    P --> CC[Payment processing]
    T --> CC
    W --> CC
    AA --> CC

    CC --> DD[Gateway processing]
    DD --> EE{Transaction status}
    EE -->|Success| FF[Payment confirmation]
    EE -->|Failed| GG[Payment failed]

    FF --> HH[Receipt generation]
    HH --> II[Email & SMS receipt]
    II --> JJ[Policy status update]
    JJ --> KK[Grace period reset]
    KK --> LL[Agent notification]

    GG --> MM[Error message display]
    MM --> NN[Retry payment option]
    NN --> OO{Failed again?}
    OO -->|Yes| PP[Contact support]
    OO -->|No| FF
```

#### Payment Method Setup
```mermaid
flowchart TD
    A[User wants to add payment method] --> B[Settings → Payment Methods]
    B --> C[Add new method screen]
    C --> D[Method type selection]
    D --> E{Which method?}
    E -->|Credit Card| F[Card details form]
    E -->|Debit Card| F
    E -->|UPI| G[UPI setup]
    E -->|Net Banking| H[Bank account setup]

    F --> I[Card number input]
    I --> J[Card validation]
    J --> K{Valid card?}
    K -->|No| L[Error message]
    L --> I
    K -->|Yes| M[Expiry date & CVV]

    M --> N[Card holder name]
    N --> O[Billing address]
    O --> P[Card verification]
    P --> Q[OTP sent to registered phone]
    Q --> R[OTP verification]
    R --> S{OTP correct?}
    S -->|No| T[Retry OTP]
    T --> Q
    S -->|Yes| U[Card added successfully]

    G --> V[UPI ID input]
    V --> W[UPI validation]
    W --> X{Valid UPI?}
    X -->|No| Y[Error message]
    Y --> V
    X -->|Yes| Z[UPI verification]
    Z --> AA[Test transaction ₹1]
    AA --> BB{Transaction success?}
    BB -->|No| CC[Verification failed]
    BB -->|Yes| DD[Refund ₹1 automatically]
    DD --> EE[UPI added successfully]

    H --> FF[Bank selection]
    FF --> GG[Account number]
    GG --> HH[IFSC code]
    HH --> II[Account verification]
    II --> JJ[Net banking login]
    JJ --> KK[Bank authentication]
    KK --> LL{Verification success?}
    LL -->|No| MM[Verification failed]
    LL -->|Yes| NN[Net banking added]

    U --> OO[Payment method list updated]
    EE --> OO
    NN --> OO
    CC --> OO
    MM --> OO

    OO --> PP[Set as default option]
    PP --> QQ{Set as default?}
    QQ -->|Yes| RR[Update default method]
    QQ -->|No| SS[Method added successfully]
    RR --> SS
    SS --> TT[Return to payment methods]
```

### 2.4 Chatbot & Support Journey

#### AI Chatbot Interaction Flow
```mermaid
flowchart TD
    A[User needs help] --> B[Open chat from bottom nav]
    B --> C[Chatbot greeting screen]
    C --> D[Welcome message with typing animation]
    D --> E[Quick action buttons]
    E --> F{User action}
    F -->|Type message| G[Message input field]
    F -->|Quick reply| H[Select quick action]
    F -->|Voice input| I[Voice recording starts]

    G --> J[User types message]
    J --> K[Send button tap]
    K --> L[Message sent to chatbot]

    H --> L
    I --> M[Speech to text conversion]
    M --> L

    L --> N[Typing indicator shows]
    N --> O[AI processing message]
    O --> P[Intent recognition]
    P --> Q{Intent identified?}
    Q -->|Yes| R[Knowledge base search]
    Q -->|No| S[Ask for clarification]

    R --> T{Relevant info found?}
    T -->|Yes| U[Generate response with links]
    T -->|No| V[Escalation check]

    U --> W[Show response with tutorial links]
    W --> X[User interaction options]
    X --> Y{User choice}
    Y -->|Satisfied| Z[End conversation]
    Y -->|Need more help| AA[Continue chatting]
    Y -->|Call agent| BB[Agent callback request]

    S --> CC[Clarification message]
    CC --> DD[User provides more info]
    DD --> O

    V --> EE[Complexity assessment]
    EE --> FF{Complex query?}
    FF -->|Yes| BB
    FF -->|No| GG[Fallback response]

    BB --> HH[Create actionable report]
    HH --> II[Show confirmation message]
    II --> JJ[Agent notified via dashboard]
    JJ --> KK[User receives callback promise]

    Z --> LL[Conversation logged]
    AA --> L
    KK --> LL
    GG --> W
```

#### Agent Callback Request Flow
```mermaid
flowchart TD
    A[User clicks 'Call Agent'] --> B[Callback request initiated]
    B --> C[Collect conversation context]
    C --> D[Extract key information]
    D --> E[Assess urgency level]

    E --> F[Create actionable report]
    F --> G[Report structure]
    G --> H[Customer details]
    H --> I[Conversation summary]
    I --> J[Identified issues]
    J --> K[Requested assistance type]

    K --> L[Priority assignment]
    L --> M{High priority?}
    M -->|Yes| N[Immediate agent notification]
    M -->|No| O[Queue for next available slot]

    N --> P[Push notification to agent]
    P --> Q[SMS alert to agent]
    Q --> R[Dashboard priority badge]
    R --> S[Agent receives callback request]

    O --> T[Dashboard queue update]
    T --> S

    S --> U[Agent reviews conversation]
    U --> V[Agent calls customer]
    V --> W[Conversation between agent & customer]
    W --> X[Issue resolved]
    X --> Y[Agent updates report status]
    Y --> Z[Report marked as completed]

    Z --> AA[Analytics update]
    AA --> BB[Performance metrics updated]
    BB --> CC[Customer satisfaction survey]
    CC --> DD[Feedback collected]
    DD --> EE[Continuous improvement data]
```

### 2.5 Agent Dashboard & Management Journey

#### Agent Daily Workflow
```mermaid
flowchart TD
    A[Agent logs in] --> B[Dashboard loads]
    B --> C[Priority notifications check]
    C --> D{Callback requests?}
    D -->|Yes| E[Show callback alerts]
    D -->|No| F[Normal dashboard]

    E --> G[Review callback requests]
    G --> H[Read conversation summary]
    H --> I[Call customer]
    I --> J[Resolve customer issues]
    J --> K[Update report status]
    K --> L[Continue with normal workflow]

    F --> M[Key metrics overview]
    M --> N[Today's revenue target]
    N --> O[Active customer count]
    O --> P[Pending tasks count]

    P --> Q[Task prioritization]
    Q --> R{Urgent tasks?}
    R -->|Yes| S[Handle urgent tasks first]
    R -->|No| T[Normal task processing]

    S --> U[Process urgent items]
    U --> V[Customer follow-ups]
    V --> W[Policy renewals]
    W --> X[Claim processing]

    T --> Y[Regular activities]
    Y --> Z[New customer outreach]
    Z --> AA[Existing customer engagement]
    AA --> BB[Product recommendations]

    X --> CC[Task completion]
    BB --> CC

    CC --> DD[Performance tracking]
    DD --> EE[Commission calculation]
    EE --> FF[Revenue reporting]
    FF --> GG[End of day summary]
    GG --> HH[Log out]
```

#### Campaign Management Journey
```mermaid
flowchart TD
    A[Agent wants to run campaign] --> B[Marketing → Campaigns]
    B --> C[Campaign dashboard]
    C --> D[View existing campaigns]
    D --> E[Campaign performance metrics]
    E --> F{Create new campaign?}
    F -->|Yes| G[Campaign builder]
    F -->|No| H[Manage existing campaigns]

    G --> I[Campaign type selection]
    I --> J{Which type?}
    J -->|Lead Generation| K[Lead gen campaign]
    J -->|Retention| L[Retention campaign]
    J -->|Renewal| M[Renewal campaign]
    J -->|Product Launch| N[Product campaign]

    K --> O[Target audience setup]
    L --> O
    M --> O
    N --> O

    O --> P[Customer segmentation]
    P --> Q[Filter by demographics]
    Q --> R[Filter by policy type]
    R --> S[Filter by engagement level]
    S --> T[Filter by geography]

    T --> U[Campaign content creation]
    U --> V[Message template selection]
    V --> W[Personalization variables]
    W --> X[Multimedia content]
    X --> Y[WhatsApp template approval]

    Y --> Z[Campaign scheduling]
    Z --> AA[Send time optimization]
    AA --> BB[Frequency settings]
    BB --> CC[A/B testing setup]

    CC --> DD[Budget allocation]
    DD --> EE[Campaign launch]
    EE --> FF[Real-time monitoring]

    H --> GG[Campaign list view]
    GG --> HH[Select campaign to manage]
    HH --> II[Edit campaign settings]
    II --> JJ[Pause/resume campaign]
    JJ --> KK[Modify targeting]
    KK --> FF

    FF --> LL[Performance analytics]
    LL --> MM[Open rates tracking]
    MM --> NN[Conversion metrics]
    NN --> OO[ROI calculation]
    OO --> PP[Campaign optimization]
    PP --> QQ[Generate reports]
    QQ --> RR[Share with management]
```

## 3. Admin & System Management Journeys

### 3.1 Super Admin System Management

#### Feature Flag Management
```mermaid
flowchart TD
    A[Super Admin logs in] --> B[Admin dashboard]
    B --> C[System management section]
    C --> D[Feature flags management]
    D --> E[View all feature flags]
    E --> F[Grouped by category]
    F --> G{Modify flag?}
    G -->|Yes| H[Select feature flag]
    G -->|No| I[Review flag status]

    H --> J[Edit flag settings]
    J --> K[Change enable/disable status]
    K --> L[Set rollout percentage]
    L --> M[Select target user groups]
    M --> N[Set activation schedule]

    N --> O[Validation checks]
    O --> P{Valid configuration?}
    P -->|No| Q[Show validation errors]
    Q --> J
    P -->|Yes| R[Save configuration]

    R --> S[Deployment trigger]
    S --> T[CDN cache invalidation]
    T --> U[App sync notification]
    U --> V[Real-time flag updates]

    I --> W[View flag analytics]
    W --> X[Adoption rates]
    X --> Y[Error rates]
    Y --> Z[Performance impact]

    V --> AA[Audit log entry]
    AA --> BB[Configuration change recorded]
    BB --> CC[Email notification sent]
    CC --> DD[Admin activity logged]
```

#### User Management & Support
```mermaid
flowchart TD
    A[Admin needs user management] --> B[Users section]
    B --> C[User search & filtering]
    C --> D[Search by name/email/phone]
    D --> E[Filter by user type/role]
    E --> F[Filter by status/region]
    F --> G[User list display]

    G --> H[Select user for action]
    H --> I{What action?}
    I -->|View Profile| J[User profile view]
    I -->|Edit Details| K[User edit form]
    I -->|Change Status| L[Status update]
    I -->|Reset Password| M[Password reset]
    I -->|View Activity| N[User activity log]

    J --> O[Complete user information]
    O --> P[Account details]
    P --> Q[Policy information]
    Q --> R[Activity history]
    R --> S[Support tickets]

    K --> T[Edit user information]
    T --> U[Update personal details]
    U --> V[Change contact information]
    V --> W[Modify preferences]

    L --> X[Status change options]
    X --> Y{New status}
    Y -->|Active| Z[Activate user]
    Y -->|Suspended| AA[Suspend with reason]
    Y -->|Deactivated| BB[Deactivate account]

    M --> CC[Generate reset token]
    CC --> DD[Send reset email/SMS]
    DD --> EE[Log password reset]

    N --> FF[Activity timeline]
    FF --> GG[Login history]
    GG --> HH[Feature usage]
    HH --> II[Payment history]

    Z --> JJ[Status update in DB]
    AA --> JJ
    BB --> JJ
    EE --> JJ
    W --> JJ

    JJ --> KK[Send notification to user]
    KK --> LL[Audit log entry]
    LL --> MM[Admin action recorded]
```

## 4. Error Handling & Recovery Journeys

### 4.1 Network Error Recovery

#### Offline Mode Handling
```mermaid
flowchart TD
    A[Network request fails] --> B[Detect network status]
    B --> C{Internet available?}
    C -->|No| D[Enter offline mode]
    C -->|Yes| E[Check server status]

    D --> F[Show offline indicator]
    F --> G[Load cached data]
    G --> H[Disable online features]
    H --> I[Enable offline capabilities]
    I --> J[Queue actions for later]
    J --> K[Show offline message]

    E --> L{Server responding?}
    L -->|No| M[Server outage detected]
    L -->|Yes| N[Check specific error]

    M --> O[Show maintenance message]
    O --> P[Retry connection periodically]
    P --> Q{Connection restored?}
    Q -->|No| P
    Q -->|Yes| R[Resume normal operation]

    N --> S{HTTP status code}
    S -->|4xx| T[Client error handling]
    S -->|5xx| U[Server error handling]
    S -->|Timeout| V[Timeout handling]

    T --> W[Show user-friendly message]
    W --> X[Provide corrective action]
    X --> Y[Suggest retry or contact support]

    U --> Z[Log error for monitoring]
    Z --> AA[Show generic error message]
    AA --> BB[Auto-retry for transient errors]
    BB --> CC{Success?}
    CC -->|No| DD[Show retry options]
    CC -->|Yes| EE[Continue normal flow]

    V --> FF[Implement exponential backoff]
    FF --> GG[Show loading with timeout warning]
    GG --> HH{User waits or cancels?}
    HH -->|Waits| II[Continue retry logic]
    HH -->|Cancels| JJ[Cancel operation gracefully]

    K --> LL[Periodic connectivity checks]
    LL --> MM{Connection restored?}
    MM -->|No| LL
    MM -->|Yes| NN[Sync queued actions]
    NN --> OO[Resume full functionality]
```

### 4.2 Payment Failure Recovery

#### Payment Error Handling
```mermaid
flowchart TD
    A[Payment fails] --> B[Identify failure reason]
    B --> C{Failure type}
    C -->|Network| D[Network error handling]
    C -->|Card| E[Card error handling]
    C -->|Bank| F[Bank error handling]
    C -->|Gateway| G[Gateway error handling]

    D --> H[Check internet connection]
    H --> I{Connected?}
    I -->|No| J[Show offline payment option]
    I -->|Yes| K[Retry payment automatically]

    E --> L[Card validation errors]
    L --> M{Error type}
    M -->|Invalid card| N[Show card format help]
    M -->|Insufficient funds| O[Show balance check option]
    M -->|Expired card| P[Show card update flow]
    M -->|Blocked card| Q[Show contact bank CTA]

    F --> R[Bank-specific errors]
    R --> S{Bank response}
    S -->|Invalid credentials| T[Show re-enter credentials]
    S -->|Account locked| U[Show unlock account steps]
    S -->|Transaction limit| V[Show limit increase options]

    G --> W[Payment gateway errors]
    W --> X{Gateway status}
    X -->|Under maintenance| Y[Show maintenance message]
    X -->|Rate limited| Z[Implement backoff retry]
    X -->|Configuration error| AA[Log for admin review]

    K --> BB{Retry successful?}
    BB -->|Yes| CC[Complete payment]
    BB -->|No| DD[Show retry options]

    N --> EE[User corrects card details]
    O --> FF[User checks balance]
    P --> GG[User updates card]
    Q --> HH[User contacts bank]

    T --> II[User re-enters details]
    U --> JJ[User follows unlock steps]
    V --> KK[User increases limits]

    Y --> LL[Show estimated resolution time]
    Z --> MM[Automatic retry with backoff]
    AA --> NN[Show generic error, log details]

    EE --> OO[Retry payment]
    FF --> OO
    GG --> OO
    HH --> OO
    II --> OO
    JJ --> OO
    KK --> OO
    MM --> OO

    OO --> PP{Second attempt successful?}
    PP -->|Yes| CC
    PP -->|No| QQ[Show alternative payment methods]

    CC --> RR[Send success confirmation]
    RR --> SS[Update payment status]
    SS --> TT[Notify relevant parties]

    QQ --> UU[User selects alternative method]
    UU --> VV[Restart payment flow]
    VV --> WW[Complete with new method]

    DD --> XX[User chooses retry timing]
    XX --> YY{Auto-retry or manual?}
    YY -->|Auto| ZZ[Schedule automatic retry]
    YY -->|Manual| AAA[Show manual retry button]

    ZZ --> BBB[Wait for scheduled retry]
    BBB --> CCC{Check payment status}
    CCC -->|Success| CC
    CCC -->|Failed| DDD[Show final failure message]

    AAA --> EEE[User clicks retry manually]
    EEE --> OO
```

## 5. Cross-Platform User Experience

### 5.1 Responsive Design Journey

#### Device Adaptation Flow
```mermaid
flowchart TD
    A[User opens app on device] --> B[Device detection]
    B --> C{Device type}
    C -->|Mobile Phone| D[Mobile layout]
    C -->|Tablet| E[Tablet layout]
    C -->|Web Browser| F[Web responsive layout]

    D --> G[Screen size detection]
    E --> G
    F --> G

    G --> H{Screen size}
    H -->|Small (<600px)| I[Single column layout]
    H -->|Medium (600-1200px)| J[Two column layout]
    H -->|Large (>1200px)| K[Multi-column layout]

    I --> L[Bottom navigation tabs]
    I --> M[Simple card layouts]
    I --> N[Touch-optimized buttons]

    J --> O[Side navigation drawer]
    J --> P[Grid card layouts]
    J --> Q[Medium-sized buttons]

    K --> R[Persistent sidebar]
    K --> S[Advanced grid layouts]
    K --> T[Desktop-style buttons]

    L --> U[Content adaptation]
    O --> U
    R --> U

    U --> V[Text size adjustment]
    V --> W[Image optimization]
    W --> X[Feature prioritization]

    X --> Y[Essential features always visible]
    Y --> Z[Secondary features in menus/drawers]
    Z --> AA[Advanced features contextually hidden]

    AA --> BB[User interaction monitoring]
    BB --> CC[Adapt UI based on usage patterns]
    CC --> DD[Personalized experience]
```

### 5.2 Multi-Language Experience Journey

#### Language Switching Flow
```mermaid
flowchart TD
    A[User wants to change language] --> B[Access settings]
    B --> C[Language preferences section]
    C --> D[Current language display]
    D --> E[Available languages list]
    E --> F[English 🇺🇸]
    E --> G[Hindi हिन्दी 🇮🇳]
    E --> H[Telugu తెలుగు 🇮🇳]

    F --> I[Select English]
    G --> I
    H --> I

    I --> J[Language change confirmation]
    J --> K{Confirm change?}
    K -->|Yes| L[Apply language change]
    K -->|No| M[Cancel change]

    L --> N[CDN localization loading]
    N --> O{Localization available?}
    O -->|Yes| P[Load from CDN]
    O -->|No| Q[Load from cache]
    Q --> R{Fallback available?}
    R -->|No| S[Load from bundled files]

    P --> T[Update app strings]
    Q --> T
    S --> T

    T --> U[UI refresh with new language]
    U --> V[Persist language preference]
    V --> W[Update user profile]
    W --> X[Sync across devices]

    X --> Y[Show success message]
    Y --> Z[Continue app usage in new language]

    M --> AA[Return to settings]
    AA --> C
```

This comprehensive user journey documentation provides detailed flow diagrams for all major user interactions within the Agent Mitra platform, ensuring intuitive and efficient user experiences across different personas and use cases.
