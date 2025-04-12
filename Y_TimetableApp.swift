import SwiftUI
import UserNotifications

@main
struct Y_TimetableApp: App {
    @StateObject private var viewModel = TimetableViewModel()
    
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            TimetableGridView(viewModel: viewModel)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知の許可が得られました")
            } else if let error = error {
                print("通知の許可取得に失敗しました: \(error)")
            }
        }
    }
    
    private func scheduleNotification(for course: Course) {
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = course.name
        content.body = "教室: \(course.classroom)"
        content.sound = .default
        
        // 現在の日付から次の授業日時を計算
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.weekday = course.dayOfWeek  // 1: 日曜日, 2: 月曜日, ...
        components.hour = startTimes[course.period - 1]
        components.minute = 0
        
        // リマインダー時間を設定（授業開始10分前）
        let reminderDate = nextDate.addingTimeInterval(-Double(course.reminderTime * 60))
    }
}

struct ClassTime {
    static let periods: [(start: (hour: Int, minute: Int), end: (hour: Int, minute: Int))] = [
        ((9, 0), (10, 30)),   // 1限
        ((10, 40), (12, 10)), // 2限
        ((13, 0), (14, 30)),  // 3限
        ((14, 40), (16, 10)), // 4限
        ((16, 20), (17, 50)), // 5限
        ((18, 0), (19, 30))   // 6限
    ]
}

struct AddCourseView: View {
    @State private var selectedStartTime: Date = Date()
    @State private var selectedEndTime: Date = Date()
    
    var body: some View {
        Form {
            Section(header: Text("授業時間")) {
                DatePicker("開始時間", selection: $selectedStartTime, displayedComponents: .hourAndMinute)
                DatePicker("終了時間", selection: $selectedEndTime, displayedComponents: .hourAndMinute)
            }
            
            Picker("時限", selection: $period) {
                ForEach(0..<ClassTime.periods.count, id: \.self) { index in
                    let period = ClassTime.periods[index]
                    Text("\(index + 1)限 (\(period.start.hour):\(String(format: "%02d", period.start.minute))-\(period.end.hour):\(String(format: "%02d", period.end.minute)))")
                }
            }
        }
    }
}

struct Course: Identifiable, Codable {
    var startTime: Date  // 授業開始時間
    var endTime: Date    // 授業終了時間
    
    // 授業時間を取得するための計算プロパティ
    var classTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime))-\(formatter.string(from: endTime))"
    }
} 