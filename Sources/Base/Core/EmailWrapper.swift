import Foundation

@propertyWrapper
public struct Email {
    private var value: String
    private let message: String

    public var wrappedValue: String {
        get { value }
        set { value = newValue }
    }

    public var projectedValue: String? {
        if value.isEmpty {
            return message
        }

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate { (object, _) in
            guard let email = object as? String else { return false }
            return email.range(of: emailRegex, options: .regularExpression) != nil
        }
        return emailPredicate.evaluate(with: value) ? nil : message
    }

    public init(wrappedValue: String, _ message: String) {
        value = wrappedValue
        self.message = message
    }

    public static func isValid(_ email: String) -> Bool {
        guard !email.isEmpty else { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate { (object, _) in
            guard let email = object as? String else { return false }
            return email.range(of: emailRegex, options: .regularExpression) != nil
        }
        return emailPredicate.evaluate(with: email)
    }
}
