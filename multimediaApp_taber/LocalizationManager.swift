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
/// @StateObject private var localization = LocalizationManager.shared
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
}
