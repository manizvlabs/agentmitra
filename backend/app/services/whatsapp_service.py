"""
WhatsApp Business API Service
=============================

This service handles WhatsApp Business API integration including:
- Message sending and receiving
- Template message management
- Webhook processing
- Message status tracking
- Rate limiting and compliance
"""

import json
import hashlib
import hmac
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any

import httpx
from sqlalchemy.orm import Session

from app.core.config.settings import settings
from app.models.whatsapp_message import WhatsAppMessage
from app.models.whatsapp_template import WhatsAppTemplate
from app.services.template_service import TemplateService


class WhatsAppService:
    """WhatsApp Business API integration service"""

    def __init__(self, db: Session):
        self.db = db
        self.template_service = TemplateService(db)
        self.http_client = httpx.AsyncClient(
            timeout=30.0,
            headers={
                "Authorization": f"Bearer {settings.whatsapp_access_token}",
                "Content-Type": "application/json"
            }
        )

    async def send_message(
        self,
        to_phone: str,
        message_type: str,
        content: Dict,
        template_name: Optional[str] = None
    ) -> Dict:
        """Send WhatsApp message"""

        # Validate phone number format
        to_phone = self._format_phone_number(to_phone)

        # Prepare message payload
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": to_phone
        }

        if message_type == "template":
            # Send template message
            template = await self.template_service.get_template(template_name)
            payload.update({
                "type": "template",
                "template": {
                    "name": template.name,
                    "language": {"code": template.language},
                    "components": self._build_template_components(template, content)
                }
            })
        elif message_type == "text":
            # Send text message
            payload.update({
                "type": "text",
                "text": {"body": content["body"]}
            })
        elif message_type == "interactive":
            # Send interactive message (buttons, lists)
            payload.update(content)

        # Send message via WhatsApp API
        response = await self._send_whatsapp_request(
            f"{settings.whatsapp_api_url}/messages",
            payload
        )

        # Store message in database
        await self._store_message({
            "message_id": response["messages"][0]["id"],
            "to_phone": to_phone,
            "from_phone": settings.whatsapp_business_number,
            "message_type": message_type,
            "content": content,
            "status": "sent",
            "direction": "outbound",
            "template_name": template_name
        })

        return response

    async def process_webhook(self, webhook_data: Dict) -> bool:
        """Process incoming WhatsApp webhook"""

        # Verify webhook signature
        if not self._verify_webhook_signature(webhook_data):
            raise ValueError("Invalid webhook signature")

        # Process each entry
        for entry in webhook_data.get("entry", []):
            for change in entry.get("changes", []):
                if change.get("field") == "messages":
                    await self._process_messages(change["value"])

        return True

    async def get_message_status(self, message_id: str) -> Dict:
        """Get message delivery status"""

        response = await self._send_whatsapp_request(
            f"{settings.whatsapp_api_url}/messages/{message_id}"
        )

        return {
            "message_id": message_id,
            "status": response.get("status", "unknown"),
            "timestamp": response.get("timestamp")
        }

    async def create_template(
        self,
        name: str,
        category: str,
        language: str,
        content: str,
        variables: List[str]
    ) -> Dict:
        """Create WhatsApp message template"""

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

        # Add header if needed
        if variables:
            payload["components"].append({
                "type": "footer",
                "text": f"Variables: {', '.join(variables)}"
            })

        response = await self._send_whatsapp_request(
            f"{settings.whatsapp_api_url}/message_templates",
            payload,
            method="POST"
        )

        # Store template in database
        await self.template_service.create_template({
            "template_id": response["id"],
            "name": name,
            "category": category,
            "language": language,
            "content": content,
            "variables": variables,
            "status": "pending_approval"
        })

        return response

    async def get_templates(self) -> List[Dict]:
        """Get approved message templates"""

        response = await self._send_whatsapp_request(
            f"{settings.whatsapp_api_url}/message_templates"
        )

        return response.get("data", [])

    # Private methods
    async def _send_whatsapp_request(
        self,
        url: str,
        payload: Optional[Dict] = None,
        method: str = "POST"
    ) -> Dict:
        """Send request to WhatsApp API"""

        try:
            if method == "POST":
                response = await self.http_client.post(url, json=payload)
            elif method == "GET":
                response = await self.http_client.get(url)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")

            response.raise_for_status()
            return response.json()

        except httpx.HTTPError as e:
            # Log error and handle rate limiting
            print(f"WhatsApp API error: {e}")
            if response.status_code == 429:
                # Implement backoff strategy
                await self._handle_rate_limit()
            raise

    async def _process_messages(self, messages_data: Dict):
        """Process incoming messages"""

        for message in messages_data.get("messages", []):
            # Store incoming message
            await self._store_message({
                "message_id": message["id"],
                "to_phone": settings.whatsapp_business_number,
                "from_phone": message["from"],
                "message_type": message["type"],
                "content": message.get("text", {}).get("body", ""),
                "status": "received",
                "direction": "inbound",
                "timestamp": message["timestamp"]
            })

            # Process based on message type
            if message["type"] == "text":
                await self._handle_text_message(message)
            elif message["type"] == "interactive":
                await self._handle_interactive_message(message)

    async def _handle_text_message(self, message: Dict):
        """Handle incoming text message"""
        # Check if it's a chatbot query
        from app.services.chatbot_service import ChatbotService

        chatbot_service = ChatbotService(self.db)
        response = await chatbot_service.process_message(
            message["from"],
            message["text"]["body"]
        )

        # Send response
        if response:
            await self.send_message(
                message["from"],
                "text",
                {"body": response}
            )

    async def _handle_interactive_message(self, message: Dict):
        """Handle interactive message responses"""
        # Process button clicks, list selections, etc.
        interactive_data = message.get("interactive", {})

        if interactive_data.get("type") == "button_reply":
            button_id = interactive_data["button_reply"]["id"]
            await self._process_button_click(message["from"], button_id)

        elif interactive_data.get("type") == "list_reply":
            selection_id = interactive_data["list_reply"]["id"]
            await self._process_list_selection(message["from"], selection_id)

    async def _process_button_click(self, phone: str, button_id: str):
        """Process button click actions"""
        # Handle different button actions
        if button_id == "call_agent":
            # Create agent callback request
            from app.services.callback_service import CallbackService
            callback_service = CallbackService(self.db)
            await callback_service.create_callback_request(phone)
        elif button_id == "pay_premium":
            # Send payment link
            await self._send_payment_link(phone)
        # Handle other button actions...

    async def _store_message(self, message_data: Dict):
        """Store WhatsApp message in database"""
        whatsapp_message = WhatsAppMessage(**message_data)
        self.db.add(whatsapp_message)
        await self.db.commit()

    def _verify_webhook_signature(self, webhook_data: Dict) -> bool:
        """Verify WhatsApp webhook signature"""
        signature = webhook_data.get("signature", "")
        body = json.dumps(webhook_data, separators=(',', ':'))

        expected_signature = hmac.new(
            settings.whatsapp_webhook_secret.encode(),
            body.encode(),
            hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(signature, expected_signature)

    def _format_phone_number(self, phone: str) -> str:
        """Format phone number for WhatsApp API"""
        # Remove all non-numeric characters
        phone = ''.join(filter(str.isdigit, phone))

        # Add country code if missing
        if not phone.startswith('91'):
            phone = f'91{phone}'

        return phone

    def _build_template_components(self, template: WhatsAppTemplate, variables: Dict) -> List[Dict]:
        """Build template components for WhatsApp API"""
        components = []

        # Body component
        components.append({
            "type": "body",
            "parameters": [
                {"type": "text", "text": variables.get(var, "")}
                for var in template.variables
            ]
        })

        return components

    async def _handle_rate_limit(self):
        """Handle WhatsApp API rate limiting"""
        # Implement exponential backoff
        import asyncio
        await asyncio.sleep(60)  # Wait 1 minute before retrying
