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
} 
