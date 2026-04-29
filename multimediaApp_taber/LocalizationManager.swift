import SwiftUI
import Combine

/// Gestor centralizado para la localización y cambio de idioma de la aplicación
///
/// LocalizationManager es un singleton que mantiene el idioma actual de la app
/// y permite cambiar entre idiomas disponibles. Los cambios se guardan automáticamente
/// en UserDefaults para persistencia entre sesiones.
///
/// Características:
/// - Singleton para acceso global (`LocalizationManager.shared`)
/// - Publicación de cambios de idioma (observable)
/// - Persistencia automática en UserDefaults
/// - Interfaz simple para cambiar idiomas
/// - Carga del idioma del sistema como predeterminado
///
/// Ejemplo de uso:
/// ```swift
/// @ObservedObject private var localization = LocalizationManager.shared
///
/// Button("Español") {
///     localization.changeLanguage(to: "es")
/// }
/// ```
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    // MARK: - Published Properties
    
    /// Idioma actual de la aplicación (publicado para reactividad)
    @Published var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "es"
    
    // MARK: - Computed Properties
    
    /// Obtiene el código de idioma actual
    var currentLanguage: String {
        appLanguage
    }
    
    // MARK: - Public Methods
    
    /// Cambia el idioma de la aplicación
    ///
    /// - Parameters:
    ///   - language: Código de idioma (ej: "es", "en")
    ///
    /// El cambio se notifica automáticamente a todos los observers
    /// y se persiste en UserDefaults.
    ///
    /// Ejemplo:
    /// ```swift
    /// localization.changeLanguage(to: "en")
    /// // La UI se actualiza automáticamente
    /// ```
    func changeLanguage(to language: String) {
        appLanguage = language
        UserDefaults.standard.set(language, forKey: "appLanguage")
    }
    
    // MARK: - Initialization
    
    /// Inicializa el manager (singleton)
    ///
    /// Al inicializar, carga el idioma guardado o usa el predeterminado del sistema.
    private init() {
        // Cargar idioma guardado de sesiones anteriores
        if let saved = UserDefaults.standard.string(forKey: "appLanguage") {
            appLanguage = saved
        }
    }
}

// MARK: - String Extension for Localization

/// Extensión de String para facilitar el acceso a traducciones
extension String {
    /// Obtiene la versión localizada del string en el idioma actual
    ///
    /// Busca el archivo `.lproj` correspondiente al idioma actual
    /// y devuelve la cadena traducida.
    ///
    /// - Returns: String traducido o la cadena original si no existe traducción
    ///
    /// Ejemplo:
    /// ```swift
    /// Text("app_name".localized())
    /// // Mostrará el nombre de la app en el idioma actual
    /// ```
    func localized() -> String {
        let language = LocalizationManager.shared.currentLanguage
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

// MARK: - Localization Keys

/// Enumeración centralizada de todas las claves de traducción disponibles
///
/// Esta estructura facilita el acceso a todas las cadenas localizables
/// y proporciona autocompletado en el IDE.
enum L10n {
    // MARK: - Greetings
    
    /// Saludo matutino
    static let goodMorning = "good_morning"
    /// Saludo vespertino
    static let goodAfternoon = "good_afternoon"
    /// Saludo nocturno
    static let goodEvening = "good_evening"
    
    // MARK: - General App
    
    /// Nombre de la aplicación
    static let appName = "app_name"
    /// Texto para seleccionar contenido
    static let selectContent = "select_content"
    
    // MARK: - Radio Section
    
    /// Título de la sección de Radio
    static let radioTitle = "radio_title"
    /// Subtítulo de la sección de Radio
    static let radioSubtitle = "radio_subtitle"
    /// Descripción de la sección de Radio
    static let radioDescription = "radio_description"
    /// Label genérico para Radio
    static let radio = "radio"
    
    // MARK: - TV Section
    
    /// Título de la sección de TV
    static let tvTitle = "tv_title"
    /// Subtítulo de la sección de TV
    static let tvSubtitle = "tv_subtitle"
    /// Descripción de la sección de TV
    static let tvDescription = "tv_description"
    /// Label genérico para TV
    static let tv = "tv"
    
    // MARK: - Info Section
    
    /// Título de la sección de Información
    static let infoTitle = "info_title"
    /// Subtítulo de la sección de Información
    static let infoSubtitle = "info_subtitle"
    /// Descripción de la sección de Información
    static let infoDescription = "info_description"
    
    // MARK: - Bible Section
    
    /// Título de la sección de Biblia
    static let bibleTitle = "bible_title"
    /// Subtítulo de la sección de Biblia
    static let bibleSubtitle = "bible_subtitle"
    /// Descripción de la sección de Biblia
    static let bibleDescription = "bible_description"
    
    // MARK: - Playback States
    
    /// Estado EN VIVO
    static let live = "live"
    /// Estado PAUSADO
    static let paused = "paused"
    /// Instrucción para reproducir
    static let tapToPlay = "tap_to_play"
    /// Instrucción para detener
    static let tapToStop = "tap_to_stop"
    /// Conectando
    static let connecting = "connecting"
    /// Error de conexión
    static let connectionError = "connection_error"
    /// Reintentar
    static let retry = "retry"
    
    // MARK: - Info View Content
    
    /// Horario de servicios
    static let serviceSchedule = "service_schedule"
    /// Ubicación de la iglesia
    static let ourLocation = "our_location"
    /// Nombre de la iglesia
    static let churchName = "church_name"
    
    // MARK: - Settings
    
    /// Opción de idioma
    static let language = "language"
    /// Título de configuración
    static let settings = "settings"
    
    // MARK: - TV View
    
    /// Estado de transmisión
    static let streaming = "streaming"
    /// Opción AirPlay
    static let airplay = "airplay"
    /// Nombre del canal de TV cristiana 24h
    static let christianTv24 = "christian_tv_24"
    
    // MARK: - Address & Days
    
    /// Dirección de ubicación
    static let locationAddress = "location_address"
    /// Lunes
    static let monday = "monday"
    /// Martes
    static let tuesday = "tuesday"
    /// Miércoles
    static let wednesday = "wednesday"
    /// Jueves
    static let thursday = "thursday"
    /// Viernes
    static let friday = "friday"
    /// Sábado
    static let saturday = "saturday"
    /// Domingo
    static let sunday = "sunday"
    
    // MARK: - Church Programs
    
    /// Programa de ayuno y oración
    static let fastingPrayer = "fasting_prayer"
    /// Programa familias victoriosas
    static let victoryFamilies = "victory_families"
    /// Torre de oración
    static let prayerTower = "prayer_tower"
    /// Martes de invitados
    static let guestTuesday = "guest_tuesday"
    /// Madrugada con Dios
    static let dawnWithGod = "dawn_with_god"
    /// Noche de estudio bíblico
    static let bibleStudyNight = "bible_study_night"
    /// Noche de adoración
    static let worshipNight = "worship_night"
    /// Noche de milagros
    static let miracleNight = "miracle_night"
    /// Programa jóvenes
    static let youngJev = "young_jev"
    /// Sábado de milagros
    static let miracleSaturday = "miracle_saturday"
    /// Oración y adoración
    static let worshipPrayer = "worship_prayer"
    
    // MARK: - Bible View
    
    /// Label para libros
    static let books = "books"
    /// Label para búsqueda
    static let search = "search"
    /// Label para favoritos
    static let favorites = "favorites"
    /// Antiguo Testamento
    static let oldTestament = "old_testament"
    /// Nuevo Testamento
    static let newTestament = "new_testament"
    /// Capítulo
    static let chapter = "chapter"
    /// Placeholder para campo de búsqueda
    static let searchPlaceholder = "search_placeholder"
    /// Mensaje cuando no hay resultados
    static let noResults = "no_results"
    /// Mensaje de instrucción para búsqueda
    static let searchPrompt = "search_prompt"
    /// Mensaje cuando no hay favoritos
    static let noFavorites = "no_favorites"
    /// Opción de tamaño de fuente
    static let fontSize = "font_size"
    /// Botón Hecho/Listo
    static let done = "done"
    /// Error al cargar capítulo
    static let errorLoadingChapter = "error_loading_chapter"
    
    // MARK: - Home View
    
    static let homeTagline = "home_tagline"
    static let dailyInspiration = "daily_inspiration"
    static let verseOfTheDay = "verse_of_the_day"
    static let quickAccess = "quick_access"
    static let contact = "contact"
    static let communicate = "communicate"
    static let notifications = "notifications"
    static let reminders = "reminders"
    static let spiritualJourney = "spiritual_journey"
    static let weeklyPlan = "weekly_plan"
    static let dailyCheckIn = "daily_checkin"
    static let timeInWord = "time_in_word"
    static let accumulatedMinutes = "accumulated_minutes"
    
    // MARK: - Dashboard Fallbacks
    
    static let verseLoadError = "verse_load_error"
    static let noConnection = "no_connection"
    static let noContentFound = "no_content_found"
    static let readingOfDay = "reading_of_day"
    
    // MARK: - Extra Views
    
    static let contactUs = "contact_us"
    static let generalPastor = "general_pastor"
    static let sendMessage = "send_message"
    static let legalInfo = "legal_info"
    static let privacyPolicy = "privacy_policy"
    static let termsOfService = "terms_of_service"
    
    static let loading = "loading"
    static let videoLoadError = "video_load_error"
    
    static let offlineBible = "offline_bible"
    static let downloadBiblePrompt = "download_bible_prompt"
    static let downloading = "downloading"
    static let bibleDownloaded = "bible_downloaded"
    static let downloadFullBiblePrompt = "download_full_bible_prompt"
    static let downloadBible = "download_bible"
    static let readingProgress = "reading_progress"
    static let continueReading = "continue_reading"
    static let noProgressSaved = "no_progress_saved"
    static let storage = "storage"
    static let downloadedChapters = "downloaded_chapters"
    static let spaceUsed = "space_used"
    static let offlineModeActive = "offline_mode_active"
    static let clearCache = "clear_cache"
    
    static let notificationsPrompt = "notifications_prompt"
    static let addReminder = "add_reminder"
    static let noRemindersConfigured = "no_reminders_configured"
    
    static let splashTagline = "splash_tagline"
    static let downloaded = "downloaded"
    static let download = "download"
    static let addFavoritesPrompt = "add_favorites_prompt"
    static let goBack = "go_back"
    static let chooseStation = "choose_station"
    static let minToday = "min_today"
    static let ofSevenDays = "of_seven_days"
    
    // MARK: - More Missing Views
    
    static let radioBautistaDesc = "radio_bautista_desc"
    static let radioNeumaDesc = "radio_neuma_desc"
    
    static let permissionsNotGranted = "permissions_not_granted"
    static let notificationsEnabled = "notifications_enabled"
    static let enable = "enable"
    static let everyDay = "every_day"
    static let dailyVerse = "daily_verse"
    
    static let termsTitle = "terms_title"
    static let termsAcceptanceTitle = "terms_acceptance_title"
    static let termsAcceptanceText = "terms_acceptance_text"
    static let termsLicenseTitle = "terms_license_title"
    static let termsLicenseText = "terms_license_text"
    static let termsDisclaimerTitle = "terms_disclaimer_title"
    static let termsDisclaimerText = "terms_disclaimer_text"
    static let termsLimitationsTitle = "terms_limitations_title"
    static let termsLimitationsText = "terms_limitations_text"
    static let termsPrivacyTitle = "terms_privacy_title"
    static let termsPrivacyText = "terms_privacy_text"
    static let termsModificationsTitle = "terms_modifications_title"
    static let termsModificationsText = "terms_modifications_text"
}
