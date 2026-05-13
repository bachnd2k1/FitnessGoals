# instruction.md
# SwiftUI + MVVM + Combine Architecture Guide
# Refactor Standard for Production Project

---

# 1. Core Principles

Project must follow:

- MVVM strictly
- Single Responsibility Principle
- Unidirectional Data Flow
- Dependency Injection
- Reactive state management using Combine
- UI layer must NOT contain business logic
- ViewModel must NOT know UIKit/SwiftUI rendering details
- Services handle networking/database only
- Repository handles data abstraction
- Use protocol-oriented architecture
- Avoid God Objects
- Prefer composition over inheritance

---

# 2. Recommended Folder Structure

```txt
Project/
│
├── App/
│   ├── AppEntry.swift
│   ├── AppRouter.swift
│   └── AppEnvironment.swift
│
├── Core/
│   ├── Extensions/
│   ├── Utilities/
│   ├── Constants/
│   ├── Errors/
│   ├── Networking/
│   ├── Storage/
│   ├── DesignSystem/
│   └── Helpers/
│
├── Modules/
│   ├── Home/
│   │   ├── View/
│   │   ├── ViewModel/
│   │   ├── Model/
│   │   ├── Repository/
│   │   ├── Service/
│   │   ├── Components/
│   │   └── Routing/
│   │
│   └── Profile/
│
├── Shared/
│   ├── Components/
│   ├── Modifiers/
│   ├── Managers/
│   └── ViewStates/
│
├── Resources/
│
└── Tests/
    ├── UnitTests/
    └── UITests/