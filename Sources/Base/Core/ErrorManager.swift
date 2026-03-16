import Foundation
import Observation

@Observable
@MainActor
public final class ErrorManager: Sendable {

    private(set) public var currentError: String?
    private var dismissTask: Task<Void, Never>?

    public init() {}

    public func show(_ error: Error, duration: TimeInterval = 3.0) {
        show(message: error.localizedDescription, duration: duration)
    }

    public func show(message: String, duration: TimeInterval = 3.0) {
        dismissTask?.cancel()

        currentError = message

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            if !Task.isCancelled {
                currentError = nil
            }
        }
    }

    public func dismiss() {
        dismissTask?.cancel()
        currentError = nil
    }

    public var isPresented: Bool {
        currentError != nil
    }
}
