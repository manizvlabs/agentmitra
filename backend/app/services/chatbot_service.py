"""
Chatbot service with OpenAI integration for customer support
"""
import openai
import json
import uuid
from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session

from app.core.config.settings import settings
from app.repositories.analytics_repository import AnalyticsRepository
from app.models.analytics import (
    ChatbotSession,
    ChatMessage,
    KnowledgeBaseArticle,
    ChatbotIntent
)


class ChatbotService:
    """Service for OpenAI-powered chatbot functionality"""

    def __init__(self, db: Session):
        self.db = db
        self.analytics_repo = AnalyticsRepository(db)

        # Initialize OpenAI client
        self.openai_client = openai.OpenAI(api_key=settings.openai_api_key)

        # System prompt for insurance agent chatbot
        self.system_prompt = """
        You are an AI assistant for AgentMitra, an insurance agency management platform.
        You help users with insurance-related queries, policy information, claims, and general support.

        Key capabilities:
        - Answer questions about insurance policies, coverage, and claims
        - Provide information about different types of insurance (life, health, general)
        - Help with policy-related processes and documentation
        - Guide users through common insurance workflows
        - Escalate complex issues to human agents when needed

        Guidelines:
        - Be helpful, professional, and empathetic
        - Use simple language and avoid jargon
        - If you're unsure about something, admit it and suggest contacting a human agent
        - Always prioritize user safety and data privacy
        - Provide accurate information based on general insurance knowledge
        - Do not give financial or legal advice

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

            # Generate response using OpenAI
            response_content = await self._generate_response(
                message=message,
                intent=intent_analysis,
                knowledge=knowledge_results,
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
                "knowledge_used": len(knowledge_results) > 0
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

        # In a real implementation, this would query a vector database or full-text search
        # For now, return mock results
        return [
            {
                "article_id": "kb_001",
                "title": "Life Insurance Policy Basics",
                "content": "Life insurance provides financial protection...",
                "relevance_score": 0.85
            }
        ]

    async def _generate_response(
        self,
        message: str,
        intent: Dict[str, Any],
        knowledge: List[Dict[str, Any]],
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

        # Build conversation context
        context_info = ""
        if context:
            context_info = f"\n\nUser context: {json.dumps(context)}"

        prompt = f"""
        User message: "{message}"
        Detected intent: {intent.get('intent', 'unknown')}
        Confidence: {intent.get('confidence', 0)}{knowledge_context}{context_info}

        Generate a helpful, professional response for an insurance chatbot.
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

        except Exception as e:
            # Log the error for debugging
            print(f"OpenAI API Error in _generate_response: {e}")
            # Fallback response
            return "I understand you're asking about insurance. Could you please provide more details so I can assist you better?"

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
        """Search knowledge base articles"""

        # In a real implementation, perform semantic search on vectorized content
        # For now, return mock results
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
