import SwiftUI
import UserNotifications

struct AddCourseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TimetableViewModel
    
    @State private var name = ""
    @State private var professor = ""
    @State private var classroom = ""
    @State private var dayOfWeek = 1
    @State private var period = 1
    @State private var color = "#FF0000"
    @State private var hasReminder = false
    @State private var reminderTime = 10
    
    private let days = Array(1...5)
    private let periods = Array(1...6)
    private let colors = ["#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("授業情報")) {
                    TextField("科目名", text: $name)
                    TextField("教授名", text: $professor)
                    TextField("教室", text: $classroom)
                }
                
                Section(header: Text("時間")) {
                    Picker("曜日", selection: $dayOfWeek) {
                        ForEach(days, id: \.self) { day in
                            Text(Course.daysOfWeek[day - 1]).tag(day)
                        }
                    }
                    
                    Picker("時限", selection: $period) {
                        ForEach(periods, id: \.self) { period in
                            Text("\(period)限 (\(ClassTime.getTimeString(for: period)))").tag(period)
                        }
                    }
                }
                
                Section(header: Text("色")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(colors, id: \.self) { colorCode in
                                Circle()
                                    .fill(Color(hex: colorCode))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: color == colorCode ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        color = colorCode
                                    }
                            }
                        }
                    }
                }
                
                Section(header: Text("リマインダー")) {
                    Toggle("リマインダーを設定", isOn: $hasReminder)
                    
                    if hasReminder {
                        Stepper("\(reminderTime)分前に通知", value: $reminderTime, in: 5...30, step: 5)
                    }
                }
            }
            .navigationTitle("授業を追加")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    dismiss()
                },
                trailing: Button("保存") {
                    saveCourse()
                }
                .disabled(name.isEmpty || classroom.isEmpty)
            )
        }
    }
    
    private func saveCourse() {
        let course = Course(
            name: name,
            professor: professor,
            classroom: classroom,
            dayOfWeek: dayOfWeek,
            period: period,
            color: color,
            hasReminder: hasReminder,
            reminderTime: reminderTime
        )
        
        viewModel.addCourse(course)
        
        if hasReminder {
            scheduleNotification(for: course)
        }
        
        dismiss()
    }
    
    private func scheduleNotification(for course: Course) {
        let content = UNMutableNotificationContent()
        content.title = course.name
        content.body = "教室: \(course.classroom)\n開始時間: \(course.timeString)"
        content.sound = .default
        
        let calendar = Calendar.current
        let now = Date()
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.weekday = course.dayOfWeek
        
        let startTime = ClassTime.getStartTime(for: course.period)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        components.hour = startComponents.hour
        components.minute = startComponents.minute
        
        guard let nextDate = calendar.date(from: components) else { return }
        
        let reminderDate = nextDate.addingTimeInterval(-Double(course.reminderTime * 60))
        let finalDate = reminderDate < now ? reminderDate.addingTimeInterval(7 * 24 * 60 * 60) : reminderDate
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalDate),
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: course.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知の設定に失敗しました: \(error)")
            }
        }
    }
} 