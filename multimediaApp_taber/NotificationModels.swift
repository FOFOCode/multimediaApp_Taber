import Foundation

enum NotificationType: String, Codable, CaseIterable {
    case dailyVerse = "daily_verse"
    case serviceReminder = "service_reminder"
    case custom = "custom"

    var title: String {
        switch self {
        case .dailyVerse: return "Versículo Diario"
        case .serviceReminder: return "Recordatorio de Culto"
        case .custom: return "Personalizado"
        }
    }

    var icon: String {
        switch self {
        case .dailyVerse: return "book.pages"
        case .serviceReminder: return "building.2"
        case .custom: return "bell"
        }
    }
}

struct ChurchNotification: Identifiable, Codable {
    let id: String
    var type: NotificationType
    var title: String
    var body: String
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var repeatDays: [Int]
    var customId: String?

    init(id: String = UUID().uuidString, type: NotificationType, title: String, body: String, hour: Int, minute: Int, isEnabled: Bool = true, repeatDays: [Int] = [1, 2, 3, 4, 5, 6, 7], customId: String? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.customId = customId
    }

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var weekdaysString: String {
        let days = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        if repeatDays.count == 7 {
            return "Todos los días"
        } else if repeatDays == [1, 2, 3, 4, 5] {
            return "Lunes a Viernes"
        } else if repeatDays == [7] {
            return "Domingos"
        } else {
            return repeatDays.sorted().map { days[$0 - 1] }.joined(separator: ", ")
        }
    }
}