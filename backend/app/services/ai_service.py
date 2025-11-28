"""
AI Service with OpenAI Integration
===================================

Comprehensive AI service for natural language processing including:
- Chat completions
- Intent recognition
- Text analysis and summarization
- Content generation
- Sentiment analysis
- Multi-language support
"""

import logging
import os
import json
from typing import Dict, List, Optional, Any, Union
from datetime import datetime
import asyncio

import httpx
from sqlalchemy.orm import Session

from app.core.config.settings import settings
from app.core.monitoring import monitoring

logger = logging.getLogger(__name__)


class AIService:
    """OpenAI integration service for AI-powered features"""

    def __init__(self, db: Optional[Session] = None):
        self.db = db

        # OpenAI configuration from environment
        self.api_key = os.getenv("OPENAI_API_KEY", settings.openai_api_key)
        self.api_url = "https://api.openai.com/v1"
        self.model = os.getenv("OPENAI_MODEL", settings.chatbot_model)
        self.max_tokens = int(os.getenv("OPENAI_MAX_TOKENS", settings.chatbot_max_tokens))
        self.temperature = float(os.getenv("OPENAI_TEMPERATURE", settings.chatbot_temperature))

        # Initialize HTTP client
        self.http_client = httpx.AsyncClient(
            timeout=httpx.Timeout(60.0, connect=10.0),
            headers={
                "Authorization": f"Bearer {self.api_key}" if self.api_key else "",
                "Content-Type": "application/json"
            }
        )

        # Model configurations
        self.models = {
            "chat": "gpt-3.5-turbo",
            "completion": "text-davinci-003",
            "embedding": "text-embedding-ada-002"
        }

    async def chat_completion(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: Optional[float] = None,
        max_tokens: Optional[int] = None,
        functions: Optional[List[Dict]] = None
    ) -> Dict[str, Any]:
        """
        Generate chat completion using OpenAI

        Args:
            messages: List of message dicts with 'role' and 'content'
            model: Model to use (defaults to configured model)
            temperature: Creativity level (0.0-2.0)
            max_tokens: Maximum tokens to generate
            functions: Function definitions for function calling
        """

        if not self._is_configured():
            return self._mock_chat_completion(messages)

        try:
            url = f"{self.api_url}/chat/completions"

            payload = {
                "model": model or self.model,
                "messages": messages,
                "temperature": temperature or self.temperature,
                "max_tokens": max_tokens or self.max_tokens
            }

            if functions:
                payload["functions"] = functions

            response = await self.http_client.post(url, json=payload)

            if response.status_code == 200:
                result = response.json()
                completion = result["choices"][0]["message"]

                response_data = {
                    "content": completion.get("content", ""),
                    "role": completion.get("role", "assistant"),
                    "finish_reason": result["choices"][0].get("finish_reason"),
                    "usage": result.get("usage", {}),
                    "model": result.get("model"),
                    "timestamp": datetime.utcnow().isoformat()
                }

                # Record usage metrics
                monitoring.record_business_metrics("ai_completion_generated", {
                    "model": model or self.model,
                    "tokens_used": result.get("usage", {}).get("total_tokens", 0),
                    "success": True
                })

                return response_data
            else:
                error_data = response.json()
                raise Exception(f"OpenAI API error: {error_data.get('error', {}).get('message', 'Unknown error')}")

        except Exception as e:
            monitoring.record_business_metrics("ai_completion_failed", {
                "model": model or self.model,
                "error": str(e)
            })
            logger.error(f"Chat completion failed: {e}")
            raise

    async def analyze_intent(
        self,
        text: str,
        context: Optional[Dict[str, Any]] = None,
        possible_intents: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """Analyze intent from text using AI"""

        if not self._is_configured():
            return self._mock_intent_analysis(text)

        try:
            system_prompt = """
            You are an expert intent classifier for an insurance agency platform.
            Analyze the user's message and classify their intent.
            Return a JSON object with: intent, confidence (0-1), entities (any extracted data), sentiment.
            """

            user_prompt = f"""
            Analyze this message: "{text}"
            Context: {json.dumps(context) if context else 'None'}
            Possible intents: {', '.join(possible_intents) if possible_intents else 'Any'}
            """

            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ]

            response = await self.chat_completion(
                messages=messages,
                temperature=0.1,  # Low temperature for consistent analysis
                max_tokens=300
            )

            # Parse JSON response
            try:
                analysis = json.loads(response["content"])
                return {
                    **analysis,
                    "analyzed_at": datetime.utcnow().isoformat(),
                    "text_length": len(text)
                }
            except json.JSONDecodeError:
                # Fallback if JSON parsing fails
                return {
                    "intent": "unknown",
                    "confidence": 0.5,
                    "entities": [],
                    "sentiment": "neutral",
                    "fallback": True
                }

        except Exception as e:
            logger.error(f"Intent analysis failed: {e}")
            return {
                "intent": "unknown",
                "confidence": 0.0,
                "entities": [],
                "sentiment": "neutral",
                "error": str(e)
            }

    async def summarize_text(
        self,
        text: str,
        max_length: int = 100,
        style: str = "concise"
    ) -> Dict[str, Any]:
        """Summarize text using AI"""

        if not self._is_configured():
            return self._mock_text_summary(text, max_length)

        try:
            system_prompt = f"You are a text summarizer. Create a {style} summary of the given text in {max_length} words or less."

            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": text}
            ]

            response = await self.chat_completion(
                messages=messages,
                temperature=0.3,
                max_tokens=max_length * 2
            )

            return {
                "summary": response["content"].strip(),
                "original_length": len(text),
                "summary_length": len(response["content"]),
                "style": style,
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Text summarization failed: {e}")
            return {
                "summary": text[:max_length] + "..." if len(text) > max_length else text,
                "error": str(e)
            }

    async def analyze_sentiment(self, text: str, language: str = "en") -> Dict[str, Any]:
        """Analyze sentiment of text"""

        if not self._is_configured():
            return self._mock_sentiment_analysis(text)

        try:
            system_prompt = """
            Analyze the sentiment of the given text.
            Return a JSON object with: sentiment (positive/negative/neutral), confidence (0-1), emotions (list of detected emotions).
            """

            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Language: {language}\nText: {text}"}
            ]

            response = await self.chat_completion(
                messages=messages,
                temperature=0.1,
                max_tokens=150
            )

            try:
                analysis = json.loads(response["content"])
                return {
                    **analysis,
                    "language": language,
                    "analyzed_at": datetime.utcnow().isoformat()
                }
            except json.JSONDecodeError:
                return {
                    "sentiment": "neutral",
                    "confidence": 0.5,
                    "emotions": [],
                    "fallback": True
                }

        except Exception as e:
            logger.error(f"Sentiment analysis failed: {e}")
            return {
                "sentiment": "neutral",
                "confidence": 0.5,
                "emotions": [],
                "error": str(e)
            }

    async def generate_content(
        self,
        prompt: str,
        content_type: str = "general",
        tone: str = "professional",
        max_length: int = 500
    ) -> Dict[str, Any]:
        """Generate content using AI"""

        if not self._is_configured():
            return self._mock_content_generation(prompt, content_type)

        try:
            system_prompt = f"""
            You are a content generator for an insurance agency platform.
            Generate {content_type} content in a {tone} tone.
            Keep it under {max_length} words.
            """

            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ]

            response = await self.chat_completion(
                messages=messages,
                temperature=0.7,
                max_tokens=max_length * 2
            )

            return {
                "content": response["content"].strip(),
                "content_type": content_type,
                "tone": tone,
                "word_count": len(response["content"].split()),
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Content generation failed: {e}")
            return {
                "content": f"Generated content for: {prompt[:50]}...",
                "error": str(e)
            }

    async def translate_text(
        self,
        text: str,
        target_language: str,
        source_language: str = "auto"
    ) -> Dict[str, Any]:
        """Translate text to target language"""

        if not self._is_configured():
            return self._mock_translation(text, target_language)

        try:
            system_prompt = f"Translate the following text to {target_language}. Maintain the original meaning and tone."

            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": text}
            ]

            response = await self.chat_completion(
                messages=messages,
                temperature=0.1,
                max_tokens=len(text) * 2
            )

            return {
                "original_text": text,
                "translated_text": response["content"].strip(),
                "source_language": source_language,
                "target_language": target_language,
                "translated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Translation failed: {e}")
            return {
                "original_text": text,
                "translated_text": text,  # Return original on failure
                "error": str(e)
            }

    async def check_moderation(self, text: str) -> Dict[str, Any]:
        """Check text for moderation violations"""

        if not self._is_configured():
            return {"moderation_passed": True, "mock": True}

        try:
            url = f"{self.api_url}/moderations"

            payload = {
                "input": text,
                "model": "text-moderation-latest"
            }

            response = await self.http_client.post(url, json=payload)

            if response.status_code == 200:
                result = response.json()
                moderation_result = result["results"][0]

                return {
                    "moderation_passed": not moderation_result["flagged"],
                    "categories": moderation_result["categories"],
                    "category_scores": moderation_result["category_scores"],
                    "checked_at": datetime.utcnow().isoformat()
                }
            else:
                return {"moderation_passed": True, "error": "Moderation check failed"}

        except Exception as e:
            logger.error(f"Moderation check failed: {e}")
            return {"moderation_passed": True, "error": str(e)}

    def _is_configured(self) -> bool:
        """Check if OpenAI is properly configured"""
        return bool(self.api_key and self.api_key != "your-openai-api-key")

    def _mock_chat_completion(self, messages: List[Dict[str, str]]) -> Dict[str, Any]:
        """Return mock chat completion when OpenAI is not configured"""
        last_message = messages[-1]["content"] if messages else ""

        return {
            "content": f"I understand you said: '{last_message[:50]}...'. This is a mock response because OpenAI is not configured.",
            "role": "assistant",
            "finish_reason": "stop",
            "usage": {"total_tokens": 50, "prompt_tokens": 25, "completion_tokens": 25},
            "model": "mock-gpt",
            "mock": True,
            "timestamp": datetime.utcnow().isoformat()
        }

    def _mock_intent_analysis(self, text: str) -> Dict[str, Any]:
        """Mock intent analysis response"""
        return {
            "intent": "general_inquiry",
            "confidence": 0.7,
            "entities": [],
            "sentiment": "neutral",
            "mock": True,
            "analyzed_at": datetime.utcnow().isoformat()
        }

    def _mock_text_summary(self, text: str, max_length: int) -> Dict[str, Any]:
        """Mock text summary response"""
        summary = text[:max_length] + "..." if len(text) > max_length else text
        return {
            "summary": summary,
            "original_length": len(text),
            "summary_length": len(summary),
            "mock": True
        }

    def _mock_sentiment_analysis(self, text: str) -> Dict[str, Any]:
        """Mock sentiment analysis response"""
        return {
            "sentiment": "neutral",
            "confidence": 0.6,
            "emotions": ["calm"],
            "mock": True
        }

    def _mock_content_generation(self, prompt: str, content_type: str) -> Dict[str, Any]:
        """Mock content generation response"""
        return {
            "content": f"Generated {content_type} content for prompt: {prompt[:50]}...",
            "content_type": content_type,
            "mock": True
        }

    def _mock_translation(self, text: str, target_language: str) -> Dict[str, Any]:
        """Mock translation response"""
        return {
            "original_text": text,
            "translated_text": f"[Mock translation to {target_language}]: {text}",
            "mock": True
        }

    async def get_usage_stats(self) -> Dict[str, Any]:
        """Get AI service usage statistics"""
        # This would integrate with OpenAI usage API in production
        return {
            "total_requests": 0,
            "total_tokens": 0,
            "costs": {"total": 0.0, "currency": "USD"},
            "models_used": [],
            "period": "lifetime",
            "mock": True
        }

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.http_client.aclose()
