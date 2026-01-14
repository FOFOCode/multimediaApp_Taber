import Foundation
import Combine

/// Servicio para gestionar acceso a contenido bíblico mediante API.Bible
/// 
/// BibleService proporciona métodos para:
/// - Obtener Biblias disponibles en diferentes idiomas
/// - Recuperar libros de una Biblia específica
/// - Leer capítulos completos
/// - Buscar versículos específicos
/// 
/// Este es un singleton que mantiene el estado actual de la Biblia y proporciona
/// propiedades publicadas para actualizar la UI en tiempo real.
/// 
/// **Configuración requerida:**
/// 1. Regístrate en https://scripture.api.bible
/// 2. Obtén tu API Key
/// 3. Reemplaza `apiKey` con tu clave personal
/// 
/// Ejemplo de uso:
/// ```swift
/// let service = BibleService.shared
/// let bibles = try await service.fetchBibles(language: "es")
/// let books = try await service.fetchBooks(bibleId: bibles[0].id)
/// ```
class BibleService: ObservableObject {
    static let shared = BibleService()
    
    // MARK: - Configuration
    
    /// API Key de API.Bible - Requiere registro en https://scripture.api.bible
    /// ⚠️ Importante: Reemplaza con tu propia API Key
    private let apiKey = "lB1S138vRr8WXNuj88_f2"
    
    /// URL base para todas las solicitudes API
    private let baseURL = "https://rest.api.bible/v1"
    
    // MARK: - Published Properties
    
    /// Array de Biblias disponibles en el idioma actual
    @Published var availableBibles: [Bible] = []
    
    /// Biblia actualmente seleccionada
    @Published var currentBible: Bible?
    
    /// Libros de la Biblia actual
    @Published var books: [Book] = []
    
    /// Indica si se está realizando una solicitud a la API
    @Published var isLoading = false
    
    /// Mensaje de error de la última operación (si la hay)
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// IDs de Biblias recomendadas por idioma
    private let spanishBibleId = "592420522e16049f-01"    // Reina Valera 1909
    private let englishBibleId = "de4e12af7f28f599-02"    // King James Version
    
    /// Conjunto de subscripciones de Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Inicializa el servicio (singleton)
    private init() {}
    
    // MARK: - Get Available Bibles
    
    /// Obtiene una lista de Biblias disponibles en el idioma especificado
    ///
    /// - Parameters:
    ///   - language: Código de idioma ISO (ej: "spa" para español, "eng" para inglés)
    /// - Returns: Array de Biblias disponibles en el idioma
    /// - Throws: `BibleError` si la solicitud falla
    ///
    /// Ejemplo:
    /// ```swift
    /// let spanishBibles = try await service.fetchBibles(language: "spa")
    /// ```
    func fetchBibles(language: String = "spa") async throws -> [Bible] {
        let urlString = "\(baseURL)/bibles?language=\(language)"
        
        guard let url = URL(string: urlString) else {
            throw BibleError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BibleError.invalidResponse("No se pudo obtener respuesta del servidor")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Error desconocido"
            throw BibleError.invalidResponse("Código \(httpResponse.statusCode): \(errorMsg)")
        }
        
        let bibleResponse = try JSONDecoder().decode(BibleAPIResponse.self, from: data)
        return bibleResponse.data
    }
    
    // MARK: - Get Books
    
    /// Obtiene todos los libros de la Biblia especificada
    ///
    /// - Parameters:
    ///   - bibleId: Identificador único de la Biblia
    /// - Returns: Array de libros de la Biblia
    /// - Throws: `BibleError` si la solicitud falla o API Key no está configurada
    ///
    /// Ejemplo:
    /// ```swift
    /// let books = try await service.fetchBooks(bibleId: "592420522e16049f-01")
    /// ```
    func fetchBooks(bibleId: String) async throws -> [Book] {
        // Verificar que la API key esté configurada
        guard apiKey != "TU_API_KEY_AQUI" && !apiKey.isEmpty else {
            throw BibleError.apiKeyNotConfigured
        }
        
        let urlString = "\(baseURL)/bibles/\(bibleId)/books"
        
        guard let url = URL(string: urlString) else {
            throw BibleError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BibleError.invalidResponse("No se pudo obtener respuesta del servidor")
        }
        
        // Verificar diferentes códigos de estado
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw BibleError.unauthorized
        case 403:
            throw BibleError.forbidden
        case 404:
            throw BibleError.notFound
        default:
            let errorMsg = String(data: data, encoding: .utf8) ?? "Error desconocido"
            throw BibleError.invalidResponse("Código \(httpResponse.statusCode): \(errorMsg)")
        }
        
        do {
            let booksResponse = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
            return booksResponse.data
        } catch {
            throw BibleError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Get Chapter
    
    /// Obtiene el contenido completo de un capítulo específico
    ///
    /// - Parameters:
    ///   - bibleId: Identificador de la Biblia
    ///   - chapterId: Identificador del capítulo
    /// - Returns: Datos del capítulo incluyendo versículos y contenido
    /// - Throws: `BibleError` si la solicitud falla
    ///
    /// Ejemplo:
    /// ```swift
    /// let chapter = try await service.fetchChapter(
    ///     bibleId: "592420522e16049f-01",
    ///     chapterId: "GEN.1"
    /// )
    /// ```
    func fetchChapter(bibleId: String, chapterId: String) async throws -> ChapterAPIResponse.ChapterData {
        guard apiKey != "TU_API_KEY_AQUI" && !apiKey.isEmpty else {
            throw BibleError.apiKeyNotConfigured
        }
        
        let urlString = "\(baseURL)/bibles/\(bibleId)/chapters/\(chapterId)?content-type=text&include-notes=false&include-titles=true&include-chapter-numbers=false&include-verse-numbers=true&include-verse-spans=false"
        
        guard let url = URL(string: urlString) else {
            throw BibleError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BibleError.invalidResponse("No se pudo obtener respuesta del servidor")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Error desconocido"
            throw BibleError.invalidResponse("Código \(httpResponse.statusCode): \(errorMsg)")
        }
        
        do {
            let chapterResponse = try JSONDecoder().decode(ChapterAPIResponse.self, from: data)
            return chapterResponse.data
        } catch {
            throw BibleError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Search
    
    /// Busca versículos que coincidan con una consulta específica
    ///
    /// - Parameters:
    ///   - bibleId: Identificador de la Biblia
    ///   - query: Texto a buscar (ej: "amor", "fe", "esperanza")
    /// - Returns: Array de resultados de búsqueda con versículos que coinciden
    /// - Throws: `BibleError` si la solicitud falla
    ///
    /// Ejemplo:
    /// ```swift
    /// let results = try await service.searchVerses(
    ///     bibleId: "592420522e16049f-01",
    ///     query: "amor"
    /// )
    /// ```
    func searchVerses(bibleId: String, query: String) async throws -> [SearchAPIResponse.VerseResult] {
        guard apiKey != "TU_API_KEY_AQUI" && !apiKey.isEmpty else {
            throw BibleError.apiKeyNotConfigured
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/bibles/\(bibleId)/search?query=\(encodedQuery)&limit=100"
        
        guard let url = URL(string: urlString) else {
            throw BibleError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BibleError.invalidResponse("No se pudo obtener respuesta del servidor")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Error desconocido"
            throw BibleError.invalidResponse("Código \(httpResponse.statusCode): \(errorMsg)")
        }
        
        do {
            let searchResponse = try JSONDecoder().decode(SearchAPIResponse.self, from: data)
            return searchResponse.data.verses
        } catch {
            throw BibleError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Obtiene el ID de Biblia correspondiente al código de idioma
    ///
    /// - Parameters:
    ///   - languageCode: Código de idioma ("es" para español, otro para inglés)
    /// - Returns: ID de Biblia recomendada para el idioma
    func getBibleForLanguage(_ languageCode: String) -> String {
        return languageCode == "es" ? spanishBibleId : englishBibleId
    }
    
    /// Carga datos de la Biblia (libros) de forma asíncrona
    ///
    /// Actualiza automáticamente las propiedades publicadas:
    /// - `books`: Se rellena con los libros disponibles
    /// - `isLoading`: Indica si se está cargando
    /// - `errorMessage`: Contiene cualquier error que ocurra
    ///
    /// - Parameters:
    ///   - language: Código de idioma ("es", "en", etc.)
    ///
    /// Ejemplo:
    /// ```swift
    /// service.loadBibleData(language: "es")
    /// // Los datos se cargan de forma asíncrona y se actualiza @Published
    /// ```
    func loadBibleData(language: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let bibleId = getBibleForLanguage(language)
                let fetchedBooks = try await fetchBooks(bibleId: bibleId)
                
                await MainActor.run {
                    self.books = fetchedBooks
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Bible Errors

/// Enumeración de errores que pueden ocurrir al acceder a la API de Biblia
enum BibleError: LocalizedError {
    /// URL inválida
    case invalidURL
    
    /// Respuesta inválida del servidor
    case invalidResponse(String)
    
    /// Error al decodificar JSON
    case decodingError(String)
    
    /// Error de conectividad
    case networkError(Error)
    
    /// API Key no configurada o vacía
    case apiKeyNotConfigured
    
    /// Credenciales no autorizadas (401)
    case unauthorized
    
    /// Acceso prohibido (403)
    case forbidden
    
    /// Recurso no encontrado (404)
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse(let message):
            return "Respuesta inválida: \(message)"
        case .decodingError(let message):
            return "Error al procesar datos: \(message)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .apiKeyNotConfigured:
            return "⚠️ API Key no configurada\n\nPara usar la Biblia necesitas:\n1. Ir a https://scripture.api.bible\n2. Crear cuenta gratuita\n3. Obtener API key\n4. Configurarla en BibleService.swift"
        case .unauthorized:
            return "API Key inválida o no autorizada"
        case .forbidden:
            return "Acceso prohibido - verifica tu API key"
        case .notFound:
            return "Recurso no encontrado en la API"
        }
    }
}
