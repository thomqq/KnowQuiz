# KnowQuiz

KnowQuiz is an AI-powered study partner that helps users learn efficiently through flashcards generated with artificial intelligence.

![KnowQuiz Logo](public/favicon.svg)

## Table of Contents
- [About the Project](#about-the-project)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Available Scripts](#available-scripts)
- [Project Scope](#project-scope)
- [Project Status](#project-status)
- [License](#license)

## About the Project

KnowQuiz is a web application that supports effective learning through a flashcard system generated with the help of artificial intelligence. The application allows users to create topics and lessons, automatically generate flashcard content based on user questions, and then learn using an algorithm that takes spaced repetition into account. The product uses OpenAI API both to generate answers to questions created by the user and to evaluate the correctness of answers provided during learning sessions.

### Key Features
- AI-generated flashcards from user questions
- Structured organization with topics and lessons
- Intelligent spaced repetition system
- Voice recognition and text-to-speech capabilities
- Support for both Polish and English languages

## Tech Stack

### Frontend
- [Astro 5](https://astro.build/) - For creating fast, efficient pages and applications with minimal JavaScript
- [React 19](https://react.dev/) - For interactive components
- [TypeScript 5](https://www.typescriptlang.org/) - For static typing and better IDE support
- [Tailwind 4](https://tailwindcss.com/) - For convenient styling
- [Shadcn/ui](https://ui.shadcn.com/) - For accessible React components

### Backend
- [Supabase](https://supabase.com/) - Comprehensive backend solution providing:
  - PostgreSQL database
  - Authentication system
  - Backend-as-a-Service SDK

### AI Integration
- [Openrouter.ai](https://openrouter.ai/) - For communication with various AI models:
  - Access to models from OpenAI, Anthropic, Google, and others
  - Financial limit controls for API keys

### CI/CD & Hosting
- GitHub Actions - For CI/CD pipelines
- DigitalOcean - For application hosting via Docker image

## Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/) version 22.14.0 (LTS)
- npm (included with Node.js)

### Installation

1. Clone the repository
   ```sh
   git clone https://github.com/yourusername/KnowQuiz.git
   cd KnowQuiz
   ```

2. Install NPM packages
   ```sh
   npm install
   ```

3. Start the development server
   ```sh
   npm run dev
   ```

4. Open your browser and navigate to `http://localhost:4321`

## Available Scripts

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |

## Project Scope

### Functional Requirements
1. User registration and login system
2. Topic and lesson management
3. Flashcard creation and management with AI assistance
4. Learning system with spaced repetition
5. OpenAI API integration
6. Responsive user interface

### Limitations
- Web application only (no native mobile app)
- Text-only flashcards (no images, graphs, or audio materials)
- No sharing flashcards between users
- No advanced statistics and learning progress analysis
- No offline mode - requires constant internet connection

### MVP Exclusions
- Advanced learning statistics
- Flashcard sharing system
- Integrations with external educational platforms
- Native mobile applications
- Expanded gamification system
- Support for more languages beyond Polish and English

## Project Status

🚧 **In Development** 🚧

KnowQuiz is currently in active development. The application is being built with attention to user experience, performance, and learning effectiveness.

## License

This project is proprietary and not open for public distribution or use without explicit permission.

---

© 2024 KnowQuiz Team
