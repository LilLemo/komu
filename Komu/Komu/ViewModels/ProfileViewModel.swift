import Foundation
import SwiftData
import SwiftUI

@Observable
class ProfileViewModel {
    var modelContext: ModelContext?
    
    // Stats
    var mostExpensiveItem: GroceryItem?
    var longestSession: ShoppingSession?
    var currentMonthSpending: Double = 0.0
    var monthlySpendingHistory: [(month: Date, total: Double)] = []
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func calculateStats(sessions: [ShoppingSession], items: [GroceryItem]) {
        // 1. Most Expensive Item
        // Filter only bought items
        let boughtItems = items.filter { $0.status == .bought }
        self.mostExpensiveItem = boughtItems.max(by: { ($0.actualPrice ?? 0) < ($1.actualPrice ?? 0) })
        
        // 2. Longest Session
        self.longestSession = sessions.max(by: { $0.duration < $1.duration })
        
        // 3. Monthly Spending
        calculateMonthlySpending(sessions: sessions)
    }
    
    private func calculateMonthlySpending(sessions: [ShoppingSession]) {
        var spendingByMonth: [Date: Double] = [:]
        let calendar = Calendar.current
        
        for session in sessions {
            // Normalize to start of month
            let components = calendar.dateComponents([.year, .month], from: session.startTime)
            if let monthDate = calendar.date(from: components) {
                spendingByMonth[monthDate, default: 0] += session.totalCost
            }
        }
        
        // Convert to sorted array
        let sortedMonths = spendingByMonth.keys.sorted(by: >) // Newest first
        self.monthlySpendingHistory = sortedMonths.map { date in
            (month: date, total: spendingByMonth[date]!)
        }
        
        // Current Month
        let currentComponents = calendar.dateComponents([.year, .month], from: Date())
        if let currentMonth = calendar.date(from: currentComponents) {
            self.currentMonthSpending = spendingByMonth[currentMonth] ?? 0.0
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
    
    func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
}
