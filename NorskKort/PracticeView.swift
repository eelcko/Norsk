import SwiftUI

/// Режим карточек: видна норвежская сторона, перевод открывается по нажатию.
struct PracticeView: View {
    @State private var category: CardCategory?
    @State private var deck: [Card] = CardDeck.all.shuffled()
    @State private var index = 0
    @State private var isRevealed = false

    private var card: Card? {
        deck.isEmpty ? nil : deck[index]
    }

    var body: some View {
        VStack(spacing: 24) {
            Picker("Категория", selection: $category) {
                Text("Все карточки").tag(CardCategory?.none)
                ForEach(CardCategory.allCases) { category in
                    Text(category.title).tag(CardCategory?.some(category))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 260)

            Spacer(minLength: 0)

            if let card {
                face(of: card)
            }

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                Button(isRevealed ? "Скрыть перевод" : "Показать перевод") {
                    withAnimation { isRevealed.toggle() }
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Дальше") { next() }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)

            Text("Пробел — перевод, → — следующая карточка")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if !deck.isEmpty {
                Text("\(index + 1) / \(deck.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(32)
        .navigationTitle("Тренировка")
        .onChange(of: category) { _, newValue in
            deck = CardDeck.cards(in: newValue).shuffled()
            index = 0
            isRevealed = false
        }
    }

    private func face(of card: Card) -> some View {
        VStack(spacing: 16) {
            CategoryBadge(category: card.category)

            HStack {
                Text(card.norwegian)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                SpeakButton(text: card.norwegian)
            }

            if isRevealed {
                VStack(spacing: 12) {
                    Text(card.russian)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Divider().frame(maxWidth: 320)
                    Text(card.example)
                        .italic()
                        .multilineTextAlignment(.center)
                    Text(card.exampleTranslation)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    if let note = card.note {
                        Label(note, systemImage: "lightbulb")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .transition(.opacity)
            } else {
                Text(card.example)
                    .italic()
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: 560)
        .background(card.category.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }

    private func next() {
        guard !deck.isEmpty else { return }
        isRevealed = false
        if index + 1 < deck.count {
            index += 1
        } else {
            deck.shuffle()
            index = 0
        }
    }
}
