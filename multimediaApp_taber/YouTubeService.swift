import Foundation
import Combine

class YouTubeService: ObservableObject {
    // Obtén tu API key en: https://console.cloud.google.com/apis/credentials
    private let apiKey = "AIzaSyAuKPOUk48eb4GjwOJ1jdFkEyEcRbcdjMc"
    private let baseURL = "https://www.googleapis.com/youtube/v3"
    
    @Published var videos: [YouTubeVideo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    enum YouTubeError: Error {
        case apiKeyNotConfigured
        case invalidURL
        case networkError
        case decodingError
        case apiError(String)
    }
    
    func searchVideos(query: String, maxResults: Int = 10) async {
        await MainActor.run { isLoading = true }
        
        // Validar API key
        guard apiKey != "TU_API_KEY_AQUI" && !apiKey.isEmpty else {
            await MainActor.run {
                errorMessage = "⚠️ API Key no configurada\n\nVe a YouTubeService.swift y reemplaza 'TU_API_KEY_AQUI' con tu clave de YouTube Data API v3.\n\nObtén una en: console.cloud.google.com"
                isLoading = false
            }
            return
        }
        
        // Construir URL
        let urlString = "\(baseURL)/search?part=snippet&q=\(query)&type=video&maxResults=\(maxResults)&key=\(apiKey)&order=relevance&videoEmbeddable=true"
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            await MainActor.run {
                errorMessage = "URL inválida"
                isLoading = false
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Verificar código de estado HTTP
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    let errorText = String(data: data, encoding: .utf8) ?? "Error desconocido"
                    throw YouTubeError.apiError("HTTP \(httpResponse.statusCode): \(errorText)")
                }
            }
            
            // Decodificar respuesta
            let searchResponse = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
            
            let fetchedVideos = searchResponse.items.map { item in
                YouTubeVideo(
                    id: item.id.videoId,
                    title: item.snippet.title,
                    description: item.snippet.description,
                    thumbnailURL: item.snippet.thumbnails.high.url,
                    channelTitle: item.snippet.channelTitle,
                    publishedAt: item.snippet.publishedAt,
                    videoId: item.id.videoId
                )
            }
            
            await MainActor.run {
                self.videos = fetchedVideos
                self.errorMessage = nil
                self.isLoading = false
            }
            
        } catch let error as YouTubeError {
            await MainActor.run {
                self.errorMessage = handleError(error)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error de conexión: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func searchByCategory(_ category: YouTubeCategory) async {
        await searchVideos(query: category.searchQuery)
    }
    
    private func handleError(_ error: YouTubeError) -> String {
        switch error {
        case .apiKeyNotConfigured:
            return "API Key no configurada"
        case .invalidURL:
            return "URL inválida"
        case .networkError:
            return "Error de conexión"
        case .decodingError:
            return "Error al procesar datos"
        case .apiError(let message):
            return message
        }
    }
    
    func getVideoURL(videoId: String) -> URL? {
        URL(string: "https://www.youtube.com/watch?v=\(videoId)")
    }
}
