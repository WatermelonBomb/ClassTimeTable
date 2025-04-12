import SwiftUI

struct TimetableGridView: View {
    @ObservedObject var viewModel: TimetableViewModel
    @State private var showingAddCourse = false
    
    private let periods = Array(1...6)
    private let days = Array(1...5) // 月曜から金曜まで
    
    var body: some View {
        NavigationView {
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    // ヘッダー行（曜日）
                    HStack(spacing: 0) {
                        Text("時限")
                            .frame(width: 60, height: 40)
                            .background(Color.gray.opacity(0.2))
                        
                        ForEach(days, id: \.self) { day in
                            Text(Course.daysOfWeek[day - 1])
                                .frame(width: 100, height: 40)
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                    
                    // 時間割グリッド
                    ForEach(periods, id: \.self) { period in
                        HStack(spacing: 0) {
                            Text("\(period)限")
                                .frame(width: 60, height: 80)
                                .background(Color.gray.opacity(0.2))
                            
                            ForEach(days, id: \.self) { day in
                                let courses = viewModel.getCourses(for: day, period: period)
                                VStack {
                                    ForEach(courses) { course in
                                        CourseCell(course: course)
                                    }
                                }
                                .frame(width: 100, height: 80)
                                .background(Color.white)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("時間割")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView(viewModel: viewModel)
            }
        }
    }
}

struct CourseCell: View {
    let course: Course
    
    var body: some View {
        VStack(spacing: 2) {
            Text(course.name)
                .font(.caption)
                .lineLimit(1)
            Text(course.classroom)
                .font(.caption2)
                .lineLimit(1)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: course.color))
        .cornerRadius(4)
    }
}

// カラーコードをColorに変換するための拡張
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
