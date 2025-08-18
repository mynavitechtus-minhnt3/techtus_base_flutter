---
mode: 'ask'
model: 'Claude Sonnet 4'
description: 'Phân tích và tối ưu performance cho Flutter app'
---

# Optimize Flutter Performance

Phân tích và đưa ra recommendations để tối ưu performance Flutter app.

## Areas cần phân tích:

### 1. Widget Performance
- Unnecessary widget rebuilds
- Heavy widgets trong build methods
- Improper use của StatefulWidget vs StatelessWidget
- Missing const constructors

### 2. State Management Performance
- Provider/Riverpod optimization
- State granularity
- Listener efficiency
- Memory leaks từ subscriptions

### 3. List/Grid Performance
- ListView vs ListView.builder
- Pagination implementation
- Item caching strategies
- Scroll performance

### 4. Image/Asset Performance
- Image loading và caching
- Asset bundling optimization
- Network image handling
- Memory usage của images

### 5. Network Performance
- API call optimization
- Response caching
- Request batching
- Connection pooling

### 6. Memory Management
- Widget disposal
- Stream subscriptions cleanup
- Large object handling
- Garbage collection optimization

## Performance Metrics cần check:
- Frame rendering time
- Memory usage patterns
- CPU utilization
- Network request timing
- App startup time
- Navigation performance

## Tools để measure:
- Flutter Inspector
- Performance tab trong DevTools
- Memory tab trong DevTools
- Network tab trong DevTools
- Timeline view

## Optimization Strategies:
1. **Widget Level**: const, keys, selective rebuilds
2. **State Level**: granular providers, proper disposal
3. **Data Level**: caching, pagination, lazy loading
4. **Asset Level**: optimization, compression, caching
5. **Code Level**: async patterns, efficient algorithms

Hãy cung cấp specific performance issues hoặc code areas cần optimize để tôi phân tích và đưa ra solutions cụ thể.
