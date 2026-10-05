import AppIntents
import SwiftUI
import WidgetKit

struct CardEntry: TimelineEntry {
    let date: Date
    let card: Card
    let isRevealed: Bool
    let quizMode: Bool
    let position: Int
    let total: Int

    static let placeholder = CardEntry(
        date: .now,
        card: CardDeck.sample,
        isRevealed: true,
        quizMode: false,
        position: 1,
        total: 1
    )
}

struct CardProvider: AppIntentTimelineProvider {
    /// Seed перемешивания: порядок карточек одинаковый при каждой перезагрузке виджета.
    private static let shuffleSeed: UInt64 = 0x4E_6F_72_73_6B

    func placeholder(in context: Context) -> CardEntry {
        .placeholder
    }

    func snapshot(for configuration: CardWidgetConfiguration, in context: Context) async -> CardEntry {
        if context.isPreview { return .placeholder }
        return entries(for: configuration, count: 1).first ?? .placeholder
    }

    func timeline(for configuration: CardWidgetConfiguration, in context: Context) async -> Timeline<CardEntry> {
        Timeline(entries: entries(for: configuration, count: 24), policy: .atEnd)
    }

    /// Карточка зависит от номера временного слота плюс число нажатий «Дальше».
    private func entries(for configuration: CardWidgetConfiguration, count: Int) -> [CardEntry] {
        let deck = CardDeck.shuffled(CardDeck.cards(in: configuration.category.category), seed: Self.shuffleSeed)
        guard !deck.isEmpty else { return [.placeholder] }

        let now = Date.now
        let interval = configuration.interval.seconds
        let currentSlot = Int(now.timeIntervalSince1970) / interval
        let offset = WidgetState.offset % deck.count
        let revealedID = WidgetState.revealedCardID

        return (0..<count).map { step in
            let slot = currentSlot + step
            var index = (slot % deck.count + offset) % deck.count
            if index < 0 { index += deck.count }
            let card = deck[index]
            return CardEntry(
                date: step == 0 ? now : Date(timeIntervalSince1970: TimeInterval(slot * interval)),
                card: card,
                isRevealed: !configuration.quizMode || card.id == revealedID,
                quizMode: configuration.quizMode,
                position: index + 1,
                total: deck.count
            )
        }
    }
}

struct CardWidget: Widget {
    let kind = "NorskCardWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: CardWidgetConfiguration.self, provider: CardProvider()) { entry in
            CardWidgetView(entry: entry)
        }
        .configurationDisplayName("Норвежские карточки")
        .description("Слово, фраза или идиома: норвежский, перевод и пример.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Views

struct CardWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CardEntry

    private var card: Card { entry.card }

    var body: some View {
        content
            .containerBackground(for: .widget) {
                ZStack {
                    Rectangle().fill(.background)
                    LinearGradient(
                        colors: [card.category.tint.opacity(0.20), card.category.tint.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .widgetURL(.card(card.id))
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall: small
        case .systemLarge: large
        default: medium
        }
    }

    // MARK: Small

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: card.category.symbol)
                .font(.caption)
                .foregroundStyle(card.category.tint)

            Text(card.norwegian)
                .font(.headline)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            translation(font: .caption, lineLimit: 3)

            Spacer(minLength: 0)

            buttons(iconOnly: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Medium

    private var medium: some View {
        VStack(alignment: .leading, spacing: 6) {
            header

            Text(card.norwegian)
                .font(.title3.bold())
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            translation(font: .subheadline, lineLimit: 2)

            Spacer(minLength: 0)

            Text(card.example)
                .font(.caption)
                .italic()
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Large

    private var large: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            Text(card.norwegian)
                .font(.title2.bold())
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            translation(font: .title3, lineLimit: 3)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Пример")
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
                Text(card.example)
                    .font(.body)
                    .italic()
                    .lineLimit(4)
                if entry.isRevealed {
                    Text(card.exampleTranslation)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                }
            }

            Spacer(minLength: 0)

            if let note = card.note, entry.isRevealed {
                Label(note, systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack {
                Text(card.category.norwegianTitle)
                Spacer()
                Text("\(entry.position) / \(entry.total)")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Parts

    private var header: some View {
        HStack(alignment: .center) {
            CategoryBadge(category: card.category)
            Spacer(minLength: 4)
            buttons(iconOnly: family != .systemLarge)
        }
    }

    @ViewBuilder
    private func translation(font: Font, lineLimit: Int) -> some View {
        if entry.isRevealed {
            Text(card.russian)
                .font(font)
                .foregroundStyle(.secondary)
                .lineLimit(lineLimit)
                .minimumScaleFactor(0.8)
        } else {
            Text("Вспомните перевод…")
                .font(font)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
    }

    private func buttons(iconOnly: Bool) -> some View {
        HStack(spacing: 6) {
            if entry.quizMode {
                Button(intent: RevealTranslationIntent(cardID: card.id)) {
                    buttonLabel(
                        entry.isRevealed ? "Скрыть" : "Перевод",
                        systemImage: entry.isRevealed ? "eye.slash" : "eye",
                        iconOnly: iconOnly
                    )
                }
            }
            Button(intent: NextCardIntent()) {
                buttonLabel("Дальше", systemImage: "arrow.right", iconOnly: iconOnly)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .tint(card.category.tint)
    }

    @ViewBuilder
    private func buttonLabel(_ title: String, systemImage: String, iconOnly: Bool) -> some View {
        if iconOnly {
            Label(title, systemImage: systemImage).labelStyle(.iconOnly)
        } else {
            Label(title, systemImage: systemImage)
        }
    }
}

@main
struct NorskKortWidgetBundle: WidgetBundle {
    var body: some Widget {
        CardWidget()
    }
}

#Preview(as: .systemMedium) {
    CardWidget()
} timeline: {
    CardEntry.placeholder
    CardEntry(date: .now, card: CardDeck.sample, isRevealed: false, quizMode: true, position: 1, total: 1)
}
