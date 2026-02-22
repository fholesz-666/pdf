import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: PDFEditorViewModel

    var body: some View {
        NavigationSplitView {
            List(viewModel.pdfFiles, id: \.handle) { file in
                Button {
                    Task {
                        await viewModel.open(file: file)
                    }
                } label: {
                    HStack {
                        Image(systemName: "doc.richtext")
                        Text(file.name)
                    }
                }
            }
            .navigationTitle("MEGA PDF")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Přihlásit") {
                        Task { await viewModel.login() }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Obnovit") {
                        Task { await viewModel.reloadFiles() }
                    }
                    .disabled(!viewModel.isAuthenticated)
                }
            }
        } detail: {
            VStack {
                if let pdfURL = viewModel.localPDFURL {
                    PDFKitRepresentedView(pdfURL: pdfURL)

                    HStack {
                        Button("Přidat poznámku") {
                            viewModel.addTextNoteToCurrentPage()
                        }

                        Button("Zvýraznit text") {
                            viewModel.addDemoHighlightToCurrentPage()
                        }

                        Button("Uložit do MEGA") {
                            Task { await viewModel.saveBackToMega() }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 8)
                } else {
                    ContentUnavailableView(
                        "Vyber PDF",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Přihlas se do MEGA a vyber PDF soubor k úpravě.")
                    )
                }

                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                }
            }
            .padding()
            .navigationTitle(viewModel.openedFileName ?? "Editor")
        }
    }
}
