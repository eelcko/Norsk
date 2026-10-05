import Foundation

/// Тип карточки. `rawValue` совпадает с полем `category` в cards.json.
enum CardCategory: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case word
    case phrasalVerb
    case idiom
    case phrase
    case expression
    case proverb

    var id: String { rawValue }

    var title: String {
        switch self {
        case .word: "Слова"
        case .phrasalVerb: "Фразовые глаголы"
        case .idiom: "Идиомы"
        case .phrase: "Фразы"
        case .expression: "Выражения"
        case .proverb: "Пословицы"
        }
    }

    var norwegianTitle: String {
        switch self {
        case .word: "Ord"
        case .phrasalVerb: "Partikkelverb"
        case .idiom: "Idiomer"
        case .phrase: "Fraser"
        case .expression: "Uttrykk"
        case .proverb: "Ordtak"
        }
    }

    var symbol: String {
        switch self {
        case .word: "textformat.abc"
        case .phrasalVerb: "arrow.triangle.branch"
        case .idiom: "theatermasks"
        case .phrase: "bubble.left.and.bubble.right"
        case .expression: "quote.bubble"
        case .proverb: "book.closed"
        }
    }
}

/// Одна карточка: норвежский → русский → пример.
struct Card: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let category: CardCategory
    let norwegian: String
    let russian: String
    let example: String
    let exampleTranslation: String
    /// Формы глагола, род, буквальный перевод идиомы и т. п.
    let note: String?
}

enum CardDeck {
    /// Все карточки из cards.json (файл копируется и в приложение, и в виджет).
    static let all: [Card] = load()

    static let sample = Card(
        id: "sample",
        category: .idiom,
        norwegian: "Det er ingen ku på isen.",
        russian: "Всё в порядке, волноваться не о чем.",
        example: "Slapp av, det er ingen ku på isen – vi rekker toget.",
        exampleTranslation: "Расслабься, всё в порядке – мы успеваем на поезд.",
        note: "Букв.: «На льду нет коровы»."
    )

    static func cards(in category: CardCategory?) -> [Card] {
        guard let category else { return all }
        return all.filter { $0.category == category }
    }

    static func card(withID id: String) -> Card? {
        all.first { $0.id == id }
    }

    /// Перемешивает карточки всегда одинаково для одного и того же `seed`,
    /// чтобы виджет показывал стабильную последовательность между перезагрузками.
    static func shuffled(_ cards: [Card], seed: UInt64) -> [Card] {
        var generator = SeededGenerator(seed: seed)
        return cards.shuffled(using: &generator)
    }

    private static func load() -> [Card] {
        guard
            let url = Bundle.main.url(forResource: "cards", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            assertionFailure("cards.json не найден в бандле")
            return []
        }
        do {
            return try JSONDecoder().decode([Card].self, from: data)
        } catch {
            assertionFailure("Не удалось прочитать cards.json: \(error)")
            return []
        }
    }
}

/// SplitMix64 — простой детерминированный генератор случайных чисел.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
