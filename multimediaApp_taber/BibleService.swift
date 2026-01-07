import Foundation
import Combine

class BibleService: ObservableObject {
    static let shared = BibleService()
    
    // API Key de API.Bible - Necesitarás registrarte en https://scripture.api.bible para obtener una
    private let apiKey = "lB1S138vRr8WXNuj88_f2"
    private let baseURL = "https://rest.api.bible/v1"
    
    @Published var availableBibles: [Bible] = []
    @Published var currentBible: Bible?
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // IDs de Biblias recomendadas
    private let spanishBibleId = "592420522e16049f-01" // Reina Valera 1909
    private let englishBibleId = "de4e12af7f28f599-02" // King James Version
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Get Available Bibles
    
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
    
    func getBibleForLanguage(_ languageCode: String) -> String {
        return languageCode == "es" ? spanishBibleId : englishBibleId
    }
    
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

// MARK: - Errors

enum BibleError: LocalizedError {
    case invalidURL
    case invalidResponse(String)
    case decodingError(String)
    case networkError(Error)
    case apiKeyNotConfigured
    case unauthorized
    case forbidden
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
