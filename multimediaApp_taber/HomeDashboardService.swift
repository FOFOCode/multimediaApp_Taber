import Foundation
import Combine

final class HomeDashboardService: ObservableObject {
    static let shared = HomeDashboardService()

    @Published var verseText: String = ""
    @Published var verseRef: String = ""
    @Published var isLoadingVerse = false

    @Published var weeklyPlanProgress: Double = 0
    @Published var weeklyPlanBadgeText: String = "0 de 7 días"

    @Published var minutesProgress: Double = 0
    @Published var minutesBadgeText: String = "0 min hoy"

    private let defaults = UserDefaults.standard

    private let checkinsKey = "home_dashboard_checkins"
    private let todaySecondsKey = "home_dashboard_today_seconds"

    private let cachedVerseDateKey = "home_dashboard_cached_verse_date"
    private let cachedVerseTextKey = "home_dashboard_cached_verse_text"
    private let cachedVerseRefKey = "home_dashboard_cached_verse_ref"

    private var activeSessions: [String: Date] = [:]
    private var cancellables = Set<AnyCancellable>()

    private init() {
        recalculateProgress()
    }

    func handleHomeAppear() {
        registerTodayCheckIn()
        recalculateProgress()
    }

    @MainActor
    func refreshVerseOfDayIfNeeded() async {
        let todayKey = dayKey(for: Date())

        if let cachedDate = defaults.string(forKey: cachedVerseDateKey),
           cachedDate == todayKey,
           let cachedText = defaults.string(forKey: cachedVerseTextKey),
           let cachedRef = defaults.string(forKey: cachedVerseRefKey),
           !cachedText.isEmpty,
           !cachedRef.isEmpty {
            verseText = cachedText
            verseRef = cachedRef
            return
        }

        isLoadingVerse = true

        do {
            let languageCode = LocalizationManager.shared.currentLanguage
            let bibleId = BibleService.shared.getBibleForLanguage(languageCode)
            let query = queryForToday(languageCode: languageCode)
            let results = try await BibleService.shared.searchVerses(bibleId: bibleId, query: query)

            if let picked = pickVerse(for: Date(), from: results) {
                let cleanText = cleanHTMLTags(from: picked.displayText)
                updateVerse(text: cleanText, reference: picked.reference, dateKey: todayKey)
            } else {
                applyOfflineFallback(dateKey: todayKey)
            }
        } catch {
            applyOfflineFallback(dateKey: todayKey)
        }

        isLoadingVerse = false
    }

    func beginMediaSession(source: String) {
        if activeSessions[source] == nil {
            activeSessions[source] = Date()
        }
    }

    func endMediaSession(source: String) {
        guard let start = activeSessions[source] else {
            return
        }

        activeSessions[source] = nil

        let elapsed = Date().timeIntervalSince(start)
        guard elapsed > 0 else {
            return
        }

        var todaySeconds = defaults.double(forKey: todaySecondsKey)
        todaySeconds += elapsed
        defaults.set(todaySeconds, forKey: todaySecondsKey)

        recalculateProgress()
    }

    func recalculateProgress() {
        cleanupIfDayChanged()

        let weekDates = currentWeekDayKeys()
        let checkins = Set(defaults.stringArray(forKey: checkinsKey) ?? [])
        let completed = weekDates.filter { checkins.contains($0) }.count

        weeklyPlanProgress = min(Double(completed) / 7.0, 1.0)
        weeklyPlanBadgeText = "\(completed) de 7 días"

        let goalMinutes = 15.0
        let todayMinutes = Int((defaults.double(forKey: todaySecondsKey) / 60.0).rounded(.down))

        minutesProgress = min(Double(todayMinutes) / goalMinutes, 1.0)
        minutesBadgeText = "\(todayMinutes) min hoy"
    }

    private func registerTodayCheckIn() {
        let today = dayKey(for: Date())
        var checkins = defaults.stringArray(forKey: checkinsKey) ?? []

        if !checkins.contains(today) {
            checkins.append(today)
            defaults.set(checkins, forKey: checkinsKey)
        }
    }

    private func cleanupIfDayChanged() {
        let today = dayKey(for: Date())

        let lastTrackedDate = defaults.string(forKey: "home_dashboard_last_tracked_date")
        if lastTrackedDate != today {
            defaults.set(0.0, forKey: todaySecondsKey)
            defaults.set(today, forKey: "home_dashboard_last_tracked_date")
        }

        let validRange = Set(last14DayKeys())
        let checkins = defaults.stringArray(forKey: checkinsKey) ?? []
        let filtered = checkins.filter { validRange.contains($0) }
        defaults.set(filtered, forKey: checkinsKey)
    }

    private func currentWeekDayKeys() -> [String] {
        let calendar = Calendar.current
        let today = Date()

        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return [dayKey(for: today)]
        }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else {
                return nil
            }
            return dayKey(for: date)
        }
    }

    private func last14DayKeys() -> [String] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<14).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                return nil
            }
            return dayKey(for: date)
        }
    }

    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func queryForToday(languageCode: String) -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1

        let spanishQueries = ["esperanza", "amor", "fe", "gracia", "paz", "fortaleza", "misericordia"]
        let englishQueries = ["hope", "love", "faith", "grace", "peace", "strength", "mercy"]

        let source = languageCode == "es" ? spanishQueries : englishQueries
        return source[day % source.count]
    }

    private func pickVerse(for date: Date, from results: [SearchAPIResponse.VerseResult]) -> SearchAPIResponse.VerseResult? {
        guard !results.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return results[day % results.count]
    }

    private func cleanHTMLTags(from text: String) -> String {
        text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateVerse(text: String, reference: String, dateKey: String) {
        let safeText = text.isEmpty ? "No se encontró contenido para hoy." : text
        let safeRef = reference.isEmpty ? "Lectura del día" : reference

        verseText = safeText
        verseRef = safeRef

        defaults.set(dateKey, forKey: cachedVerseDateKey)
        defaults.set(safeText, forKey: cachedVerseTextKey)
        defaults.set(safeRef, forKey: cachedVerseRefKey)
    }

    private func applyOfflineFallback(dateKey: String) {
        if let favorite = FavoritesService.shared.favorites.first {
            updateVerse(text: favorite.text, reference: favorite.reference, dateKey: dateKey)
            return
        }

        updateVerse(
            text: "No fue posible cargar el versículo de hoy. Intenta nuevamente con conexión a internet.",
            reference: "Sin conexión",
            dateKey: dateKey
        )
    }
}
