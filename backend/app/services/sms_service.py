"""
SMS Service
===========

Service for sending SMS messages using various SMS providers.
Supports OTP delivery, notifications, and bulk messaging.
"""

import logging
from typing import Dict, Optional, Any
from datetime import datetime

import httpx
from sqlalchemy.orm import Session

from app.core.config.settings import settings

logger = logging.getLogger(__name__)


class SMSService:
    """SMS service with multiple provider support"""

    def __init__(self):
        self.providers = {
            "twilio": self._send_twilio_sms,
            "aws_sns": self._send_aws_sns_sms,
            "msg91": self._send_msg91_sms,
        }
        self.http_client = httpx.AsyncClient(timeout=30.0)

    async def send_sms(self, to_phone: str, message: str, provider: Optional[str] = None) -> Dict[str, Any]:
        """Send SMS using configured provider"""

        provider = provider or settings.sms_provider
        if provider not in self.providers:
            raise ValueError(f"Unsupported SMS provider: {provider}")

        try:
            result = await self.providers[provider](to_phone, message)
            logger.info(f"SMS sent successfully to {to_phone} via {provider}")
            return result
        except Exception as e:
            logger.error(f"Failed to send SMS to {to_phone} via {provider}: {e}")
            raise

    async def send_otp(self, to_phone: str, otp: str) -> Dict[str, Any]:
        """Send OTP via SMS"""
        message = f"Your Agent Mitra verification code is: {otp}"
        return await self.send_sms(to_phone, message)

    async def send_bulk_sms(self, recipients: list, message: str) -> Dict[str, Any]:
        """Send SMS to multiple recipients"""
        results = {"successful": 0, "failed": 0, "details": []}

        for phone in recipients:
            try:
                await self.send_sms(phone, message)
                results["successful"] += 1
                results["details"].append({"phone": phone, "status": "success"})
            except Exception as e:
                results["failed"] += 1
                results["details"].append({"phone": phone, "status": "failed", "error": str(e)})

        return results

    async def _send_twilio_sms(self, to_phone: str, message: str) -> Dict[str, Any]:
        """Send SMS via Twilio"""
        import base64

        auth_string = base64.b64encode(
            f"{settings.sms_api_key}:{settings.sms_api_secret}".encode()
        ).decode()

        headers = {
            "Authorization": f"Basic {auth_string}",
            "Content-Type": "application/x-www-form-urlencoded"
        }

        data = {
            "To": to_phone,
            "From": settings.sms_from_number,
            "Body": message
        }

        response = await self.http_client.post(
            f"https://api.twilio.com/2010-04-01/Accounts/{settings.sms_api_key}/Messages.json",
            headers=headers,
            data=data
        )

        response.raise_for_status()
        result = response.json()

        return {
            "provider": "twilio",
            "message_id": result["sid"],
            "status": result["status"],
            "to": to_phone,
            "sent_at": datetime.utcnow().isoformat()
        }

    async def _send_aws_sns_sms(self, to_phone: str, message: str) -> Dict[str, Any]:
        """Send SMS via AWS SNS"""
        import boto3

        sns_client = boto3.client(
            "sns",
            aws_access_key_id=settings.aws_access_key_id,
            aws_secret_access_key=settings.aws_secret_access_key,
            region_name=settings.aws_region
        )

        response = sns_client.publish(
            PhoneNumber=to_phone,
            Message=message
        )

        return {
            "provider": "aws_sns",
            "message_id": response["MessageId"],
            "status": "sent",
            "to": to_phone,
            "sent_at": datetime.utcnow().isoformat()
        }

    async def _send_msg91_sms(self, to_phone: str, message: str) -> Dict[str, Any]:
        """Send SMS via MSG91"""
        url = "https://api.msg91.com/api/v2/sms"
        headers = {
            "authkey": settings.sms_api_key,
            "content-type": "application/json"
        }

        data = {
            "sender": settings.sms_sender_id or "AGMITR",
            "route": "4",  # Transactional route
            "country": "91",
            "sms": [
                {
                    "message": message,
                    "to": [to_phone.replace("+91", "")]
                }
            ]
        }

        response = await self.http_client.post(url, headers=headers, json=data)
        response.raise_for_status()
        result = response.json()

        return {
            "provider": "msg91",
            "message_id": result["request_id"],
            "status": "sent",
            "to": to_phone,
            "sent_at": datetime.utcnow().isoformat()
        }

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.http_client.aclose()
