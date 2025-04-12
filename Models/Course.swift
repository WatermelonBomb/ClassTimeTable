import Foundation

struct Course: Identifiable, Codable {
    var id = UUID()
    var name: String
    var professor: String
    var classroom: String
    var dayOfWeek: Int // 1: 月曜日, 2: 火曜日, ...
    var period: Int // 1限目, 2限目, ...
    var color: String // カラーコード
    var hasReminder: Bool // リマインダー設定
    var reminderTime: Int // リマインダー時間（分）
    
    static let daysOfWeek = ["月", "火", "水", "木", "金", "土", "日"]
    
    var dayOfWeekString: String {
        return Course.daysOfWeek[dayOfWeek - 1]
    }
    
    var timeString: String {
        return ClassTime.getTimeString(for: period)
    }
    
    var startTime: Date {
        return ClassTime.getStartTime(for: period)
    }
    
    var endTime: Date {
        return ClassTime.getEndTime(for: period)
    }
} 