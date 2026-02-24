import SwiftUI

// MARK: - Colors
extension Color {
    // Pastels for Categories
    static let pastelYellow = Color(hue: 0.15, saturation: 0.2, brightness: 1.0)
    static let pastelGreen = Color(hue: 0.35, saturation: 0.2, brightness: 1.0)
    static let pastelRed = Color(hue: 0.0, saturation: 0.2, brightness: 1.0)
    static let pastelBlue = Color(hue: 0.6, saturation: 0.2, brightness: 1.0)
    static let pastelOrange = Color(hue: 0.08, saturation: 0.2, brightness: 1.0)
    static let pastelCyan = Color(hue: 0.5, saturation: 0.2, brightness: 1.0)
    static let pastelPurple = Color(hue: 0.8, saturation: 0.2, brightness: 1.0)
    static let pastelGray = Color(hue: 0.0, saturation: 0.0, brightness: 0.9)
    
    // UI Colors
    static let offWhite = Color(white: 0.98)
    static let darkText = Color(white: 0.1)
    
    // Helper for String -> Color
    init?(_ name: String) {
        switch name {
        case "PastelYellow": self = .pastelYellow
        case "PastelGreen": self = .pastelGreen
        case "PastelRed": self = .pastelRed
        case "PastelBlue": self = .pastelBlue
        case "PastelOrange": self = .pastelOrange
        case "PastelCyan": self = .pastelCyan
        case "PastelPurple": self = .pastelPurple
        case "PastelGray": self = .pastelGray
        default: return nil
        }
    }
}

// MARK: - View Modifiers

struct NotionCardStyle: ViewModifier {
    var backgroundColor: Color = .white
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
    }
}

extension View {
    func notionCard(backgroundColor: Color = .white) -> some View {
        self.modifier(NotionCardStyle(backgroundColor: backgroundColor))
    }
}
