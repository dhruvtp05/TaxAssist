# Tax Assist 🧾

Tax Assist is an iOS application designed to take the stress out of tax season. It simplifies complex tax forms by breaking them down into easy, conversational, step-by-step questions. Once you finish the questionnaire, Tax Assist automatically generates a completed PDF of your tax forms that you can view, download, or print.

## Features ✨
- **Step-by-Step Questionnaire:** No more confusing IRS jargon. Answer simple questions one at a time.
- **Automated PDF Generation:** Instantly builds your official tax documents based on your answers.
- **Secure Account Management:** Save your progress and securely access your documents via Firebase Authentication.
- **Modern UI:** Built fully in SwiftUI for a fluid, native iOS experience.

## Tech Stack 🛠️
- **Platform:** iOS
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Backend & Auth:** Firebase (Authentication, Cloud Firestore)

## Development Roadmap 🗺️

### Phase 1: Foundation & UI (Current)
- [x] Design initial UI concepts and wireframes (Figma).
- [ ] Implement core UI components (Loading screens, navigation bars) in SwiftUI.
- [ ] Set up project architecture and folder structure.

### Phase 2: User Authentication & Backend Setup
- [ ] Integrate Firebase SDK into the Xcode project.
- [ ] Implement Firebase Authentication (Sign Up, Log In, Password Reset).
- [ ] Set up Cloud Firestore for secure user data storage and session management.

### Phase 3: Core Logic & Questionnaires
- [ ] Design data models for tax questions and user responses.
- [ ] Build the interactive step-by-step questionnaire flow.
- [ ] Implement state management to save user progress seamlessly.

### Phase 4: PDF Generation Engine
- [ ] Integrate PDF mapping logic (placing user data accurately onto official IRS form templates).
- [ ] Build the PDF viewer and export/download functionality.
- [ ] Ensure secure handling of sensitive tax data during document generation.

### Phase 5: Testing & Launch
- [ ] Validate tax logic, edge cases, and form accuracy.
- [ ] Conduct rigorous QA, UI/UX, and security testing.
- [ ] Prepare pitch-deck and demo for showcase day.
