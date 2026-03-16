import Foundation
import Core
import Models

actor RefreshManager {

    private var refreshTask: Task<String, Error>?

    func refresh(_ token: String) async throws -> String {

        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }

        let task = Task { () throws -> String in
            defer { refreshTask = nil }
            return "token"
        }
        self.refreshTask = task
        return try await task.value
    }
}
