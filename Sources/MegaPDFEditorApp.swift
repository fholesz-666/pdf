import SwiftUI

@main
struct MegaPDFEditorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PDFEditorViewModel())
        }
    }
}
