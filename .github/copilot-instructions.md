# AI Agent Instructions for SFW-Project

## Project Overview
This is a Flutter-based Student Organization Application that helps students manage their courses, tasks, calendar, and includes an AI assistant feature. The app is designed with a modern Material Design 3 aesthetic using a brown-themed color scheme.

## Core Architecture
- **Main App Structure** (`lib/main.dart`):
  - Central state management using StatefulWidget pattern
  - Navigation handled through drawer menu
  - Theme configuration with custom brown color palette

- **Key Components**:
  1. Home Page: Displays pinned messages and quick access features
  2. Courses Page: Manages course information
  3. Weekly Calendar: Handles scheduling and reminders
  4. Tasks Due Page: Task management system
  5. AI Assistant: Gemini-powered chatbot integration

## State Management
- State is managed in `_MainScaffoldState` class within `main.dart`
- Core data structures:
  ```dart
  List<Course> courses
  List<Task> tasks
  List<Reminder> reminders
  List<String> pinnedMessages
  ```
- State mutations are handled through explicit methods (addCourse, removeTask, etc.)

## AI Integration
- Uses Google's Gemini API (see `ai_assistant_page.dart`)
- API key management:
  1. Direct key in code (current)
  2. Environment file support available (commented code for .env usage)
- Chat session maintains history for context
- Configuration:
  ```dart
  GenerationConfig(
    temperature: 0.7,
    topK: 40,
    topP: 0.95,
    maxOutputTokens: 1024,
  )
  ```

## Development Workflow
1. **Environment Setup**:
   - Flutter SDK ≥3.9.2
   - Dependencies: google_generative_ai, flutter_dotenv, intl, table_calendar
   - Optional: Create `gemini_api_key.env` for API key management

2. **Building**:
   ```powershell
   flutter pub get
   flutter build
   ```

3. **Platform-Specific Notes**:
   - Android: Use `build.gradle.kts` for Kotlin DSL configuration
   - iOS: Standard Flutter iOS setup with Swift integration
   - Web/Desktop: Basic configuration included

## Conventions
1. **UI Components**:
   - Use underscore prefix for private widgets (e.g., `_ChatBubble`)
   - Follow Material 3 design patterns
   - Maintain brown theme consistency

2. **File Structure**:
   - One widget per file
   - State management in parent widgets
   - Keep UI logic separate from business logic

3. **Error Handling**:
   - AI errors displayed in red chat bubbles
   - State mutations wrapped in setState calls
   - Initialization errors shown with retry options

## Extension Points
- AI Assistant customization in `ai_assistant_page.dart`
- Theme modifications in `main.dart`
- New feature pages can be added to navigation drawer
- Data models can be extended in `data_models.dart`

For questions or improvements, refer to specific files mentioned above or consult the project maintainers.