# AWS Security Setup Guide

## ⚠️ CRITICAL SECURITY FIX: Root Access Keys Removed

Your AWS CLI was previously configured with **root user access keys**, which provide unlimited permissions and cannot be restricted. These keys have been removed for security reasons.

## 🔒 Recommended Authentication Methods

### Option 1: AWS SSO (Recommended for Teams)

1. **Set up AWS SSO in your AWS account:**
   - Go to AWS IAM Identity Center (formerly AWS SSO)
   - Create a permission set with appropriate permissions (not AdministratorAccess)
   - Create users and assign them to the permission set

2. **Configure AWS CLI with SSO:**
   ```bash
   aws configure sso
   ```
   Follow the prompts to:
   - Enter SSO session name
   - Enter SSO start URL (from your AWS SSO setup)
   - Select the appropriate AWS account and role

3. **Login when needed:**
   ```bash
   aws login
   ```

### Option 2: IAM User with Limited Permissions (Individual Developer)

1. **Create an IAM user in AWS Console:**
   - Go to IAM → Users → Create user
   - Give it programmatic access only
   - Attach appropriate policies (not AdministratorAccess)

2. **Configure AWS CLI:**
   ```bash
   aws configure --profile agentmitra-dev
   ```
   Enter the access key ID and secret key from the IAM user.

3. **Use the profile in your scripts:**
   ```bash
   aws s3 ls --profile agentmitra-dev
   ```

### Option 3: AWS CLI v2 SSO Login (Simplest for Local Development)

If you have AWS CLI v2 installed:
```bash
aws login
```
This opens a browser for authentication using your AWS console credentials.

## 🔧 Updating Your Scripts

Your AWS scripts need to be updated to use proper authentication. Here are the changes needed:

### For setup-sandbox.sh
Replace direct `aws` commands with profile-aware commands:

```bash
# Instead of:
aws ec2 create-vpc --cidr-block $VPC_CIDR

# Use:
aws ec2 create-vpc --cidr-block $VPC_CIDR --profile agentmitra-dev
```

### Environment Variables
Update your environment files to not include AWS credentials directly. Instead, use:

```bash
# Remove these from .env files:
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret

# AWS CLI will automatically provide temporary credentials when using SSO
```

## 🚨 Immediate Actions Required

1. **Delete the old root access keys:**
   - Go to AWS Console → IAM → My Security Credentials
   - Under "Access keys", delete the key starting with `AKIAYVCR5WTEM76ARNNM`

2. **Set up proper authentication** using one of the methods above

3. **Test your setup:**
   ```bash
   aws sts get-caller-identity
   ```
   Should show an IAM user or role ARN, NOT root

## 📋 Checklist

- [ ] Root access keys deleted from AWS Console
- [ ] AWS CLI reconfigured with secure authentication
- [ ] Scripts updated to use profiles or SSO
- [ ] Environment files cleaned of hardcoded credentials
- [ ] Team members notified of the change

## 🔍 Verification

Run these commands to verify your setup is secure:

```bash
# Should show IAM user/role, not root
aws sts get-caller-identity

# Should show SSO session or profile configuration
aws configure list

# Should fail if using SSO (credentials are temporary)
aws configure get aws_access_key_id
```

## 📚 Additional Resources

- [AWS CLI SSO Configuration](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Security Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)

---

**Security Note:** Never commit AWS credentials to version control. Always use temporary credentials or SSO for development and CI/CD pipelines.
