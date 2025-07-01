import SwiftUI

struct NotesView: View {
    @Binding var session: PokerSession
    @State private var notesText = ""
    @State private var selectedTags: Set<String> = []
    @FocusState private var isTextFieldFocused: Bool
    
    let quickTags = [
        "Tight table", "Loose table", "Aggressive players", "Passive players",
        "Good run", "Bad run", "Tilted", "Focused", "Tournament",
        "Cash game", "Short session", "Long session", "Good reads",
        "Missed opportunities", "Lucky", "Unlucky", "Study session"
    ]
    
    let quickNotes = [
        "Played solid poker today",
        "Need to work on bet sizing",
        "Table was very loose/aggressive",
        "Made some good reads",
        "Ran below expectation",
        "Great session overall"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            ScrollView {
                VStack(spacing: 24) {
                    sessionSummaryCard
                    
                    notesInputSection
                    
                    quickTagsSection
                    
                    quickNotesSection
                }
                .padding(.horizontal, 20)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.top, 20)
        .onAppear {
            notesText = session.notes
        }
        .onChange(of: notesText) { newValue in
            session.notes = newValue
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Session Notes")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Record your thoughts and observations")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var sessionSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session Summary")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(session.gameType.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if let profit = session.profit {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(profit >= 0 ? "+$\(Int(abs(profit)))" : "-$\(Int(abs(profit)))")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(profit >= 0 ? .green : .red)
                        
                        Text(session.formattedDuration)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            HStack(spacing: 16) {
                SummaryMetric(
                    title: "Stakes",
                    value: session.stakes?.displayString ?? "N/A"
                )
                
                SummaryMetric(
                    title: "Location",
                    value: session.location.isEmpty ? "Unknown" : session.location
                )
                
                SummaryMetric(
                    title: "Buy-in",
                    value: "$\(Int(session.buyIn))"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var notesInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            TextEditor(text: $notesText)
                .focused($isTextFieldFocused)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding()
                .frame(minHeight: 120)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isTextFieldFocused ? 
                               Color(red: 0.0, green: 0.8, blue: 0.8) : 
                               Color.white.opacity(0.1), lineWidth: 1)
                )
            
            if notesText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Tip: Record what worked well and what to improve")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Consider noting: table dynamics, key hands, emotions, strategy adjustments")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var quickTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Tags")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(quickTags, id: \.self) { tag in
                    QuickTagButton(
                        tag: tag,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        toggleTag(tag)
                    }
                }
            }
        }
    }
    
    private var quickNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Notes")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(quickNotes, id: \.self) { note in
                    QuickNoteButton(note: note) {
                        addQuickNote(note)
                    }
                }
            }
        }
    }
    
    private func toggleTag(_ tag: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedTags.contains(tag) {
                selectedTags.remove(tag)
                removeTagFromNotes(tag)
            } else {
                selectedTags.insert(tag)
                addTagToNotes(tag)
            }
        }
    }
    
    private func addTagToNotes(_ tag: String) {
        if !notesText.contains("#\(tag.replacingOccurrences(of: " ", with: ""))") {
            if !notesText.isEmpty && !notesText.hasSuffix(" ") {
                notesText += " "
            }
            notesText += "#\(tag.replacingOccurrences(of: " ", with: "")) "
        }
    }
    
    private func removeTagFromNotes(_ tag: String) {
        let tagString = "#\(tag.replacingOccurrences(of: " ", with: ""))"
        notesText = notesText.replacingOccurrences(of: tagString, with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func addQuickNote(_ note: String) {
        if !notesText.isEmpty {
            notesText += "\n\n"
        }
        notesText += note
    }
}

struct SummaryMetric: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickTagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.0, green: 0.8, blue: 0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? 
                              Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.3) : 
                              Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.5), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct QuickNoteButton: View {
    let note: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(note)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
            }
            .padding()
            .background(Color.white.opacity(0.03))
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
    return NotesView(session: $sampleSession)
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
}