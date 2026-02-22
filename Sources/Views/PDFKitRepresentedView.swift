 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/Sources/Views/PDFKitRepresentedView.swift b/Sources/Views/PDFKitRepresentedView.swift
new file mode 100644
index 0000000000000000000000000000000000000000..99a75589acdeebfba0254c15e6a7bc6664be7108
--- /dev/null
+++ b/Sources/Views/PDFKitRepresentedView.swift
@@ -0,0 +1,19 @@
+import SwiftUI
+import PDFKit
+
+struct PDFKitRepresentedView: UIViewRepresentable {
+    let pdfURL: URL
+
+    func makeUIView(context: Context) -> PDFView {
+        let view = PDFView()
+        view.autoScales = true
+        view.displayMode = .singlePageContinuous
+        view.displayDirection = .vertical
+        view.document = PDFDocument(url: pdfURL)
+        return view
+    }
+
+    func updateUIView(_ uiView: PDFView, context: Context) {
+        uiView.document = PDFDocument(url: pdfURL)
+    }
+}
 
EOF
)
