import SwiftUI

@main
struct NorskKortApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 480)
        }
        .windowToolbarStyle(.unified)
    }
}
