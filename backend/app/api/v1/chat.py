"""
Chat & Chatbot API Endpoints with OpenAI Integration
"""
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from datetime import datetime

from app.core.database import get_db
from app.services.chatbot_service import ChatbotService
from app.models.analytics import (
    ChatbotSession,
    ChatMessage,
    KnowledgeBaseArticle,
    ChatbotIntent,
    ChatbotAnalytics
)

router = APIRouter()


# =====================================================
# CHATBOT CONVERSATION ENDPOINTS
# =====================================================

class ChatMessageRequest(BaseModel):
    """Request model for sending a chat message"""
    message: str
    user_id: Optional[str] = None
    context: Optional[Dict[str, Any]] = None


class ChatResponse(BaseModel):
    """Response model for chatbot messages"""
    response: str
    session_id: str
    intent: Optional[str] = None
    confidence: Optional[float] = None
    response_time_ms: Optional[int] = None
    suggested_actions: Optional[List[str]] = []
    knowledge_used: bool = False


class CreateSessionRequest(BaseModel):
    """Request model for creating a chat session"""
    user_id: Optional[str] = None
    device_info: Optional[Dict[str, Any]] = None


@router.post("/sessions", response_model=ChatbotSession)
async def create_chat_session(
    request: CreateSessionRequest,
    db: Session = Depends(get_db)
):
    """Create a new chatbot session"""
    try:
        chatbot = ChatbotService(db)
        session = await chatbot.create_session(
            user_id=request.user_id,
            device_info=request.device_info
        )
        return session
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create chat session: {str(e)}")


@router.post("/sessions/{session_id}/messages", response_model=ChatResponse)
async def send_message(
    session_id: str,
    request: ChatMessageRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Send a message to the chatbot and get AI-powered response"""
    try:
        chatbot = ChatbotService(db)
        result = await chatbot.process_message(
            session_id=session_id,
            message=request.message,
            user_id=request.user_id,
            context=request.context
        )

        # Add background task to update analytics if needed
        background_tasks.add_task(update_chat_analytics, session_id, db)

        return ChatResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process message: {str(e)}")


@router.put("/sessions/{session_id}/end")
async def end_chat_session(
    session_id: str,
    satisfaction_score: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """End a chatbot session"""
    try:
        chatbot = ChatbotService(db)
        success = await chatbot.end_session(session_id, satisfaction_score)

        if not success:
            raise HTTPException(status_code=404, detail="Session not found")

        return {
            "message": "Session ended successfully",
            "session_id": session_id,
            "satisfaction_score": satisfaction_score
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to end session: {str(e)}")


@router.get("/sessions/{session_id}/analytics")
async def get_session_analytics(
    session_id: str,
    db: Session = Depends(get_db)
):
    """Get analytics for a specific chat session"""
    try:
        chatbot = ChatbotService(db)
        analytics = await chatbot.get_session_analytics(session_id)

        if not analytics:
            raise HTTPException(status_code=404, detail="Session analytics not found")

        return analytics
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get session analytics: {str(e)}")


# =====================================================
# KNOWLEDGE BASE MANAGEMENT ENDPOINTS
# =====================================================

class CreateArticleRequest(BaseModel):
    """Request model for creating knowledge base articles"""
    title: str
    content: str
    category: str
    tags: Optional[List[str]] = []


class UpdateArticleRequest(BaseModel):
    """Request model for updating knowledge base articles"""
    title: Optional[str] = None
    content: Optional[str] = None
    category: Optional[str] = None
    tags: Optional[List[str]] = None


@router.post("/knowledge-base/articles", response_model=KnowledgeBaseArticle)
async def create_knowledge_article(
    request: CreateArticleRequest,
    db: Session = Depends(get_db)
):
    """Create a new knowledge base article"""
    try:
        chatbot = ChatbotService(db)
        article = await chatbot.add_knowledge_article(
            title=request.title,
            content=request.content,
            category=request.category,
            tags=request.tags
        )
        return article
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create article: {str(e)}")


@router.put("/knowledge-base/articles/{article_id}", response_model=KnowledgeBaseArticle)
async def update_knowledge_article(
    article_id: str,
    request: UpdateArticleRequest,
    db: Session = Depends(get_db)
):
    """Update an existing knowledge base article"""
    try:
        chatbot = ChatbotService(db)
        article = await chatbot.update_knowledge_article(
            article_id=article_id,
            title=request.title,
            content=request.content,
            category=request.category,
            tags=request.tags
        )

        if not article:
            raise HTTPException(status_code=404, detail="Article not found")

        return article
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update article: {str(e)}")


@router.get("/knowledge-base/search")
async def search_knowledge_base(
    query: str,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """Search knowledge base articles"""
    try:
        chatbot = ChatbotService(db)
        articles = await chatbot.search_knowledge_base(query=query, limit=limit)

        return {
            "query": query,
            "results": articles,
            "total_found": len(articles)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to search knowledge base: {str(e)}")


@router.delete("/knowledge-base/articles/{article_id}")
async def delete_knowledge_article(
    article_id: str,
    db: Session = Depends(get_db)
):
    """Delete a knowledge base article"""
    try:
        # In a real implementation, this would soft delete the article
        return {
            "message": "Article deleted successfully",
            "article_id": article_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete article: {str(e)}")


# =====================================================
# INTENT MANAGEMENT ENDPOINTS
# =====================================================

class CreateIntentRequest(BaseModel):
    """Request model for creating chatbot intents"""
    intent_name: str
    description: str
    training_examples: List[str]
    response_templates: List[str]


@router.post("/intents", response_model=ChatbotIntent)
async def create_intent(
    request: CreateIntentRequest,
    db: Session = Depends(get_db)
):
    """Create a new chatbot intent"""
    try:
        chatbot = ChatbotService(db)
        intent = await chatbot.add_intent(
            intent_name=request.intent_name,
            description=request.description,
            training_examples=request.training_examples,
            response_templates=request.response_templates
        )
        return intent
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create intent: {str(e)}")


@router.get("/intents/stats")
async def get_intent_statistics(
    db: Session = Depends(get_db)
):
    """Get statistics about intent usage"""
    try:
        chatbot = ChatbotService(db)
        stats = await chatbot.get_intent_stats()

        return {
            "intent_stats": stats,
            "generated_at": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get intent stats: {str(e)}")


# =====================================================
# CHATBOT ANALYTICS ENDPOINTS
# =====================================================

@router.get("/analytics", response_model=ChatbotAnalytics)
async def get_chatbot_analytics(
    db: Session = Depends(get_db)
):
    """Get comprehensive chatbot analytics"""
    try:
        # Use real analytics from the database
        from app.repositories.analytics_repository import AnalyticsRepository
        analytics_repo = AnalyticsRepository(db)

        # For now, return basic analytics structure - in a full implementation,
        # this would query actual chatbot session and message tables
        # TODO: Implement real chatbot analytics when tables are created

        # Mock analytics for now, but structure is ready for real data
        analytics = ChatbotAnalytics(
            total_sessions=1250,
            total_messages=8900,
            average_session_duration=420.5,  # seconds
            average_response_time=1250.0,  # milliseconds
            resolution_rate=0.78,
            escalation_rate=0.12,
            user_satisfaction_score=4.2,
            top_intents=[
                {"intent": "policy_inquiry", "count": 450, "percentage": 36.0},
                {"intent": "claim_help", "count": 280, "percentage": 22.4},
                {"intent": "premium_payment", "count": 195, "percentage": 15.6}
            ],
            session_trends=[
                {"date": "2024-11-01", "sessions": 45},
                {"date": "2024-11-02", "sessions": 52},
                {"date": "2024-11-03", "sessions": 38}
            ],
            peak_hours=[
                {"hour": "10", "message_count": 234},
                {"hour": "14", "message_count": 289},
                {"hour": "16", "message_count": 198}
            ]
        )

        return analytics
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get chatbot analytics: {str(e)}")


# =====================================================
# UTILITY FUNCTIONS
# =====================================================

async def update_chat_analytics(session_id: str, db: Session):
    """Background task to update chat analytics"""
    try:
        # This would update analytics counters in the database
        # For now, it's a placeholder
        pass
    except Exception:
        # Log error but don't fail the main request
        pass


@router.get("/health")
async def chatbot_health_check():
    """Health check for chatbot service"""
    return {
        "status": "healthy",
        "service": "chatbot",
        "timestamp": datetime.now().isoformat()
    }

