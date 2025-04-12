import Foundation

struct ClassTime {
    static let periods: [(start: (hour: Int, minute: Int), end: (hour: Int, minute: Int))] = [
        ((9, 0), (10, 30)),   // 1限
        ((10, 40), (12, 10)), // 2限
        ((13, 0), (14, 30)),  // 3限
        ((14, 40), (16, 10)), // 4限
        ((16, 20), (17, 50)), // 5限
        ((18, 0), (19, 30))   // 6限
    ]
    
    static func getTimeString(for period: Int) -> String {
        guard period > 0 && period <= periods.count else { return "" }
        let time = periods[period - 1]
        return "\(time.start.hour):\(String(format: "%02d", time.start.minute))-\(time.end.hour):\(String(format: "%02d", time.end.minute))"
    }
    
    static func getStartTime(for period: Int) -> Date {
        guard period > 0 && period <= periods.count else { return Date() }
        let time = periods[period - 1]
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = time.start.hour
        components.minute = time.start.minute
        return calendar.date(from: components) ?? Date()
    }
    
    static func getEndTime(for period: Int) -> Date {
        guard period > 0 && period <= periods.count else { return Date() }
        let time = periods[period - 1]
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = time.end.hour
        components.minute = time.end.minute
        return calendar.date(from: components) ?? Date()
    }
} 