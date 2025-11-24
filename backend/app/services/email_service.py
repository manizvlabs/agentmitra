"""
Email Service for sending emails via SMTP
Supports Gmail and other SMTP providers
"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Optional, Dict, Any
from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class EmailService:
    """Email service for sending emails via SMTP"""
    
    def __init__(self):
        self.smtp_host = settings.email_host
        self.smtp_port = settings.email_port
        self.smtp_user = settings.email_user
        self.smtp_password = settings.email_password
        self.from_email = settings.email_from or settings.email_user
        
    def _get_smtp_connection(self) -> smtplib.SMTP:
        """Create and return SMTP connection"""
        try:
            # Use TLS for port 587, SSL for port 465
            if self.smtp_port == 465:
                smtp = smtplib.SMTP_SSL(self.smtp_host, self.smtp_port)
            else:
                smtp = smtplib.SMTP(self.smtp_host, self.smtp_port)
                smtp.starttls()
            
            # Login if credentials provided
            if self.smtp_user and self.smtp_password:
                smtp.login(self.smtp_user, self.smtp_password)
            
            return smtp
        except Exception as e:
            logger.error(f"Failed to create SMTP connection: {e}")
            raise
    
    def send_email(
        self,
        to_email: str,
        subject: str,
        html_body: str,
        text_body: Optional[str] = None
    ) -> bool:
        """
        Send email via SMTP
        
        Args:
            to_email: Recipient email address
            subject: Email subject
            html_body: HTML email body
            text_body: Plain text email body (optional, auto-generated from HTML if not provided)
        
        Returns:
            True if email sent successfully, False otherwise
        """
        if not self.smtp_user or not self.smtp_password:
            logger.warning("Email credentials not configured. Email sending disabled.")
            # In development, log the email instead of sending
            if settings.environment == "development":
                logger.info(f"[DEV MODE] Would send email to {to_email}")
                logger.info(f"Subject: {subject}")
                logger.info(f"Body: {html_body}")
                return True
            return False
        
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From'] = self.from_email
            msg['To'] = to_email
            
            # Create plain text version if not provided
            if not text_body:
                # Simple HTML to text conversion
                text_body = html_body.replace('<br>', '\n').replace('<br/>', '\n')
                text_body = text_body.replace('<p>', '').replace('</p>', '\n\n')
                # Remove HTML tags (simple approach)
                import re
                text_body = re.sub(r'<[^>]+>', '', text_body)
            
            # Add both plain text and HTML parts
            part1 = MIMEText(text_body, 'plain')
            part2 = MIMEText(html_body, 'html')
            
            msg.attach(part1)
            msg.attach(part2)
            
            # Send email
            with self._get_smtp_connection() as smtp:
                smtp.send_message(msg)
            
            logger.info(f"Email sent successfully to {to_email}")
            return True
            
        except smtplib.SMTPAuthenticationError as e:
            logger.error(f"SMTP authentication failed: {e}")
            logger.error("Please check your email credentials and App Password")
            return False
        except smtplib.SMTPException as e:
            logger.error(f"SMTP error while sending email: {e}")
            return False
        except Exception as e:
            logger.error(f"Failed to send email to {to_email}: {e}")
            return False
    
    def send_otp_email(self, to_email: str, otp: str) -> bool:
        """
        Send OTP email to user
        
        Args:
            to_email: Recipient email address
            otp: 6-digit OTP code
        
        Returns:
            True if email sent successfully, False otherwise
        """
        subject = "Agent Mitra - Verification Code"
        
        html_body = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }}
                .container {{
                    background-color: #f9f9f9;
                    border-radius: 8px;
                    padding: 30px;
                    border: 1px solid #e0e0e0;
                }}
                .header {{
                    text-align: center;
                    margin-bottom: 30px;
                }}
                .logo {{
                    font-size: 24px;
                    font-weight: bold;
                    color: #1976d2;
                }}
                .otp-box {{
                    background-color: #ffffff;
                    border: 2px dashed #1976d2;
                    border-radius: 8px;
                    padding: 20px;
                    text-align: center;
                    margin: 30px 0;
                }}
                .otp-code {{
                    font-size: 32px;
                    font-weight: bold;
                    color: #1976d2;
                    letter-spacing: 8px;
                    font-family: 'Courier New', monospace;
                }}
                .footer {{
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 1px solid #e0e0e0;
                    font-size: 12px;
                    color: #666;
                    text-align: center;
                }}
                .warning {{
                    background-color: #fff3cd;
                    border-left: 4px solid #ffc107;
                    padding: 12px;
                    margin: 20px 0;
                    border-radius: 4px;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <div class="logo">Agent Mitra</div>
                </div>
                
                <h2>Verification Code</h2>
                
                <p>Hello,</p>
                
                <p>You requested a verification code for your Agent Mitra account. Use the code below to complete your verification:</p>
                
                <div class="otp-box">
                    <div class="otp-code">{otp}</div>
                </div>
                
                <div class="warning">
                    <strong>⚠️ Security Notice:</strong>
                    <ul style="margin: 8px 0; padding-left: 20px;">
                        <li>This code will expire in 5 minutes</li>
                        <li>Never share this code with anyone</li>
                        <li>If you didn't request this code, please ignore this email</li>
                    </ul>
                </div>
                
                <p>If you didn't request this verification code, you can safely ignore this email.</p>
                
                <div class="footer">
                    <p>This is an automated message from Agent Mitra. Please do not reply to this email.</p>
                    <p>&copy; {settings.app_name} - All rights reserved</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        text_body = f"""
Agent Mitra - Verification Code

Hello,

You requested a verification code for your Agent Mitra account. Use the code below to complete your verification:

Verification Code: {otp}

⚠️ Security Notice:
- This code will expire in 5 minutes
- Never share this code with anyone
- If you didn't request this code, please ignore this email

If you didn't request this verification code, you can safely ignore this email.

---
This is an automated message from Agent Mitra. Please do not reply to this email.
© {settings.app_name} - All rights reserved
        """
        
        return self.send_email(to_email, subject, html_body, text_body)


# Singleton instance
_email_service_instance: Optional[EmailService] = None


def get_email_service() -> EmailService:
    """Get singleton email service instance"""
    global _email_service_instance
    if _email_service_instance is None:
        _email_service_instance = EmailService()
    return _email_service_instance

