import SwiftUI

struct SessionTimerView: View {
    @Binding var session: PokerSession
    @State private var currentTime = Date()
    @State private var timer: Timer?
    
    var elapsedTime: TimeInterval {
        currentTime.timeIntervalSince(session.startTime)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            headerView
            
            timerDisplay
            
            controlButtons
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Session Timer")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(session.state == .inProgress ? "Session in progress" : "Ready to start")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var timerDisplay: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: min(elapsedTime / 14400, 1.0)) // 4 hours max
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.8, blue: 0.8),
                                Color(red: 0.5, green: 0.2, blue: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: elapsedTime)
                
                VStack(spacing: 8) {
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("Elapsed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            sessionStatsView
        }
    }
    
    private var sessionStatsView: some View {
        HStack(spacing: 30) {
            StatCard(
                title: "Buy-in",
                value: "$\(Int(session.buyIn))",
                color: Color(red: 0.5, green: 0.2, blue: 1.0)
            )
            
            StatCard(
                title: "Stakes",
                value: session.stakes?.displayString ?? "N/A",
                color: Color(red: 0.0, green: 0.8, blue: 0.8)
            )
        }
    }
    
    private var controlButtons: some View {
        VStack(spacing: 16) {
            if session.state != .inProgress {
                Button("Start Session") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        session.state = .inProgress
                        session.startTime = Date()
                        currentTime = Date()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                HStack(spacing: 16) {
                    Button("Pause") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            session.state = .setup
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("End Session") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            session.state = .completed
                            session.endTime = Date()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct StatCard: View {
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
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 0.8, blue: 0.8),
                        Color(red: 0.5, green: 0.2, blue: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.0, green: 0.8, blue: 0.8), lineWidth: 1)
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LocationView: View {
    @Binding var session: PokerSession
    @State private var locationText = ""
    
    let popularLocations = [
        "Aria Casino", "Bellagio", "MGM Grand", "Wynn Las Vegas",
        "Commerce Casino", "Borgata", "Foxwoods", "Mohegan Sun",
        "Home Game", "Online", "Private Club"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            headerView
            
            VStack(spacing: 20) {
                TextField("Enter location", text: $locationText)
                    .textFieldStyle(LocationTextFieldStyle())
                    .onChange(of: locationText) { newValue in
                        session.location = newValue
                    }
                
                popularLocationsView
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            locationText = session.location
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Where are you playing?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Enter your location")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var popularLocationsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Locations")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(popularLocations, id: \.self) { location in
                    Button(location) {
                        locationText = location
                        session.location = location
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    .font(.system(size: 14, weight: .medium))
                }
            }
        }
    }
}

struct LocationTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 18, weight: .medium))
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.3), lineWidth: 1)
            )
    }
}

struct BuyInView: View {
    @Binding var session: PokerSession
    @State private var buyInText = ""
    
    let quickAmounts = [100, 200, 300, 500, 1000, 2000]
    
    var body: some View {
        VStack(spacing: 30) {
            headerView
            
            VStack(spacing: 24) {
                TextField("$0", text: $buyInText)
                    .textFieldStyle(BuyInTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: buyInText) { newValue in
                        if let amount = Double(newValue) {
                            session.buyIn = amount
                        }
                    }
                
                quickAmountsView
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            if session.buyIn > 0 {
                buyInText = "\(Int(session.buyIn))"
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Buy-in Amount")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("How much are you buying in for?")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var quickAmountsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Amounts")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    Button("$\(amount)") {
                        buyInText = "\(amount)"
                        session.buyIn = Double(amount)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

struct BuyInTextFieldStyle: TextFieldStyle {
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

#Preview {
    @State var sampleSession = PokerSession.sampleSession
    return SessionTimerView(session: $sampleSession)
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
}