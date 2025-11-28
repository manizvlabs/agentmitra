"""
External Services API Endpoints
================================

API endpoints for external service integrations:
- SMS service (Twilio)
- WhatsApp service
- AI service (OpenAI)
"""

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import get_current_user_context, UserContext
from app.services.sms_service import SMSService
from app.services.whatsapp_service import WhatsAppService
from app.services.ai_service import AIService
from app.core.logging_config import get_logger

router = APIRouter(prefix="/external", tags=["external-services"])
logger = get_logger(__name__)


# =====================================================
# SMS SERVICE ENDPOINTS
# =====================================================

class SMSRequest(BaseModel):
    to_phone: str
    message: str
    provider: Optional[str] = None
    message_type: str = "transactional"
    priority: str = "normal"


class OTPRequest(BaseModel):
    to_phone: str
    otp: str


@router.post("/sms/send")
async def send_sms(
    request: SMSRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Send SMS via configured provider"""
    try:
        sms_service = SMSService(db)
        result = await sms_service.send_sms(
            to_phone=request.to_phone,
            message=request.message,
            provider=request.provider,
            message_type=request.message_type,
            priority=request.priority
        )

        return {
            "success": True,
            "data": result,
            "message": "SMS sent successfully"
        }

    except Exception as e:
        logger.error(f"SMS send failed: {e}")
        raise HTTPException(status_code=500, detail=f"SMS send failed: {str(e)}")


@router.post("/sms/otp")
async def send_otp(
    request: OTPRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Send OTP via SMS"""
    try:
        sms_service = SMSService(db)
        result = await sms_service.send_otp(
            to_phone=request.to_phone,
            otp=request.otp
        )

        return {
            "success": True,
            "data": result,
            "message": "OTP sent successfully"
        }

    except Exception as e:
        logger.error(f"OTP send failed: {e}")
        raise HTTPException(status_code=500, detail=f"OTP send failed: {str(e)}")


@router.get("/sms/status/{message_id}")
async def get_sms_status(
    message_id: str,
    provider: str = "twilio",
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get SMS delivery status"""
    try:
        sms_service = SMSService(db)
        status = await sms_service.get_delivery_status(message_id, provider)

        return {
            "success": True,
            "data": status
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Status check failed: {str(e)}")


# =====================================================
# WHATSAPP SERVICE ENDPOINTS
# =====================================================

class WhatsAppMessageRequest(BaseModel):
    to_phone: str
    message_type: str
    content: Dict[str, Any]
    template_name: Optional[str] = None


class WhatsAppTemplateRequest(BaseModel):
    name: str
    category: str
    language: str
    content: str
    variables: List[str]


@router.post("/whatsapp/send")
async def send_whatsapp_message(
    request: WhatsAppMessageRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Send WhatsApp message"""
    try:
        whatsapp_service = WhatsAppService(db)
        result = await whatsapp_service.send_message(
            to_phone=request.to_phone,
            message_type=request.message_type,
            content=request.content,
            template_name=request.template_name
        )

        return {
            "success": True,
            "data": result,
            "message": "WhatsApp message sent successfully"
        }

    except Exception as e:
        logger.error(f"WhatsApp send failed: {e}")
        raise HTTPException(status_code=500, detail=f"WhatsApp send failed: {str(e)}")


@router.post("/whatsapp/otp")
async def send_whatsapp_otp(
    to_phone: str,
    otp: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Send OTP via WhatsApp"""
    try:
        whatsapp_service = WhatsAppService(db)
        result = await whatsapp_service.send_otp_message(to_phone, otp)

        return {
            "success": True,
            "data": result,
            "message": "WhatsApp OTP sent successfully"
        }

    except Exception as e:
        logger.error(f"WhatsApp OTP send failed: {e}")
        raise HTTPException(status_code=500, detail=f"WhatsApp OTP send failed: {str(e)}")


@router.post("/whatsapp/template")
async def create_whatsapp_template(
    request: WhatsAppTemplateRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Create WhatsApp message template"""
    try:
        whatsapp_service = WhatsAppService(db)
        result = await whatsapp_service.create_template(
            name=request.name,
            category=request.category,
            language=request.language,
            content=request.content,
            variables=request.variables
        )

        return {
            "success": True,
            "data": result,
            "message": "Template created successfully"
        }

    except Exception as e:
        logger.error(f"Template creation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Template creation failed: {str(e)}")


@router.get("/whatsapp/templates")
async def get_whatsapp_templates(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get available WhatsApp templates"""
    try:
        whatsapp_service = WhatsAppService(db)
        templates = await whatsapp_service.get_templates()

        return {
            "success": True,
            "data": templates
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get templates: {str(e)}")


@router.get("/whatsapp/status/{message_id}")
async def get_whatsapp_status(
    message_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get WhatsApp message status"""
    try:
        whatsapp_service = WhatsAppService(db)
        status = await whatsapp_service.get_message_status(message_id)

        return {
            "success": True,
            "data": status
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Status check failed: {str(e)}")


# =====================================================
# AI SERVICE ENDPOINTS
# =====================================================

class ChatCompletionRequest(BaseModel):
    messages: List[Dict[str, str]]
    model: Optional[str] = None
    temperature: Optional[float] = None
    max_tokens: Optional[int] = None


class IntentAnalysisRequest(BaseModel):
    text: str
    context: Optional[Dict[str, Any]] = None
    possible_intents: Optional[List[str]] = None


class TextSummaryRequest(BaseModel):
    text: str
    max_length: int = 100
    style: str = "concise"


class ContentGenerationRequest(BaseModel):
    prompt: str
    content_type: str = "general"
    tone: str = "professional"
    max_length: int = 500


class TranslationRequest(BaseModel):
    text: str
    target_language: str
    source_language: str = "auto"


@router.post("/ai/chat")
async def chat_completion(
    request: ChatCompletionRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Generate AI chat completion"""
    try:
        ai_service = AIService(db)
        result = await ai_service.chat_completion(
            messages=request.messages,
            model=request.model,
            temperature=request.temperature,
            max_tokens=request.max_tokens
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"Chat completion failed: {e}")
        raise HTTPException(status_code=500, detail=f"Chat completion failed: {str(e)}")


@router.post("/ai/intent")
async def analyze_intent(
    request: IntentAnalysisRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Analyze intent from text"""
    try:
        ai_service = AIService(db)
        result = await ai_service.analyze_intent(
            text=request.text,
            context=request.context,
            possible_intents=request.possible_intents
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"Intent analysis failed: {e}")
        raise HTTPException(status_code=500, detail=f"Intent analysis failed: {str(e)}")


@router.post("/ai/summarize")
async def summarize_text(
    request: TextSummaryRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Summarize text using AI"""
    try:
        ai_service = AIService(db)
        result = await ai_service.summarize_text(
            text=request.text,
            max_length=request.max_length,
            style=request.style
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"Text summarization failed: {e}")
        raise HTTPException(status_code=500, detail=f"Text summarization failed: {str(e)}")


@router.post("/ai/generate")
async def generate_content(
    request: ContentGenerationRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Generate content using AI"""
    try:
        ai_service = AIService(db)
        result = await ai_service.generate_content(
            prompt=request.prompt,
            content_type=request.content_type,
            tone=request.tone,
            max_length=request.max_length
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"Content generation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Content generation failed: {str(e)}")


@router.post("/ai/translate")
async def translate_text(
    request: TranslationRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Translate text using AI"""
    try:
        ai_service = AIService(db)
        result = await ai_service.translate_text(
            text=request.text,
            target_language=request.target_language,
            source_language=request.source_language
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"Translation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Translation failed: {str(e)}")


@router.post("/ai/sentiment")
async def analyze_sentiment(
    text: str,
    language: str = "en",
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Analyze sentiment of text"""
    try:
        ai_service = AIService(db)
        result = await ai_service.analyze_sentiment(text=text, language=language)

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"Sentiment analysis failed: {e}")
        raise HTTPException(status_code=500, detail=f"Sentiment analysis failed: {str(e)}")


@router.post("/ai/moderate")
async def moderate_content(
    text: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Check content for moderation violations"""
    try:
        ai_service = AIService(db)
        result = await ai_service.check_moderation(text=text)

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"Content moderation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Content moderation failed: {str(e)}")


@router.get("/ai/usage")
async def get_ai_usage_stats(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get AI service usage statistics"""
    try:
        ai_service = AIService(db)
        stats = await ai_service.get_usage_stats()

        return {
            "success": True,
            "data": stats
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get usage stats: {str(e)}")


# =====================================================
# WEBHOOK ENDPOINTS
# =====================================================

@router.post("/whatsapp/webhook")
async def whatsapp_webhook(
    request_body: bytes,
    signature: str = None,
    background_tasks: BackgroundTasks = None,
    db: Session = Depends(get_db)
):
    """Handle WhatsApp webhook events"""
    try:
        whatsapp_service = WhatsAppService(db)

        # Verify webhook signature
        if signature and not whatsapp_service.verify_webhook_signature(request_body, signature):
            raise HTTPException(status_code=403, detail="Invalid webhook signature")

        # Parse webhook data
        webhook_data = json.loads(request_body.decode())

        # Process webhook in background
        if background_tasks:
            background_tasks.add_task(whatsapp_service.process_webhook, webhook_data)

        return {"status": "ok"}

    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON payload")
    except Exception as e:
        logger.error(f"Webhook processing failed: {e}")
        raise HTTPException(status_code=500, detail=f"Webhook processing failed: {str(e)}")


@router.get("/whatsapp/webhook")
async def whatsapp_webhook_verify(
    hub_mode: str = None,
    hub_challenge: str = None,
    hub_verify_token: str = None
):
    """Verify WhatsApp webhook"""
    from app.core.config.settings import settings

    if (hub_mode == "subscribe" and
        hub_challenge and
        hub_verify_token == settings.whatsapp_verify_token):
        return hub_challenge

    raise HTTPException(status_code=403, detail="Webhook verification failed")
