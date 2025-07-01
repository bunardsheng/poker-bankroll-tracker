import SwiftUI

struct CashOutView: View {
    @Binding var session: PokerSession
    @State private var cashOutText = ""
    @State private var showProfitAnimation = false
    
    var profit: Double {
        guard let cashOut = session.cashOut else { return 0 }
        return cashOut - session.buyIn
    }
    
    var profitPercentage: Double {
        guard session.buyIn > 0, let cashOut = session.cashOut else { return 0 }
        return (profit / session.buyIn) * 100
    }
    
    var body: some View {
        VStack(spacing: 30) {
            headerView
            
            VStack(spacing: 24) {
                cashOutInputView
                
                if session.cashOut != nil {
                    profitDisplayView
                }
                
                quickCashOutView
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            if let cashOut = session.cashOut, cashOut > 0 {
                cashOutText = "\(Int(cashOut))"
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Cash Out")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("How much are you leaving with?")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var cashOutInputView: some View {
        VStack(spacing: 16) {
            TextField("$0", text: $cashOutText)
                .textFieldStyle(CashOutTextFieldStyle())
                .keyboardType(.decimalPad)
                .onChange(of: cashOutText) { newValue in
                    if let amount = Double(newValue) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            session.cashOut = amount
                            showProfitAnimation = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showProfitAnimation = false
                        }
                    } else {
                        session.cashOut = nil
                    }
                }
            
            HStack(spacing: 20) {
                SessionSummaryCard(
                    title: "Buy-in",
                    value: "$\(Int(session.buyIn))",
                    color: Color(red: 0.5, green: 0.2, blue: 1.0)
                )
                
                SessionSummaryCard(
                    title: "Duration",
                    value: session.formattedDuration,
                    color: Color.gray
                )
            }
        }
    }
    
    private var profitDisplayView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profit/Loss")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Text(profit >= 0 ? "+$\(Int(abs(profit)))" : "-$\(Int(abs(profit)))")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(profit >= 0 ? .green : .red)
                        
                        Text("(\(profit >= 0 ? "+" : "")\(String(format: "%.1f", profitPercentage))%)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(profit >= 0 ? .green : .red)
                    }
                }
                
                Spacer()
                
                Image(systemName: profit >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(profit >= 0 ? .green : .red)
                    .scaleEffect(showProfitAnimation ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showProfitAnimation)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(profit >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(profit >= 0 ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            
            if abs(profit) > 0 {
                profitMetricsView
            }
        }
    }
    
    private var profitMetricsView: some View {
        HStack(spacing: 20) {
            MetricCard(
                title: "BB/hour",
                value: calculateBBPerHour(),
                subtitle: "Big blinds per hour"
            )
            
            MetricCard(
                title: "ROI",
                value: "\(String(format: "%.1f", profitPercentage))%",
                subtitle: "Return on investment"
            )
        }
    }
    
    private var quickCashOutView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Cash Out")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickCashOutButton(
                    title: "Break Even",
                    amount: session.buyIn,
                    subtitle: "$\(Int(session.buyIn))"
                ) {
                    setCashOut(session.buyIn)
                }
                
                QuickCashOutButton(
                    title: "Double Up",
                    amount: session.buyIn * 2,
                    subtitle: "$\(Int(session.buyIn * 2))"
                ) {
                    setCashOut(session.buyIn * 2)
                }
                
                QuickCashOutButton(
                    title: "Lost All",
                    amount: 0,
                    subtitle: "$0"
                ) {
                    setCashOut(0)
                }
                
                QuickCashOutButton(
                    title: "50% Profit",
                    amount: session.buyIn * 1.5,
                    subtitle: "$\(Int(session.buyIn * 1.5))"
                ) {
                    setCashOut(session.buyIn * 1.5)
                }
            }
        }
    }
    
    private func setCashOut(_ amount: Double) {
        cashOutText = "\(Int(amount))"
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            session.cashOut = amount
            showProfitAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showProfitAnimation = false
        }
    }
    
    private func calculateBBPerHour() -> String {
        guard let stakes = session.stakes,
              let duration = session.duration,
              duration > 0 else { return "N/A" }
        
        let hours = duration / 3600
        let bbPerHour = profit / stakes.bigBlind / hours
        
        return String(format: "%.1f", bbPerHour)
    }
}

struct CashOutTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 32, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.3), lineWidth: 2)
            )
    }
}

struct SessionSummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
            
            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
}

struct QuickCashOutButton: View {
    let title: String
    let amount: Double
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    @State var sampleSession = PokerSession.sampleSession
    return CashOutView(session: $sampleSession)
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
}