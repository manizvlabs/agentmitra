# OpenAI API Cost Optimization Guide

## 🚨 Current Cost Analysis

Based on code analysis, here's the cost breakdown per 1000 requests:

| Service | Model | Cost per 1000 requests |
|---------|-------|------------------------|
| **Video Transcription** | whisper-1 | **$30.00** ⚠️ |
| Chatbot Service | gpt-3.5-turbo | $4.24 |
| AI Service | gpt-3.5-turbo | $1.82 |
| **TOTAL** | | **$36.05** |

## 🔴 Biggest Cost Driver: Video Transcription

**Video transcription (Whisper-1) is consuming ~83% of your API costs!**

- **Cost**: $0.006 per minute of audio
- **Example**: A 10-minute video = $0.06 per transcription
- **Problem**: Auto-transcription runs for EVERY uploaded video

## ✅ Immediate Actions to Reduce Costs

### 1. Disable Auto-Transcription (SAVES ~$30 per 1000 videos)

**Option A: Environment Variable (Recommended)**
```bash
# In your .env file
VIDEO_TRANSCRIPTION_AUTO=false
```

**Option B: Per-Video Control**
- Transcription will only run when explicitly requested
- Use the API endpoint to transcribe specific videos on-demand

### 2. Optimize Chatbot Service (SAVES ~$2-3 per 1000 requests)

The chatbot makes **multiple API calls per interaction**:
- Intent analysis: ~200 tokens
- Response generation: ~500 tokens

**Optimizations:**
```python
# Reduce max_tokens for intent analysis
max_tokens=150  # Instead of 200-300

# Cache intent analysis for similar messages
# Implement response caching for common queries
```

### 3. Reduce Token Usage

**Current token usage:**
- Intent analysis: 200-300 tokens
- Response generation: 300-500 tokens
- Content generation: 500-1000 tokens

**Recommended limits:**
- Intent analysis: 150 tokens (sufficient for classification)
- Chat responses: 300 tokens (shorter, focused responses)
- Summaries: 200 tokens (concise summaries)

## 📊 Model Cost Comparison

| Model | Input (per 1K tokens) | Output (per 1K tokens) | Use Case |
|-------|----------------------|----------------------|----------|
| **gpt-3.5-turbo** | $0.0005 | $0.0015 | ✅ **Current - Best value** |
| gpt-4 | $0.0300 | $0.0600 | ❌ Too expensive |
| gpt-4-turbo | $0.0100 | $0.0300 | ⚠️ Only for complex tasks |
| whisper-1 | $0.006/min | - | ⚠️ **Disable auto-transcription** |

## 🎯 Recommended Configuration

### Environment Variables

```bash
# Disable expensive auto-transcription
VIDEO_TRANSCRIPTION_AUTO=false

# Use cheapest model (already set)
OPENAI_MODEL=gpt-3.5-turbo
CHATBOT_MODEL=gpt-3.5-turbo

# Reduce token limits
CHATBOT_MAX_TOKENS=300
OPENAI_MAX_TOKENS=300
```

### Code Optimizations

1. **Implement Caching**
   ```python
   # Cache intent analysis for similar messages
   # Cache common chatbot responses
   # Cache transcriptions (don't re-transcribe same video)
   ```

2. **Batch Similar Requests**
   - Group similar queries together
   - Use single API call for multiple analyses

3. **Use Streaming**
   - For long responses, use streaming to reduce latency
   - Doesn't reduce cost but improves UX

4. **Monitor Usage**
   - Check OpenAI dashboard: https://platform.openai.com/usage
   - Set up usage alerts
   - Track costs per endpoint

## 📈 Expected Cost Reduction

After implementing optimizations:

| Optimization | Current Cost | After Optimization | Savings |
|-------------|--------------|-------------------|---------|
| Disable auto-transcription | $30.00 | $0.00 | **$30.00** |
| Reduce chatbot tokens | $4.24 | $2.50 | **$1.74** |
| Optimize AI service | $1.82 | $1.20 | **$0.62** |
| **TOTAL** | **$36.05** | **$3.70** | **$32.35 (90% reduction)** |

## 🔍 Monitoring Usage

### Check Current Usage

```bash
# Run cost analysis script
python3 backend/scripts/check_api_costs.py

# Check OpenAI dashboard
# https://platform.openai.com/usage
```

### Set Usage Limits

1. Go to OpenAI dashboard → Settings → Limits
2. Set hard spending limit (e.g., $15/month)
3. Set soft limit alerts (e.g., $10/month)

## 🚀 Quick Start: Disable Auto-Transcription

**Step 1:** Update your `.env` file:
```bash
VIDEO_TRANSCRIPTION_AUTO=false
```

**Step 2:** Restart your backend service

**Step 3:** Verify:
```bash
# Check if transcription is disabled
grep VIDEO_TRANSCRIPTION_AUTO backend/.env
```

**Result:** Immediate 83% cost reduction! 🎉

## 📝 Additional Recommendations

1. **Review Video Upload Frequency**
   - How many videos are uploaded per day?
   - Consider transcribing only popular videos

2. **Implement On-Demand Transcription**
   - Add "Transcribe" button in UI
   - Only transcribe when user requests it

3. **Use Alternative Transcription Services**
   - Consider free/open-source alternatives for development
   - Use Whisper only for production videos

4. **Monitor and Alert**
   - Set up daily cost reports
   - Alert when approaching budget limits

## 🔗 Resources

- OpenAI Pricing: https://openai.com/pricing
- Usage Dashboard: https://platform.openai.com/usage
- Cost Analysis Script: `backend/scripts/check_api_costs.py`




