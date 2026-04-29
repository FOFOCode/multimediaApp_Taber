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
    private let cachedVerseLanguageKey = "home_dashboard_cached_verse_lang"

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
        let languageCode = LocalizationManager.shared.currentLanguage

        if let cachedDate = defaults.string(forKey: cachedVerseDateKey),
           cachedDate == todayKey,
           let cachedLanguage = defaults.string(forKey: cachedVerseLanguageKey),
           cachedLanguage == languageCode,
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
            let bibleId = BibleService.shared.getBibleForLanguage(languageCode)
            let verseId = verseIdForToday()
            let verseResult = try await BibleService.shared.fetchVerse(bibleId: bibleId, verseId: verseId)
            
            let cleanText = cleanHTMLTags(from: verseResult.displayText)
            updateVerse(text: cleanText, reference: verseResult.reference, dateKey: todayKey)
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
        weeklyPlanBadgeText = "\(completed) " + L10n.ofSevenDays.localized()

        let goalMinutes = 15.0
        let todayMinutes = Int((defaults.double(forKey: todaySecondsKey) / 60.0).rounded(.down))

        minutesProgress = min(Double(todayMinutes) / goalMinutes, 1.0)
        minutesBadgeText = "\(todayMinutes) " + L10n.minToday.localized()
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

    private func verseIdForToday() -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        let dailyVerses = [
            "JHN.3.16", "PSA.23.1", "PHP.4.13", "ROM.8.28", "PRO.3.5",
            "ISA.41.10", "JER.29.11", "MAT.6.33", "HEB.11.1", "1COR.13.4",
            "JAM.1.2", "1PET.5.7", "1JN.5.7", "1TH.5.7"
        ]
        
        let index = (day - 1) % dailyVerses.count
        return dailyVerses[index]
    }


    private func cleanHTMLTags(from text: String) -> String {
        text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateVerse(text: String, reference: String, dateKey: String) {
        let safeText = text.isEmpty ? L10n.noContentFound.localized() : text
        let safeRef = reference.isEmpty ? L10n.readingOfDay.localized() : reference

        verseText = safeText
        verseRef = safeRef

        defaults.set(dateKey, forKey: cachedVerseDateKey)
        defaults.set(safeText, forKey: cachedVerseTextKey)
        defaults.set(safeRef, forKey: cachedVerseRefKey)
        defaults.set(LocalizationManager.shared.currentLanguage, forKey: cachedVerseLanguageKey)
    }

    private func applyOfflineFallback(dateKey: String) {
        if let favorite = FavoritesService.shared.favorites.first {
            updateVerse(text: favorite.text, reference: favorite.reference, dateKey: dateKey)
            return
        }

        updateVerse(
            text: L10n.verseLoadError.localized(),
            reference: L10n.noConnection.localized(),
            dateKey: dateKey
        )
    }
}
