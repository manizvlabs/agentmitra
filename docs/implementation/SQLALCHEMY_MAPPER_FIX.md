# SQLAlchemy Mapper Configuration Fix

## Problem

SQLAlchemy is trying to resolve the `NotificationSettings` relationship when initializing the `User` mapper, but it can't find the class name. This causes a 500 Internal Server Error on the login endpoint.

## Root Cause

SQLAlchemy tries to configure mappers during class definition, not after all imports are complete. Even though we import `NotificationSettings` before `User`, SQLAlchemy's mapper initialization happens eagerly when the `User` class is defined with relationships.

## Solution Implemented

1. **Import Order**: Ensured `NotificationSettings` is imported before `User` in `__init__.py`
2. **Deferred Mapper Configuration**: Added `configure_all_mappers()` function that's called explicitly in `main.py` startup event
3. **String-based Relationships**: Using string references for relationships to allow lazy resolution

## Current Status

- ✅ Relationships restored in User, NotificationSettings, and DeviceToken models
- ✅ Mapper configuration function added to `__init__.py`
- ✅ Mapper configuration called in `main.py` startup event
- ⚠️ Error still persists - SQLAlchemy resolves relationships during class definition

## Next Steps

The issue requires one of these approaches:

1. **Remove relationships temporarily** - Comment out the problematic relationships and access data via direct queries
2. **Use mapper_configured event** - Set up an event listener to configure relationships after all models are loaded
3. **Lazy relationship configuration** - Use a different pattern that doesn't require immediate resolution
4. **Check Docker container** - Ensure notification.py file is properly copied into the container

## Files Modified

- `backend/app/models/user.py` - Restored relationships
- `backend/app/models/notification.py` - Restored relationships  
- `backend/app/models/__init__.py` - Added `configure_all_mappers()` function
- `backend/main.py` - Added mapper configuration call in startup event

## Testing

Login endpoint still returns 500 Internal Server Error due to mapper initialization error.

