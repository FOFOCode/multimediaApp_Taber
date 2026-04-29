import Foundation
import UserNotifications
import UIKit
import Combine

final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false
    @Published var notifications: [ChurchNotification] = []
    @Published var dailyVerse: String = ""
    @Published var dailyVerseReference: String = ""

    private let center = UNUserNotificationCenter.current()
    private let notificationsKey = "saved_notifications"
    private let dailyVerseKey = "daily_verse"
    private let dailyVerseRefKey = "daily_verse_reference"

    private init() {
        loadNotifications()
        loadDailyVerse()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Daily Verse

    func loadDailyVerse() {
        if let verse = UserDefaults.standard.string(forKey: dailyVerseKey) {
            dailyVerse = verse
        }
        if let ref = UserDefaults.standard.string(forKey: dailyVerseRefKey) {
            dailyVerseReference = ref
        }
    }

    func setDailyVerse(verse: String, reference: String) {
        dailyVerse = verse
        dailyVerseReference = reference
        UserDefaults.standard.set(verse, forKey: dailyVerseKey)
        UserDefaults.standard.set(reference, forKey: dailyVerseRefKey)
    }

    func fetchDailyVerse() async {
        // Ejemplo: obtener versículo de API o usar lista local
        let verses = [
            ("Juan 3:16", "Porque tanto amó Dios al mundo, que dio a su Hijo unigénito, para que todo el que cree en él no se pierda, sino que tenga vida eternal."),
            ("Salmos 23:1", "Jehová es mi pastor; nada me faltará."),
            ("Filipenses 4:13", "Todo lo puedo en Cristo que me fortalece."),
            ("Isaías 41:10", "No temas, porque yo estoy contigo; no desmayes, porque yo soy tu Dios que te fortalezco."),
            ("Romanos 8:28", "Y sabemos que todas las cosas cooperan para el bien de los que aman a Dios.")
        ]

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % verses.count

        await MainActor.run {
            self.setDailyVerse(verse: verses[index].1, reference: verses[index].0)
        }
    }

    // MARK: - Manage Notifications

    func loadNotifications() {
        guard let data = UserDefaults.standard.data(forKey: notificationsKey),
              let saved = try? JSONDecoder().decode([ChurchNotification].self, from: data) else {
            // Notificaciones por defecto
            notifications = defaultNotifications()
            saveNotifications()
            return
        }
        notifications = saved
    }

    func saveNotifications() {
        if let data = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(data, forKey: notificationsKey)
        }
    }

    private func defaultNotifications() -> [ChurchNotification] {
        [
            ChurchNotification(
                type: .dailyVerse,
                title: L10n.dailyVerse.localized(),
                body: "Recibe tu versículo del día",
                hour: 8,
                minute: 0,
                isEnabled: true,
                repeatDays: [1, 2, 3, 4, 5, 6, 7]
            ),
            ChurchNotification(
                type: .serviceReminder,
                title: "Culto de Adoración",
                body: "El culto comienza en 30 minutos",
                hour: 10,
                minute: 0,
                isEnabled: true,
                repeatDays: [7],
                customId: "sunday_service"
            )
        ]
    }

    func updateNotification(_ notification: ChurchNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
            saveNotifications()
            scheduleNotification(notification)
        }
    }

    func addNotification(_ notification: ChurchNotification) {
        notifications.append(notification)
        saveNotifications()
        scheduleNotification(notification)
    }

    func deleteNotification(id: String) {
        notifications.removeAll { $0.id == id }
        saveNotifications()
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func toggleNotification(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isEnabled.toggle()
            saveNotifications()

            if notifications[index].isEnabled {
                scheduleNotification(notifications[index])
            } else {
                center.removePendingNotificationRequests(withIdentifiers: [id])
            }
        }
    }

    // MARK: - Schedule Notifications

    func scheduleAllNotifications() async {
        center.removeAllPendingNotificationRequests()

        for notification in notifications where notification.isEnabled {
            scheduleNotification(notification)
        }
    }

    func scheduleNotification(_ notification: ChurchNotification) {
        guard notification.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.type == .dailyVerse ? dailyVerse : notification.body
        content.sound = .default
        content.badge = 1

        if notification.type == .dailyVerse {
            content.body = "\(dailyVerseReference): \(dailyVerse)"
        }

        for day in notification.repeatDays {
            var dateComponents = DateComponents()
            dateComponents.hour = notification.hour
            dateComponents.minute = notification.minute

            if day == 7 {
                dateComponents.weekday = 1
            } else {
                dateComponents.weekday = day + 1
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(notification.id)_\(day)",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func scheduleImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Badge

    func clearBadge() {
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    // MARK: - Service Reminders

    func updateServiceReminder(hour: Int, minute: Int, days: [Int]) {
        if let index = notifications.firstIndex(where: { $0.type == .serviceReminder }) {
            var notification = notifications[index]
            notification.hour = hour
            notification.minute = minute
            notification.repeatDays = days
            notifications[index] = notification
            saveNotifications()
            scheduleNotification(notification)
        }
    }
}