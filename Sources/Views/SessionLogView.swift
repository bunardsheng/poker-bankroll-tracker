import SwiftUI

struct SessionLogView: View {
    @StateObject private var viewModel = SessionLogViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.12)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    progressIndicator
                    
                    TabView(selection: $viewModel.currentStep) {
                        GameTypeSelectionView(session: $viewModel.session)
                            .tag(SessionLogStep.gameType)
                        
                        StakesSelectionView(session: $viewModel.session)
                            .tag(SessionLogStep.stakes)
                        
                        LocationView(session: $viewModel.session)
                            .tag(SessionLogStep.location)
                        
                        BuyInView(session: $viewModel.session)
                            .tag(SessionLogStep.buyIn)
                        
                        SessionTimerView(session: $viewModel.session)
                            .tag(SessionLogStep.timer)
                        
                        CashOutView(session: $viewModel.session)
                            .tag(SessionLogStep.cashOut)
                        
                        NotesView(session: $viewModel.session)
                            .tag(SessionLogStep.notes)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                    
                    navigationButtons
                }
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentStep == .notes {
                        Button("Save") {
                            viewModel.saveSession()
                            dismiss()
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(SessionLogStep.allCases.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= viewModel.currentStep.rawValue ? 
                          Color(red: 0.0, green: 0.8, blue: 0.8) : 
                          Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var navigationButtons: some View {
        HStack {
            if viewModel.currentStep != .gameType {
                Button("Back") {
                    viewModel.previousStep()
                }
                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
                .padding()
            }
            
            Spacer()
            
            if viewModel.currentStep != .notes {
                Button("Next") {
                    viewModel.nextStep()
                }
                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
                .fontWeight(.semibold)
                .padding()
                .disabled(!viewModel.canProceedToNextStep)
                .opacity(viewModel.canProceedToNextStep ? 1.0 : 0.5)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

enum SessionLogStep: Int, CaseIterable {
    case gameType = 0
    case stakes = 1
    case location = 2
    case buyIn = 3
    case timer = 4
    case cashOut = 5
    case notes = 6
    
    var title: String {
        switch self {
        case .gameType: return "Game Type"
        case .stakes: return "Stakes"
        case .location: return "Location"
        case .buyIn: return "Buy-in"
        case .timer: return "Session"
        case .cashOut: return "Cash Out"
        case .notes: return "Notes"
        }
    }
}

class SessionLogViewModel: ObservableObject {
    @Published var session = PokerSession(gameType: .nlhe)
    @Published var currentStep: SessionLogStep = .gameType
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .gameType:
            return true
        case .stakes:
            return session.stakes != nil
        case .location:
            return !session.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .buyIn:
            return session.buyIn > 0
        case .timer:
            return session.state == .inProgress || session.state == .completed
        case .cashOut:
            return session.cashOut != nil && session.cashOut! >= 0
        case .notes:
            return true
        }
    }
    
    func nextStep() {
        if let nextStep = SessionLogStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
    
    func previousStep() {
        if let previousStep = SessionLogStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }
    
    func saveSession() {
        session.state = .completed
        if session.endTime == nil {
            session.endTime = Date()
        }
    }
}

#Preview {
    SessionLogView()
}