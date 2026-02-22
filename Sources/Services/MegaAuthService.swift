import Foundation
import MEGASdk

final class MegaAuthService: NSObject {
    private let sdk = MEGASdk.sharedSdk()

    func login(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let delegate = MegaRequestDelegateProxy { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            sdk.login(withEmail: email, password: password, delegate: delegate)
        }
    }

    func isLoggedIn() -> Bool {
        sdk.myUser != nil
    }

    func logout() {
        sdk.logout()
    }

    func sharedSDK() -> MEGASdk {
        sdk
    }
}

final class MegaRequestDelegateProxy: NSObject, MEGARequestDelegate {
    enum DelegateError: Error {
        case unknown
        case sdkError(code: Int)
    }

    private let completion: (Result<Void, Error>) -> Void

    init(completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion
    }

    func onRequestFinish(_ api: MEGASdk, request: MEGARequest, error: MEGAError) {
        if error.type == .apiOk {
            completion(.success(()))
        } else {
            completion(.failure(DelegateError.sdkError(code: Int(error.type.rawValue))))
        }
    }
}
