import Foundation

public enum DateFormat: String {
    case fullFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
}

extension Date {

    public func toString(with format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }

    public func toUTCString(with format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }

    public func fromUTCString(with format: DateFormat) -> String {
        let dateStr = self.toString(with: DateFormat.fullFormat)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.fullFormat.rawValue
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "ru_RU")
        guard let date = formatter.date(from: dateStr) else { return "" }
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter.string(from: date)
    }

    public func toDate(with format: DateFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone.autoupdatingCurrent
        let stringDate = self.toString(with: format)
        return formatter.date(from: stringDate)
    }

    public static func createDateWithTime(_ time: String?) -> Date? {
        guard let time = time else { return nil }
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let dateP = formatter.date(from: time) else { return nil }
        return Date(timeIntervalSince1970: Double(dateP.timeIntervalSince1970))
    }

    public func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
}

extension String {

    public func toDate(with format: DateFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter.date(from: self)
    }
}
