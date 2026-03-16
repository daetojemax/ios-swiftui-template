import Foundation

@propertyWrapper
public struct Required {
    private var value: String
    private let message: String

    public var wrappedValue: String {
        get { value }
        set { value = newValue }
    }

    public var projectedValue: String? {
        value.isEmpty ? message : nil
    }

    public init(wrappedValue: String, _ message: String) {
        value = wrappedValue
        self.message = message
    }
}
