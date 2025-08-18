---
mode: 'ask'
model: 'Claude Sonnet 4'
description: 'Debug Flutter issues và đưa ra giải pháp'
---

# Debug Flutter Issue

Phân tích và debug vấn đề Flutter với systematic approach.

## Thông tin cần cung cấp:
1. **Error message** hoặc **unexpected behavior**
2. **Steps to reproduce** 
3. **Expected vs Actual behavior**
4. **Relevant code snippets**
5. **Flutter version** và **dependencies**

## Debugging Process:

### 1. Error Analysis
- Phân tích stack trace
- Identify root cause
- Check common Flutter pitfalls

### 2. Code Review
- Review relevant code files
- Check state management logic
- Verify widget lifecycle
- Validate data flow

### 3. Common Issues & Solutions

#### State Management Issues:
- Provider/Riverpod state không update
- Memory leaks từ listeners
- State inconsistency

#### UI/Layout Issues:
- RenderFlex overflow
- Widget disposal issues  
- Theme/styling problems
- Navigation stack issues

#### Performance Issues:
- Unnecessary rebuilds
- Heavy computations on UI thread
- Memory usage problems
- Network request optimization

#### Build/Configuration Issues:
- Dependency conflicts
- Platform-specific configurations
- Build settings problems

### 4. Solution Implementation
- Provide step-by-step fix
- Explain why the solution works
- Suggest best practices để avoid future issues
- Include relevant code examples

### 5. Prevention Tips
- Code review checklist
- Testing strategies
- Monitoring và logging
- Performance optimization tips

## Output Format:
1. **Root Cause Analysis**
2. **Step-by-step Solution** 
3. **Code Implementation**
4. **Testing Verification**
5. **Prevention Recommendations**

Hãy mô tả vấn đề bạn đang gặp phải để tôi có thể debug và đưa ra giải pháp phù hợp.
