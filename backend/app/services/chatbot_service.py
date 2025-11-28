"""
Advanced Chatbot Service with AI Intent Recognition
===================================================

Enhanced chatbot service with:
- Advanced intent recognition and classification
- Context-aware conversations
- Knowledge base integration
- Sentiment analysis
- Proactive suggestions
- Multi-language support
- Escalation intelligence
- Analytics and performance tracking
"""

import openai
import json
import uuid
import re
from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any, Tuple
from sqlalchemy.orm import Session
from enum import Enum

from app.core.config.settings import settings
from app.repositories.analytics_repository import AnalyticsRepository
from app.models.analytics import (
    ChatbotSession,
    ChatMessage,
    KnowledgeBaseArticle,
    ChatbotIntent
)
from app.services.video_tutorial_service import VideoTutorialService
from app.services.actionable_report_service import ActionableReportService
from app.core.monitoring import monitoring
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class IntentType(Enum):
    """Chatbot intent types"""
    POLICY_INQUIRY = "policy_inquiry"
    CLAIM_STATUS = "claim_status"
    PREMIUM_PAYMENT = "premium_payment"
    POLICY_PURCHASE = "policy_purchase"
    DOCUMENT_REQUEST = "document_request"
    COMPLAINT = "complaint"
    GENERAL_INFO = "general_info"
    ESCALATION_REQUEST = "escalation_request"
    GREETING = "greeting"
    FAREWELL = "farewell"
    UNKNOWN = "unknown"


class SentimentType(Enum):
    """Message sentiment types"""
    POSITIVE = "positive"
    NEGATIVE = "negative"
    NEUTRAL = "neutral"
    FRUSTRATED = "frustrated"


class ChatbotService:
    """Advanced AI-powered chatbot service with intent recognition"""

    def __init__(self, db: Session):
        self.db = db
        self.analytics_repo = AnalyticsRepository(db)
        self.video_service = VideoTutorialService(db)
        self.actionable_report_service = ActionableReportService(db)

        # Initialize OpenAI client
        self.openai_client = openai.OpenAI(api_key=settings.openai_api_key)

        # Enhanced system prompt for advanced chatbot
        self.system_prompt = """
        You are an advanced AI assistant for AgentMitra, an insurance agency management platform.
        You provide intelligent, context-aware support for insurance-related queries and processes.

        Advanced Capabilities:
        - Intent recognition and classification
        - Context-aware conversation management
        - Knowledge base integration for accurate responses
        - Sentiment analysis for appropriate responses
        - Proactive suggestions and next steps
        - Intelligent escalation to human agents
        - Multi-language support (Hindi, English, Telugu)
        - Policy-specific guidance and documentation

        Core Functions:
        - Answer questions about insurance policies, coverage, and claims
        - Provide policy status and premium payment information
        - Guide through policy purchase and renewal processes
        - Assist with claim filing and status tracking
        - Help with document requests and policy changes
        - Handle complaints and feedback appropriately

        Guidelines:
        - Be helpful, professional, and empathetic
        - Use simple language and avoid insurance jargon
        - Provide accurate information based on verified knowledge
        - Recognize user frustration and respond appropriately
        - Offer proactive solutions and next steps
        - Escalate complex issues to human agents when needed
        - Always prioritize user safety and data privacy
        - Do not give financial or legal advice
        - Maintain conversation context and continuity

        Response format:
        - Keep responses concise but comprehensive
        - Use bullet points for lists or steps
        - Ask clarifying questions when needed
        - End with offers for further assistance
        """

    async def create_session(self, user_id: Optional[str] = None, device_info: Optional[Dict] = None) -> ChatbotSession:
        """Create a new chatbot session"""

        session_id = str(uuid.uuid4())
        conversation_id = f"conv_{session_id}"

        # Create session record (would be saved to database)
        session = ChatbotSession(
            session_id=session_id,
            user_id=user_id,
            conversation_id=conversation_id,
            started_at=datetime.now(),
            message_count=0,
            device_info=device_info
        )

        # In a real implementation, save to database
        # self._save_session(session)

        return session

    async def process_message(
        self,
        session_id: str,
        message: str,
        user_id: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Process a user message and generate AI response"""

        start_time = datetime.now()

        try:
            # Detect intent and entities (simplified)
            intent_analysis = await self._analyze_intent(message)

            # Search knowledge base for relevant information
            knowledge_results = await self._search_knowledge_base(message)

            # Get video recommendations based on intent
            video_recommendations = await self.video_service.get_recommended_videos(
                user_id=user_id,
                intent_query=intent_analysis.get("intent", ""),
                context=context,
                limit=3
            )

            # Generate response using OpenAI
            response_content = await self._generate_response(
                message=message,
                intent=intent_analysis,
                knowledge=knowledge_results,
                video_recommendations=video_recommendations,
                context=context
            )

            # Calculate response time
            response_time = (datetime.now() - start_time).total_seconds() * 1000

            # Create message record
            user_message = ChatMessage(
                message_id=str(uuid.uuid4()),
                session_id=session_id,
                user_id=user_id,
                content=message,
                is_from_user=True,
                intent_detected=intent_analysis.get("intent"),
                confidence_score=intent_analysis.get("confidence"),
                entities_detected=intent_analysis.get("entities"),
                timestamp=datetime.now()
            )

            bot_message = ChatMessage(
                message_id=str(uuid.uuid4()),
                session_id=session_id,
                content=response_content,
                is_from_user=False,
                response_generated=response_content,
                response_time_ms=int(response_time),
                timestamp=datetime.now()
            )

            # In a real implementation, save messages to database
            # self._save_message(user_message)
            # self._save_message(bot_message)

            # Update session
            # self._update_session_message_count(session_id)

            return {
                "response": response_content,
                "session_id": session_id,
                "intent": intent_analysis.get("intent"),
                "confidence": intent_analysis.get("confidence"),
                "response_time_ms": int(response_time),
                "suggested_actions": intent_analysis.get("suggested_actions", []),
                "knowledge_used": len(knowledge_results) > 0,
                "video_recommendations": video_recommendations[:3] if video_recommendations else []
            }

        except Exception as e:
            # Fallback response for errors
            return {
                "response": "I apologize, but I'm having trouble processing your message right now. Please try again or contact our support team for assistance.",
                "session_id": session_id,
                "error": str(e),
                "response_time_ms": int((datetime.now() - start_time).total_seconds() * 1000)
            }

    async def _analyze_intent(self, message: str) -> Dict[str, Any]:
        """Analyze user intent using OpenAI"""

        try:
            prompt = f"""
            Analyze the following user message and determine:
            1. Primary intent (one word)
            2. Confidence score (0-1)
            3. Key entities mentioned
            4. Suggested actions

            Message: "{message}"

            Common insurance intents: policy_inquiry, claim_help, premium_payment, coverage_question,
            document_request, complaint, general_info, agent_contact, quote_request

            Return as JSON with keys: intent, confidence, entities, suggested_actions
            """

            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are an intent analysis expert for insurance chatbots. Return only valid JSON."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=200,
                temperature=0.3
            )

            result = json.loads(response.choices[0].message.content)

            return {
                "intent": result.get("intent", "general_inquiry"),
                "confidence": result.get("confidence", 0.5),
                "entities": result.get("entities", {}),
                "suggested_actions": result.get("suggested_actions", [])
            }

        except Exception as e:
            # Log the error for debugging
            print(f"OpenAI API Error in _analyze_intent: {e}")
            # Fallback intent analysis
            return {
                "intent": "general_inquiry",
                "confidence": 0.5,
                "entities": {},
                "suggested_actions": ["escalate_to_agent"]
            }

    async def _search_knowledge_base(self, query: str) -> List[Dict[str, Any]]:
        """Search knowledge base for relevant articles"""

        try:
            # Query knowledge base articles from database
            # This assumes knowledge_base_articles table exists
            result = self.db.execute("""
                SELECT id, title, content, category
                FROM knowledge_base_articles
                WHERE
                    title ILIKE :query OR
                    content ILIKE :query OR
                    category ILIKE :query
                ORDER BY
                    CASE
                        WHEN title ILIKE :query THEN 1
                        WHEN content ILIKE :query THEN 2
                        ELSE 3
                    END,
                    LENGTH(content) DESC
                LIMIT 5
            """, {"query": f"%{query}%"})

            articles = []
            for row in result:
                articles.append({
                    "article_id": str(row.id),
                    "title": row.title,
                    "content": row.content[:200] + "..." if len(row.content) > 200 else row.content,
                    "category": row.category,
                    "relevance_score": 0.8  # Simplified scoring
                })

            return articles

        except Exception as e:
            # If knowledge base table doesn't exist yet, return empty results
            logger.warning(f"Knowledge base search failed: {e}")
            return []

    async def _generate_response(
        self,
        message: str,
        intent: Dict[str, Any],
        knowledge: List[Dict[str, Any]],
        video_recommendations: List[Dict[str, Any]] = None,
        context: Optional[Dict[str, Any]] = None
    ) -> str:
        """Generate AI response using OpenAI"""

        # Build context from knowledge base
        knowledge_context = ""
        if knowledge:
            knowledge_context = "\n\nRelevant knowledge:\n" + "\n".join([
                f"- {item['title']}: {item['content'][:200]}..."
                for item in knowledge[:2]  # Limit to top 2 results
            ])

        # Build video recommendations context
        video_context = ""
        if video_recommendations:
            video_context = "\n\nRecommended videos:\n" + "\n".join([
                f"- {video['title']} ({video['duration_seconds'] // 60}:{video['duration_seconds'] % 60:02d}min) - {video['agent_name']}"
                for video in video_recommendations[:2]  # Limit to top 2 recommendations
            ])

        # Build conversation context
        context_info = ""
        if context:
            context_info = f"\n\nUser context: {json.dumps(context)}"

        # Determine if we should include video recommendations in response
        include_videos = bool(video_recommendations and intent.get('confidence', 0) > 0.6)

        prompt = f"""
        User message: "{message}"
        Detected intent: {intent.get('intent', 'unknown')}
        Confidence: {intent.get('confidence', 0)}{knowledge_context}{video_context}{context_info}

        Generate a helpful, professional response for an insurance chatbot.
        {'Include relevant video tutorial recommendations in your response when appropriate.' if include_videos else ''}
        Keep it concise but comprehensive.
        """

        try:
            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=500,
                temperature=0.7
            )

            return response.choices[0].message.content.strip()

        except openai.RateLimitError as e:
            # Handle quota exceeded / rate limit errors gracefully
            print(f"OpenAI Rate Limit Error: {e}")
            raise Exception("AI service quota exceeded. Please try again later or contact support.")
        except openai.APIError as e:
            # Handle other OpenAI API errors
            print(f"OpenAI API Error: {e}")
            raise Exception("AI service temporarily unavailable. Please try again later.")
        except Exception as e:
            # Handle any other errors
            print(f"Unexpected error in OpenAI API: {e}")
            raise Exception("Failed to generate AI response. Please try again later.")

    async def end_session(self, session_id: str, satisfaction_score: Optional[int] = None) -> bool:
        """End a chatbot session"""

        try:
            # In a real implementation, update session in database
            # session = self._get_session(session_id)
            # session.ended_at = datetime.now()
            # session.user_satisfaction_score = satisfaction_score
            # session.duration_seconds = (session.ended_at - session.started_at).total_seconds()
            # self._save_session(session)

            return True
        except Exception:
            return False

    async def get_session_analytics(self, session_id: str) -> Optional[Dict[str, Any]]:
        """Get analytics for a specific session"""

        try:
            # In a real implementation, query database for session analytics
            return {
                "session_id": session_id,
                "message_count": 0,
                "duration_seconds": 0,
                "average_response_time": 0.0,
                "resolution_status": "unknown"
            }
        except Exception:
            return None

    # Knowledge Base Management Methods

    async def add_knowledge_article(
        self,
        title: str,
        content: str,
        category: str,
        tags: List[str] = None
    ) -> KnowledgeBaseArticle:
        """Add a new article to the knowledge base"""

        article = KnowledgeBaseArticle(
            article_id=str(uuid.uuid4()),
            title=title,
            content=content,
            category=category,
            tags=tags or [],
            created_at=datetime.now(),
            updated_at=datetime.now()
        )

        # In a real implementation, save to database and vectorize for search
        # self._save_knowledge_article(article)
        # self._vectorize_article(article)

        return article

    async def update_knowledge_article(
        self,
        article_id: str,
        title: Optional[str] = None,
        content: Optional[str] = None,
        category: Optional[str] = None,
        tags: Optional[List[str]] = None
    ) -> Optional[KnowledgeBaseArticle]:
        """Update an existing knowledge base article"""

        # In a real implementation, update in database
        # article = self._get_knowledge_article(article_id)
        # if article:
        #     if title: article.title = title
        #     if content: article.content = content
        #     if category: article.category = category
        #     if tags: article.tags = tags
        #     article.updated_at = datetime.now()
        #     self._save_knowledge_article(article)
        #     self._vectorize_article(article)
        #     return article

        return None

    async def search_knowledge_base(self, query: str, limit: int = 5) -> List[KnowledgeBaseArticle]:
        """Search knowledge base articles using full-text search"""

        try:
            # Perform full-text search on title and content
            search_query = f"%{query.lower()}%"
            result = self.db.execute("""
                SELECT id, article_id, title, content, category, tags, language, difficulty_level,
                       target_audience, view_count, helpful_votes, created_at
                FROM knowledge_base_articles
                WHERE is_published = true
                  AND (LOWER(title) LIKE :query
                       OR LOWER(content) LIKE :query
                       OR LOWER(category) LIKE :query
                       OR EXISTS (SELECT 1 FROM jsonb_array_elements_text(tags) AS tag
                                WHERE LOWER(tag) LIKE :query))
                ORDER BY
                  CASE
                    WHEN LOWER(title) LIKE :query THEN 1
                    WHEN LOWER(content) LIKE :query THEN 2
                    WHEN LOWER(category) LIKE :query THEN 3
                    ELSE 4
                  END,
                  helpful_votes DESC,
                  view_count DESC
                LIMIT :limit
            """, {"query": search_query, "limit": limit})

            articles = []
            for row in result:
                article = KnowledgeBaseArticle(
                    article_id=row.article_id,
                    title=row.title,
                    content=row.content,
                    category=row.category,
                    tags=row.tags,
                    language=row.language,
                    difficulty_level=row.difficulty_level,
                    target_audience=row.target_audience,
                    view_count=row.view_count,
                    helpful_votes=row.helpful_votes,
                    created_at=row.created_at
                )
                articles.append(article)

            # Update view counts
            if articles:
                article_ids = [a.article_id for a in articles]
                self.db.execute("""
                    UPDATE knowledge_base_articles
                    SET view_count = view_count + 1
                    WHERE article_id = ANY(:article_ids)
                """, {"article_ids": article_ids})
                self.db.commit()

            return articles

        except Exception as e:
            logger.error(f"Knowledge base search failed: {e}")
            return []

    # Intent Management Methods

    async def add_intent(
        self,
        intent_name: str,
        description: str,
        training_examples: List[str],
        response_templates: List[str]
    ) -> ChatbotIntent:
        """Add a new intent for the chatbot"""

        intent = ChatbotIntent(
            intent_name=intent_name,
            description=description,
            training_examples=training_examples,
            response_templates=response_templates
        )

        # In a real implementation, save to database and retrain model
        return intent

    async def get_intent_stats(self) -> List[Dict[str, Any]]:
        """Get statistics about intent usage"""

        # In a real implementation, query database for intent analytics
        return [
            {"intent": "policy_inquiry", "usage_count": 150, "success_rate": 0.85},
            {"intent": "claim_help", "usage_count": 89, "success_rate": 0.92},
            {"intent": "premium_payment", "usage_count": 67, "success_rate": 0.78}
        ]


    # =====================================================
    # ADVANCED AI INTENT RECOGNITION METHODS
    # =====================================================

    async def analyze_intent(self, message: str, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Advanced intent recognition with AI analysis"""

        try:
            # Use OpenAI for intent classification
            intent_prompt = f"""
            Analyze the following user message and classify the intent.
            Consider the context: {json.dumps(context) if context else 'No context'}

            Message: "{message}"

            Classify into one of these intents:
            - policy_inquiry: Questions about existing policies
            - claim_status: Checking claim status or filing claims
            - premium_payment: Payment-related queries
            - policy_purchase: Buying new insurance
            - document_request: Requesting documents or certificates
            - complaint: Expressing dissatisfaction or issues
            - general_info: General insurance information
            - escalation_request: Wants to speak to human agent
            - greeting: Hello, hi, etc.
            - farewell: Goodbye, bye, etc.
            - unknown: Cannot classify

            Also analyze:
            - Sentiment (positive, negative, neutral, frustrated)
            - Urgency level (low, medium, high)
            - Key entities mentioned (policy numbers, dates, amounts)

            Return as JSON with keys: intent, confidence, sentiment, urgency, entities
            """

            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are an expert intent classifier for insurance chatbot. Return only valid JSON."},
                    {"role": "user", "content": intent_prompt}
                ],
                max_tokens=300,
                temperature=0.1
            )

            result = json.loads(response.choices[0].message.content.strip())

            # Enhance with additional analysis
            result.update({
                "language": self._detect_language(message),
                "requires_escalation": self._check_escalation_needed(result, message),
                "suggested_actions": self._get_suggested_actions(result),
                "confidence_score": result.get("confidence", 0.8)
            })

            return result

        except Exception as e:
            logger.error(f"Intent analysis failed: {e}")
            return {
                "intent": "unknown",
                "confidence": 0.0,
                "sentiment": "neutral",
                "urgency": "low",
                "entities": [],
                "language": "en",
                "requires_escalation": False,
                "suggested_actions": []
            }

    async def generate_ai_response(
        self,
        intent_analysis: Dict[str, Any],
        message: str,
        session_context: Optional[Dict[str, Any]] = None,
        user_profile: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Generate intelligent AI response based on intent analysis"""

        try:
            intent = intent_analysis.get("intent", "unknown")
            sentiment = intent_analysis.get("sentiment", "neutral")
            urgency = intent_analysis.get("urgency", "low")
            language = intent_analysis.get("language", "en")

            # Build context-aware prompt
            context_info = ""
            if session_context:
                context_info += f"Conversation history: {json.dumps(session_context.get('recent_messages', []))}\n"
            if user_profile:
                context_info += f"User profile: {json.dumps(user_profile)}\n"

            response_prompt = f"""
            Generate an intelligent response for an insurance chatbot.

            Context:
            {context_info}

            User Message: "{message}"
            Detected Intent: {intent}
            Sentiment: {sentiment}
            Urgency: {urgency}
            Language: {language}

            Guidelines for response:
            - Address the user's intent directly and helpfully
            - Match the sentiment (be empathetic for negative/frustrated users)
            - Provide specific, actionable information
            - Use appropriate language for the user's language preference
            - Offer next steps or proactive suggestions
            - If needed, suggest escalation to human agent
            - Keep response concise but comprehensive
            - Include relevant policy information or processes

            Response should include:
            - Main answer/solution
            - Any additional helpful information
            - Next steps or suggestions
            - Contact information if escalation needed
            """

            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": response_prompt}
                ],
                max_tokens=500,
                temperature=0.7
            )

            ai_response = response.choices[0].message.content.strip()

            # Analyze response quality
            response_quality = await self._analyze_response_quality(ai_response, intent_analysis)

            return {
                "response": ai_response,
                "quality_score": response_quality.get("score", 0.8),
                "requires_follow_up": response_quality.get("requires_follow_up", False),
                "suggested_actions": intent_analysis.get("suggested_actions", []),
                "language": language,
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"AI response generation failed: {e}")
            return {
                "response": "I apologize, but I'm having trouble processing your request right now. Please try again or contact our support team.",
                "quality_score": 0.0,
                "requires_follow_up": True,
                "suggested_actions": ["escalate_to_agent"],
                "language": "en",
                "generated_at": datetime.utcnow().isoformat()
            }

    async def get_proactive_suggestions(
        self,
        user_id: str,
        session_context: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """Generate proactive suggestions based on user behavior and context"""

        try:
            suggestions = []

            # Analyze user history and context for suggestions
            if session_context:
                recent_intents = session_context.get("recent_intents", [])

                # Policy renewal suggestions
                if "policy_inquiry" in recent_intents:
                    suggestions.append({
                        "type": "policy_renewal",
                        "title": "Policy Renewal Reminder",
                        "message": "Don't forget to renew your policy before it expires",
                        "action": "view_policies",
                        "priority": "medium"
                    })

                # Payment reminders
                if "premium_payment" in recent_intents:
                    suggestions.append({
                        "type": "payment_reminder",
                        "title": "Payment Due Soon",
                        "message": "Your next premium payment is coming up",
                        "action": "view_payments",
                        "priority": "high"
                    })

                # Claim assistance
                if any(intent in ["complaint", "claim_status"] for intent in recent_intents):
                    suggestions.append({
                        "type": "claim_assistance",
                        "title": "Need Help with Claims?",
                        "message": "I can guide you through the claims process",
                        "action": "start_claim",
                        "priority": "medium"
                    })

            # Default suggestions
            if not suggestions:
                suggestions = [
                    {
                        "type": "general_help",
                        "title": "How can I help you?",
                        "message": "Ask me about policies, claims, or payments",
                        "action": "show_options",
                        "priority": "low"
                    }
                ]

            return suggestions

        except Exception as e:
            logger.error(f"Proactive suggestions failed: {e}")
            return []

    async def handle_escalation(
        self,
        session_id: str,
        reason: str,
        user_context: Dict[str, Any],
        conversation_context: Optional[Dict[str, Any]] = None,
        intent_analysis: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Handle intelligent escalation to human agents with actionable reports"""

        try:
            # Get customer and agent information
            customer_id = user_context.get("customer_id", user_context.get("user_id"))
            agent_id = user_context.get("agent_id")

            if not customer_id or not agent_id:
                # Fallback to basic callback creation
                from app.services.callback_service import CallbackService
                callback_service = CallbackService(self.db)

                callback = await callback_service.create_callback(
                    customer_name=user_context.get("name", "Chatbot User"),
                    customer_phone=user_context.get("phone", ""),
                    subject=f"Chatbot Escalation: {reason}",
                    description=f"User escalated from chatbot. Reason: {reason}",
                    category="chatbot_escalation",
                    source="chatbot",
                    metadata={
                        "session_id": session_id,
                        "escalation_reason": reason,
                        "chatbot_context": user_context
                    }
                )

                response = "Thank you for using Agent Mitra! Your request has been forwarded to your agent. They will call you back within 2 hours during business hours."

                return {
                    "escalation_created": True,
                    "callback_id": callback.callback_id,
                    "response": response,
                    "priority": callback.priority.value,
                    "expected_response_time": f"{callback.sla_target_minutes or 120} minutes"
                }

            # Create comprehensive actionable report
            current_query = conversation_context.get("current_message", "") if conversation_context else reason
            complexity_score = intent_analysis.get("confidence", 0.5) if intent_analysis else 0.5

            # Prepare conversation context for the report
            conversation_data = {
                "messages": conversation_context.get("messages", []) if conversation_context else [],
                "session_id": session_id,
                "total_messages": conversation_context.get("total_messages", 0) if conversation_context else 0
            }

            report_result = await self.actionable_report_service.create_actionable_report(
                customer_id=customer_id,
                agent_id=agent_id,
                conversation_context=conversation_data,
                current_query=current_query,
                intent_analysis=intent_analysis or {"intent": "escalation_request", "confidence": 0.8},
                complexity_score=complexity_score,
                source="chatbot"
            )

            # Generate appropriate response based on priority
            priority = report_result.get("priority", "medium")
            sla_minutes = report_result.get("sla_target_minutes", 120)
            next_steps = report_result.get("next_steps", "An agent will contact you shortly.")

            response = f"Thank you for using Agent Mitra! {next_steps}"

            return {
                "escalation_created": True,
                "callback_id": report_result.get("callback_id"),
                "response": response,
                "priority": priority,
                "expected_response_time": report_result.get("estimated_response_time", "2 hours"),
                "actionable_report_created": True,
                "report_summary": report_result.get("report_summary", {})
            }

        except Exception as e:
            logger.error(f"Escalation handling failed: {e}")
            return {
                "escalation_created": False,
                "response": "I'm having trouble escalating your request. Please call our customer service directly.",
                "error": str(e)
            }

    async def analyze_conversation_quality(
        self,
        session_id: str,
        messages: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Analyze conversation quality and user satisfaction"""

        try:
            # Analyze message patterns
            total_messages = len(messages)
            user_messages = [m for m in messages if m.get("sender") == "user"]
            bot_messages = [m for m in messages if m.get("sender") == "bot"]

            # Calculate metrics
            avg_response_time = self._calculate_avg_response_time(messages)
            resolution_indicators = self._check_resolution_indicators(messages)
            sentiment_trend = self._analyze_sentiment_trend(user_messages)

            quality_score = self._calculate_quality_score(
                avg_response_time,
                resolution_indicators,
                sentiment_trend,
                total_messages
            )

            return {
                "session_id": session_id,
                "quality_score": quality_score,
                "metrics": {
                    "total_messages": total_messages,
                    "avg_response_time_seconds": avg_response_time,
                    "resolution_indicators": resolution_indicators,
                    "sentiment_trend": sentiment_trend,
                    "user_satisfaction_estimate": self._estimate_satisfaction(sentiment_trend)
                },
                "recommendations": self._generate_quality_recommendations(quality_score)
            }

        except Exception as e:
            logger.error(f"Conversation quality analysis failed: {e}")
            return {"error": "Failed to analyze conversation quality"}

    # Private helper methods

    def _detect_language(self, message: str) -> str:
        """Detect message language"""
        # Simple language detection - in production, use a proper NLP library
        hindi_chars = re.findall(r'[\u0900-\u097F]', message)
        telugu_chars = re.findall(r'[\u0C00-\u0C7F]', message)

        if len(hindi_chars) > len(message) * 0.1:
            return "hi"
        elif len(telugu_chars) > len(message) * 0.1:
            return "te"
        else:
            return "en"

    def _check_escalation_needed(self, intent_analysis: Dict[str, Any], message: str) -> bool:
        """Check if message requires escalation"""
        intent = intent_analysis.get("intent")
        sentiment = intent_analysis.get("sentiment")
        urgency = intent_analysis.get("urgency")

        # Escalation triggers
        escalation_triggers = [
            intent in ["complaint", "escalation_request"],
            sentiment == "frustrated",
            urgency == "high",
            "speak to human" in message.lower(),
            "talk to agent" in message.lower(),
            "supervisor" in message.lower()
        ]

        return any(escalation_triggers)

    def _get_suggested_actions(self, intent_analysis: Dict[str, Any]) -> List[str]:
        """Get suggested actions based on intent"""
        intent = intent_analysis.get("intent", "unknown")

        action_map = {
            "policy_inquiry": ["view_policy", "download_documents", "update_policy"],
            "claim_status": ["check_claim_status", "upload_documents", "contact_agent"],
            "premium_payment": ["view_payment_history", "make_payment", "setup_auto_pay"],
            "policy_purchase": ["compare_plans", "start_application", "contact_agent"],
            "complaint": ["file_complaint", "contact_supervisor", "request_callback"]
        }

        return action_map.get(intent, ["contact_support"])

    async def _analyze_response_quality(self, response: str, intent_analysis: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze quality of generated response"""
        try:
            intent = intent_analysis.get("intent")

            # Basic quality checks
            quality_score = 0.8  # Base score

            # Length appropriateness
            if 50 <= len(response) <= 500:
                quality_score += 0.1

            # Contains relevant keywords for intent
            intent_keywords = {
                "policy_inquiry": ["policy", "coverage", "premium"],
                "claim_status": ["claim", "status", "process"],
                "premium_payment": ["payment", "premium", "pay"]
            }

            keywords = intent_keywords.get(intent, [])
            if keywords and any(keyword in response.lower() for keyword in keywords):
                quality_score += 0.1

            # Has actionable content
            action_words = ["contact", "call", "visit", "download", "upload", "check"]
            if any(word in response.lower() for word in action_words):
                quality_score += 0.1

            return {
                "score": min(quality_score, 1.0),
                "requires_follow_up": quality_score < 0.6
            }

        except Exception:
            return {"score": 0.5, "requires_follow_up": True}

    def _calculate_avg_response_time(self, messages: List[Dict[str, Any]]) -> float:
        """Calculate average response time"""
        response_times = []

        for i in range(1, len(messages)):
            current = messages[i]
            previous = messages[i-1]

            if (current.get("sender") == "bot" and previous.get("sender") == "user"):
                current_time = datetime.fromisoformat(current.get("timestamp", ""))
                previous_time = datetime.fromisoformat(previous.get("timestamp", ""))
                response_times.append((current_time - previous_time).total_seconds())

        return sum(response_times) / len(response_times) if response_times else 0

    def _check_resolution_indicators(self, messages: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Check for resolution indicators in conversation"""
        last_messages = messages[-5:]  # Check last 5 messages

        resolution_keywords = ["solved", "resolved", "thank you", "that helps", "perfect"]
        confusion_keywords = ["confused", "don't understand", "not clear", "help"]

        has_resolution = any(
            any(keyword in msg.get("content", "").lower() for keyword in resolution_keywords)
            for msg in last_messages if msg.get("sender") == "user"
        )

        has_confusion = any(
            any(keyword in msg.get("content", "").lower() for keyword in confusion_keywords)
            for msg in last_messages if msg.get("sender") == "user"
        )

        return {
            "likely_resolved": has_resolution,
            "has_confusion": has_confusion,
            "needs_follow_up": has_confusion and not has_resolution
        }

    def _analyze_sentiment_trend(self, user_messages: List[Dict[str, Any]]) -> str:
        """Analyze sentiment trend in user messages"""
        if not user_messages:
            return "neutral"

        # Simple sentiment analysis - in production, use proper NLP
        positive_words = ["good", "great", "excellent", "thanks", "helpful", "perfect"]
        negative_words = ["bad", "terrible", "awful", "frustrated", "angry", "disappointed"]

        positive_count = 0
        negative_count = 0

        for msg in user_messages[-3:]:  # Check last 3 messages
            content = msg.get("content", "").lower()
            positive_count += sum(1 for word in positive_words if word in content)
            negative_count += sum(1 for word in negative_words if word in content)

        if positive_count > negative_count:
            return "improving"
        elif negative_count > positive_count:
            return "worsening"
        else:
            return "stable"

    def _calculate_quality_score(
        self,
        avg_response_time: float,
        resolution_indicators: Dict[str, Any],
        sentiment_trend: str,
        total_messages: int
    ) -> float:
        """Calculate overall conversation quality score"""
        score = 0.5  # Base score

        # Response time factor (faster is better)
        if avg_response_time < 30:
            score += 0.2
        elif avg_response_time < 60:
            score += 0.1

        # Resolution factor
        if resolution_indicators.get("likely_resolved"):
            score += 0.2
        if resolution_indicators.get("has_confusion"):
            score -= 0.1

        # Sentiment factor
        if sentiment_trend == "improving":
            score += 0.1
        elif sentiment_trend == "worsening":
            score -= 0.1

        # Conversation length factor
        if total_messages > 10:
            score += 0.1  # Longer conversations might indicate better engagement

        return max(0, min(1, score))

    def _estimate_satisfaction(self, sentiment_trend: str) -> str:
        """Estimate user satisfaction"""
        if sentiment_trend == "improving":
            return "satisfied"
        elif sentiment_trend == "worsening":
            return "dissatisfied"
        else:
            return "neutral"

    def _generate_quality_recommendations(self, quality_score: float) -> List[str]:
        """Generate recommendations based on quality score"""
        recommendations = []

        if quality_score < 0.6:
            recommendations.extend([
                "Improve response time",
                "Add more detailed answers",
                "Consider escalating complex queries"
            ])

        if quality_score < 0.8:
            recommendations.extend([
                "Include more proactive suggestions",
                "Better handle user frustration"
            ])

        if not recommendations:
            recommendations = ["Conversation quality is good"]

        return recommendations
