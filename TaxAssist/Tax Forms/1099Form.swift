import SwiftUI

struct _099Form: View {
    var initialDocumentId: String? = nil
    var encryptedData: String? = nil
    var customDocumentName: String = "Form 1099-NEC"
    
    struct _099FormData: Codable {
        var payerName = ""
        var payerTIN = ""
        var recipientName = ""
        var recipientTIN = ""
        var streetAddress = ""
        var city = ""
        var state = ""
        var zipCode = ""
        var nonemployeeCompensation = ""
        var federalTaxWithheld = ""
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
            TaxQuestion(title: "What is the Payer's business name?", subtitle: "Payer Name", placeholder: "Acme Corp", help: "Look at the top-left large box on your 1099-NEC.", type: .text, highlight: .payerName),
            TaxQuestion(title: "What is the Payer's TIN?", subtitle: "Payer TIN", placeholder: "12-3456789", help: "This is the Payer's 9-digit Identification Number.", type: .text, highlight: .employerEIN),
            TaxQuestion(title: "What is your Social Security number or TIN?", subtitle: "Recipient TIN", placeholder: "123-45-6789", help: "Look for 'RECIPIENT'S TIN' box.", type: .text, highlight: .socialSecurityNumber),
            TaxQuestion(title: "What is your full legal name?", subtitle: "Recipient Name", placeholder: "John Smith", help: "Look for the 'RECIPIENT'S name' box.", type: .text, highlight: .employeeName),
            TaxQuestion(title: "What is your street address?", subtitle: "Street Address", placeholder: "123 Main St", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress),
            TaxQuestion(title: "What city do you live in?", subtitle: "City", placeholder: "Chicago", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress),
            TaxQuestion(title: "What state do you live in?", subtitle: "State", placeholder: "Illinois", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress),
            TaxQuestion(title: "What is your ZIP code?", subtitle: "ZIP Code", placeholder: "60601", help: "Use the mailing address on your 1099-NEC.", type: .text, highlight: .employeeAddress),
            TaxQuestion(title: "What is the amount in Box 1?", subtitle: "Nonemployee Compensation", placeholder: "0.00", help: "This is the total amount paid to you as an independent contractor.", type: .money, highlight: .wages),
            TaxQuestion(title: "What is the amount in Box 4?", subtitle: "Federal Income Tax Withheld", placeholder: "0.00", help: "Enter any federal income tax withheld. Leave 0 if empty.", type: .money, highlight: .federalTax)
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
                    saveCurrentAnswer()
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
                let payerRect = UniversalPDFGenerator.fieldRect(x: 0.06, y: 0.11, width: 0.40, height: 0.20, inside: imageRect)
                UniversalPDFGenerator.drawText(data.payerName, in: payerRect, fontSize: 10)
                
                let pTINRect = UniversalPDFGenerator.fieldRect(x: 0.06, y: 0.38, width: 0.18, height: 0.04, inside: imageRect)
                UniversalPDFGenerator.drawText(data.payerTIN, in: pTINRect, fontSize: 10)
                
                let rTINRect = UniversalPDFGenerator.fieldRect(x: 0.26, y: 0.38, width: 0.20, height: 0.04, inside: imageRect)
                UniversalPDFGenerator.drawText(data.recipientTIN, in: rTINRect, fontSize: 10)
                
                let nameRect = UniversalPDFGenerator.fieldRect(x: 0.06, y: 0.47, width: 0.40, height: 0.04, inside: imageRect)
                UniversalPDFGenerator.drawText(data.recipientName, in: nameRect, fontSize: 11)
                
                let address = [data.streetAddress, "\(data.city), \(data.state) \(data.zipCode)"].filter { !$0.isEmpty }.joined(separator: "\n")
                let addrRect = UniversalPDFGenerator.fieldRect(x: 0.06, y: 0.55, width: 0.40, height: 0.12, inside: imageRect)
                UniversalPDFGenerator.drawText(address, in: addrRect, fontSize: 10)
                
                let box1Rect = UniversalPDFGenerator.fieldRect(x: 0.50, y: 0.38, width: 0.25, height: 0.04, inside: imageRect)
                UniversalPDFGenerator.drawText(data.nonemployeeCompensation, in: box1Rect, fontSize: 11)
                
                let box4Rect = UniversalPDFGenerator.fieldRect(x: 0.50, y: 0.63, width: 0.25, height: 0.04, inside: imageRect)
                UniversalPDFGenerator.drawText(data.federalTaxWithheld, in: box4Rect, fontSize: 11)
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
            case 0: f1099.payerName = answer
            case 1: f1099.payerTIN = answer
            case 2: f1099.recipientTIN = answer
            case 3: f1099.recipientName = answer
            case 4: f1099.streetAddress = answer
            case 5: f1099.city = answer
            case 6: f1099.state = answer
            case 7: f1099.zipCode = answer
            case 8: f1099.nonemployeeCompensation = answer
            case 9: f1099.federalTaxWithheld = answer
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
            case 0: return f1099.payerName
            case 1: return f1099.payerTIN
            case 2: return f1099.recipientTIN
            case 3: return f1099.recipientName
            case 4: return f1099.streetAddress
            case 5: return f1099.city
            case 6: return f1099.state
            case 7: return f1099.zipCode
            case 8: return f1099.nonemployeeCompensation
            case 9: return f1099.federalTaxWithheld
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
                reviewRow(title: "Payer Name", value: f1099.payerName, questionIndex: 0)
                reviewRow(title: "Payer TIN", value: f1099.payerTIN, questionIndex: 1)
                reviewRow(title: "Recipient TIN", value: f1099.recipientTIN, questionIndex: 2)
                reviewRow(title: "Recipient Full Name", value: f1099.recipientName, questionIndex: 3)
                reviewRow(title: "Street Address", value: f1099.streetAddress, questionIndex: 4)
                reviewRow(title: "City", value: f1099.city, questionIndex: 5)
                reviewRow(title: "State", value: f1099.state, questionIndex: 6)
                reviewRow(title: "ZIP Code", value: f1099.zipCode, questionIndex: 7)
                reviewRow(title: "Box 1: Compensation", value: f1099.nonemployeeCompensation, questionIndex: 8)
                reviewRow(title: "Box 4: Federal Withholding", value: f1099.federalTaxWithheld, questionIndex: 9)
                
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
    static let payerName = _099Form._099FormHighlight(id: "payer-name", title: "Payer Info", rect: CGRect(x: 0.045, y: 0.08, width: 0.43, height: 0.27))
    static let employerEIN = _099Form._099FormHighlight(id: "employer-ein", title: "Payer TIN", rect: CGRect(x: 0.045, y: 0.35, width: 0.20, height: 0.09))
    static let socialSecurityNumber = _099Form._099FormHighlight(id: "employee-social-security", title: "Recipient TIN", rect: CGRect(x: 0.245, y: 0.35, width: 0.23, height: 0.09))
    static let employeeName = _099Form._099FormHighlight(id: "employee-name", title: "Recipient Name", rect: CGRect(x: 0.045, y: 0.44, width: 0.43, height: 0.08))
    static let employeeAddress = _099Form._099FormHighlight(id: "employee-address", title: "Recipient Address", rect: CGRect(x: 0.045, y: 0.52, width: 0.43, height: 0.20))
    static let wages = _099Form._099FormHighlight(id: "wages", title: "Box 1: Nonemployee Compensation", rect: CGRect(x: 0.48, y: 0.35, width: 0.29, height: 0.09))
    static let federalTax = _099Form._099FormHighlight(id: "federal-tax", title: "Box 4: Federal Tax Withheld", rect: CGRect(x: 0.48, y: 0.60, width: 0.29, height: 0.09))
    static let fullForm = _099Form._099FormHighlight(id: "full-form", title: "1099-NEC Form", rect: CGRect(x: 0.04, y: 0.02, width: 0.92, height: 0.86))
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
