//
//  W2Form.swift
//  TaxAssist
//
//  Created by ChatGPT
//

import SwiftUI

// MARK: - W2 Data Model

struct W2Data {
    var employeeName = ""
    var socialSecurity = ""
    var streetAddress = ""
    var city = ""
    var state = ""
    var zipCode = ""
}

// MARK: - Question Types

enum QuestionType {
    case text
    case money
    case yesNo
}

// MARK: - Question Model

struct TaxQuestion: Identifiable {

    let id = UUID()
    let title: String
    let subtitle: String
    let placeholder: String
    let help: String
    let type: QuestionType
    let highlight: W2Highlight?
    let definition: String?

    init(title: String, subtitle: String, placeholder: String, help: String, type: QuestionType, highlight: W2Highlight? = nil, definition: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self.help = help
        self.type = type
        self.highlight = highlight
        self.definition = definition
    }
}

struct W2Highlight: Identifiable {
    let id: String
    let title: String
    let rect: CGRect
}

extension W2Highlight {
    static let socialSecurityNumber = W2Highlight(id: "employee-social-security", title: "Box a", rect: CGRect(x: 0.25, y: 0.03, width: 0.21, height: 0.06))
    static let employerEIN = W2Highlight(id: "employer-ein", title: "Box b", rect: CGRect(x: 0.06, y: 0.10, width: 0.48, height: 0.06))
    static let employerName = W2Highlight(id: "employer-name", title: "Box c", rect: CGRect(x: 0.06, y: 0.16, width: 0.48, height: 0.20))
    static let employeeName = W2Highlight(id: "employee-name", title: "Box e", rect: CGRect(x: 0.06, y: 0.43, width: 0.48, height: 0.08))
    static let employeeAddress = W2Highlight(id: "employee-address", title: "Box f", rect: CGRect(x: 0.06, y: 0.51, width: 0.48, height: 0.22))
    static let wages = W2Highlight(id: "wages", title: "Box 1", rect: CGRect(x: 0.54, y: 0.09, width: 0.20, height: 0.07))
    static let federalTax = W2Highlight(id: "federal-tax", title: "Box 2", rect: CGRect(x: 0.74, y: 0.09, width: 0.20, height: 0.07))
    static let socialSecurityWages = W2Highlight(id: "social-security-wages", title: "Box 3", rect: CGRect(x: 0.54, y: 0.16, width: 0.20, height: 0.07))
    static let socialSecurityTax = W2Highlight(id: "social-security-tax", title: "Box 4", rect: CGRect(x: 0.74, y: 0.16, width: 0.20, height: 0.07))
    static let medicareWages = W2Highlight(id: "medicare-wages", title: "Box 5", rect: CGRect(x: 0.54, y: 0.23, width: 0.20, height: 0.07))
    static let medicareTax = W2Highlight(id: "medicare-tax", title: "Box 6", rect: CGRect(x: 0.74, y: 0.23, width: 0.20, height: 0.07))
    static let state = W2Highlight(id: "state", title: "Box 15", rect: CGRect(x: 0.06, y: 0.74, width: 0.04, height: 0.08))
    static let stateTax = W2Highlight(id: "state-tax", title: "Box 17", rect: CGRect(x: 0.46, y: 0.74, width: 0.13, height: 0.08))
    static let fullForm = W2Highlight(id: "full-form", title: "W-2 Form", rect: CGRect(x: 0.05, y: 0.02, width: 0.89, height: 0.86))
}

// MARK: - Main View

struct W2Form: View {

    // Current Question
    @State private var currentQuestion = 0
    @State private var showingIntro = true
    @State private var showingReview = false
    @State private var showingW2Help = false
    @State private var definitionTitle = ""
    @State private var definitionMessage = ""
    @State private var showingDefinition = false
    @State private var showingTaxDictionary = false

    // User Input
    @State private var answer = ""
    @State private var validationMessage = ""
    @State private var yesNoAnswer = true
    
    // NEW: Stores the generated URL to trigger navigation
    @State private var generatedPDFUrl: URL?

    // Stores all information
    @State private var w2 = W2Data()

    // Questions
    let questions: [TaxQuestion] = [
        TaxQuestion(
            title: "What is your full name?",
            subtitle: "Your Name",
            placeholder: "John Smith",
            help: "Enter your legal name as it appears on your W-2.",
            type: .text,
            highlight: .employeeName,
            definition: "Your full name is your legal first and last name."
        ),
        TaxQuestion(
            title: "What is your Social Security number?",
            subtitle: "Social Security Number",
            placeholder: "123-45-6789",
            help: "Look for Box a on your W-2.",
            type: .text,
            highlight: .socialSecurityNumber,
            definition: "Your Social Security number is the 9-digit number given to you by the Government. It is on your Social Security Card."
        ),
        TaxQuestion(
            title: "What is your street address?",
            subtitle: "Street Address",
            placeholder: "123 Main St",
            help: "Look for Box f on your W-2.",
            type: .text,
            highlight: .employeeAddress,
            definition: "Your street address is the house or building number and street name where you live, including unit number"
        ),
        TaxQuestion(
            title: "What city do you live in?",
            subtitle: "City",
            placeholder: "Chicago",
            help: "Look for Box f on your W-2.",
            type: .text,
            highlight: .employeeAddress,
            definition: "Your city is the city or town listed in your mailing address."
        ),
        TaxQuestion(
            title: "What state do you live in?",
            subtitle: "State",
            placeholder: "Illinois",
            help: "Look for Box f on your W-2.",
            type: .text,
            highlight: .employeeAddress,
            definition: "Your state is the U.S. state in your mailing address."
        ),
        TaxQuestion(
            title: "What is your ZIP code?",
            subtitle: "ZIP Code",
            placeholder: "60601",
            help: "Look for Box f on your W-2.",
            type: .text,
            highlight: .employeeAddress,
            definition: "Your ZIP code is the 5-digit postal code for your address. If you do not know it, you can enter your street address into Google to find it."
        )
    ]

    var progress: Double {
        Double(currentQuestion + 1) / Double(questions.count)
    }

    var currentHighlight: W2Highlight {
        questions[currentQuestion].highlight ?? .fullForm
    }

    private var answerBinding: Binding<String> {
        Binding(
            get: { answer },
            set: { newValue in
                answer = newValue
                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    validationMessage = ""
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if showingIntro {
                    introCard
                    startQuestionsButton
                } else if showingReview {
                    reviewCard
                } else {
                    progressCard
                    questionCard
                    questionNavigationButtons
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("W-2 Guide")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingTaxDictionary = true
                } label: {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        // NEW: Triggers the PDF Preview screen when we have a URL!
        .navigationDestination(item: $generatedPDFUrl) { url in
            PDFPreviewScreen(pdfURL: url)
        }
        .sheet(isPresented: $showingW2Help) {
            W2FormHelpView(highlight: currentHighlight)
        }
        .sheet(isPresented: $showingTaxDictionary) {
            TaxDictionary()
        }
        .alert(definitionTitle, isPresented: $showingDefinition) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(definitionMessage)
        }
    }

    // MARK: - Intro Card
    private var introCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 44))
                .foregroundColor(.blue)

            Text("Before You Start")
                .font(.title.bold())

            Text("You only need to enter your personal information. Your employer will take care of the rest.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private var startQuestionsButton: some View {
        Button {
            currentQuestion = 0
            loadAnswerForCurrentQuestion()
            showingIntro = false
        } label: {
            HStack {
                Spacer()
                Text("Start Questions")
                    .font(.headline)
                Image(systemName: "arrow.right")
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Progress Card
    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("W-2 Tax Guide")
                        .font(.title2.bold())
                    Text("Step \(currentQuestion + 1) of \(questions.count)")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)

            Text("\(Int(progress * 100))% Complete")
                .foregroundColor(.blue)
                .font(.headline)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Question Card
    private var questionCard: some View {
        let question = questions[currentQuestion]

        return VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 6) {
                Text(question.subtitle)
                    .font(.headline)
                    .foregroundColor(.blue)

                if let definition = question.definition {
                    Button {
                        definitionTitle = question.subtitle
                        definitionMessage = definition
                        showingDefinition = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(question.title)
                .font(.title2.bold())

            switch question.type {
            case .text:
                TextField(question.placeholder, text: answerBinding)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

            case .money:
                HStack {
                    Text("$")
                        .font(.title2.bold())
                    TextField(question.placeholder, text: answerBinding)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            case .yesNo:
                VStack(spacing: 12) {
                    Button {
                        yesNoAnswer = true
                    } label: {
                        HStack {
                            Image(systemName: yesNoAnswer ? "checkmark.circle.fill" : "circle")
                            Text("Yes")
                            Spacer()
                        }
                        .padding()
                    }
                    .buttonStyle(.bordered)

                    Button {
                        yesNoAnswer = false
                    } label: {
                        HStack {
                            Image(systemName: !yesNoAnswer ? "checkmark.circle.fill" : "circle")
                            Text("No")
                            Spacer()
                        }
                        .padding()
                    }
                    .buttonStyle(.bordered)
                }
            }

            if !validationMessage.isEmpty {
                Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            Divider()

            Button {
                showingW2Help = true
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Need Help?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(question.help)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                showingTaxDictionary = true
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "character.book.closed.fill")
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Confused by a term?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Look it up in the Tax Dictionary")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Question Navigation
    private var questionNavigationButtons: some View {
        HStack(spacing: 12) {
            if currentQuestion > 0 {
                Button {
                    goToPreviousQuestion()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.left")
                        Text("Back")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            Button {
                goToNextQuestion()
            } label: {
                HStack {
                    Spacer()
                    Text(currentQuestion == questions.count - 1 ? "Review Answers" : "Continue")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                    Spacer()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Logic Functions
    func goToPreviousQuestion() {
        saveCurrentAnswer()
        if currentQuestion > 0 {
            currentQuestion -= 1
            loadAnswerForCurrentQuestion()
        }
    }

    func goToNextQuestion() {
        guard validateCurrentAnswer() else { return }
        saveCurrentAnswer()
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
            loadAnswerForCurrentQuestion()
        } else {
            showingReview = true
        }
    }

    func saveCurrentAnswer() {
        switch currentQuestion {
        case 0: w2.employeeName = answer
        case 1: w2.socialSecurity = answer
        case 2: w2.streetAddress = answer
        case 3: w2.city = answer
        case 4: w2.state = answer
        case 5: w2.zipCode = answer
        default: break
        }
    }

    func loadAnswerForCurrentQuestion() {
        answer = answerForQuestion(currentQuestion)
        validationMessage = ""
    }

    func validateCurrentAnswer() -> Bool {
        let question = questions[currentQuestion]
        switch question.type {
        case .text, .money:
            if answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validationMessage = "Please enter your \(question.subtitle.lowercased())."
                return false
            }
        case .yesNo: break
        }
        validationMessage = ""
        return true
    }

    func editQuestion(at questionIndex: Int) {
        guard questions.indices.contains(questionIndex) else { return }
        currentQuestion = questionIndex
        loadAnswerForCurrentQuestion()
        showingReview = false
        showingIntro = false
    }

    func answerForQuestion(_ questionIndex: Int) -> String {
        switch questionIndex {
        case 0: return w2.employeeName
        case 1: return w2.socialSecurity
        case 2: return w2.streetAddress
        case 3: return w2.city
        case 4: return w2.state
        case 5: return w2.zipCode
        default: return ""
        }
    }

    // NEW: PDF Generator Function
    func createW2PDF(from data: W2Data) throws -> URL {
        let fileName = "W2Form"
        
        return try UniversalPDFGenerator.generate(baseImageName: "W2Form", outputFileName: fileName) { imageRect in
            let address = [data.streetAddress, "\(data.city), \(data.state) \(data.zipCode)"]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
            
            let ssRect = UniversalPDFGenerator.fieldRect(x: 0.26, y: 0.055, width: 0.19, height: 0.032, inside: imageRect)
            UniversalPDFGenerator.drawText(data.socialSecurity, in: ssRect, fontSize: 10)
            
            let nameRect = UniversalPDFGenerator.fieldRect(x: 0.075, y: 0.462, width: 0.43, height: 0.038, inside: imageRect)
            UniversalPDFGenerator.drawText(data.employeeName, in: nameRect, fontSize: 11)
            
            let addressRect = UniversalPDFGenerator.fieldRect(x: 0.075, y: 0.548, width: 0.43, height: 0.12, inside: imageRect)
            UniversalPDFGenerator.drawText(address, in: addressRect, fontSize: 10)
        }
    }

    // MARK: - Review Card
    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review Your Answers")
                .font(.largeTitle.bold())
            Text("Make sure everything looks correct.")
                .foregroundColor(.secondary)
            Divider()

            reviewRow(title: "Full Name", value: w2.employeeName, questionIndex: 0)
            reviewRow(title: "Social Security Number", value: w2.socialSecurity, questionIndex: 1)
            reviewRow(title: "Street Address", value: w2.streetAddress, questionIndex: 2)
            reviewRow(title: "City", value: w2.city, questionIndex: 3)
            reviewRow(title: "State", value: w2.state, questionIndex: 4)
            reviewRow(title: "ZIP Code", value: w2.zipCode, questionIndex: 5)

            Button {
                // NEW: Trigger PDF Engine
                do {
                    generatedPDFUrl = try createW2PDF(from: w2)
                } catch {
                    print("Error generating W-2 PDF: \(error.localizedDescription)")
                }
            } label: {
                Text("Finish")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                currentQuestion = 0
                showingIntro = true
                showingReview = false
                answer = ""
                w2 = W2Data()
            } label: {
                Text("Start Over")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private func reviewRow(title: String, value: String, questionIndex: Int) -> some View {
        Button {
            editQuestion(at: questionIndex)
        } label: {
            HStack(spacing: 12) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                Text(value.isEmpty ? "-" : value)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helper Views

struct W2FormHelpView: View {
    let highlight: W2Highlight
    @Environment(\.dismiss) private var dismiss
    private let imageAspectRatio = 728.0 / 420.0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(highlight.title)
                        .font(.title2.bold())

                    ZStack {
                        GeometryReader { proxy in
                            let imageFrame = fittedImageFrame(in: proxy.size)
                            let highlightFrame = CGRect(
                                x: imageFrame.minX + highlight.rect.minX * imageFrame.width,
                                y: imageFrame.minY + highlight.rect.minY * imageFrame.height,
                                width: highlight.rect.width * imageFrame.width,
                                height: highlight.rect.height * imageFrame.height
                            )

                            ZStack(alignment: .topLeading) {
                                Image("W2Form")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: proxy.size.width, height: proxy.size.height)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.yellow.opacity(0.28))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.orange, lineWidth: 3)
                                    )
                                    .frame(width: highlightFrame.width, height: highlightFrame.height)
                                    .offset(x: highlightFrame.minX, y: highlightFrame.minY)
                            }
                        }
                    }
                    .aspectRatio(imageAspectRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }
            .navigationTitle("W-2 Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
            }
        }
    }

    private func fittedImageFrame(in size: CGSize) -> CGRect {
        let containerRatio = size.width / size.height
        if containerRatio > imageAspectRatio {
            let width = size.height * imageAspectRatio
            return CGRect(x: (size.width - width) / 2, y: 0, width: width, height: size.height)
        }
        let height = size.width / imageAspectRatio
        return CGRect(x: 0, y: (size.height - height) / 2, width: size.width, height: height)
    }
}

#Preview {
    NavigationStack {
        W2Form()
    }
}
