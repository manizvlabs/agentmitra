#!/usr/bin/env python3
"""
Script to programmatically create FeatureHub feature flags
"""
import asyncio
import sys
from pathlib import Path

# Add backend to path
backend_dir = Path(__file__).parent.parent / "backend"
sys.path.insert(0, str(backend_dir))

from app.services.featurehub_admin_service import get_featurehub_admin_service
from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)


async def main():
    """Main function to create feature flags"""
    print("=" * 80)
    print("FEATUREHUB FLAG CREATION SCRIPT")
    print("=" * 80)
    print()
    
    print("Configuration:")
    print(f"  FeatureHub URL: {settings.featurehub_url}")
    print(f"  API Key: {'✅ Configured' if settings.featurehub_api_key else '❌ Not set'}")
    print(f"  SDK Key: {'✅ Configured' if settings.featurehub_sdk_key else '❌ Not set'}")
    print(f"  Environment: {settings.featurehub_environment}")
    print()
    
    if not settings.featurehub_api_key or not settings.featurehub_sdk_key:
        print("❌ Error: FeatureHub API keys not configured!")
        print("   Please set FEATUREHUB_API_KEY and FEATUREHUB_SDK_KEY in .env.local")
        sys.exit(1)
    
    try:
        admin_service = await get_featurehub_admin_service()
        
        # Extract IDs from SDK key
        sdk_parts = settings.featurehub_sdk_key.split('/')
        if len(sdk_parts) >= 3:
            application_id = sdk_parts[1]
            environment_id = sdk_parts[2]
        else:
            print("❌ Error: Invalid SDK key format")
            print("   Expected format: portfolio/app_id/env_id/key")
            sys.exit(1)
        
        print(f"Application ID: {application_id}")
        print(f"Environment ID: {environment_id}")
        print()
        
        # Verify application and environment exist
        print("Verifying application and environment...")
        apps = await admin_service.get_applications()
        if not apps:
            print("⚠️  Warning: Could not verify application. Continuing anyway...")
        else:
            print(f"✅ Found {len(apps)} application(s)")
        
        envs = await admin_service.get_environments(application_id)
        if not envs:
            print("⚠️  Warning: Could not verify environment. Continuing anyway...")
        else:
            print(f"✅ Found {len(envs)} environment(s)")
        print()
        
        # Create all feature flags
        print("Creating feature flags...")
        print("-" * 80)
        
        results = await admin_service.create_all_default_flags(
            application_id=application_id,
            environment_id=environment_id
        )
        
        print()
        print("=" * 80)
        print("RESULTS")
        print("=" * 80)
        print(f"✅ Created: {len(results['created'])} flags")
        print(f"⚠️  Updated: {len(results['updated'])} flags")
        print(f"❌ Failed: {len(results['failed'])} flags")
        print(f"⏭️  Skipped: {len(results['skipped'])} flags")
        print()
        
        if results['created']:
            print("Created flags:")
            for flag in results['created']:
                print(f"  ✅ {flag}")
            print()
        
        if results['failed']:
            print("Failed flags:")
            for flag in results['failed']:
                print(f"  ❌ {flag}")
            print()
        
        if results['updated']:
            print("Updated flags:")
            for flag in results['updated']:
                print(f"  ⚠️  {flag}")
            print()
        
        await admin_service.close()
        
        print("=" * 80)
        print("✅ Feature flag creation complete!")
        print("=" * 80)
        
        if len(results['created']) > 0:
            print("\nNext steps:")
            print("1. Verify flags in FeatureHub dashboard:")
            print(f"   {settings.featurehub_url}/dashboard")
            print("2. Restart backend to load flags from FeatureHub")
            print("3. Test with: curl http://localhost:8012/api/v1/feature-flags")
        
    except Exception as e:
        logger.error(f"Error creating feature flags: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())

