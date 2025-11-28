# Predictive analytics for churn risk and ROI forecasting
from typing import Dict, List, Any, Optional
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, mean_squared_error
import joblib
import os
import numpy as np
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

class PredictiveAnalyticsService:
    def __init__(self, db=None):
        self.db = db
        self.models_dir = "models"
        os.makedirs(self.models_dir, exist_ok=True)

        self.churn_model_path = os.path.join(self.models_dir, "churn_prediction_model.pkl")
        self.churn_scaler_path = os.path.join(self.models_dir, "churn_feature_scaler.pkl")
        self.roi_model_path = os.path.join(self.models_dir, "roi_forecast_model.pkl")
        self.roi_scaler_path = os.path.join(self.models_dir, "roi_feature_scaler.pkl")

        self.churn_model = None
        self.churn_scaler = None
        self.roi_model = None
        self.roi_scaler = None

    async def predict_churn_risk(self, user_id: str) -> Dict[str, Any]:
        """Predict churn risk for a user based on behavior patterns"""
        try:
            # Gather user behavior data
            user_data = await self._gather_user_behavior_data(user_id)
            if not user_data:
                return self._get_default_churn_response(user_id)

            # Load or train model
            model, scaler = await self._load_or_train_churn_model()

            # Make prediction
            features = scaler.transform([user_data['features']])
            churn_probability = float(model.predict_proba(features)[0][1])

            # Determine risk level
            risk_level = self._calculate_risk_level(churn_probability)

            # Generate recommendations
            recommendations = self._generate_churn_recommendations(risk_level, user_data)

            return {
                "user_id": user_id,
                "churn_probability": churn_probability,
                "risk_level": risk_level,
                "recommendations": recommendations,
                "confidence_score": 0.85,  # Model confidence
                "prediction_timestamp": datetime.utcnow().isoformat(),
                "data_points_used": len(user_data['features'])
            }
        except Exception as e:
            logger.error(f"Error predicting churn risk for user {user_id}: {e}")
            return self._get_default_churn_response(user_id)

    async def forecast_roi(self, agent_id: str, months_ahead: int = 6) -> Dict[str, Any]:
        """Forecast ROI for an agent over the next N months"""
        try:
            # Gather historical ROI data
            historical_data = await self._gather_agent_roi_history(agent_id)
            if not historical_data:
                return self._get_default_roi_response(agent_id, months_ahead)

            # Load or train model
            model, scaler = await self._load_or_train_roi_model()

            # Generate forecast
            forecast_data = self._generate_roi_forecast(historical_data, months_ahead, model, scaler)

            return {
                "agent_id": agent_id,
                "current_roi": historical_data[-1]['roi'] if historical_data else 0,
                "forecasted_roi": forecast_data['forecasted_roi'],
                "confidence_interval": forecast_data['confidence_interval'],
                "trend": forecast_data['trend'],
                "recommendations": self._generate_roi_recommendations(forecast_data['forecasted_roi']),
                "forecast_period_months": months_ahead,
                "historical_data_points": len(historical_data),
                "prediction_timestamp": datetime.utcnow().isoformat()
            }
        except Exception as e:
            logger.error(f"Error forecasting ROI for agent {agent_id}: {e}")
            return self._get_default_roi_response(agent_id, months_ahead)

    async def _gather_user_behavior_data(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Gather user behavior data for churn prediction"""
        try:
            # This would query multiple tables for user behavior patterns
            # For now, we'll simulate with some basic queries

            # Check user login patterns
            login_query = """
            SELECT COUNT(*) as login_count,
                   MAX(last_login) as last_login,
                   AVG(login_frequency) as avg_frequency
            FROM user_sessions
            WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '30 days'
            """

            # Check feature usage
            feature_query = """
            SELECT feature_name, COUNT(*) as usage_count
            FROM user_feature_usage
            WHERE user_id = $1 AND used_at >= NOW() - INTERVAL '30 days'
            GROUP BY feature_name
            """

            # Check engagement metrics
            engagement_query = """
            SELECT AVG(session_duration) as avg_session_time,
                   COUNT(DISTINCT DATE(created_at)) as active_days
            FROM user_sessions
            WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '30 days'
            """

            # Simulate data gathering (replace with actual queries)
            login_data = {"login_count": 15, "last_login_days": 2, "avg_frequency": 0.8}
            feature_usage = {"dashboard": 20, "policies": 5, "chatbot": 8, "learning": 3}
            engagement = {"avg_session_time": 450, "active_days": 12}

            # Convert to feature vector
            features = [
                login_data["login_count"] / 30.0,  # Normalized login frequency
                min(login_data["last_login_days"] / 7.0, 1.0),  # Days since last login (capped at 1 week)
                login_data["avg_frequency"],  # Login frequency score
                len(feature_usage),  # Number of features used
                sum(feature_usage.values()) / 100.0,  # Total feature interactions
                engagement["avg_session_time"] / 600.0,  # Session time (normalized)
                engagement["active_days"] / 30.0,  # Active days ratio
            ]

            return {
                "features": features,
                "activity_score": sum(features) / len(features),
                "engagement_score": (engagement["avg_session_time"] / 600.0 + engagement["active_days"] / 30.0) / 2,
                "last_login_days": login_data["last_login_days"],
                "feature_usage_count": sum(feature_usage.values()),
                "raw_data": {
                    "login_data": login_data,
                    "feature_usage": feature_usage,
                    "engagement": engagement
                }
            }
        except Exception as e:
            logger.error(f"Error gathering behavior data for user {user_id}: {e}")
            return None

    async def _gather_agent_roi_history(self, agent_id: str) -> List[Dict[str, Any]]:
        """Gather historical ROI data for an agent"""
        try:
            # Query for historical ROI data
            # This would aggregate commission data, policy sales, etc.

            roi_query = """
            SELECT DATE_TRUNC('month', created_at) as month,
                   SUM(commission_amount) as total_commission,
                   SUM(premium_amount) as total_premium,
                   COUNT(DISTINCT policy_id) as policies_sold
            FROM agent_commissions
            WHERE agent_id = $1 AND created_at >= NOW() - INTERVAL '12 months'
            GROUP BY DATE_TRUNC('month', created_at)
            ORDER BY month
            """

            # Simulate historical ROI data (replace with actual query)
            historical_data = []
            base_date = datetime.utcnow().replace(day=1)

            for i in range(12):
                month_date = base_date - timedelta(days=30 * (11 - i))
                # Simulate ROI with some trend and seasonality
                base_roi = 15.0  # Base ROI percentage
                trend = i * 0.5  # Upward trend
                seasonal = np.sin(i * np.pi / 6) * 2  # Seasonal variation
                noise = np.random.normal(0, 1)  # Random noise

                roi = max(5.0, min(35.0, base_roi + trend + seasonal + noise))

                historical_data.append({
                    "month": month_date.isoformat(),
                    "roi": round(roi, 2),
                    "total_commission": round(roi * 1000, 2),  # Simulated commission
                    "policies_sold": int(roi / 2) + 5  # Simulated policy count
                })

            return historical_data
        except Exception as e:
            logger.error(f"Error gathering ROI history for agent {agent_id}: {e}")
            return []

    async def _load_or_train_churn_model(self):
        """Load pre-trained churn model or train new one"""
        if os.path.exists(self.churn_model_path) and os.path.exists(self.churn_scaler_path):
            try:
                model = joblib.load(self.churn_model_path)
                scaler = joblib.load(self.churn_scaler_path)
                logger.info("Loaded existing churn prediction model")
                return model, scaler
            except Exception as e:
                logger.warning(f"Error loading churn model: {e}")

        # Train new model
        logger.info("Training new churn prediction model")
        model, scaler = await self._train_churn_model()
        return model, scaler

    async def _load_or_train_roi_model(self):
        """Load pre-trained ROI model or train new one"""
        if os.path.exists(self.roi_model_path) and os.path.exists(self.roi_scaler_path):
            try:
                model = joblib.load(self.roi_model_path)
                scaler = joblib.load(self.roi_scaler_path)
                logger.info("Loaded existing ROI forecast model")
                return model, scaler
            except Exception as e:
                logger.warning(f"Error loading ROI model: {e}")

        # Train new model
        logger.info("Training new ROI forecast model")
        model, scaler = await self._train_roi_model()
        return model, scaler

    async def _train_churn_model(self):
        """Train churn prediction model with historical data"""
        # Generate synthetic training data
        np.random.seed(42)

        # Create realistic feature data
        n_samples = 10000
        features = []

        for _ in range(n_samples):
            # Simulate user behavior features
            login_freq = np.random.exponential(0.5)  # Login frequency
            days_since_login = np.random.exponential(3)  # Days since last login
            session_time = np.random.normal(400, 100)  # Session time
            features_used = np.random.poisson(3)  # Number of features used
            total_interactions = np.random.poisson(50)  # Total interactions

            features.append([
                min(login_freq, 2.0),  # Cap at 2.0
                min(days_since_login / 7.0, 4.0),  # Weeks since login, cap at 4
                max(0, min(session_time / 600.0, 2.0)),  # Normalized session time
                min(features_used / 10.0, 1.0),  # Normalized features used
                min(total_interactions / 200.0, 1.0),  # Normalized interactions
            ])

        # Generate churn labels (churn if low engagement + long time since login)
        labels = []
        for feature in features:
            churn_prob = 0.1  # Base churn probability
            if feature[1] > 2.0:  # High days since login
                churn_prob += 0.3
            if feature[0] < 0.3:  # Low login frequency
                churn_prob += 0.2
            if feature[2] < 0.3:  # Low session time
                churn_prob += 0.2
            if feature[3] < 0.2:  # Few features used
                churn_prob += 0.2

            churn_prob = min(churn_prob, 0.9)  # Cap at 90%
            labels.append(1 if np.random.random() < churn_prob else 0)

        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            features, labels, test_size=0.2, random_state=42, stratify=labels
        )

        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train model
        model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            class_weight='balanced'
        )
        model.fit(X_train_scaled, y_train)

        # Evaluate model
        y_pred = model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)
        logger.info(f"Churn model trained with accuracy: {accuracy:.3f}")

        # Save model
        joblib.dump(model, self.churn_model_path)
        joblib.dump(scaler, self.churn_scaler_path)

        return model, scaler

    async def _train_roi_model(self):
        """Train ROI forecasting model with historical data"""
        # Generate synthetic training data
        np.random.seed(123)

        n_samples = 5000
        features = []
        targets = []

        for _ in range(n_samples):
            # Agent features
            experience_years = np.random.exponential(2)  # Years of experience
            policies_sold_monthly = np.random.poisson(8)  # Policies per month
            commission_rate = np.random.normal(0.15, 0.03)  # Commission rate
            region_performance = np.random.normal(1.0, 0.2)  # Regional performance factor
            marketing_spend = np.random.exponential(5000)  # Monthly marketing spend

            # Target ROI (with some realistic relationships)
            base_roi = 12.0
            experience_bonus = min(experience_years * 0.5, 3.0)
            policy_bonus = min(policies_sold_monthly * 0.3, 4.0)
            commission_bonus = (commission_rate - 0.12) * 20
            region_bonus = (region_performance - 1.0) * 5
            marketing_penalty = marketing_spend / 10000.0

            roi = base_roi + experience_bonus + policy_bonus + commission_bonus + region_bonus - marketing_penalty
            roi = max(3.0, min(roi + np.random.normal(0, 2), 40.0))  # Add noise and cap

            features.append([
                min(experience_years / 10.0, 1.0),  # Normalized experience
                min(policies_sold_monthly / 20.0, 1.0),  # Normalized policies
                commission_rate,  # Commission rate (already 0-1)
                region_performance,  # Region factor
                min(marketing_spend / 20000.0, 1.0),  # Normalized marketing spend
            ])
            targets.append(roi)

        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            features, targets, test_size=0.2, random_state=42
        )

        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train model
        model = RandomForestRegressor(
            n_estimators=100,
            max_depth=10,
            random_state=42
        )
        model.fit(X_train_scaled, y_train)

        # Evaluate model
        y_pred = model.predict(X_test_scaled)
        mse = mean_squared_error(y_test, y_pred)
        rmse = np.sqrt(mse)
        logger.info(f"ROI model trained with RMSE: {rmse:.3f}")

        # Save model
        joblib.dump(model, self.roi_model_path)
        joblib.dump(scaler, self.roi_scaler_path)

        return model, scaler

    def _calculate_risk_level(self, probability: float) -> str:
        """Calculate risk level from churn probability"""
        if probability >= 0.8:
            return "critical"
        elif probability >= 0.6:
            return "high"
        elif probability >= 0.4:
            return "medium"
        else:
            return "low"

    def _generate_churn_recommendations(self, risk_level: str, user_data: Dict[str, Any]) -> List[str]:
        """Generate personalized recommendations based on risk level"""
        recommendations = []

        if risk_level in ["high", "critical"]:
            recommendations.extend([
                "Schedule a personal call with the agent within 24 hours",
                "Send personalized re-engagement email campaign",
                "Offer premium support and assistance"
            ])

        if user_data.get('last_login_days', 0) > 7:
            recommendations.append("Send re-engagement email with login reminder")

        if user_data.get('feature_usage_count', 0) < 10:
            recommendations.append("Recommend key features through targeted tutorials")

        if user_data.get('engagement_score', 0) < 0.3:
            recommendations.append("Create personalized learning path for better engagement")

        return recommendations[:5]  # Limit to top 5 recommendations

    def _generate_roi_forecast(self, historical_data: List[Dict], months: int, model, scaler) -> Dict[str, Any]:
        """Generate ROI forecast using trained model"""
        if not historical_data:
            return {"forecasted_roi": 12.0, "confidence_interval": {"lower": 8.0, "upper": 16.0}, "trend": "stable"}

        # Extract recent features
        recent_data = historical_data[-3:] if len(historical_data) >= 3 else historical_data
        avg_roi = sum(d['roi'] for d in recent_data) / len(recent_data)
        avg_policies = sum(d['policies_sold'] for d in recent_data) / len(recent_data)
        avg_commission = sum(d['total_commission'] for d in recent_data) / len(recent_data)

        # Create feature vector (simplified)
        features = [
            0.5,  # Placeholder for experience (would be actual data)
            min(avg_policies / 20.0, 1.0),  # Normalized policies
            0.15,  # Placeholder for commission rate
            1.0,  # Placeholder for region performance
            0.25,  # Placeholder for marketing spend
        ]

        # Make prediction
        features_scaled = scaler.transform([features])
        forecasted_roi = float(model.predict(features_scaled)[0])

        # Calculate trend
        if len(historical_data) >= 2:
            recent_trend = historical_data[-1]['roi'] - historical_data[-2]['roi']
            if recent_trend > 1.0:
                trend = "increasing"
            elif recent_trend < -1.0:
                trend = "decreasing"
            else:
                trend = "stable"
        else:
            trend = "insufficient_data"

        # Add some uncertainty to forecast
        confidence_margin = 0.15  # 15% confidence interval
        confidence_interval = {
            "lower": round(max(0, forecasted_roi * (1 - confidence_margin)), 2),
            "upper": round(forecasted_roi * (1 + confidence_margin), 2)
        }

        return {
            "forecasted_roi": round(forecasted_roi, 2),
            "confidence_interval": confidence_interval,
            "trend": trend
        }

    def _generate_roi_recommendations(self, forecasted_roi: float) -> List[str]:
        """Generate ROI improvement recommendations"""
        recommendations = []

        if forecasted_roi < 10.0:
            recommendations.extend([
                "Increase marketing spend in high-performing regions",
                "Focus on upselling existing customers",
                "Improve agent training and product knowledge"
            ])

        if forecasted_roi > 25.0:
            recommendations.append("Consider expanding to new regions with similar profile")

        recommendations.extend([
            "Monitor competitive commission rates",
            "Implement performance-based incentives",
            "Regular portfolio review and optimization"
        ])

        return recommendations[:4]  # Limit to top 4 recommendations

    def _get_default_churn_response(self, user_id: str) -> Dict[str, Any]:
        """Return default churn response when prediction fails"""
        return {
            "user_id": user_id,
            "churn_probability": 0.5,
            "risk_level": "medium",
            "recommendations": ["Monitor user engagement closely"],
            "confidence_score": 0.0,
            "prediction_timestamp": datetime.utcnow().isoformat(),
            "data_points_used": 0
        }

    def _get_default_roi_response(self, agent_id: str, months: int) -> Dict[str, Any]:
        """Return default ROI response when forecast fails"""
        return {
            "agent_id": agent_id,
            "current_roi": 0,
            "forecasted_roi": 12.0,
            "confidence_interval": {"lower": 8.0, "upper": 16.0},
            "trend": "unknown",
            "recommendations": ["Gather more historical data for accurate forecasting"],
            "forecast_period_months": months,
            "historical_data_points": 0,
            "prediction_timestamp": datetime.utcnow().isoformat()
        }
