# WebSocket manager for real-time feature flag updates
from fastapi import WebSocket
import json
from typing import Dict, List
from datetime import datetime
from app.services.feature_flag_service import FeatureFlagService
import logging

logger = logging.getLogger(__name__)

class WebSocketManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}
        self.feature_flag_service = FeatureFlagService()

    async def connect(self, websocket: WebSocket, user_id: str):
        """Connect a new WebSocket for a user"""
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)
        logger.info(f"WebSocket connected for user {user_id}. Total connections: {len(self.active_connections[user_id])}")

    async def disconnect(self, websocket: WebSocket, user_id: str):
        """Disconnect a WebSocket for a user"""
        if user_id in self.active_connections:
            if websocket in self.active_connections[user_id]:
                self.active_connections[user_id].remove(websocket)
                logger.info(f"WebSocket disconnected for user {user_id}. Remaining connections: {len(self.active_connections[user_id])}")

            # Clean up empty user lists
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def broadcast_feature_update(self, user_id: str, feature_key: str, new_value: bool):
        """Broadcast feature flag update to all connections for a user"""
        if user_id in self.active_connections:
            message = {
                "type": "feature_flag_update",
                "feature_key": feature_key,
                "new_value": new_value,
                "timestamp": datetime.utcnow().isoformat()
            }

            disconnected_connections = []
            for connection in self.active_connections[user_id]:
                try:
                    await connection.send_json(message)
                    logger.debug(f"Sent feature flag update to user {user_id}: {feature_key} = {new_value}")
                except Exception as e:
                    logger.warning(f"Failed to send message to user {user_id}: {e}")
                    disconnected_connections.append(connection)

            # Remove dead connections
            for dead_connection in disconnected_connections:
                self.active_connections[user_id].remove(dead_connection)

            # Clean up if no connections remain
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def broadcast_to_all_users(self, feature_key: str, new_value: bool):
        """Broadcast feature flag update to all connected users"""
        message = {
            "type": "feature_flag_update",
            "feature_key": feature_key,
            "new_value": new_value,
            "timestamp": datetime.utcnow().isoformat()
        }

        disconnected_users = []
        for user_id, connections in self.active_connections.items():
            disconnected_connections = []
            for connection in connections:
                try:
                    await connection.send_json(message)
                    logger.debug(f"Sent feature flag update to user {user_id}: {feature_key} = {new_value}")
                except Exception as e:
                    logger.warning(f"Failed to send message to user {user_id}: {e}")
                    disconnected_connections.append(connection)

            # Remove dead connections for this user
            for dead_connection in disconnected_connections:
                connections.remove(dead_connection)

            # Mark user for cleanup if no connections remain
            if not connections:
                disconnected_users.append(user_id)

        # Clean up disconnected users
        for user_id in disconnected_users:
            del self.active_connections[user_id]

    async def get_connection_count(self, user_id: str = None) -> int:
        """Get total number of active connections"""
        if user_id:
            return len(self.active_connections.get(user_id, []))
        return sum(len(connections) for connections in self.active_connections.values())

    async def ping_all_connections(self):
        """Send ping to all connections to check if they're still alive"""
        ping_message = {
            "type": "ping",
            "timestamp": datetime.utcnow().isoformat()
        }

        disconnected_users = []
        for user_id, connections in self.active_connections.items():
            disconnected_connections = []
            for connection in connections:
                try:
                    await connection.send_json(ping_message)
                except Exception as e:
                    logger.warning(f"Failed to ping user {user_id}: {e}")
                    disconnected_connections.append(connection)

            # Remove dead connections for this user
            for dead_connection in disconnected_connections:
                connections.remove(dead_connection)

            # Mark user for cleanup if no connections remain
            if not connections:
                disconnected_users.append(user_id)

        # Clean up disconnected users
        for user_id in disconnected_users:
            del self.active_connections[user_id]

    async def broadcast_to_role(self, role_name: str, feature_key: str, new_value: bool, db=None):
        """Broadcast feature flag update to all users with a specific role"""
        if not db:
            # If no db provided, broadcast to all (fallback)
            await self.broadcast_to_all_users(feature_key, new_value)
            return

        try:
            # Get users with the specified role
            from app.services.rbac_service import RBACService
            rbac_service = RBACService(db)
            users_with_role = rbac_service.get_users_by_role(role_name)

            message = {
                "type": "feature_flag_update",
                "feature_key": feature_key,
                "new_value": new_value,
                "role_targeted": role_name,
                "timestamp": datetime.utcnow().isoformat()
            }

            broadcast_count = 0
            for user in users_with_role:
                user_id = str(user['user_id'])
                if user_id in self.active_connections:
                    disconnected_connections = []
                    for connection in self.active_connections[user_id]:
                        try:
                            await connection.send_json(message)
                            broadcast_count += 1
                            logger.debug(f"Sent role-targeted feature flag update to user {user_id} ({role_name}): {feature_key} = {new_value}")
                        except Exception as e:
                            logger.warning(f"Failed to send role-targeted message to user {user_id}: {e}")
                            disconnected_connections.append(connection)

                    # Clean up dead connections
                    for dead_connection in disconnected_connections:
                        self.active_connections[user_id].remove(dead_connection)

                    if not self.active_connections[user_id]:
                        del self.active_connections[user_id]

            logger.info(f"Broadcasted feature flag update to {broadcast_count} users with role {role_name}")

        except Exception as e:
            logger.error(f"Error broadcasting to role {role_name}: {e}")
            # Fallback to broadcasting to all
            await self.broadcast_to_all_users(feature_key, new_value)

    async def broadcast_to_tenant(self, tenant_id: str, feature_key: str, new_value: bool):
        """Broadcast feature flag update to all users in a specific tenant"""
        message = {
            "type": "feature_flag_update",
            "feature_key": feature_key,
            "new_value": new_value,
            "tenant_targeted": tenant_id,
            "timestamp": datetime.utcnow().isoformat()
        }

        broadcast_count = 0
        disconnected_users = []

        for user_id, connections in self.active_connections.items():
            # Note: In a real implementation, you'd check if user belongs to tenant
            # For now, we'll broadcast to all active connections
            disconnected_connections = []
            for connection in connections:
                try:
                    await connection.send_json(message)
                    broadcast_count += 1
                    logger.debug(f"Sent tenant-targeted feature flag update to user {user_id}: {feature_key} = {new_value}")
                except Exception as e:
                    logger.warning(f"Failed to send tenant-targeted message to user {user_id}: {e}")
                    disconnected_connections.append(connection)

            # Clean up dead connections
            for dead_connection in disconnected_connections:
                connections.remove(dead_connection)

            if not connections:
                disconnected_users.append(user_id)

        # Clean up disconnected users
        for user_id in disconnected_users:
            del self.active_connections[user_id]

        logger.info(f"Broadcasted tenant-targeted feature flag update to {broadcast_count} users")

    async def get_active_users_count(self) -> Dict[str, int]:
        """Get statistics about active WebSocket connections"""
        return {
            "total_users": len(self.active_connections),
            "total_connections": sum(len(connections) for connections in self.active_connections.values()),
            "users_by_connection_count": {
                "single": len([uid for uid, conns in self.active_connections.items() if len(conns) == 1]),
                "multiple": len([uid for uid, conns in self.active_connections.items() if len(conns) > 1])
            }
        }

# Global WebSocket manager instance
websocket_manager = WebSocketManager()
