import SwiftUI

extension CardCategory {
    var tint: Color {
        switch self {
        case .word: .blue
        case .phrasalVerb: .orange
        case .idiom: .purple
        case .phrase: .green
        case .expression: .teal
        case .proverb: .brown
        }
    }
}

/// Небольшой цветной ярлык категории.
struct CategoryBadge: View {
    let category: CardCategory
    var showsNorwegian = false

    var body: some View {
        Label(showsNorwegian ? category.norwegianTitle : category.title, systemImage: category.symbol)
            .font(.caption2.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(category.tint)
            .lineLimit(1)
    }
}

extension URL {
    /// Ссылка из виджета в приложение: norskkort://card/<id>
    static func card(_ id: String) -> URL {
        URL(string: "norskkort://card/\(id)")!
    }

    var cardID: String? {
        guard scheme == "norskkort", host == "card" else { return nil }
        let id = pathComponents.dropFirst().first
        return id
    }
}
