"""
Database performance and health tests
"""
import pytest
import time
from unittest.mock import patch
from app.core.database import (
    check_db_connection,
    get_db_stats,
    execute_with_retry,
    get_db_config,
    get_db_session,
)
from app.core.config.settings import Settings


class TestDatabaseConfiguration:
    """Test database configuration and setup"""

    def test_get_db_config_development(self):
        """Test development database configuration"""
        with patch('app.core.database.settings') as mock_settings:
            mock_settings.environment = "development"
            mock_settings.debug = True

            config = get_db_config()

            assert config["poolclass"].__name__ == "NullPool"
            assert config["echo"] is True
            assert "pool_pre_ping" in config

    def test_get_db_config_production(self):
        """Test production database configuration"""
        with patch('app.core.database.settings') as mock_settings:
            mock_settings.environment = "production"
            mock_settings.database_url = "postgresql://user:pass@host:5432/db?sslmode=require"

            config = get_db_config()

            assert config["poolclass"].__name__ == "QueuePool"
            assert config["pool_size"] == 20
            assert config["max_overflow"] == 30
            assert config["echo"] is False

    def test_get_db_config_staging(self):
        """Test staging database configuration"""
        with patch('app.core.database.settings') as mock_settings:
            mock_settings.environment = "staging"

            config = get_db_config()

            assert config["poolclass"].__name__ == "QueuePool"
            assert config["pool_size"] == 10
            assert config["max_overflow"] == 10


class TestDatabaseHealth:
    """Test database health monitoring"""

    def test_check_db_connection_success(self, db_session):
        """Test successful database connection check"""
        result = check_db_connection()

        assert result["status"] == "healthy"
        assert "response_time_ms" in result
        assert isinstance(result["response_time_ms"], (int, float))
        assert result["response_time_ms"] > 0

    def test_get_db_stats(self):
        """Test database pool statistics"""
        stats = get_db_stats()

        assert "pool_class" in stats
        assert "checked_at" in stats
        assert isinstance(stats["checked_at"], float)

    def test_execute_with_retry_success(self):
        """Test successful query execution with retry"""
        result = execute_with_retry("SELECT 1 as test")

        assert result is not None
        assert len(result) == 1
        assert result[0][0] == 1

    def test_execute_with_retry_failure(self):
        """Test query execution failure and retry"""
        # This should eventually fail after retries
        with pytest.raises(Exception):
            execute_with_retry("SELECT * FROM nonexistent_table")

    def test_db_session_context_manager(self, db_session):
        """Test database session context manager"""
        with get_db_session() as session:
            # Execute a simple query
            result = session.execute("SELECT 1").fetchone()
            assert result[0] == 1
            # Session should commit automatically

        # Session should be closed
        assert session.is_active is False


class TestDatabasePerformance:
    """Test database performance under load"""

    def test_connection_pool_performance(self, db_session):
        """Test connection pool performance"""
        start_time = time.time()

        # Execute multiple queries to test connection reuse
        for i in range(10):
            result = db_session.execute("SELECT 1").fetchone()
            assert result[0] == 1

        end_time = time.time()
        total_time = end_time - start_time

        # Should complete in reasonable time (less than 1 second)
        assert total_time < 1.0

    def test_query_performance(self, db_session):
        """Test query performance"""
        start_time = time.time()

        # Execute a more complex query
        result = db_session.execute("""
            SELECT COUNT(*) as count
            FROM information_schema.tables
            WHERE table_schema = 'lic_schema'
        """).fetchone()

        end_time = time.time()
        query_time = end_time - start_time

        # Should complete quickly
        assert query_time < 0.1
        assert result[0] >= 0  # Should return a count

    @pytest.mark.parametrize("query_count", [1, 5, 10])
    def test_concurrent_query_performance(self, db_session, query_count):
        """Test performance with multiple concurrent queries"""
        start_time = time.time()

        results = []
        for i in range(query_count):
            result = db_session.execute(f"SELECT {i} as num").fetchone()
            results.append(result[0])

        end_time = time.time()
        total_time = end_time - start_time

        # Verify all queries executed
        assert len(results) == query_count
        assert results == list(range(query_count))

        # Performance check - should be reasonably fast
        avg_time_per_query = total_time / query_count
        assert avg_time_per_query < 0.01  # Less than 10ms per query


class TestDatabaseMigration:
    """Test database migration and schema integrity"""

    def test_schema_tables_exist(self, db_session):
        """Test that all required tables exist"""
        required_tables = [
            "users", "user_sessions", "agents", "insurance_policies",
            "premium_payments", "presentations", "presentation_slides",
            "presentation_templates", "presentation_analytics"
        ]

        for table in required_tables:
            result = db_session.execute(f"""
                SELECT EXISTS (
                    SELECT 1
                    FROM information_schema.tables
                    WHERE table_schema = 'lic_schema'
                    AND table_name = '{table}'
                )
            """).fetchone()

            assert result[0] is True, f"Table {table} does not exist"

    def test_indexes_exist(self, db_session):
        """Test that performance indexes exist"""
        required_indexes = [
            "idx_users_phone_verified",
            "idx_agents_code_status",
            "idx_presentations_agent_status",
            "idx_slides_presentation_order"
        ]

        for index in required_indexes:
            result = db_session.execute(f"""
                SELECT EXISTS (
                    SELECT 1
                    FROM pg_indexes
                    WHERE schemaname = 'lic_schema'
                    AND indexname = '{index}'
                )
            """).fetchone()

            assert result[0] is True, f"Index {index} does not exist"

    def test_foreign_keys_exist(self, db_session):
        """Test that foreign key constraints exist"""
        # Test users -> user_sessions relationship
        result = db_session.execute("""
            SELECT EXISTS (
                SELECT 1
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
                WHERE tc.table_schema = 'lic_schema'
                AND tc.table_name = 'user_sessions'
                AND tc.constraint_type = 'FOREIGN KEY'
                AND kcu.column_name = 'user_id'
            )
        """).fetchone()

        assert result[0] is True, "Foreign key constraint missing for user_sessions.user_id"
