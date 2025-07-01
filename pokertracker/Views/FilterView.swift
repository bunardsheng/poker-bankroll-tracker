import SwiftUI

struct FilterView: View {
    @ObservedObject var dataManager: AnalyticsDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var startDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    @State private var useCustomDateRange: Bool = false
    @State private var selectedQuickRange: QuickDateRange = .all
    
    @State private var selectedGameTypes: Set<GameType> = []
    @State private var selectedStakes: Set<Stakes> = []
    @State private var selectedLocations: Set<String> = []
    
    private var allGameTypes: [GameType] = GameType.allCases
    private var allStakes: [Stakes] = Stakes.common
    private var allLocations: [String] {
        Array(Set(dataManager.analyticsData.sessions.map { $0.location })).sorted()
    }
    
    var body: some View {
        NavigationView {
            Form {
                dateRangeSection
                gameTypeSection
                stakesSection
                locationSection
                actionButtons
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadCurrentFilters()
        }
    }
    
    private var dateRangeSection: some View {
        Section(header: Text("Date Range")) {
            Picker("Quick Range", selection: $selectedQuickRange) {
                ForEach(QuickDateRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .onChange(of: selectedQuickRange) { range in
                if range != .custom {
                    useCustomDateRange = false
                    updateDatesForQuickRange(range)
                }
            }
            
            Toggle("Custom Date Range", isOn: $useCustomDateRange)
                .onChange(of: useCustomDateRange) { isCustom in
                    if isCustom {
                        selectedQuickRange = .custom
                    }
                }
            
            if useCustomDateRange {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }
        }
    }
    
    private var gameTypeSection: some View {
        Section(header: Text("Game Types")) {
            ForEach(allGameTypes, id: \.self) { gameType in
                MultiSelectRow(
                    title: gameType.rawValue,
                    subtitle: gameType.shortName,
                    isSelected: selectedGameTypes.contains(gameType)
                ) {
                    toggleSelection(gameType: gameType)
                }
            }
            
            if !selectedGameTypes.isEmpty {
                Button("Clear All Game Types") {
                    selectedGameTypes.removeAll()
                }
                .foregroundColor(.red)
            }
        }
    }
    
    private var stakesSection: some View {
        Section(header: Text("Stakes")) {
            ForEach(allStakes, id: \.self) { stakes in
                MultiSelectRow(
                    title: stakes.description,
                    isSelected: selectedStakes.contains(stakes)
                ) {
                    toggleSelection(stakes: stakes)
                }
            }
            
            if !selectedStakes.isEmpty {
                Button("Clear All Stakes") {
                    selectedStakes.removeAll()
                }
                .foregroundColor(.red)
            }
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Locations")) {
            ForEach(allLocations, id: \.self) { location in
                MultiSelectRow(
                    title: location,
                    isSelected: selectedLocations.contains(location)
                ) {
                    toggleSelection(location: location)
                }
            }
            
            if !selectedLocations.isEmpty {
                Button("Clear All Locations") {
                    selectedLocations.removeAll()
                }
                .foregroundColor(.red)
            }
        }
    }
    
    private var actionButtons: some View {
        Section {
            Button("Reset All Filters") {
                resetFilters()
            }
            .foregroundColor(.red)
        }
    }
    
    private func loadCurrentFilters() {
        let filters = dataManager.appliedFilters
        
        selectedGameTypes = filters.selectedGameTypes
        selectedStakes = filters.selectedStakes
        selectedLocations = filters.selectedLocations
        
        if let dateRange = filters.dateRange {
            startDate = dateRange.lowerBound
            endDate = dateRange.upperBound
            useCustomDateRange = true
            selectedQuickRange = .custom
        }
    }
    
    private func toggleSelection(gameType: GameType) {
        if selectedGameTypes.contains(gameType) {
            selectedGameTypes.remove(gameType)
        } else {
            selectedGameTypes.insert(gameType)
        }
    }
    
    private func toggleSelection(stakes: Stakes) {
        if selectedStakes.contains(stakes) {
            selectedStakes.remove(stakes)
        } else {
            selectedStakes.insert(stakes)
        }
    }
    
    private func toggleSelection(location: String) {
        if selectedLocations.contains(location) {
            selectedLocations.remove(location)
        } else {
            selectedLocations.insert(location)
        }
    }
    
    private func updateDatesForQuickRange(_ range: QuickDateRange) {
        let calendar = Calendar.current
        let now = Date()
        
        switch range {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            endDate = now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            endDate = now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            endDate = now
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            endDate = now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            endDate = now
        case .all:
            break
        case .custom:
            break
        }
    }
    
    private func applyFilters() {
        var filters = FilterSettings()
        
        if selectedQuickRange != .all {
            filters.dateRange = startDate...endDate
        }
        
        filters.selectedGameTypes = selectedGameTypes
        filters.selectedStakes = selectedStakes
        filters.selectedLocations = selectedLocations
        
        dataManager.applyFilters(filters)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func resetFilters() {
        selectedQuickRange = .all
        useCustomDateRange = false
        selectedGameTypes.removeAll()
        selectedStakes.removeAll()
        selectedLocations.removeAll()
        
        let calendar = Calendar.current
        startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        endDate = Date()
    }
}

struct MultiSelectRow: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(isSelected ? .medium : .regular)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

enum QuickDateRange: String, CaseIterable {
    case week = "Last Week"
    case month = "Last Month"
    case threeMonths = "Last 3 Months"
    case sixMonths = "Last 6 Months"
    case year = "Last Year"
    case all = "All Time"
    case custom = "Custom Range"
}

#Preview {
    FilterView(dataManager: AnalyticsDataManager.shared)
}