import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(NavigationManager.self) private var navManager
    @Query(sort: \ShoppingSession.startTime, order: .reverse) private var allSessions: [ShoppingSession]
    
    var sessions: [ShoppingSession] {
        guard let selectedList = navManager.selectedList else { return [] }
        return allSessions.filter { $0.list == selectedList }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sessions) { session in
                    NavigationLink(destination: SummaryView(session: session)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                                .font(.headline)
                            HStack {
                                Text("\(session.items.count) itens")
                                Spacer()
                                Text(String(format: "R$ %.2f", session.totalCost))
                                    .fontWeight(.bold)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Histórico")
            .overlay {
                if sessions.isEmpty {
                    ContentUnavailableView("Nenhuma compra ainda", systemImage: "clock.arrow.circlepath", description: Text("Suas compras finalizadas aparecerão aqui."))
                }
            }
        }
    }
}
