import Foundation

/// Состояние, которое меняют кнопки виджета. Интенты выполняются в процессе
/// расширения, поэтому хватает UserDefaults самого расширения.
enum WidgetState {
    private static let defaults = UserDefaults.standard
    private static let offsetKey = "cardOffset"
    private static let revealedKey = "revealedCardID"

    /// Сколько раз нажали «Дальше» — сдвиг относительно расписания по времени.
    static var offset: Int {
        defaults.integer(forKey: offsetKey)
    }

    static var revealedCardID: String? {
        defaults.string(forKey: revealedKey)
    }

    static func advance() {
        defaults.set(offset &+ 1, forKey: offsetKey)
        defaults.removeObject(forKey: revealedKey)
    }

    static func toggleReveal(cardID: String) {
        if revealedCardID == cardID {
            defaults.removeObject(forKey: revealedKey)
        } else {
            defaults.set(cardID, forKey: revealedKey)
        }
    }
}
