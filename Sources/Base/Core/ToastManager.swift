import Foundation
import Observation

public enum ToastType: Equatable, Sendable {
    case error
    case success
}

public struct ToastMessage: Equatable, Sendable {
    public let message: String
    public let type: ToastType

    public init(message: String, type: ToastType) {
        self.message = message
        self.type = type
    }
}

@Observable
@MainActor
public final class ToastManager: Sendable {

    private(set) public var currentToast: ToastMessage?
    private var dismissTask: Task<Void, Never>?

    public init() {}
}

public extension ToastManager {
    func show(message: String, type: ToastType, duration: TimeInterval = 3.0) {
        dismissTask?.cancel()

        currentToast = ToastMessage(message: message, type: type)

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            if !Task.isCancelled {
                currentToast = nil
            }
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        currentToast = nil
    }

    var isPresented: Bool {
        currentToast != nil
    }
}
