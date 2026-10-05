import AppIntents
import WidgetKit

enum CategoryOption: String, AppEnum {
    case all
    case word
    case phrasalVerb
    case idiom
    case phrase
    case expression
    case proverb

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Категория"

    static var caseDisplayRepresentations: [CategoryOption: DisplayRepresentation] = [
        .all: "Все карточки",
        .word: "Слова",
        .phrasalVerb: "Фразовые глаголы",
        .idiom: "Идиомы",
        .phrase: "Фразы",
        .expression: "Выражения",
        .proverb: "Пословицы",
    ]

    var category: CardCategory? {
        CardCategory(rawValue: rawValue)
    }
}

enum IntervalOption: String, AppEnum {
    case fifteenMinutes
    case thirtyMinutes
    case hour
    case threeHours
    case day

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Интервал"

    static var caseDisplayRepresentations: [IntervalOption: DisplayRepresentation] = [
        .fifteenMinutes: "15 минут",
        .thirtyMinutes: "30 минут",
        .hour: "1 час",
        .threeHours: "3 часа",
        .day: "1 день",
    ]

    var seconds: Int {
        switch self {
        case .fifteenMinutes: 15 * 60
        case .thirtyMinutes: 30 * 60
        case .hour: 60 * 60
        case .threeHours: 3 * 60 * 60
        case .day: 24 * 60 * 60
        }
    }
}

/// Настройки, которые открываются по «Изменить виджет».
struct CardWidgetConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Норвежские карточки"
    static var description = IntentDescription("Норвежские слова, фразы и идиомы с переводом и примером.")

    @Parameter(title: "Категория", default: .all)
    var category: CategoryOption

    @Parameter(title: "Менять карточку каждые", default: .thirtyMinutes)
    var interval: IntervalOption

    @Parameter(title: "Режим тренировки", description: "Скрывать перевод, пока не нажмёте «Перевод»", default: false)
    var quizMode: Bool
}

/// Кнопка «Дальше» в виджете.
struct NextCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Следующая карточка"
    static var isDiscoverable = false

    func perform() async throws -> some IntentResult {
        WidgetState.advance()
        return .result()
    }
}

/// Кнопка «Перевод» в режиме тренировки.
struct RevealTranslationIntent: AppIntent {
    static var title: LocalizedStringResource = "Показать перевод"
    static var isDiscoverable = false

    @Parameter(title: "Карточка")
    var cardID: String

    init() {}

    init(cardID: String) {
        self.cardID = cardID
    }

    func perform() async throws -> some IntentResult {
        WidgetState.toggleReveal(cardID: cardID)
        return .result()
    }
}
