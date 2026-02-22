 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/Sources/MegaPDFEditorApp.swift b/Sources/MegaPDFEditorApp.swift
new file mode 100644
index 0000000000000000000000000000000000000000..d229da1ae05508c02eac2cf4128daca34d40ac8a
--- /dev/null
+++ b/Sources/MegaPDFEditorApp.swift
@@ -0,0 +1,10 @@
+import SwiftUI
+
+@main
+struct MegaPDFEditorApp: App {
+    var body: some Scene {
+        WindowGroup {
+            ContentView(viewModel: PDFEditorViewModel())
+        }
+    }
+}
 
EOF
)
