import SwiftUI
import Combine

// Manager para el idioma de la app
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "es"
    
    var currentLanguage: String {
        appLanguage
    }
    
    func changeLanguage(to language: String) {
        appLanguage = language
        UserDefaults.standard.set(language, forKey: "appLanguage")
    }
    
    private init() {
        // Cargar idioma guardado
        if let saved = UserDefaults.standard.string(forKey: "appLanguage") {
            appLanguage = saved
        }
    }
}

// Extension para facilitar el uso de traducciones
extension String {
    func localized() -> String {
        let language = LocalizationManager.shared.currentLanguage
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

// Keys para las traducciones
enum L10n {
    // Saludos
    static let goodMorning = "good_morning"
    static let goodAfternoon = "good_afternoon"
    static let goodEvening = "good_evening"
    
    // App general
    static let appName = "app_name"
    static let selectContent = "select_content"
    
    // Radio
    static let radioTitle = "radio_title"
    static let radioSubtitle = "radio_subtitle"
    static let radioDescription = "radio_description"
    static let radio = "radio"
    
    // TV
    static let tvTitle = "tv_title"
    static let tvSubtitle = "tv_subtitle"
    static let tvDescription = "tv_description"
    static let tv = "tv"
    
    // Info
    static let infoTitle = "info_title"
    static let infoSubtitle = "info_subtitle"
    static let infoDescription = "info_description"
    
    // Estados
    static let live = "live"
    static let paused = "paused"
    static let tapToPlay = "tap_to_play"
    static let tapToStop = "tap_to_stop"
    
    // Info view
    static let serviceSchedule = "service_schedule"
    static let ourLocation = "our_location"
    static let churchName = "church_name"
    
    // Settings
    static let language = "language"
    static let settings = "settings"
    
    // TV View
    static let streaming = "streaming"
    static let airplay = "airplay"
    static let christianTv24 = "christian_tv_24"
    
    // Info View
    static let locationAddress = "location_address"
    static let monday = "monday"
    static let tuesday = "tuesday"
    static let wednesday = "wednesday"
    static let thursday = "thursday"
    static let friday = "friday"
    static let saturday = "saturday"
    static let sunday = "sunday"
    
    // Programas de la iglesia
    static let fastingPrayer = "fasting_prayer"
    static let victoryFamilies = "victory_families"
    static let prayerTower = "prayer_tower"
    static let guestTuesday = "guest_tuesday"
    static let dawnWithGod = "dawn_with_god"
    static let bibleStudyNight = "bible_study_night"
    static let worshipNight = "worship_night"
    static let miracleNight = "miracle_night"
    static let youngJev = "young_jev"
    static let miracleSaturday = "miracle_saturday"
    static let worshipPrayer = "worship_prayer"
}
