//
//  1099Form.swift
//  TaxAssist
//

import SwiftUI

struct _099Form: View {
    var initialDocumentId: String? = nil
    var encryptedData: String? = nil
    var customDocumentName: String = "Form 1099-NEC"
    
    struct _099FormData: Codable {
        var employeeName = ""
        var socialSecurity = ""
        var streetAddress = ""
        var city = ""
        var state = ""
        var zipCode = ""
    }

    enum QuestionType {
        case text
        case money
        case yesNo
    }

    struct TaxQuestion: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let placeholder: String
        let help: String
        let type: QuestionType
        let highlight: _099FormHighlight?
        let definition: String?

        init(title: String, subtitle: String, placeholder: String, help: String, type: QuestionType, highlight: _099FormHighlight? = nil, definition: String? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.placeholder = placeholder
            self.help = help
            self.type = type
            self.highlight = highlight
            self.definition = definition
        }
    }

    struct _099FormHighlight: Identifiable {
        let id: String
        let title: String
        let rect: CGRect
    }

    struct _099FormGuideView: View {
        @State private var currentQuestion = 0
        @State private var showingIntro = true
        @State private var showingReview = false
        @State private var showingHelp = false
        @State private var definitionTitle = ""
        @State private var definitionMessage = ""
        @State private var showingDefinition = false

        @State private var answer = ""
        @State private var validationMessage = ""
        @State private var yesNoAnswer = true
        
        @State private var previewData: PDFPreviewData?
        
        @State private var documentId: String? = nil

        @State private var f1099 = _099FormData()
        
        var initialDocumentId: String? = nil
        var encryptedData: String? = nil
        var customDocumentName: String = "Form 1099-NEC"

        let questions: [TaxQuestion] = [
            TaxQuestion(title: "What is your full name?", subtitle: "Your Name", placeholder: "John Smith", help: "Enter your legal name as it should appear on your 1099-NEC.", type: .text, highlight: .employeeName, definition: "Your full name is your legal first and last name."),
            TaxQuestion(title: "What is your Social Security number?", subtitle: "Social Security Number", placeholder: "123-45-6789", help: "This is your SSN or TIN as it appears on your 1099-NEC.", type: .text, highlight: .socialSecurityNumber, definition: "Your Social Security number is the 9-digit number given to you by the Government. It is on your Social Security Card."),
            TaxQuestion(title: "What is your street address?", subtitle: "Street Address", placeholder: "123 Main St", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress, definition: "Your street address is the house or building number and street name where you live, including unit number"),
            TaxQuestion(title: "What city do you live in?", subtitle: "City", placeholder: "Chicago", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress, definition: "Your city is the city or town listed in your mailing address."),
            TaxQuestion(title: "What state do you live in?", subtitle: "State", placeholder: "Illinois", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress, definition: "Your state is the U.S. state in your mailing address."),
            TaxQuestion(title: "What is your ZIP code?", subtitle: "ZIP Code", placeholder: "60601", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress, definition: "Your ZIP code is the 5-digit postal code for your address. If you do not know it, you can enter your street address into Google to find it.")
        ]

        var progress: Double {
            Double(currentQuestion + 1) / Double(questions.count)
        }

        var currentHighlight: _099FormHighlight {
            questions[currentQuestion].highlight ?? .fullForm
        }

        private var answerBinding: Binding<String> {
            Binding(
                get: { answer },
                set: { newValue in
                    answer = newValue
                    saveCurrentAnswer() // Instantly syncs text memory
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
            .navigationTitle(customDocumentName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let docId = initialDocumentId, let encData = encryptedData, documentId == nil {
                    self.documentId = docId
                    
                    do {
                        let decryptedString = try SecurityManager.shared.decrypt(encData)
                        if let rawData = decryptedString.data(using: .utf8) {
                            self.f1099 = try JSONDecoder().decode(_099FormData.self, from: rawData)
                            loadAnswerForCurrentQuestion()
                        }
                    } catch {
                        print("Failed to decrypt saved document: \(error.localizedDescription)")
                    }
                }
            }
            .navigationDestination(item: $previewData) { data in
                PDFPreviewScreen(pdfURL: data.url, documentId: data.documentId)
            }
            .sheet(isPresented: $showingHelp) {
                _099FormHelpView(highlight: currentHighlight)
            }
            .alert(definitionTitle, isPresented: $showingDefinition) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(definitionMessage)
            }
        }

        func saveInProgress() {
            Task {
                do {
                    let encoder = JSONEncoder()
                    let jsonData = try encoder.encode(f1099)
                    let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
                    
                    let newId = try await DatabaseManager.shared.saveDocument(
                        documentId: documentId,
                        documentName: customDocumentName,
                        formType: "Form 1099-NEC",
                        status: .inProgress,
                        pdfUrl: nil,
                        rawData: jsonString
                    )
                    
                    await MainActor.run {
                        self.documentId = newId
                    }
                } catch {
                    print("Failed to save in progress: \(error.localizedDescription)")
                }
            }
        }
        
        func create1099PDF(from data: _099FormData, docId: String) throws -> URL {
            let fileName = "TaxAssist-\(docId)-1099"
            
            return try UniversalPDFGenerator.generate(baseImageName: "1099-NEC", outputFileName: fileName) { imageRect in
                let nameRect = UniversalPDFGenerator.fieldRect(x: 0.06, y: 0.43, width: 0.48, height: 0.08, inside: imageRect)
                UniversalPDFGenerator.drawText(data.employeeName, in: nameRect, fontSize: 11)
                
                let ssRect = UniversalPDFGenerator.fieldRect(x: 0.25, y: 0.03, width: 0.21, height: 0.06, inside: imageRect)
                UniversalPDFGenerator.drawText(data.socialSecurity, in: ssRect, fontSize: 10)
                
                let address = [data.streetAddress, "\(data.city), \(data.state) \(data.zipCode)"]
                    .filter { !$0.isEmpty }
                    .joined(separator: "\n")
                let addressRect = UniversalPDFGenerator.fieldRect(x: 0.06, y: 0.51, width: 0.48, height: 0.22, inside: imageRect)
                UniversalPDFGenerator.drawText(address, in: addressRect, fontSize: 10)
            }
        }

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

        private var progressCard: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("1099-NEC Guide")
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
                    showingHelp = true
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
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }

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

        func goToPreviousQuestion() {
            saveCurrentAnswer()
            saveInProgress()
            if currentQuestion > 0 {
                currentQuestion -= 1
                loadAnswerForCurrentQuestion()
            }
        }

        func goToNextQuestion() {
            guard validateCurrentAnswer() else { return }
            saveCurrentAnswer()
            saveInProgress()
            if currentQuestion < questions.count - 1 {
                currentQuestion += 1
                loadAnswerForCurrentQuestion()
            } else {
                showingReview = true
            }
        }

        func saveCurrentAnswer() {
            switch currentQuestion {
            case 0: f1099.employeeName = answer
            case 1: f1099.socialSecurity = answer
            case 2: f1099.streetAddress = answer
            case 3: f1099.city = answer
            case 4: f1099.state = answer
            case 5: f1099.zipCode = answer
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
            case .yesNo:
                break
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
            case 0: return f1099.employeeName
            case 1: return f1099.socialSecurity
            case 2: return f1099.streetAddress
            case 3: return f1099.city
            case 4: return f1099.state
            case 5: return f1099.zipCode
            default: return ""
            }
        }

        private var reviewCard: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Review Your Answers")
                    .font(.largeTitle.bold())
                Text("Make sure everything looks correct.")
                    .foregroundColor(.secondary)
                Divider()
                reviewRow(title: "Full Name", value: f1099.employeeName, questionIndex: 0)
                reviewRow(title: "Social Security Number", value: f1099.socialSecurity, questionIndex: 1)
                reviewRow(title: "Street Address", value: f1099.streetAddress, questionIndex: 2)
                reviewRow(title: "City", value: f1099.city, questionIndex: 3)
                reviewRow(title: "State", value: f1099.state, questionIndex: 4)
                reviewRow(title: "ZIP Code", value: f1099.zipCode, questionIndex: 5)
                
                Button {
                    Task {
                        do {
                            let encoder = JSONEncoder()
                            let jsonData = try encoder.encode(f1099)
                            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
                            
                            let currentDocId = try await DatabaseManager.shared.saveDocument(
                                documentId: documentId,
                                documentName: customDocumentName,
                                formType: "Form 1099-NEC",
                                status: .inProgress,
                                pdfUrl: nil,
                                rawData: jsonString
                            )
                            
                            let localUrl = try create1099PDF(from: f1099, docId: currentDocId)
                            
                            await MainActor.run {
                                self.documentId = currentDocId
                                previewData = PDFPreviewData(url: localUrl, documentId: currentDocId)
                            }
                        } catch {
                            print("Failed to prepare PDF: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("Review PDF")
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
                    documentId = nil
                    f1099 = _099FormData()
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

    var body: some View {
        _099FormGuideView(initialDocumentId: initialDocumentId, encryptedData: encryptedData, customDocumentName: customDocumentName)
    }
}

extension _099Form._099FormHighlight {
    static let socialSecurityNumber = _099Form._099FormHighlight(id: "employee-social-security", title: "Recipient TIN", rect: CGRect(x: 0.25, y: 0.03, width: 0.21, height: 0.06))
    static let employerEIN = _099Form._099FormHighlight(id: "employer-ein", title: "Payer TIN", rect: CGRect(x: 0.06, y: 0.10, width: 0.48, height: 0.06))
    static let employerName = _099Form._099FormHighlight(id: "employer-name", title: "Payer Name/Address", rect: CGRect(x: 0.06, y: 0.16, width: 0.48, height: 0.20))
    static let employeeName = _099Form._099FormHighlight(id: "employee-name", title: "Recipient Name", rect: CGRect(x: 0.06, y: 0.43, width: 0.48, height: 0.08))
    static let employeeAddress = _099Form._099FormHighlight(id: "employee-address", title: "Recipient Address", rect: CGRect(x: 0.06, y: 0.51, width: 0.48, height: 0.22))
    static let wages = _099Form._099FormHighlight(id: "wages", title: "Nonemployee Compensation", rect: CGRect(x: 0.54, y: 0.09, width: 0.20, height: 0.07))
    static let federalTax = _099Form._099FormHighlight(id: "federal-tax", title: "Federal Tax Withheld", rect: CGRect(x: 0.74, y: 0.09, width: 0.20, height: 0.07))
    static let socialSecurityWages = _099Form._099FormHighlight(id: "social-security-wages", title: "Other Income", rect: CGRect(x: 0.54, y: 0.16, width: 0.20, height: 0.07))
    static let socialSecurityTax = _099Form._099FormHighlight(id: "social-security-tax", title: "Backup Withholding", rect: CGRect(x: 0.74, y: 0.16, width: 0.20, height: 0.07))
    static let medicareWages = _099Form._099FormHighlight(id: "medicare-wages", title: "State Income", rect: CGRect(x: 0.54, y: 0.23, width: 0.20, height: 0.07))
    static let medicareTax = _099Form._099FormHighlight(id: "medicare-tax", title: "State Tax Withheld", rect: CGRect(x: 0.74, y: 0.23, width: 0.20, height: 0.07))
    static let state = _099Form._099FormHighlight(id: "state", title: "State", rect: CGRect(x: 0.06, y: 0.74, width: 0.04, height: 0.08))
    static let stateTax = _099Form._099FormHighlight(id: "state-tax", title: "State Tax", rect: CGRect(x: 0.46, y: 0.74, width: 0.13, height: 0.08))
    static let fullForm = _099Form._099FormHighlight(id: "full-form", title: "1099-NEC Form", rect: CGRect(x: 0.05, y: 0.02, width: 0.89, height: 0.86))
}

struct _099FormHelpView: View {
    let highlight: _099Form._099FormHighlight
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
                                Image("1099-NEC")
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
            .navigationTitle("1099-NEC Help")
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
    _099Form()
}
