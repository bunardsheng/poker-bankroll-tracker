import SwiftUI

struct GameTypeSelectionView: View {
    @Binding var session: PokerSession
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            headerView
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(GameType.allCases, id: \.self) { gameType in
                        GameTypeCard(
                            gameType: gameType,
                            isSelected: session.gameType == gameType
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                session.gameType = gameType
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("What are you playing?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Select your game type")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

struct GameTypeCard: View {
    let gameType: GameType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(gameType.emoji)
                    .font(.system(size: 40))
                
                Text(gameType.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? 
                          Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.2) : 
                          Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? 
                                   Color(red: 0.0, green: 0.8, blue: 0.8) : 
                                   Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct StakesSelectionView: View {
    @Binding var session: PokerSession
    @State private var customSmallBlind = ""
    @State private var customBigBlind = ""
    @State private var showCustomStakes = false
    
    var body: some View {
        VStack(spacing: 30) {
            headerView
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(StakesLevel.commonStakes, id: \.self) { stakes in
                        StakesCard(
                            stakes: stakes,
                            isSelected: session.stakes == stakes
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                session.stakes = stakes
                                showCustomStakes = false
                            }
                        }
                    }
                    
                    Button("Custom Stakes") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showCustomStakes.toggle()
                        }
                    }
                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
                    .padding(.top, 10)
                    
                    if showCustomStakes {
                        customStakesView
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Stakes")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Select your table stakes")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var customStakesView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Small Blind")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    TextField("$1", text: $customSmallBlind)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Big Blind")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    TextField("$2", text: $customBigBlind)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
            
            Button("Set Custom Stakes") {
                if let sb = Double(customSmallBlind), let bb = Double(customBigBlind) {
                    session.stakes = StakesLevel(smallBlind: sb, bigBlind: bb, ante: nil)
                }
            }
            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white.opacity(0.02))
        .cornerRadius(16)
    }
}

struct StakesCard: View {
    let stakes: StakesLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(stakes.displayString)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
                        .font(.system(size: 20))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                          Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.2) : 
                          Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? 
                                   Color(red: 0.0, green: 0.8, blue: 0.8) : 
                                   Color.clear, lineWidth: 1)
                    )
            )
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}

#Preview {
    @State var sampleSession = PokerSession.sampleSession
    return GameTypeSelectionView(session: $sampleSession)
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
}