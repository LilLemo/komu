import SwiftUI
import SwiftData

struct SummaryView: View {
    let session: ShoppingSession
    var onFinish: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Resumo da Partida")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Total Card
                VStack {
                    Text("TOTAL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text(String(format: "R$ %.2f", session.totalCost))
                        .font(.system(size: 48, weight: .heavy))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
                
                // Stats Grid
                HStack(spacing: 16) {
                    StatCard(title: "Tempo", value: formatDuration(session.duration))
                    StatCard(title: "Itens", value: "\(session.items.count)")
                }
                
                // Split (Real logic)
                VStack(alignment: .leading, spacing: 12) {
                    Text("DIVISÃO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    let costsByAuthor = Dictionary(grouping: session.items, by: { $0.authorName })
                        .mapValues { items in
                            items.reduce(0.0) { $0 + ($1.actualPrice ?? 0) * Double($1.quantity) }
                        }
                    
                    ForEach(costsByAuthor.keys.sorted(), id: \.self) { author in
                        HStack {
                            Text(author)
                            Spacer()
                            Text(String(format: "R$ %.2f", costsByAuthor[author] ?? 0))
                                .fontWeight(.bold)
                        }
                        if author != costsByAuthor.keys.sorted().last {
                            Divider()
                        }
                    }
                }
                .notionCard()
                
                // Items List (Receipt Check)
                VStack(alignment: .leading, spacing: 12) {
                    Text("CONFERÊNCIA")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    ForEach(session.items) { item in
                        HStack {
                            Text("\(item.quantity)x \(item.name)")
                                .font(.body)
                            Spacer()
                            let totalItemPrice = (item.actualPrice ?? 0) * Double(item.quantity)
                            Text(String(format: "R$ %.2f", totalItemPrice))
                                .font(.body)
                                .monospacedDigit()
                        }
                        if item != session.items.last {
                            Divider()
                        }
                    }
                }
                .notionCard()
                
                Spacer()
            }
            .padding()
        }
        .background(Color.offWhite)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let onFinish = onFinish {
                        onFinish()
                    } else {
                        dismiss()
                    }
                }) {
                    Text("Concluir")
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
