//
//  W4Form.swift
//  TaxAssist
//
//  Updated from W2Form.swift for a simple W-4 questionnaire
//

import SwiftUI

// MARK: - W-4 Data Model

struct W4Data {
    // Step 1: About You
    var firstName = ""
    var middleInitial = ""
    var lastName = ""
    var socialSecurityNumber = ""
    var homeAddress = ""
    var city = ""
    var state = ""
    var zipCode = ""

    // Step 2: Your Household
    var isMarried: Bool?
    var filesTogether: Bool?
    var paysMostHomeCosts: Bool?
    var supportedPersonLivesWithYou: Bool?

    // Step 3: Your Jobs
    var hasMultipleJobs: Bool?
    var spouseHasJob: Bool?
    var totalJobs = ""
    var job1Pay = ""
    var job2Pay = ""

    // Step 4: People You Support
    var supportsSomeone: Bool?
    var childrenUnder17 = ""
    var otherPeopleSupported = ""

    // Step 5: Money From Other Places
    var hasOtherMoney = ""
    var otherMoneyAmount = ""

    // Step 6: Things That Could Lower Your Taxes
    var selectedTaxLoweringItems: Set<String> = []
    var studentLoanInterest = ""
    var contributedToIRA: Bool?
    var paidLargeMedicalBills: Bool?
    var gaveToCharity: Bool?

    // Step 7: Taking Out Extra Money
    var wantsExtraWithholding = ""
    var extraPerPaycheck = ""

    // Step 8: Federal Tax Taken Out
    var gotAllFederalTaxBack = ""
    var expectsToOweFederalTax = ""

    // Step 10: Sign
    var signatureName = ""
    var signatureDate = ""
}

// MARK: - Question Types

enum W4QuestionType {
    case text
    case money
    case yesNo
    case options([String])
    case multiSelect([String])
}

// MARK: - Question Model

struct W4Question: Identifiable {
    let id: String
    let step: Int
    let section: String
    let title: String
    let subtitle: String
    let placeholder: String
    let help: String
    let type: W4QuestionType
    let definition: String?

    init(
        id: String,
        step: Int,
        section: String,
        title: String,
        subtitle: String,
        placeholder: String = "",
        help: String,
        type: W4QuestionType,
        definition: String? = nil
    ) {
        self.id = id
        self.step = step
        self.section = section
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self.help = help
        self.type = type
        self.definition = definition
    }
}

// MARK: - Main View

struct W4Form: View {

    var customDocumentName: String = "Form W-4"

    @State private var currentQuestion = 0
    @State private var showingIntro = true
    @State private var showingReview = false
    @State private var showingDefinition = false
    @State private var showingTaxDictionary = false

    @State private var generatedPDFUrl: URL?
    @State private var answer = ""
    @State private var selectedOptions: Set<String> = []
    @State private var validationMessage = ""
    @State private var definitionTitle = ""
    @State private var definitionMessage = ""

    @State private var w4 = W4Data()

    private let allQuestions: [W4Question] = [
        // STEP 1
        W4Question(id: "firstName", step: 1, section: "About You",
                   title: "What's your first name?", subtitle: "First Name",
                   placeholder: "John", help: "Enter your legal first name.",
                   type: .text),

        W4Question(id: "middleInitial", step: 1, section: "About You",
                   title: "What's the first letter of your middle name?", subtitle: "Middle Initial",
                   placeholder: "A", help: "If you do not have a middle name, you can leave this blank.",
                   type: .text),

        W4Question(id: "lastName", step: 1, section: "About You",
                   title: "What's your last name?", subtitle: "Last Name",
                   placeholder: "Smith", help: "Enter your legal last name.",
                   type: .text),

        W4Question(id: "ssn", step: 1, section: "About You",
                   title: "What's your Social Security number?", subtitle: "Social Security Number",
                   placeholder: "123-45-6789", help: "This is the 9-digit number on your Social Security card.",
                   type: .text,
                   definition: "A Social Security number is a 9-digit number used to identify you for government and tax records."),

        W4Question(id: "address", step: 1, section: "About You",
                   title: "What's your home address?", subtitle: "Home Address",
                   placeholder: "123 Main St", help: "Enter the street address where you live.",
                   type: .text),

        W4Question(id: "city", step: 1, section: "About You",
                   title: "What city do you live in?", subtitle: "City",
                   placeholder: "Chicago", help: "Enter the city in your home address.",
                   type: .text),

        W4Question(id: "state", step: 1, section: "About You",
                   title: "What state do you live in?", subtitle: "State",
                   placeholder: "Illinois", help: "Enter the state in your home address.",
                   type: .text),

        W4Question(id: "zip", step: 1, section: "About You",
                   title: "What's your ZIP code?", subtitle: "ZIP Code",
                   placeholder: "60601", help: "Enter the 5-digit ZIP code for your home address.",
                   type: .text),

        // STEP 2
        W4Question(id: "married", step: 2, section: "Your Household",
                   title: "Are you married?", subtitle: "Marriage",
                   help: "Choose the answer that matches you right now.",
                   type: .yesNo),

        W4Question(id: "filesTogether", step: 2, section: "Your Household",
                   title: "Will you and your spouse file taxes together?", subtitle: "Filing Together",
                   help: "This means you and your spouse plan to send one tax return together.",
                   type: .yesNo),

        W4Question(id: "paysMostHomeCosts", step: 2, section: "Your Household",
                   title: "Do you pay for most of your home's costs?", subtitle: "Home Costs",
                   help: "Think about costs like rent, food, and household bills.",
                   type: .yesNo),

        W4Question(id: "supportedPersonLivesWithYou", step: 2, section: "Your Household",
                   title: "Does a child or someone you support live with you?", subtitle: "Someone You Support",
                   help: "Choose Yes if a child or another person you help pay for lives with you.",
                   type: .yesNo),

        // STEP 3
        W4Question(id: "multipleJobs", step: 3, section: "Your Jobs",
                   title: "Do you have more than one job right now?", subtitle: "Your Jobs",
                   help: "Count jobs you currently work at the same time.",
                   type: .yesNo),

        W4Question(id: "spouseHasJob", step: 3, section: "Your Jobs",
                   title: "Does your spouse have a job?", subtitle: "Spouse's Job",
                   help: "Choose Yes if your spouse currently has a job.",
                   type: .yesNo),

        W4Question(id: "totalJobs", step: 3, section: "Your Jobs",
                   title: "How many jobs do you and your spouse have in total?", subtitle: "Total Jobs",
                   placeholder: "2", help: "Add together your current jobs and your spouse's current jobs.",
                   type: .text),

        W4Question(id: "job1Pay", step: 3, section: "Your Jobs",
                   title: "About how much will Job 1 pay this year?", subtitle: "Job 1 Pay",
                   placeholder: "30,000", help: "An estimate is okay.",
                   type: .money),

        W4Question(id: "job2Pay", step: 3, section: "Your Jobs",
                   title: "About how much will Job 2 pay this year?", subtitle: "Job 2 Pay",
                   placeholder: "15,000", help: "An estimate is okay.",
                   type: .money),

        // STEP 4
        W4Question(id: "supportsSomeone", step: 4, section: "People You Support",
                   title: "Do you help pay for a child or someone else?", subtitle: "People You Support",
                   help: "Not sure if someone counts? We can help.",
                   type: .yesNo),

        W4Question(id: "childrenUnder17", step: 4, section: "People You Support",
                   title: "How many children under 17 do you support?", subtitle: "Children Under 17",
                   placeholder: "0", help: "Enter the number of children under 17 you help support.",
                   type: .text),

        W4Question(id: "otherPeopleSupported", step: 4, section: "People You Support",
                   title: "How many other people do you support?", subtitle: "Other People",
                   placeholder: "0", help: "Do not count the children you already entered.",
                   type: .text),

        // STEP 5
        W4Question(id: "otherMoney", step: 5, section: "Money From Other Places",
                   title: "Will you make money from anywhere besides your job?", subtitle: "Other Money",
                   help: "Examples include money from investments, retirement, or a bank account.",
                   type: .options(["Yes", "No", "I'm not sure"])),

        W4Question(id: "otherMoneyAmount", step: 5, section: "Money From Other Places",
                   title: "About how much money will you make from those other places?", subtitle: "Other Money Amount",
                   placeholder: "1,000", help: "An estimate is okay.",
                   type: .money),

        // STEP 6
        W4Question(id: "taxLoweringItems", step: 6, section: "Things That Could Lower Your Taxes",
                   title: "Have you spent money on any of these this year?", subtitle: "Money You Spent",
                   help: "Choose every option that applies. The app will handle the tax details for you.",
                   type: .multiSelect([
                    "Student loan interest",
                    "Putting money into a retirement account",
                    "Large medical bills",
                    "Giving money to charity",
                    "None of these",
                    "I'm not sure"
                   ])),

        W4Question(id: "studentLoanInterest", step: 6, section: "Things That Could Lower Your Taxes",
                   title: "About how much student loan interest did you pay?", subtitle: "Student Loan Interest",
                   placeholder: "500", help: "Enter your best estimate.",
                   type: .money),

        W4Question(id: "ira", step: 6, section: "Things That Could Lower Your Taxes",
                   title: "Did you put your own money into an IRA?", subtitle: "Retirement",
                   help: "An IRA is a personal retirement account.",
                   type: .yesNo,
                   definition: "An IRA is an account you can use to save your own money for retirement."),

        W4Question(id: "medical", step: 6, section: "Things That Could Lower Your Taxes",
                   title: "Did you pay a lot of medical bills yourself?", subtitle: "Medical Bills",
                   help: "Think about medical costs you paid with your own money.",
                   type: .yesNo),

        W4Question(id: "charity", step: 6, section: "Things That Could Lower Your Taxes",
                   title: "Did you give money or items to charity?", subtitle: "Charity",
                   help: "Choose Yes if you donated money or items to a charity.",
                   type: .yesNo),

        // STEP 7
        W4Question(id: "extraWithholding", step: 7, section: "Taking Out Extra Money",
                   title: "Do you want a little more tax taken out of each paycheck?", subtitle: "Extra Money Taken Out",
                   help: "Taking out more now could mean you owe less later.",
                   type: .options(["Yes", "No", "I'm not sure"])),

        W4Question(id: "extraAmount", step: 7, section: "Taking Out Extra Money",
                   title: "How much extra should come out of each paycheck?", subtitle: "Extra Per Paycheck",
                   placeholder: "25", help: "Enter the extra amount you want taken from each paycheck.",
                   type: .money),

        // STEP 8
        W4Question(id: "allTaxBack", step: 8, section: "Do You Need Federal Tax Taken Out?",
                   title: "Last year, did you get back all the federal income tax taken from your paychecks?", subtitle: "Last Year's Federal Tax",
                   help: "If you do not know, choose I'm not sure.",
                   type: .options(["Yes", "No", "I'm not sure", "I didn't file taxes"])),

        W4Question(id: "oweThisYear", step: 8, section: "Do You Need Federal Tax Taken Out?",
                   title: "This year, do you think you'll owe any federal income tax?", subtitle: "This Year's Federal Tax",
                   help: "If you do not know, choose I'm not sure.",
                   type: .options(["Yes", "No", "I'm not sure"])),

        // STEP 10
        W4Question(id: "signature", step: 10, section: "Sign",
                   title: "Type your full name to sign.", subtitle: "Your Signature",
                   placeholder: "John A Smith", help: "Type your full legal name.",
                   type: .text),

        W4Question(id: "date", step: 10, section: "Sign",
                   title: "What's today's date?", subtitle: "Today's Date",
                   placeholder: "07/13/2026", help: "Enter today's date.",
                   type: .text)
    ]

    private var visibleQuestions: [W4Question] {
        allQuestions.filter { shouldShow($0) }
    }

    private var current: W4Question {
        visibleQuestions[currentQuestion]
    }

    private var progress: Double {
        guard !visibleQuestions.isEmpty else { return 0 }
        return Double(currentQuestion + 1) / Double(visibleQuestions.count)
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
        .navigationTitle("W-4 Guide")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingTaxDictionary = true } label: {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        .navigationDestination(item: $generatedPDFUrl) { url in
            PDFPreviewScreen(pdfURL: url)
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

    // MARK: - Intro

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 44))
                .foregroundColor(.blue)

            Text("Before You Start")
                .font(.title.bold())

            Text("Answer simple questions about you, your household, and your money. We'll handle the tax wording behind the scenes.")
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
                Text("Start Questions").font(.headline)
                Image(systemName: "arrow.right")
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Progress

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Step \(current.step): \(current.section)")
                        .font(.title2.bold())
                    Text("Question \(currentQuestion + 1) of \(visibleQuestions.count)")
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
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 6) {
                Text(current.subtitle)
                    .font(.headline)
                    .foregroundColor(.blue)

                if let definition = current.definition {
                    Button {
                        definitionTitle = current.subtitle
                        definitionMessage = definition
                        showingDefinition = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(current.title)
                .font(.title2.bold())

            questionInput(for: current)

            if !validationMessage.isEmpty {
                Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            Divider()

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Need Help?")
                        .font(.headline)
                    Text(current.help)
                        .foregroundColor(.secondary)
                }
            }

            Button {
                showingTaxDictionary = true
            } label: {
                HStack {
                    Image(systemName: "character.book.closed.fill")
                    VStack(alignment: .leading) {
                        Text("Confused by a term?").font(.headline)
                        Text("Look it up in the Tax Dictionary")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    @ViewBuilder
    private func questionInput(for question: W4Question) -> some View {
        switch question.type {
        case .text:
            TextField(question.placeholder, text: $answer)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))

        case .money:
            HStack {
                Text("$").font(.title2.bold())
                TextField(question.placeholder, text: $answer)
                    .keyboardType(.decimalPad)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))

        case .yesNo:
            optionButtons(["Yes", "No"], allowsMultiple: false)

        case .options(let options):
            optionButtons(options, allowsMultiple: false)

        case .multiSelect(let options):
            optionButtons(options, allowsMultiple: true)
        }
    }

    private func optionButtons(_ options: [String], allowsMultiple: Bool) -> some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                let selected = allowsMultiple
                    ? selectedOptions.contains(option)
                    : answer == option

                Button {
                    validationMessage = ""

                    if allowsMultiple {
                        if option == "None of these" || option == "I'm not sure" {
                            selectedOptions = [option]
                        } else {
                            selectedOptions.remove("None of these")
                            selectedOptions.remove("I'm not sure")
                            if selectedOptions.contains(option) {
                                selectedOptions.remove(option)
                            } else {
                                selectedOptions.insert(option)
                            }
                        }
                    } else {
                        answer = option
                    }
                } label: {
                    HStack {
                        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        Text(option)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Navigation

    private var questionNavigationButtons: some View {
        HStack(spacing: 12) {
            if currentQuestion > 0 {
                Button {
                    goToPreviousQuestion()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.left")
                        Text("Back").font(.headline)
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
                    Text(current.id == "oweThisYear" ? "Check Answers" :
                         currentQuestion == visibleQuestions.count - 1 ? "Review Answers" : "Continue")
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

    private func goToPreviousQuestion() {
        saveCurrentAnswer()
        if currentQuestion > 0 {
            currentQuestion -= 1
            loadAnswerForCurrentQuestion()
        }
    }

    private func goToNextQuestion() {
        guard validateCurrentAnswer() else { return }
        let completedID = current.id
        saveCurrentAnswer()

        // Step 9 is the review screen, shown after Step 8.
        if completedID == "oweThisYear" {
            showingReview = true
            return
        }
        // Step 10 is complete after the date question.
        // Generate the PDF instead of returning to the review screen.
        if completedID == "date" {
            do {
                generatedPDFUrl = try createW4PDF(from: w4)
            }  catch {
                validationMessage = error.localizedDescription
                print("PDF ERROR: \(error)")
            }

            return
        }

        let refreshedQuestions = visibleQuestions

        if currentQuestion < refreshedQuestions.count - 1 {
            currentQuestion += 1
            loadAnswerForCurrentQuestion()
        }
    }

    // MARK: - Conditional Questions

    private func shouldShow(_ question: W4Question) -> Bool {
        switch question.id {
        case "filesTogether":
            return w4.isMarried == true

        case "paysMostHomeCosts", "supportedPersonLivesWithYou":
            return w4.isMarried == false

        case "spouseHasJob":
            return w4.isMarried == true

        case "totalJobs", "job1Pay", "job2Pay":
            return hasMultipleHouseholdJobs

        case "childrenUnder17", "otherPeopleSupported":
            return w4.supportsSomeone == true

        case "otherMoneyAmount":
            return w4.hasOtherMoney == "Yes"

        case "studentLoanInterest":
            return w4.selectedTaxLoweringItems.contains("Student loan interest")

        case "ira":
            return w4.selectedTaxLoweringItems.contains("Putting money into a retirement account")

        case "medical":
            return w4.selectedTaxLoweringItems.contains("Large medical bills")

        case "charity":
            return w4.selectedTaxLoweringItems.contains("Giving money to charity")

        case "extraAmount":
            return w4.wantsExtraWithholding == "Yes"

        default:
            return true
        }
    }

    private var hasMultipleHouseholdJobs: Bool {
        if w4.hasMultipleJobs == true { return true }
        if w4.isMarried == true && w4.spouseHasJob == true { return true }
        return false
    }

    // MARK: - Save / Load

    private func saveCurrentAnswer() {
        switch current.id {
        case "firstName": w4.firstName = answer
        case "middleInitial": w4.middleInitial = answer
        case "lastName": w4.lastName = answer
        case "ssn": w4.socialSecurityNumber = answer
        case "address": w4.homeAddress = answer
        case "city": w4.city = answer
        case "state": w4.state = answer
        case "zip": w4.zipCode = answer

        case "married": w4.isMarried = boolValue(answer)
        case "filesTogether": w4.filesTogether = boolValue(answer)
        case "paysMostHomeCosts": w4.paysMostHomeCosts = boolValue(answer)
        case "supportedPersonLivesWithYou": w4.supportedPersonLivesWithYou = boolValue(answer)

        case "multipleJobs": w4.hasMultipleJobs = boolValue(answer)
        case "spouseHasJob": w4.spouseHasJob = boolValue(answer)
        case "totalJobs": w4.totalJobs = answer
        case "job1Pay": w4.job1Pay = answer
        case "job2Pay": w4.job2Pay = answer

        case "supportsSomeone": w4.supportsSomeone = boolValue(answer)
        case "childrenUnder17": w4.childrenUnder17 = answer
        case "otherPeopleSupported": w4.otherPeopleSupported = answer

        case "otherMoney": w4.hasOtherMoney = answer
        case "otherMoneyAmount": w4.otherMoneyAmount = answer

        case "taxLoweringItems": w4.selectedTaxLoweringItems = selectedOptions
        case "studentLoanInterest": w4.studentLoanInterest = answer
        case "ira": w4.contributedToIRA = boolValue(answer)
        case "medical": w4.paidLargeMedicalBills = boolValue(answer)
        case "charity": w4.gaveToCharity = boolValue(answer)

        case "extraWithholding": w4.wantsExtraWithholding = answer
        case "extraAmount": w4.extraPerPaycheck = answer

        case "allTaxBack": w4.gotAllFederalTaxBack = answer
        case "oweThisYear": w4.expectsToOweFederalTax = answer

        case "signature": w4.signatureName = answer
        case "date": w4.signatureDate = answer
        default: break
        }
    }

    private func loadAnswerForCurrentQuestion() {
        guard visibleQuestions.indices.contains(currentQuestion) else { return }
        let question = visibleQuestions[currentQuestion]
        answer = answerForQuestion(question)
        selectedOptions = question.id == "taxLoweringItems"
            ? w4.selectedTaxLoweringItems
            : []
        validationMessage = ""
    }

    private func answerForQuestion(_ question: W4Question) -> String {
        switch question.id {
        case "firstName": return w4.firstName
        case "middleInitial": return w4.middleInitial
        case "lastName": return w4.lastName
        case "ssn": return w4.socialSecurityNumber
        case "address": return w4.homeAddress
        case "city": return w4.city
        case "state": return w4.state
        case "zip": return w4.zipCode

        case "married": return stringValue(w4.isMarried)
        case "filesTogether": return stringValue(w4.filesTogether)
        case "paysMostHomeCosts": return stringValue(w4.paysMostHomeCosts)
        case "supportedPersonLivesWithYou": return stringValue(w4.supportedPersonLivesWithYou)

        case "multipleJobs": return stringValue(w4.hasMultipleJobs)
        case "spouseHasJob": return stringValue(w4.spouseHasJob)
        case "totalJobs": return w4.totalJobs
        case "job1Pay": return w4.job1Pay
        case "job2Pay": return w4.job2Pay

        case "supportsSomeone": return stringValue(w4.supportsSomeone)
        case "childrenUnder17": return w4.childrenUnder17
        case "otherPeopleSupported": return w4.otherPeopleSupported

        case "otherMoney": return w4.hasOtherMoney
        case "otherMoneyAmount": return w4.otherMoneyAmount

        case "studentLoanInterest": return w4.studentLoanInterest
        case "ira": return stringValue(w4.contributedToIRA)
        case "medical": return stringValue(w4.paidLargeMedicalBills)
        case "charity": return stringValue(w4.gaveToCharity)

        case "extraWithholding": return w4.wantsExtraWithholding
        case "extraAmount": return w4.extraPerPaycheck

        case "allTaxBack": return w4.gotAllFederalTaxBack
        case "oweThisYear": return w4.expectsToOweFederalTax

        case "signature": return w4.signatureName
        case "date": return w4.signatureDate
        default: return ""
        }
    }

    private func validateCurrentAnswer() -> Bool {
        if current.id == "middleInitial" {
            return true
        }

        switch current.type {
        case .multiSelect:
            if selectedOptions.isEmpty {
                validationMessage = "Please choose at least one answer."
                return false
            }

        case .text, .money, .yesNo, .options:
            if answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validationMessage = "Please answer this question."
                return false
            }
        }

        validationMessage = ""
        return true
    }

    private func boolValue(_ value: String) -> Bool? {
        if value == "Yes" { return true }
        if value == "No" { return false }
        return nil
    }

    private func stringValue(_ value: Bool?) -> String {
        guard let value else { return "" }
        return value ? "Yes" : "No"
    }

    // MARK: - Review / Step 9
    // MARK: - W-4 PDF Generator

    private func createW4PDF(from data: W4Data) throws -> URL {
        return try UniversalPDFGenerator.generate(
            baseImageName: "W4Form",
            outputFileName: customDocumentName
        ) { imageRect in

            let pageWidth: CGFloat = 611.976
            let pageHeight: CGFloat = 791.968

            func fieldRect(
                left: CGFloat,
                top: CGFloat,
                right: CGFloat,
                bottom: CGFloat
            ) -> CGRect {
                UniversalPDFGenerator.fieldRect(
                    x: left / pageWidth,
                    y: top / pageHeight,
                    width: (right - left) / pageWidth,
                    height: (bottom - top) / pageHeight,
                    inside: imageRect
                )
            }

            func draw(
                _ value: String,
                left: CGFloat,
                top: CGFloat,
                right: CGFloat,
                bottom: CGFloat,
                fontSize: CGFloat = 9
            ) {
                guard !value
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty else {
                    return
                }

                UniversalPDFGenerator.drawText(
                    value,
                    in: fieldRect(
                        left: left,
                        top: top,
                        right: right,
                        bottom: bottom
                    ),
                    fontSize: fontSize
                )
            }

            // First name and middle initial

            let firstAndMiddle = [
                data.firstName,
                data.middleInitial
            ]
            .filter {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .joined(separator: " ")

            draw(
                firstAndMiddle,
                left: 94.60,
                top: 93.999,
                right: 272.85,
                bottom: 108.00
            )

            // Last name

            draw(
                data.lastName,
                left: 274.60,
                top: 93.999,
                right: 474.45,
                bottom: 108.00
            )

            // Home address

            draw(
                data.homeAddress,
                left: 94.60,
                top: 118.00,
                right: 474.45,
                bottom: 132.001
            )

            // City, State, ZIP

            let cityStateZIP =
                "\(data.city), \(data.state) \(data.zipCode)"

            draw(
                cityStateZIP,
                left: 94.60,
                top: 142.001,
                right: 474.45,
                bottom: 156.002
            )

            // Social Security Number

            draw(
                data.socialSecurityNumber,
                left: 476.20,
                top: 93.999,
                right: 576.00,
                bottom: 108.00
            )

            // Filing Status

            let filingStatus = filingChoice

            if filingStatus == "Single or married filing separately" {
                draw(
                    "X",
                    left: 115.20,
                    top: 157.998,
                    right: 123.20,
                    bottom: 165.998,
                    fontSize: 7
                )
            } else if filingStatus == "Married filing together" {
                draw(
                    "X",
                    left: 115.20,
                    top: 170.00,
                    right: 123.20,
                    bottom: 178.00,
                    fontSize: 7
                )
            } else if filingStatus == "Head of household" {
                draw(
                    "X",
                    left: 115.20,
                    top: 181.749,
                    right: 123.20,
                    bottom: 189.749,
                    fontSize: 7
                )
            }

            // Two jobs checkbox

            if Int(data.totalJobs) == 2 {
                draw(
                    "X",
                    left: 564.00,
                    top: 404.000,
                    right: 572.00,
                    bottom: 412.000,
                    fontSize: 7
                )
            }

            // Dependents

            let childCount =
                Int(data.childrenUnder17) ?? 0

            let otherDependentCount =
                Int(data.otherPeopleSupported) ?? 0

            let childCredit =
                childCount * 2200

            let otherDependentCredit =
                otherDependentCount * 500

            if childCredit > 0 {
                draw(
                    "\(childCredit)",
                    left: 417.60,
                    top: 479.999,
                    right: 481.65,
                    bottom: 491.998
                )
            }

            if otherDependentCredit > 0 {
                draw(
                    "\(otherDependentCredit)",
                    left: 417.60,
                    top: 492.001,
                    right: 481.65,
                    bottom: 504.000
                )
            }

            let totalDependentCredit =
                childCredit + otherDependentCredit

            if totalDependentCredit > 0 {
                draw(
                    "\(totalDependentCredit)",
                    left: 511.20,
                    top: 515.999,
                    right: 576.00,
                    bottom: 527.998
                )
            }

            // Other income

            if data.hasOtherMoney == "Yes" {
                draw(
                    data.otherMoneyAmount,
                    left: 511.20,
                    top: 551.999,
                    right: 576.00,
                    bottom: 563.998
                )
            }

            // Extra withholding

            if data.wantsExtraWithholding == "Yes" {
                draw(
                    data.extraPerPaycheck,
                    left: 511.20,
                    top: 605.999,
                    right: 576.00,
                    bottom: 617.998
                )
            }

            // Exempt checkbox

            if mayNotNeedFederalWithholding {
                draw(
                    "X",
                    left: 564.00,
                    top: 654.50,
                    right: 572.00,
                    bottom: 662.50,
                    fontSize: 7
                )
            }

            // Signature

            draw(
                data.signatureName,
                left: 94.60,
                top: 725.999,
                right: 388.05,
                bottom: 756.00,
                fontSize: 10
            )

            // Date

            draw(
                data.signatureDate,
                left: 389.80,
                top: 743.999,
                right: 467.25,
                bottom: 756.00
            )
        }
    }
    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("You're almost done!")
                .font(.largeTitle.bold())

            Text("Take a quick look at your answers.")
                .foregroundColor(.secondary)

            Divider()

            reviewRow(title: "Filing choice", value: filingChoice)
            reviewRow(title: "More than one job", value: stringValue(w4.hasMultipleJobs))
            reviewRow(title: "Children you support", value: w4.childrenUnder17.isEmpty ? "0" : w4.childrenUnder17)
            reviewRow(title: "Other money", value: w4.hasOtherMoney == "Yes" ? moneyDisplay(w4.otherMoneyAmount) : "None")
            reviewRow(title: "Extra taken from paychecks", value: w4.wantsExtraWithholding == "Yes" ? moneyDisplay(w4.extraPerPaycheck) : "$0")

            if mayNotNeedFederalWithholding {
                VStack(alignment: .leading, spacing: 12) {
                    Text("You may not need federal income tax taken from your paychecks.")
                        .font(.headline)

                    Button("Explain This") {
                        definitionTitle = "Federal Tax Taken Out"
                        definitionMessage = "Based on your answers, you may qualify to claim exempt from federal income tax withholding. The app should confirm the official W-4 rules before applying this."
                        showingDefinition = true
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Text("Does everything look right?")
                .font(.title3.bold())

            Button {
                currentQuestion = 0
                showingReview = false
                loadAnswerForCurrentQuestion()
            } label: {
                Text("Change an Answer")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)

            Button {
                if let signatureIndex = visibleQuestions.firstIndex(where: { $0.id == "signature" }) {
                    currentQuestion = signatureIndex
                    showingReview = false
                    loadAnswerForCurrentQuestion()
                }
            } label: {
                Text("Yes, Looks Good")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                currentQuestion = 0
                showingIntro = true
                showingReview = false
                answer = ""
                selectedOptions = []
                w4 = W4Data()
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

    private func reviewRow(title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value.isEmpty ? "-" : value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 6)
    }

    private var filingChoice: String {
        if w4.isMarried == true && w4.filesTogether == true {
            return "Married filing together"
        }
        if w4.isMarried == false &&
            w4.paysMostHomeCosts == true &&
            w4.supportedPersonLivesWithYou == true {
            return "Head of household"
        }
        return "Single or married filing separately"
    }

    private var mayNotNeedFederalWithholding: Bool {
        w4.gotAllFederalTaxBack == "Yes" &&
        w4.expectsToOweFederalTax == "No"
    }

    private func moneyDisplay(_ value: String) -> String {
        value.isEmpty ? "$0" : "$\(value)"
    }
}

#Preview {
    NavigationStack {
        W4Form()
    }
}
