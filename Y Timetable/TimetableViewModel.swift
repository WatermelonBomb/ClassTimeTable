import Foundation

class TimetableViewModel: ObservableObject {
    @Published var courses: [Course] = []
    
    private let saveKey = "savedCourses"
    
    init() {
        loadCourses()
    }
    
    func addCourse(_ course: Course) {
        courses.append(course)
        saveCourses()
    }
    
    func updateCourse(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
            saveCourses()
        }
    }
    
    func deleteCourse(_ course: Course) {
        courses.removeAll { $0.id == course.id }
        saveCourses()
    }
    
    func getCourses(for day: Int, period: Int) -> [Course] {
        return courses.filter { $0.dayOfWeek == day && $0.period == period }
    }
    
    private func saveCourses() {
        if let encoded = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadCourses() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Course].self, from: data) {
            courses = decoded
        }
    }
} 

//test
