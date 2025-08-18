# Copilot Customization cho TechTus Flutter Project

Dự án này đã được cấu hình để tối ưu hóa trải nghiệm GitHub Copilot với các custom instructions và prompt files.

## 📁 Cấu trúc Files

### Instructions Files (`.github/instructions/`)
- `flutter-development.md` - Hướng dẫn development Flutter chung
- `test-generation.md` - Quy tắc sinh test files
- `code-review.md` - Guidelines cho code review

### Prompt Files (`.github/prompts/`)
- `create-flutter-page.prompt.md` - Tạo page mới với StateNotifier
- `create-api-service.prompt.md` - Tạo API service class
- `create-model-class.prompt.md` - Tạo model với Freezed
- `create-test-files.prompt.md` - Tạo test files
- `create-widget-component.prompt.md` - Tạo reusable widgets
- `debug-flutter-issue.prompt.md` - Debug Flutter issues
- `refactor-code.prompt.md` - Refactor code
- `optimize-performance.prompt.md` - Performance optimization

## 🚀 Cách sử dụng

### 1. Sử dụng Prompt Files
Trong VS Code chat, gõ `/` followed by prompt name:
```
/create-flutter-page
/create-api-service  
/debug-flutter-issue
```

### 2. Custom Instructions tự động áp dụng
- Code generation sẽ follow Flutter best practices
- Test generation sẽ follow project testing rules
- Code review sẽ check architecture patterns

### 3. VS Code Settings
File `.vscode/settings.json` đã được cấu hình để:
- Enable prompt files
- Enable instruction files
- Apply custom instructions cho different Copilot features

## 🎯 Benefits

### Cho Developers:
- **Consistent code style** across team
- **Faster development** với pre-built prompts
- **Better code quality** với automated guidelines
- **Proper testing** với structured test generation

### Cho Project:
- **Architecture compliance** được enforce
- **Testing coverage** được đảm bảo
- **Code review quality** được improve
- **Knowledge sharing** thông qua documented patterns

## 📝 Customization

### Thêm Prompt mới:
1. Tạo file `.prompt.md` trong `.github/prompts/`
2. Follow template format với front matter
3. Use trong chat với `/prompt-name`

### Update Instructions:
1. Edit files trong `.github/instructions/`
2. Copilot sẽ tự động apply changes
3. Test với code generation để verify

### Team Settings:
- Share `.vscode/settings.json` để sync team settings
- Use Settings Sync để sync user prompt files
- Document team-specific patterns trong instructions

## 🔧 Maintenance

### Regular Updates:
- Review và update instructions khi architecture changes
- Add new prompts cho recurring tasks
- Update based on team feedback
- Keep aligned với Flutter best practices

### Monitoring:
- Track code quality improvements
- Monitor test coverage increases  
- Collect team feedback về prompt effectiveness
- Update based on new Flutter/Dart features

## 📚 Resources

- [VS Code Copilot Customization](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Documentation](https://pub.dev/packages/freezed)
