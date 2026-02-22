 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/Sources/ViewModels/PDFEditorViewModel.swift b/Sources/ViewModels/PDFEditorViewModel.swift
new file mode 100644
index 0000000000000000000000000000000000000000..86fb841e05b01b1f9c18e64ade722a3c91b6e8ba
--- /dev/null
+++ b/Sources/ViewModels/PDFEditorViewModel.swift
@@ -0,0 +1,94 @@
+import Foundation
+import PDFKit
+
+@MainActor
+final class PDFEditorViewModel: ObservableObject {
+    @Published var pdfFiles: [MegaFile] = []
+    @Published var localPDFURL: URL?
+    @Published var statusMessage = ""
+    @Published var openedFileName: String?
+    @Published var isAuthenticated = false
+
+    private let authService = MegaAuthService()
+    private lazy var pdfService = MegaPDFService(sdk: authService.sharedSDK())
+    private(set) var selectedFile: MegaFile?
+
+    private let demoEmail = "your-email@example.com"
+    private let demoPassword = "your-password"
+
+    func login() async {
+        do {
+            try await authService.login(email: demoEmail, password: demoPassword)
+            isAuthenticated = true
+            statusMessage = "Přihlášení do MEGA proběhlo úspěšně."
+            await reloadFiles()
+        } catch {
+            statusMessage = "Chyba přihlášení: \(error.localizedDescription)"
+        }
+    }
+
+    func reloadFiles() async {
+        let files = await pdfService.listPDFFiles()
+        pdfFiles = files
+        statusMessage = files.isEmpty ? "Nebyly nalezeny žádné PDF soubory." : "Načteno \(files.count) PDF souborů."
+    }
+
+    func open(file: MegaFile) async {
+        do {
+            let url = try await pdfService.downloadPDF(file)
+            selectedFile = file
+            localPDFURL = url
+            openedFileName = file.name
+            statusMessage = "Soubor stažen a otevřen pro editaci."
+        } catch {
+            statusMessage = "Soubor se nepodařilo stáhnout: \(error.localizedDescription)"
+        }
+    }
+
+    func addTextNoteToCurrentPage() {
+        guard let localPDFURL,
+              let document = PDFDocument(url: localPDFURL),
+              let page = document.page(at: 0) else {
+            statusMessage = "PDF není otevřené."
+            return
+        }
+
+        let note = PDFAnnotation(bounds: CGRect(x: 80, y: 80, width: 220, height: 80), forType: .text, withProperties: nil)
+        note.contents = "Poznámka upravená na iPadu"
+        note.color = .systemYellow
+        page.addAnnotation(note)
+
+        document.write(to: localPDFURL)
+        statusMessage = "Přidána textová poznámka."
+    }
+
+    func addDemoHighlightToCurrentPage() {
+        guard let localPDFURL,
+              let document = PDFDocument(url: localPDFURL),
+              let page = document.page(at: 0) else {
+            statusMessage = "PDF není otevřené."
+            return
+        }
+
+        let highlight = PDFAnnotation(bounds: CGRect(x: 100, y: 350, width: 220, height: 30), forType: .highlight, withProperties: nil)
+        highlight.color = .systemYellow.withAlphaComponent(0.35)
+        page.addAnnotation(highlight)
+
+        document.write(to: localPDFURL)
+        statusMessage = "Přidáno zvýraznění."
+    }
+
+    func saveBackToMega() async {
+        guard let selectedFile, let localPDFURL else {
+            statusMessage = "Není co ukládat."
+            return
+        }
+
+        do {
+            try await pdfService.uploadPDF(localURL: localPDFURL, to: selectedFile)
+            statusMessage = "Upravené PDF bylo nahráno zpět do MEGA."
+        } catch {
+            statusMessage = "Uložení do MEGA selhalo: \(error.localizedDescription)"
+        }
+    }
+}
 
EOF
)
