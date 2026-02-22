import Foundation
import MEGASdk

final class MegaPDFService: NSObject {
    private let sdk: MEGASdk

    init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    func listPDFFiles() async -> [MegaFile] {
        guard let root = sdk.rootNode,
              let children = sdk.children(forParent: root) else {
            return []
        }

        return (0..<children.size).compactMap { index in
            guard let node = children.node(at: index) else { return nil }
            let name = node.name ?? "soubor"
            let isPDF = name.lowercased().hasSuffix(".pdf")
            return MegaFile(handle: node.handle, name: name, isPDF: isPDF)
        }
        .filter { $0.isPDF }
    }

    func downloadPDF(_ file: MegaFile) async throws -> URL {
        guard let node = sdk.node(forHandle: file.handle) else {
            throw NSError(domain: "MegaPDFService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Soubor nebyl nalezen"]) 
        }

        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(file.name)

        try? FileManager.default.removeItem(at: destination)

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = MegaTransferDelegateProxy { result in
                switch result {
                case .success:
                    continuation.resume(returning: destination)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            sdk.startDownloadNode(node, localPath: destination.path, appData: nil, startFirst: false, cancelToken: nil, collisionCheck: .collisionCheckFingerprint, collisionResolution: .collisionResolutionNewWithN, delegate: delegate)
        }
    }

    func uploadPDF(localURL: URL, to originalFile: MegaFile) async throws {
        guard let parent = sdk.rootNode else {
            throw NSError(domain: "MegaPDFService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Chybí root node"]) 
        }

        let fileName = originalFile.name

        _ = try await withCheckedThrowingContinuation { continuation in
            let delegate = MegaRequestDelegateProxy { result in
                switch result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            sdk.startUpload(withLocalPath: localURL.path, parent: parent, fileName: fileName, appData: nil, isSourceTemporary: false, delegate: delegate)
        }
    }
}

final class MegaTransferDelegateProxy: NSObject, MEGATransferDelegate {
    enum TransferError: Error {
        case sdkError(code: Int)
    }

    private let completion: (Result<Void, Error>) -> Void

    init(completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion
    }

    func onTransferFinish(_ api: MEGASdk, transfer: MEGATransfer, error: MEGAError) {
        if error.type == .apiOk {
            completion(.success(()))
        } else {
            completion(.failure(TransferError.sdkError(code: Int(error.type.rawValue))))
        }
    }
}
