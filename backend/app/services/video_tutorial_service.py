"""
Video Tutorial Service
=====================

Comprehensive video tutorial management with YouTube integration, smart recommendations,
and learning path management.
"""

import os
import uuid
import json
import logging
import tempfile
import shutil
from datetime import datetime, timedelta
from typing import List, Dict, Optional, Any, Tuple
from pathlib import Path

import aiofiles
import httpx
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_, desc
from fastapi import HTTPException

from app.core.config.settings import settings
from app.core.monitoring import monitoring
from app.core.logging_config import get_logger
from app.services.content_management_service import ContentManagementService
from app.services.minio_storage_service import get_minio_service, MinIOStorageService
from app.services.video_processing_service import VideoProcessingService
from app.models.content import (
    Content,
    VideoTutorial,
    VideoCategory,
    VideoProgress,
    VideoRecommendation,
    LearningPath
)
from app.models.user import User

logger = get_logger(__name__)


class VideoTutorialService:
    """Comprehensive video tutorial management service"""

    def __init__(self, db: Session):
        self.db = db
        self.content_service = ContentManagementService(db)
        self.minio_service = get_minio_service()
        self.video_processor = VideoProcessingService()

        # YouTube API configuration
        self.youtube_api_key = os.getenv("YOUTUBE_API_KEY")
        self.youtube_channel_id = os.getenv("YOUTUBE_CHANNEL_ID")
        self.youtube_client_id = os.getenv("YOUTUBE_CLIENT_ID")
        self.youtube_client_secret = os.getenv("YOUTUBE_CLIENT_SECRET")

        # Initialize HTTP client for YouTube API
        self.http_client = httpx.AsyncClient(
            timeout=httpx.Timeout(30.0, connect=10.0),
            headers={"Content-Type": "application/json"}
        )

    async def upload_video_tutorial(
        self,
        file,
        uploader: User,
        title: str,
        description: Optional[str] = None,
        category: str = "general",
        tags: List[str] = None,
        target_audience: List[str] = None,
        policy_types: List[str] = None,
        difficulty_level: str = "beginner",
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Upload and process a video tutorial with comprehensive metadata

        Args:
            file: Video file upload
            uploader: Agent user uploading the video
            title: Video title
            description: Video description
            category: Content category
            tags: List of tags
            target_audience: Target audience types
            policy_types: Related policy types
            difficulty_level: Difficulty level (beginner, intermediate, advanced)
            language: Video language

        Returns:
            Dict with upload results and video information
        """
        try:
            # Validate video file
            await self._validate_video_file(file)

            # Generate unique video ID
            video_id = f"vid_{uuid.uuid4().hex[:16]}"

            # Upload video file to MinIO
            storage_key, media_url, file_hash, file_size = await self.minio_service.upload_file(
                file=file,
                agent_id=str(uploader.id),
                folder="videos"
            )

            # Create content record in database
            content_record = await self._create_content_record(
                content_id=str(uuid.uuid4()),
                filename=file.filename,
                storage_key=storage_key,
                media_url=media_url,
                file_hash=file_hash,
                file_size=file_size,
                content_type="video",
                category=category,
                uploader_id=str(uploader.id),
                tags=tags or [],
                metadata={
                    "video_title": title,
                    "video_description": description,
                    "target_audience": target_audience or [],
                    "policy_types": policy_types or [],
                    "difficulty_level": difficulty_level,
                    "language": language
                }
            )

            # Create video tutorial record
            video_tutorial = VideoTutorial(
                video_id=video_id,
                content_id=content_record["id"],
                title=title,
                description=description,
                category=category,
                difficulty_level=difficulty_level,
                target_audience=target_audience or [],
                policy_types=policy_types or [],
                language=language,
                agent_id=uploader.id,
                agent_name=f"{uploader.first_name} {uploader.last_name}".strip() or uploader.email,
                processing_status="pending"
            )

            # Save to database
            self.db.add(video_tutorial)
            self.db.commit()
            self.db.refresh(video_tutorial)

            # Start background processing
            await self._start_video_processing(video_tutorial, content_record)

            # Record metrics
            monitoring.record_business_metrics(
                "video_tutorial_uploaded",
                {
                    "agent_id": str(uploader.id),
                    "category": category,
                    "difficulty_level": difficulty_level,
                    "language": language
                }
            )

            return {
                "success": True,
                "video_id": video_id,
                "content_id": content_result["content_id"],
                "processing_status": "pending",
                "message": "Video tutorial uploaded successfully. Processing will begin shortly."
            }

        except Exception as e:
            logger.error(f"Video tutorial upload failed: {e}")
            self.db.rollback()
            raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

    async def get_video_tutorial(self, video_id: str, user_id: Optional[str] = None) -> Dict[str, Any]:
        """Get video tutorial details by ID"""
        video = self.db.query(VideoTutorial).filter(VideoTutorial.video_id == video_id).first()

        if not video:
            raise HTTPException(status_code=404, detail="Video tutorial not found")

        # Get associated content
        content = self.db.query(Content).filter(Content.id == video.content_id).first()

        # Get user progress if user_id provided
        progress = None
        if user_id:
            progress = self.db.query(VideoProgress).filter(
                and_(VideoProgress.video_id == video.id, VideoProgress.user_id == user_id)
            ).first()

        # Build response
        video_data = {
            "video_id": video.video_id,
            "title": video.title,
            "description": video.description,
            "youtube_url": video.youtube_url,
            "youtube_video_id": video.youtube_video_id,
            "duration_seconds": video.duration_seconds,
            "category": video.category,
            "difficulty_level": video.difficulty_level,
            "target_audience": video.target_audience,
            "policy_types": video.policy_types,
            "language": video.language,
            "agent_name": video.agent_name,
            "view_count": video.view_count,
            "completion_rate": video.completion_rate,
            "average_watch_time": video.average_watch_time,
            "rating": video.rating,
            "rating_count": video.rating_count,
            "processing_status": video.processing_status,
            "created_at": video.created_at.isoformat() if video.created_at else None,
            "updated_at": video.updated_at.isoformat() if video.updated_at else None
        }

        if content:
            video_data.update({
                "file_size": content.file_size,
                "mime_type": content.mime_type,
                "thumbnail_url": content.metadata.get("thumbnail_url") if content.metadata else None
            })

        if progress:
            video_data["user_progress"] = {
                "completion_percentage": progress.completion_percentage,
                "watch_time_seconds": progress.watch_time_seconds,
                "is_completed": progress.is_completed,
                "last_watched_at": progress.last_watched_at.isoformat() if progress.last_watched_at else None
            }

        return video_data

    async def list_video_tutorials(
        self,
        category: Optional[str] = None,
        agent_id: Optional[str] = None,
        language: Optional[str] = None,
        difficulty_level: Optional[str] = None,
        target_audience: Optional[List[str]] = None,
        policy_types: Optional[List[str]] = None,
        search_query: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
        sort_by: str = "created_at",
        sort_order: str = "desc"
    ) -> Dict[str, Any]:
        """List video tutorials with advanced filtering and search"""

        query = self.db.query(VideoTutorial)

        # Apply filters
        if category:
            query = query.filter(VideoTutorial.category == category)
        if agent_id:
            query = query.filter(VideoTutorial.agent_id == agent_id)
        if language:
            query = query.filter(VideoTutorial.language == language)
        if difficulty_level:
            query = query.filter(VideoTutorial.difficulty_level == difficulty_level)

        # Advanced filters
        if target_audience:
            # Filter videos that have any of the specified target audiences
            query = query.filter(
                or_(*[VideoTutorial.target_audience.contains([audience]) for audience in target_audience])
            )

        if policy_types:
            # Filter videos that have any of the specified policy types
            query = query.filter(
                or_(*[VideoTutorial.policy_types.contains([policy]) for policy in policy_types])
            )

        # Search functionality
        if search_query:
            search_filter = f"%{search_query.lower()}%"
            query = query.filter(
                or_(
                    func.lower(VideoTutorial.title).like(search_filter),
                    func.lower(VideoTutorial.description).like(search_filter),
                    VideoTutorial.search_tags.contains([search_query.lower()])
                )
            )

        # Sorting
        sort_column = getattr(VideoTutorial, sort_by, VideoTutorial.created_at)
        if sort_order == "desc":
            query = query.order_by(desc(sort_column))
        else:
            query = query.order_by(sort_column)

        # Pagination
        total_count = query.count()
        videos = query.offset((page - 1) * limit).limit(limit).all()

        # Convert to dict format
        video_list = []
        for video in videos:
            video_data = {
                "video_id": video.video_id,
                "title": video.title,
                "description": video.description,
                "category": video.category,
                "difficulty_level": video.difficulty_level,
                "language": video.language,
                "agent_name": video.agent_name,
                "view_count": video.view_count,
                "rating": video.rating,
                "duration_seconds": video.duration_seconds,
                "processing_status": video.processing_status,
                "created_at": video.created_at.isoformat() if video.created_at else None
            }
            video_list.append(video_data)

        return {
            "videos": video_list,
            "total_count": total_count,
            "page": page,
            "limit": limit,
            "total_pages": (total_count + limit - 1) // limit
        }

    async def update_video_progress(
        self,
        video_id: str,
        user_id: str,
        watch_time_seconds: float,
        completion_percentage: float,
        is_completed: bool = False
    ) -> Dict[str, Any]:
        """Update user progress for a video tutorial"""

        # Get video
        video = self.db.query(VideoTutorial).filter(VideoTutorial.video_id == video_id).first()
        if not video:
            raise HTTPException(status_code=404, detail="Video tutorial not found")

        # Get or create progress record
        progress = self.db.query(VideoProgress).filter(
            and_(VideoProgress.video_id == video.id, VideoProgress.user_id == user_id)
        ).first()

        if not progress:
            progress = VideoProgress(
                user_id=user_id,
                video_id=video.id,
                watch_time_seconds=0,
                completion_percentage=0,
                play_count=1
            )
            self.db.add(progress)
        else:
            progress.play_count += 1

        # Update progress
        progress.watch_time_seconds = max(progress.watch_time_seconds, watch_time_seconds)
        progress.completion_percentage = max(progress.completion_percentage, completion_percentage)
        progress.last_watched_at = datetime.utcnow()

        if is_completed and not progress.is_completed:
            progress.is_completed = True
            progress.completed_at = datetime.utcnow()

        self.db.commit()

        # Update video analytics
        await self._update_video_analytics(video.id)

        return {
            "video_id": video_id,
            "completion_percentage": progress.completion_percentage,
            "is_completed": progress.is_completed,
            "watch_time_seconds": progress.watch_time_seconds
        }

    async def get_recommended_videos(
        self,
        user_id: str,
        intent_query: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get personalized video recommendations for a user"""

        # Get user profile and history
        user_progress = self.db.query(VideoProgress).filter(VideoProgress.user_id == user_id).all()
        watched_video_ids = [str(p.video_id) for p in user_progress]

        # Base query for available videos
        base_query = self.db.query(VideoTutorial).filter(
            VideoTutorial.processing_status == "completed"
        )

        if watched_video_ids:
            base_query = base_query.filter(VideoTutorial.id.notin_(watched_video_ids))

        videos = base_query.limit(100).all()  # Get candidate videos

        # Score videos based on various factors
        scored_videos = []
        for video in videos:
            score = await self._calculate_recommendation_score(video, user_id, intent_query, context, user_progress)
            scored_videos.append((video, score))

        # Sort by score and return top recommendations
        scored_videos.sort(key=lambda x: x[1], reverse=True)
        recommendations = []

        for video, score in scored_videos[:limit]:
            recommendations.append({
                "video_id": video.video_id,
                "title": video.title,
                "description": video.description,
                "category": video.category,
                "difficulty_level": video.difficulty_level,
                "agent_name": video.agent_name,
                "duration_seconds": video.duration_seconds,
                "view_count": video.view_count,
                "rating": video.rating,
                "relevance_score": score,
                "youtube_url": video.youtube_url
            })

        return recommendations

    async def create_learning_path(
        self,
        title: str,
        description: str,
        video_sequence: List[Dict[str, Any]],
        target_audience: List[str],
        policy_types: List[str],
        difficulty_level: str,
        created_by_agent_id: str
    ) -> Dict[str, Any]:
        """Create a structured learning path"""

        path_id = f"path_{uuid.uuid4().hex[:12]}"

        learning_path = LearningPath(
            path_id=path_id,
            title=title,
            description=description,
            video_sequence=video_sequence,
            target_audience=target_audience,
            policy_types=policy_types,
            difficulty_level=difficulty_level,
            created_by_agent_id=created_by_agent_id,
            last_updated_by=created_by_agent_id
        )

        self.db.add(learning_path)
        self.db.commit()
        self.db.refresh(learning_path)

        return {
            "path_id": path_id,
            "title": title,
            "description": description,
            "video_count": len(video_sequence),
            "created_at": learning_path.created_at.isoformat()
        }

    async def get_learning_path_progress(self, path_id: str, user_id: str) -> Dict[str, Any]:
        """Get user progress through a learning path"""

        learning_path = self.db.query(LearningPath).filter(LearningPath.path_id == path_id).first()
        if not learning_path:
            raise HTTPException(status_code=404, detail="Learning path not found")

        # Get progress for all videos in the path
        video_ids = [video["video_id"] for video in learning_path.video_sequence]
        videos = self.db.query(VideoTutorial).filter(VideoTutorial.video_id.in_(video_ids)).all()

        video_map = {v.video_id: v for v in videos}
        progress_data = []

        total_progress = 0
        completed_count = 0

        for sequence_item in learning_path.video_sequence:
            video_id = sequence_item["video_id"]
            video = video_map.get(video_id)

            if video:
                progress = self.db.query(VideoProgress).filter(
                    and_(VideoProgress.video_id == video.id, VideoProgress.user_id == user_id)
                ).first()

                progress_info = {
                    "video_id": video_id,
                    "title": video.title,
                    "order": sequence_item.get("order", 0),
                    "is_completed": progress.is_completed if progress else False,
                    "completion_percentage": progress.completion_percentage if progress else 0,
                    "watch_time_seconds": progress.watch_time_seconds if progress else 0
                }

                progress_data.append(progress_info)

                if progress and progress.is_completed:
                    completed_count += 1

                total_progress += progress.completion_percentage if progress else 0

        average_progress = total_progress / len(learning_path.video_sequence) if learning_path.video_sequence else 0

        return {
            "path_id": path_id,
            "title": learning_path.title,
            "description": learning_path.description,
            "total_videos": len(learning_path.video_sequence),
            "completed_videos": completed_count,
            "overall_progress": average_progress,
            "videos": progress_data
        }

    # Private helper methods

    async def _validate_video_file(self, file) -> None:
        """Validate video file before upload"""
        # Check file size (max 100MB for videos)
        max_size = 100 * 1024 * 1024  # 100MB
        if file.size > max_size:
            raise HTTPException(status_code=413, detail="Video file too large. Maximum size is 100MB")

        # Check file type
        allowed_types = ['video/mp4', 'video/avi', 'video/mov', 'video/mkv', 'video/webm']
        if file.content_type not in allowed_types:
            raise HTTPException(status_code=400, detail=f"Unsupported video format. Allowed: {', '.join(allowed_types)}")

    async def _start_video_processing(self, video_tutorial: VideoTutorial, content_result: Dict[str, Any]):
        """Start background video processing pipeline using real FFmpeg and AI services"""
        # Note: In production, this should be moved to a background task queue (Celery, etc.)
        # for better performance and reliability

        try:
            # Update processing status
            video_tutorial.processing_status = "processing"
            self.db.commit()

            # Execute real processing pipeline:
            # 1. Extract video metadata using FFmpeg
            await self._process_video_metadata(video_tutorial, content_result)

            # 2. Upload to YouTube using YouTube Data API v3
            await self._upload_to_youtube(video_tutorial, content_result)

            # 3. Generate transcription using OpenAI Whisper (if enabled)
            if settings.video_transcription_auto:
                await self._generate_transcription(video_tutorial)
            else:
                logger.info(f"Auto-transcription disabled. Skipping transcription for video {video_tutorial.video_id}")

            # 4. Generate search tags using AI analysis
            await self._generate_search_tags(video_tutorial)

            # Mark as completed
            video_tutorial.processing_status = "completed"
            self.db.commit()

        except Exception as e:
            logger.error(f"Video processing failed for {video_tutorial.video_id}: {e}")
            video_tutorial.processing_status = "failed"
            video_tutorial.processing_error = str(e)
            self.db.commit()

    async def _process_video_metadata(self, video_tutorial: VideoTutorial, content_result: Dict[str, Any]):
        """Extract video metadata using real video processing"""
        try:
            # Get video file from MinIO temporarily for processing
            temp_video_path = f"/tmp/{video_tutorial.video_id}_{content_result['filename']}"

            # Download video for processing
            await self.minio_service.download_file(content_result['storage_key'], temp_video_path)

            # Extract metadata
            metadata = await self.video_processor.extract_video_metadata(temp_video_path)

            # Update video tutorial with real metadata
            video_tutorial.duration_seconds = metadata['duration_seconds']
            video_tutorial.video_resolution = metadata['video_resolution']
            video_tutorial.video_codec = metadata['video_codec']
            video_tutorial.video_bitrate = metadata['video_bitrate']

            # Clean up temp file
            os.remove(temp_video_path)

            logger.info(f"Processed metadata for video {video_tutorial.video_id}: {metadata}")

        except Exception as e:
            logger.error(f"Failed to process video metadata: {e}")
            # Set fallback values
            video_tutorial.duration_seconds = 300
            video_tutorial.video_resolution = "1920x1080"
            video_tutorial.video_codec = "H.264"

    async def _upload_to_youtube(self, video_tutorial: VideoTutorial, content_result: Dict[str, Any]):
        """Upload video to YouTube channel using YouTube Data API v3"""
        if not settings.youtube_api_key or not settings.youtube_upload_enabled:
            logger.info("YouTube upload disabled or not configured")
            return

        try:
            import googleapiclient.discovery
            import googleapiclient.errors
            from google.oauth2.credentials import Credentials

            # Initialize YouTube API client
            youtube = googleapiclient.discovery.build(
                "youtube", "v3",
                developerKey=settings.youtube_api_key
            )

            # Download video file for upload
            temp_video_path = f"/tmp/{video_tutorial.video_id}_youtube_{content_result['filename']}"
            await self.minio_service.download_file(content_result['storage_key'], temp_video_path)

            # Prepare video metadata for YouTube
            video_metadata = {
                'snippet': {
                    'title': video_tutorial.title,
                    'description': self._generate_youtube_description(video_tutorial),
                    'tags': self._generate_youtube_tags(video_tutorial),
                    'categoryId': '27'  # Education category
                },
                'status': {
                    'privacyStatus': settings.youtube_default_privacy,
                    'embeddable': True,
                    'license': 'youtube'
                }
            }

            # Upload video to YouTube
            media_body = googleapiclient.http.MediaFileUpload(
                temp_video_path,
                chunksize=-1,
                resumable=True
            )

            request = youtube.videos().insert(
                part=",".join(video_metadata.keys()),
                body=video_metadata,
                media_body=media_body
            )

            response = request.execute()

            # Update video tutorial with YouTube info
            video_tutorial.youtube_video_id = response['id']
            video_tutorial.youtube_url = f"https://www.youtube.com/watch?v={response['id']}"
            video_tutorial.youtube_upload_status = "uploaded"

            # Clean up temp file
            os.remove(temp_video_path)

            logger.info(f"Successfully uploaded video {video_tutorial.video_id} to YouTube: {video_tutorial.youtube_url}")

        except Exception as e:
            logger.error(f"YouTube upload failed for video {video_tutorial.video_id}: {e}")
            video_tutorial.youtube_upload_status = "failed"

    async def _generate_transcription(self, video_tutorial: VideoTutorial):
        """Generate video transcription using AI services"""
        try:
            # Get video file path
            content = self.db.query(Content).filter(Content.id == video_tutorial.content_id).first()
            if not content:
                raise ValueError(f"Content not found for video {video_tutorial.video_id}")

            # Download video and extract audio
            temp_dir = f"/tmp/transcription_{video_tutorial.video_id}"
            os.makedirs(temp_dir, exist_ok=True)

            temp_video_path = os.path.join(temp_dir, content.filename)
            temp_audio_path = os.path.join(temp_dir, f"{video_tutorial.video_id}.mp3")

            # Download video
            await self.minio_service.download_file(content.storage_key, temp_video_path)

            # Extract audio
            await self.video_processor.extract_audio_for_transcription(temp_video_path, temp_audio_path)

            # Transcribe audio
            transcription_result = await self.video_processor.transcribe_audio(temp_audio_path)

            # Store transcription in video metadata or separate table
            # For now, we'll store in metadata as JSON
            transcription_data = {
                'text': transcription_result['text'],
                'language': transcription_result['language'],
                'duration': transcription_result['duration'],
                'segments': transcription_result['segments'],
                'generated_at': datetime.utcnow().isoformat()
            }

            # Update video metadata
            if video_tutorial.metadata:
                video_tutorial.metadata.update({'transcription': transcription_data})
            else:
                video_tutorial.metadata = {'transcription': transcription_data}

            video_tutorial.transcription_status = "completed"

            # Cleanup
            shutil.rmtree(temp_dir, ignore_errors=True)

            logger.info(f"Generated transcription for video {video_tutorial.video_id}: {len(transcription_result['text'])} characters")

        except Exception as e:
            logger.error(f"Transcription failed for video {video_tutorial.video_id}: {e}")
            video_tutorial.transcription_status = "failed"

    async def _generate_search_tags(self, video_tutorial: VideoTutorial):
        """Generate search tags and keywords using AI analysis"""
        try:
            import openai

            # Initialize OpenAI client
            client = openai.OpenAI(api_key=settings.openai_api_key)

            # Prepare content for analysis
            content_to_analyze = f"""
            Title: {video_tutorial.title}
            Description: {video_tutorial.description or ''}
            Category: {video_tutorial.category}
            Difficulty: {video_tutorial.difficulty_level}
            Target Audience: {', '.join(video_tutorial.target_audience or [])}
            Policy Types: {', '.join(video_tutorial.policy_types or [])}
            Language: {video_tutorial.language}
            """

            # Add transcription if available
            if video_tutorial.metadata and 'transcription' in video_tutorial.metadata:
                transcription = video_tutorial.metadata['transcription']
                content_to_analyze += f"\nTranscription: {transcription['text'][:1000]}"  # First 1000 chars

            # Generate tags using AI
            prompt = f"""
            Analyze the following video tutorial content and generate relevant search tags and keywords.

            Content:
            {content_to_analyze}

            Generate:
            1. 5-10 primary keywords that users might search for
            2. Related terms and synonyms
            3. Category-specific tags
            4. Difficulty-appropriate terms

            Return as a JSON array of strings, focusing on terms that insurance customers would actually search for.
            """

            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=200,
                temperature=0.3
            )

            # Parse AI response
            ai_response = response.choices[0].message.content.strip()
            try:
                # Try to parse as JSON first
                tags = json.loads(ai_response)
            except:
                # Fallback: extract tags from text
                tags = [tag.strip() for tag in ai_response.replace('[', '').replace(']', '').replace('"', '').split(',') if tag.strip()]

            # Add base tags
            base_tags = [video_tutorial.category, video_tutorial.difficulty_level, video_tutorial.language]
            if video_tutorial.policy_types:
                base_tags.extend(video_tutorial.policy_types)
            if video_tutorial.target_audience:
                base_tags.extend(video_tutorial.target_audience)

            # Combine and deduplicate
            all_tags = list(set(base_tags + tags))
            video_tutorial.search_tags = all_tags[:50]  # Limit to 50 tags

            # Generate keywords from transcription if available
            keywords = self._extract_keywords_from_transcription(video_tutorial)
            video_tutorial.keywords = keywords

            logger.info(f"Generated {len(video_tutorial.search_tags)} search tags for video {video_tutorial.video_id}")

        except Exception as e:
            logger.error(f"Tag generation failed for video {video_tutorial.video_id}: {e}")
            # Fallback to basic tags
            base_tags = [video_tutorial.category, video_tutorial.difficulty_level, video_tutorial.language]
            if video_tutorial.policy_types:
                base_tags.extend(video_tutorial.policy_types)
            video_tutorial.search_tags = base_tags

    async def _calculate_recommendation_score(
        self,
        video: VideoTutorial,
        user_id: str,
        intent_query: Optional[str],
        context: Optional[Dict[str, Any]],
        user_progress: List[VideoProgress]
    ) -> float:
        """Calculate recommendation score for a video"""

        score = 0.0

        # Intent matching score (35% weight)
        if intent_query:
            intent_score = await self._calculate_intent_match_score(video, intent_query)
            score += intent_score * 0.35

        # Learning history score (25% weight)
        history_score = self._calculate_learning_history_score(video, user_progress)
        score += history_score * 0.25

        # Policy context score (20% weight)
        if context and context.get("policy_types"):
            context_score = self._calculate_policy_context_score(video, context["policy_types"])
            score += context_score * 0.20

        # Agent expertise score (15% weight) - based on agent's video performance
        agent_score = await self._calculate_agent_expertise_score(video.agent_id)
        score += agent_score * 0.15

        # Content freshness score (5% weight)
        freshness_score = self._calculate_freshness_score(video)
        score += freshness_score * 0.05

        return min(score, 1.0)  # Cap at 1.0

    async def _calculate_intent_match_score(self, video: VideoTutorial, query: str) -> float:
        """Calculate how well video matches user intent"""
        # Simple keyword matching - in production, use semantic similarity
        query_lower = query.lower()
        title_match = query_lower in video.title.lower()
        desc_match = video.description and query_lower in video.description.lower()
        tag_match = video.search_tags and any(query_lower in tag for tag in video.search_tags)

        if title_match:
            return 0.9
        elif desc_match or tag_match:
            return 0.7
        else:
            return 0.3

    def _calculate_learning_history_score(self, video: VideoTutorial, user_progress: List[VideoProgress]) -> float:
        """Calculate score based on user's learning history"""
        # Favor videos in categories user has engaged with
        category_completions = {}
        for progress in user_progress:
            if progress.is_completed:
                # This would need to be optimized with proper joins
                category_completions[video.category] = category_completions.get(video.category, 0) + 1

        if video.category in category_completions:
            return min(category_completions[video.category] * 0.2, 1.0)
        return 0.1

    def _calculate_policy_context_score(self, video: VideoTutorial, policy_types: List[str]) -> float:
        """Calculate score based on policy context relevance"""
        if not video.policy_types:
            return 0.0

        matching_policies = set(video.policy_types) & set(policy_types)
        if matching_policies:
            return min(len(matching_policies) * 0.3, 1.0)
        return 0.0

    def _calculate_freshness_score(self, video: VideoTutorial) -> float:
        """Calculate score based on content freshness"""
        if not video.created_at:
            return 0.5

        days_old = (datetime.utcnow() - video.created_at).days
        if days_old < 7:
            return 1.0
        elif days_old < 30:
            return 0.8
        elif days_old < 90:
            return 0.6
        else:
            return 0.3

    async def _update_video_analytics(self, video_id: str):
        """Update video analytics after user interaction"""
        # Calculate updated metrics for the video
        progress_records = self.db.query(VideoProgress).filter(VideoProgress.video_id == video_id).all()

        if progress_records:
            total_watch_time = sum(p.watch_time_seconds for p in progress_records)
            total_completions = sum(1 for p in progress_records if p.is_completed)
            completion_rate = total_completions / len(progress_records)

            # Update video record
            video = self.db.query(VideoTutorial).filter(VideoTutorial.id == video_id).first()
            if video:
                video.average_watch_time = total_watch_time / len(progress_records)
                video.completion_rate = completion_rate * 100  # Store as percentage
                video.view_count = len(progress_records)

                self.db.commit()

    async def _create_content_record(self, **kwargs) -> Dict[str, Any]:
        """Create content record in database"""
        content_record = Content(
            content_id=kwargs["content_id"],
            filename=kwargs["filename"],
            original_filename=kwargs["filename"],
            storage_key=kwargs["storage_key"],
            media_url=kwargs["media_url"],
            file_hash=kwargs["file_hash"],
            file_size=kwargs["file_size"],
            mime_type="video/mp4",  # Default, will be updated during processing
            content_type=kwargs["content_type"],
            category=kwargs["category"],
            uploader_id=kwargs["uploader_id"],
            owner_id=kwargs["uploader_id"],
            tags=kwargs["tags"],
            metadata=kwargs["metadata"],
            status="active",
            processing_status="pending"
        )

        self.db.add(content_record)
        self.db.commit()
        self.db.refresh(content_record)

        return {
            "id": content_record.id,
            "content_id": content_record.content_id,
            "storage_key": content_record.storage_key,
            "media_url": content_record.media_url,
            "file_size": content_record.file_size
        }

    async def __aenter__(self):
        return self

    def _generate_youtube_description(self, video_tutorial: VideoTutorial) -> str:
        """Generate YouTube description for video"""
        description = f"{video_tutorial.description or ''}\n\n"

        # Add agent information
        description += f"Created by: {video_tutorial.agent_name}\n"

        # Add policy information if available
        if video_tutorial.policy_types:
            description += f"Related Policies: {', '.join(video_tutorial.policy_types)}\n"

        # Add category and tags
        description += f"Category: {video_tutorial.category}\n"
        if video_tutorial.search_tags:
            description += f"Tags: {', '.join(video_tutorial.search_tags[:10])}\n"

        # Add call-to-action
        description += "\nDownload the Agent Mitra app for more insurance tutorials and personalized assistance.\n"
        description += "#Insurance #Tutorial #AgentMitra"

        return description[:5000]  # YouTube description limit

    def _generate_youtube_tags(self, video_tutorial: VideoTutorial) -> List[str]:
        """Generate YouTube tags for video"""
        tags = []

        # Add base tags
        tags.extend(["AgentMitra", "Insurance", "Tutorial", "InsuranceTutorial"])

        # Add category-specific tags
        if video_tutorial.category:
            tags.append(video_tutorial.category.replace("_", ""))

        # Add difficulty level
        if video_tutorial.difficulty_level:
            tags.append(video_tutorial.difficulty_level)

        # Add policy types
        if video_tutorial.policy_types:
            tags.extend(video_tutorial.policy_types[:5])  # Limit to 5 policy tags

        # Add search tags
        if video_tutorial.search_tags:
            tags.extend(video_tutorial.search_tags[:10])  # Limit to 10 tags

        # Clean and limit tags (YouTube allows max 500 chars total)
        tags = [tag.replace(" ", "").replace("-", "") for tag in tags if tag]
        tags = tags[:15]  # Limit to 15 tags

        return tags

    async def _calculate_agent_expertise_score(self, agent_id: str) -> float:
        """Calculate agent expertise score based on their video performance"""
        try:
            # Get agent's video statistics
            agent_videos = self.db.query(VideoTutorial).filter(VideoTutorial.agent_id == agent_id).all()

            if not agent_videos:
                return 0.5  # Default score for new agents

            total_views = sum(video.view_count for video in agent_videos)
            total_ratings = sum(video.rating_count for video in agent_videos)
            avg_rating = sum(video.rating or 0 for video in agent_videos) / len(agent_videos) if agent_videos else 0
            total_completion_rate = sum(video.completion_rate for video in agent_videos) / len(agent_videos) if agent_videos else 0

            # Calculate expertise score (0-1 scale)
            # Weight: views (30%), ratings (30%), avg_rating (20%), completion_rate (20%)
            views_score = min(total_views / 10000, 1)  # Cap at 10k views = 1.0
            ratings_score = min(total_ratings / 100, 1)  # Cap at 100 ratings = 1.0
            rating_score = (avg_rating / 5.0) if avg_rating > 0 else 0.5  # 5-star scale
            completion_score = total_completion_rate / 100.0  # Percentage to decimal

            expertise_score = (
                views_score * 0.3 +
                ratings_score * 0.3 +
                rating_score * 0.2 +
                completion_score * 0.2
            )

            return min(expertise_score, 1.0)

        except Exception as e:
            logger.warning(f"Failed to calculate agent expertise score for {agent_id}: {e}")
            return 0.5

    def _extract_keywords_from_transcription(self, video_tutorial: VideoTutorial) -> List[str]:
        """Extract important keywords from transcription"""
        keywords = []

        if video_tutorial.metadata and 'transcription' in video_tutorial.metadata:
            transcription = video_tutorial.metadata['transcription']
            text = transcription.get('text', '')

            # Simple keyword extraction (in production, use NLP libraries)
            # Look for important insurance terms
            insurance_terms = [
                'premium', 'policy', 'claim', 'payment', 'coverage', 'insurance',
                'agent', 'customer', 'document', 'form', 'application', 'renewal',
                'benefit', 'term', 'life insurance', 'health insurance', 'ulip',
                'investment', 'saving', 'tax', 'nominee', 'maturity'
            ]

            for term in insurance_terms:
                if term.lower() in text.lower():
                    keywords.append(term)

            # Limit to top 10 keywords
            keywords = keywords[:10]

        return keywords

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.http_client.aclose()
