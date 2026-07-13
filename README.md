# 📄 TaxAssist

![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=flat-square&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=flat-square&logo=apple&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)

> **TaxAssist** is a secure, interactive tax document builder designed to simplify the paperwork process. Instead of squinting at tiny boxes on a PDF, step through a clean, guided questionnaire. TaxAssist perfectly maps your answers to standard IRS forms (like W-2 and 1099-NEC), encrypts your personal data, and securely syncs your records to the cloud.

---

## Features

* **Interactive Form Guides:** Say goodbye to confusing tax jargon. TaxAssist breaks down complex forms into simple, step-by-step questions with visual highlights showing exactly where to look on your physical documents.
* **Universal PDF Generation:** A custom, math-driven engine (`UniversalPDFGenerator`) flawlessly maps your inputs onto precise pixel coordinates to generate pixel-perfect, official PDF replicas of your tax documents.
* **End-to-End Security:** Your sensitive information (SSN, income, addresses) is locked down. The built-in `SecurityManager` encrypts all raw form data locally on your device *before* it ever touches the cloud database.
* **Cloud Sync & Resume:** Backed by **Firebase**, forms are automatically saved as "In Progress". Close the app halfway through a W-2 and pick up exactly where you left off from the "My Documents" screen. 
* **Preview & Export:** Once completed, preview your rendered PDF natively using **PDFKit**. Use the built-in iOS Share Sheet to print, email, or save the final document directly to your device's Files app.

---

## Quick Start

Get up and running locally in Xcode:

```bash
# Clone the repository
git clone https://github.com/johndoe/TaxAssist.git

# Navigate to the project directory
cd TaxAssist

# Open the project in Xcode
open TaxAssist.xcodeproj

# Add the Google Service plist environment variables
