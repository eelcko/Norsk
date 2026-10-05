import SwiftUI

enum SidebarItem: Hashable {
    case practice
    case all
    case category(CardCategory)
}

struct ContentView: View {
    @State private var selection: SidebarItem? = .all
    @State private var search = ""
    @State private var openedCard: Card?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    Label("Тренировка", systemImage: "rectangle.on.rectangle.angled")
                        .tag(SidebarItem.practice)
                }
                Section("Карточки") {
                    Label("Все", systemImage: "square.stack")
                        .badge(CardDeck.all.count)
                        .tag(SidebarItem.all)
                    ForEach(CardCategory.allCases) { category in
                        Label(category.title, systemImage: category.symbol)
                            .badge(CardDeck.cards(in: category).count)
                            .tag(SidebarItem.category(category))
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            switch selection ?? .all {
            case .practice:
                PracticeView()
            case .all:
                CardListView(title: "Все карточки", cards: CardDeck.all, search: $search)
            case .category(let category):
                CardListView(title: category.title, cards: CardDeck.cards(in: category), search: $search)
            }
        }
        .onOpenURL { url in
            if let id = url.cardID {
                openedCard = CardDeck.card(withID: id)
            }
        }
        .sheet(item: $openedCard) { card in
            VStack(alignment: .trailing, spacing: 12) {
                CardView(card: card)
                Button("Готово") { openedCard = nil }
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
            .frame(width: 480)
        }
    }
}

struct CardListView: View {
    let title: String
    let cards: [Card]
    @Binding var search: String

    private var filtered: [Card] {
        let query = search.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return cards }
        return cards.filter {
            $0.norwegian.localizedCaseInsensitiveContains(query)
                || $0.russian.localizedCaseInsensitiveContains(query)
                || $0.example.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                ForEach(filtered) { card in
                    CardView(card: card)
                }
            }
            .padding()
        }
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView.search(text: search)
            }
        }
        .navigationTitle(title)
        .searchable(text: $search, prompt: "Поиск по-норвежски или по-русски")
    }
}

/// Полная карточка: норвежский → перевод → пример → заметка.
struct CardView: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CategoryBadge(category: card.category)

            HStack(alignment: .firstTextBaseline) {
                Text(card.norwegian)
                    .font(.title3.bold())
                    .textSelection(.enabled)
                Spacer(minLength: 8)
                SpeakButton(text: card.norwegian)
            }

            Text(card.russian)
                .foregroundStyle(.secondary)

            Divider()

            HStack(alignment: .firstTextBaseline) {
                Text(card.example)
                    .italic()
                    .textSelection(.enabled)
                Spacer(minLength: 8)
                SpeakButton(text: card.example)
            }
            Text(card.exampleTranslation)
                .font(.callout)
                .foregroundStyle(.secondary)

            if let note = card.note {
                Label(note, systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card.category.tint.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(card.category.tint.opacity(0.25)))
    }
}

struct SpeakButton: View {
    let text: String

    var body: some View {
        Button {
            Speaker.shared.speak(text)
        } label: {
            Image(systemName: "speaker.wave.2")
        }
        .buttonStyle(.borderless)
        .help("Прослушать")
    }
}

#Preview {
    ContentView()
}
