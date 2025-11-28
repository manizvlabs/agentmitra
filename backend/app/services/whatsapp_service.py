"""
WhatsApp Business API Service
=============================

Comprehensive WhatsApp integration for business messaging including:
- Message sending and receiving
- Template management
- Webhook processing
- Media handling
- Contact management
"""

import logging
import os
import json
import hmac
import hashlib
from typing import Dict, List, Optional, Any, Union
from datetime import datetime
from pathlib import Path

import httpx
from sqlalchemy.orm import Session

from app.core.config.settings import settings
from app.core.monitoring import monitoring
from app.services.chatbot_service import ChatbotService

logger = logging.getLogger(__name__)


class WhatsAppService:
    """WhatsApp Business API integration service"""

    def __init__(self, db: Optional[Session] = None):
        self.db = db
        self.chatbot_service = ChatbotService(db) if db else None

        # WhatsApp configuration from environment
        self.access_token = os.getenv("WHATSAPP_ACCESS_TOKEN", settings.whatsapp_access_token)
        self.api_url = os.getenv("WHATSAPP_API_URL", settings.whatsapp_api_url)
        self.business_number = os.getenv("WHATSAPP_BUSINESS_NUMBER", settings.whatsapp_business_number)
        self.webhook_secret = os.getenv("WHATSAPP_WEBHOOK_SECRET", settings.whatsapp_webhook_secret)
        self.verify_token = os.getenv("WHATSAPP_VERIFY_TOKEN", settings.whatsapp_verify_token)
        self.business_account_id = os.getenv("WHATSAPP_BUSINESS_ACCOUNT_ID")

        # Initialize HTTP client
        self.http_client = httpx.AsyncClient(
            timeout=httpx.Timeout(30.0, connect=10.0),
            headers={
                "Authorization": f"Bearer {self.access_token}" if self.access_token else "",
                "Content-Type": "application/json"
            }
        )

    async def send_message(
        self,
        to_phone: str,
        message_type: str,
        content: Dict[str, Any],
        template_name: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Send WhatsApp message

        Args:
            to_phone: Recipient phone number (E.164 format)
            message_type: Type of message (text, template, image, document, etc.)
            content: Message content
            template_name: Template name for template messages
        """

        if not self._is_configured():
            raise Exception("WhatsApp credentials not configured. Please set WHATSAPP_ACCESS_TOKEN, WHATSAPP_API_URL, and WHATSAPP_BUSINESS_NUMBER environment variables.")

        try:
            url = f"{self.api_url}/{self.business_number}/messages"

            # Prepare message payload based on type
            payload = self._prepare_message_payload(to_phone, message_type, content, template_name)

            response = await self.http_client.post(url, json=payload)

            if response.status_code == 200:
                result = response.json()
                message_data = {
                    "provider": "whatsapp",
                    "message_id": result["messages"][0]["id"],
                    "status": "sent",
                    "to": to_phone,
                    "message_type": message_type,
                    "timestamp": datetime.utcnow().isoformat()
                }

                monitoring.record_business_metrics("whatsapp_message_sent", {
                    "message_type": message_type,
                    "success": True
                })

                return message_data
            else:
                error_data = response.json()
                raise Exception(f"WhatsApp API error: {error_data}")

        except Exception as e:
            monitoring.record_business_metrics("whatsapp_message_failed", {
                "message_type": message_type,
                "error": str(e)
            })
            logger.error(f"WhatsApp send failed: {e}")
            raise

    async def send_text_message(self, to_phone: str, text: str) -> Dict[str, Any]:
        """Send simple text message"""
        return await self.send_message(
            to_phone=to_phone,
            message_type="text",
            content={"body": text}
        )

    async def send_template_message(
        self,
        to_phone: str,
        template_name: str,
        language_code: str = "en",
        components: Optional[List[Dict]] = None
    ) -> Dict[str, Any]:
        """Send template message"""
        content = {
            "name": template_name,
            "language": {"code": language_code}
        }
        if components:
            content["components"] = components

        return await self.send_message(
            to_phone=to_phone,
            message_type="template",
            content=content,
            template_name=template_name
        )

    async def send_otp_message(self, to_phone: str, otp: str) -> Dict[str, Any]:
        """Send OTP via WhatsApp"""
        text = f"Your Agent Mitra verification code is: {otp}. Valid for 5 minutes."
        return await self.send_text_message(to_phone, text)

    def verify_webhook_signature(self, request_body: bytes, signature: str) -> bool:
        """Verify webhook signature from WhatsApp"""
        if not self.webhook_secret:
            logger.warning("WhatsApp webhook secret not configured")
            return True  # Allow in development

        expected_signature = hmac.new(
            self.webhook_secret.encode(),
            request_body,
            hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(f"sha256={expected_signature}", signature)

    async def process_webhook(self, webhook_data: Dict[str, Any]) -> bool:
        """Process incoming WhatsApp webhook"""
        try:
            if "messages" in webhook_data.get("entry", [{}])[0].get("changes", [{}])[0]:
                messages = webhook_data["entry"][0]["changes"][0]["messages"]

                for message in messages:
                    await self._process_incoming_message(message)

            elif "statuses" in webhook_data.get("entry", [{}])[0].get("changes", [{}])[0]:
                statuses = webhook_data["entry"][0]["changes"][0]["statuses"]

                for status in statuses:
                    await self._process_message_status(status)

            return True

        except Exception as e:
            logger.error(f"Webhook processing failed: {e}")
            return False

    async def get_message_status(self, message_id: str) -> Dict[str, Any]:
        """Get message delivery status"""
        if not self._is_configured():
            return {
                "message_id": message_id,
                "status": "unknown",
                "error": "WhatsApp not configured. Please set WHATSAPP_ACCESS_TOKEN, WHATSAPP_API_URL, and WHATSAPP_BUSINESS_NUMBER environment variables."
            }

        try:
            url = f"{self.api_url}/{message_id}"
            response = await self.http_client.get(url)

            if response.status_code == 200:
                result = response.json()
                return {
                    "message_id": message_id,
                    "status": result.get("status", "unknown"),
                    "timestamp": result.get("timestamp"),
                    "recipient_id": result.get("recipient_id"),
                    "api_response": result
                }
            else:
                error_data = response.json()
                return {
                    "message_id": message_id,
                    "status": "error",
                    "error": error_data.get("error", {}).get("message", "Unknown error"),
                    "error_code": response.status_code
                }

        except Exception as e:
            logger.error(f"Failed to get message status: {e}")
            return {
                "message_id": message_id,
                "status": "error",
                "error": str(e)
            }

    async def create_template(
        self,
        name: str,
        category: str,
        language: str,
        content: str,
        variables: List[str]
    ) -> Dict[str, Any]:
        """Create message template"""
        if not self._is_configured():
            raise Exception("WhatsApp credentials not configured. Please set WHATSAPP_ACCESS_TOKEN, WHATSAPP_API_URL, and WHATSAPP_BUSINESS_NUMBER environment variables.")

        try:
            url = f"{self.api_url}/{self.business_account_id}/message_templates"

            payload = {
                "name": name,
                "category": category,
                "language": language,
                "components": [
                    {
                        "type": "body",
                        "text": content
                    }
                ]
            }

            response = await self.http_client.post(url, json=payload)

            if response.status_code == 200:
                return response.json()
            else:
                raise Exception(f"Template creation failed: {response.text}")

        except Exception as e:
            logger.error(f"Template creation failed: {e}")
            raise

    async def get_templates(self) -> List[Dict[str, Any]]:
        """Get available message templates"""
        if not self._is_configured():
            raise Exception("WhatsApp credentials not configured. Please set WHATSAPP_ACCESS_TOKEN, WHATSAPP_API_URL, and WHATSAPP_BUSINESS_NUMBER environment variables.")

        try:
            url = f"{self.api_url}/{self.business_account_id}/message_templates"
            response = await self.http_client.get(url)

            if response.status_code == 200:
                return response.json().get("data", [])
            else:
                return []

        except Exception as e:
            logger.error(f"Failed to get templates: {e}")
            return []

    def _prepare_message_payload(
        self,
        to_phone: str,
        message_type: str,
        content: Dict[str, Any],
        template_name: Optional[str] = None
    ) -> Dict[str, Any]:
        """Prepare message payload for WhatsApp API"""

        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": self._format_phone_number(to_phone)
        }

        if message_type == "text":
            payload["type"] = "text"
            payload["text"] = {"body": content["body"]}
        elif message_type == "template":
            payload["type"] = "template"
            payload["template"] = content
        elif message_type == "image":
            payload["type"] = "image"
            payload["image"] = content
        elif message_type == "document":
            payload["type"] = "document"
            payload["document"] = content
        else:
            raise ValueError(f"Unsupported message type: {message_type}")

        return payload

    def _format_phone_number(self, phone: str) -> str:
        """Format phone number for WhatsApp (ensure international format)"""
        import re

        # Remove all non-digit characters except +
        clean_phone = re.sub(r'[^\d+]', '', phone)

        # Ensure international format
        if not clean_phone.startswith('+'):
            if clean_phone.startswith('91'):
                clean_phone = '+' + clean_phone
            else:
                clean_phone = '+91' + clean_phone

        return clean_phone

    def _is_configured(self) -> bool:
        """Check if WhatsApp is properly configured"""
        return bool(
            self.access_token and
            self.api_url and
            self.business_number
        )


    async def _process_incoming_message(self, message: Dict[str, Any]):
        """Process incoming message from webhook"""
        # Extract message details
        message_id = message.get("id")
        from_number = message.get("from")
        message_type = message.get("type")
        timestamp = message.get("timestamp")

        # Handle different message types
        if message_type == "text":
            text_content = message.get("text", {}).get("body")
            await self._handle_text_message(from_number, text_content, message_id)
        elif message_type == "image":
            await self._handle_media_message(from_number, message, "image")
        elif message_type == "document":
            await self._handle_media_message(from_number, message, "document")

        # Log message reception
        monitoring.record_business_metrics("whatsapp_message_received", {
            "message_type": message_type,
            "from": from_number
        })

    async def _process_message_status(self, status: Dict[str, Any]):
        """Process message status update from webhook"""
        message_id = status.get("id")
        status_value = status.get("status")

        # Log status update
        monitoring.record_business_metrics("whatsapp_status_update", {
            "message_id": message_id,
            "status": status_value
        })

    async def _handle_text_message(self, from_number: str, text: str, message_id: str):
        """Handle incoming text message with chatbot integration"""
        logger.info(f"Received text message from {from_number}: {text[:50]}...")

        # Check if this is a chatbot conversation
        if self.db and self.chatbot_service:
            await self._handle_chatbot_message(from_number, text, message_id)
        else:
            # Fallback: simple auto-response
            await self._send_auto_response(from_number, text)

    async def _handle_media_message(self, from_number: str, message: Dict[str, Any], media_type: str):
        """Handle incoming media message"""
        logger.info(f"Received {media_type} message from {from_number}")

    async def _handle_chatbot_message(self, from_number: str, text: str, message_id: str):
        """Handle chatbot conversation via WhatsApp"""
        try:
            # Get or create WhatsApp conversation session
            session_id = await self._get_whatsapp_session(from_number)

            # Prepare user context (simplified - in production, look up user by phone)
            user_context = {
                "phone": from_number,
                "channel": "whatsapp",
                "message_id": message_id
            }

            # Check for escalation keywords
            if self._is_escalation_request(text):
                await self._handle_whatsapp_escalation(from_number, text, session_id, user_context)
                return

            # Process message with chatbot
            chatbot_response = await self.chatbot_service.process_message(
                session_id=session_id,
                message=text,
                user_id=None,  # We don't have user ID from phone number
                context=user_context
            )

            # Send chatbot response via WhatsApp
            response_text = chatbot_response.get("response", "I apologize, but I'm having trouble processing your request.")

            # Add video recommendations if available
            video_recommendations = chatbot_response.get("video_recommendations", [])
            if video_recommendations:
                response_text += self._format_video_recommendations(video_recommendations)

            await self.send_text_message(from_number, response_text)

            # Store conversation context for handoff
            await self._store_conversation_context(from_number, session_id, chatbot_response)

        except Exception as e:
            logger.error(f"Chatbot message handling failed: {e}")
            # Fallback response
            await self.send_text_message(
                from_number,
                "I apologize, but I'm experiencing technical difficulties. Please try again or contact our support team."
            )

    async def _handle_whatsapp_escalation(self, from_number: str, text: str, session_id: str, user_context: Dict[str, Any]):
        """Handle escalation requests from WhatsApp"""
        try:
            # Get conversation context for actionable report
            conversation_context = await self._get_conversation_context(from_number, session_id)

            # Create escalation with actionable report
            escalation_result = await self.chatbot_service.handle_escalation(
                session_id=session_id,
                reason="WhatsApp user requested human assistance",
                user_context=user_context,
                conversation_context=conversation_context,
                intent_analysis={"intent": "escalation_request", "confidence": 0.9}
            )

            # Send escalation confirmation via WhatsApp
            response_text = escalation_result.get("response", "Your request has been forwarded to our support team.")
            await self.send_text_message(from_number, response_text)

        except Exception as e:
            logger.error(f"WhatsApp escalation failed: {e}")
            await self.send_text_message(
                from_number,
                "I'm having trouble connecting you with our support team. Please call our customer service directly."
            )

    async def _send_auto_response(self, from_number: str, text: str):
        """Send automatic response for basic queries"""
        # Simple keyword-based responses
        text_lower = text.lower()

        if "hello" in text_lower or "hi" in text_lower:
            response = "Hello! Welcome to Agent Mitra. How can I help you with your insurance queries today?"
        elif "premium" in text_lower or "payment" in text_lower:
            response = "For premium payment assistance, I recommend checking our app or website. You can also call your agent directly."
        elif "policy" in text_lower:
            response = "I'd be happy to help with your policy questions. Could you please provide more details about what you need?"
        elif "claim" in text_lower:
            response = "For claim assistance, please contact your insurance agent or visit our claims portal."
        else:
            response = "Thank you for your message. For personalized assistance, please reply with more details about your insurance query, or type 'AGENT' to speak with a human representative."

        await self.send_text_message(from_number, response)

    def _is_escalation_request(self, text: str) -> bool:
        """Check if message contains escalation keywords"""
        escalation_keywords = [
            "speak to human", "talk to agent", "customer service",
            "supervisor", "manager", "representative", "agent",
            "help me directly", "human assistance", "person"
        ]

        text_lower = text.lower()
        return any(keyword in text_lower for keyword in escalation_keywords)

    def _format_video_recommendations(self, video_recommendations: List[Dict[str, Any]]) -> str:
        """Format video recommendations for WhatsApp"""
        if not video_recommendations:
            return ""

        formatted = "\n\n📹 Recommended Videos:\n"
        for i, video in enumerate(video_recommendations[:2], 1):  # Limit to 2
            duration_min = video.get("duration_seconds", 0) // 60
            formatted += f"{i}. {video.get('title', 'Video')} ({duration_min}min)\n"

        formatted += "\nWatch these videos in our app for detailed guidance!"
        return formatted

    async def _get_whatsapp_session(self, from_number: str) -> str:
        """Get or create WhatsApp conversation session"""
        # In a real implementation, this would store session mapping in database
        # For now, use phone number as session identifier
        return f"whatsapp_{from_number}"

    async def _store_conversation_context(self, from_number: str, session_id: str, chatbot_response: Dict[str, Any]):
        """Store conversation context for potential handoff"""
        # In a real implementation, store recent conversation in Redis/database
        # This enables seamless handoff between WhatsApp and app
        pass

    async def _get_conversation_context(self, from_number: str, session_id: str) -> Dict[str, Any]:
        """Get conversation context for actionable reports"""
        # Return basic context - in production, retrieve from storage
        return {
            "channel": "whatsapp",
            "phone_number": from_number,
            "session_id": session_id,
            "messages": [],  # Would be populated from stored conversation
            "total_messages": 0
        }

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.http_client.aclose()