 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/Sources/Services/MegaAuthService.swift b/Sources/Services/MegaAuthService.swift
new file mode 100644
index 0000000000000000000000000000000000000000..087867c92ca0e56bc206ebaa8788574c3369369d
--- /dev/null
+++ b/Sources/Services/MegaAuthService.swift
@@ -0,0 +1,54 @@
+import Foundation
+import MEGASdk
+
+final class MegaAuthService: NSObject {
+    private let sdk = MEGASdk.sharedSdk()
+
+    func login(email: String, password: String) async throws {
+        try await withCheckedThrowingContinuation { continuation in
+            let delegate = MegaRequestDelegateProxy { result in
+                switch result {
+                case .success:
+                    continuation.resume()
+                case .failure(let error):
+                    continuation.resume(throwing: error)
+                }
+            }
+
+            sdk.login(withEmail: email, password: password, delegate: delegate)
+        }
+    }
+
+    func isLoggedIn() -> Bool {
+        sdk.myUser != nil
+    }
+
+    func logout() {
+        sdk.logout()
+    }
+
+    func sharedSDK() -> MEGASdk {
+        sdk
+    }
+}
+
+final class MegaRequestDelegateProxy: NSObject, MEGARequestDelegate {
+    enum DelegateError: Error {
+        case unknown
+        case sdkError(code: Int)
+    }
+
+    private let completion: (Result<Void, Error>) -> Void
+
+    init(completion: @escaping (Result<Void, Error>) -> Void) {
+        self.completion = completion
+    }
+
+    func onRequestFinish(_ api: MEGASdk, request: MEGARequest, error: MEGAError) {
+        if error.type == .apiOk {
+            completion(.success(()))
+        } else {
+            completion(.failure(DelegateError.sdkError(code: Int(error.type.rawValue))))
+        }
+    }
+}
 
EOF
)
