import Foundation

// MARK: - YouTube Models
struct YouTubeVideo: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let channelTitle: String
    let publishedAt: String
    let videoId: String
    
    var thumbnailImageURL: URL? {
        URL(string: thumbnailURL)
    }
}

// MARK: - API Response Models
struct YouTubeSearchResponse: Codable {
    let items: [YouTubeSearchItem]
}

struct YouTubeSearchItem: Codable {
    let id: YouTubeVideoId
    let snippet: YouTubeSnippet
}

struct YouTubeVideoId: Codable {
    let videoId: String
}

struct YouTubeSnippet: Codable {
    let title: String
    let description: String
    let thumbnails: YouTubeThumbnails
    let channelTitle: String
    let publishedAt: String
}

struct YouTubeThumbnails: Codable {
    let high: YouTubeThumbnail
}

struct YouTubeThumbnail: Codable {
    let url: String
}

// MARK: - Video Categories
enum YouTubeCategory: String, CaseIterable {
    case himnos = "Himnos Bautistas"
    case alabanzas = "Alabanzas Cristianas"
    case predicaciones = "Predicaciones"
    case estudios = "Estudios Bíblicos"
    case testimonios = "Testimonios"
    
    var searchQuery: String {
        switch self {
        case .himnos: return "himnario bautista"
        case .alabanzas: return "alabanza cristiana"
        case .predicaciones: return "predicación cristiana"
        case .estudios: return "estudio bíblico"
        case .testimonios: return "testimonio cristiano"
        }
    }
    
    var icon: String {
        switch self {
        case .himnos: return "music.note.list"
        case .alabanzas: return "music.mic"
        case .predicaciones: return "person.wave.2.fill"
        case .estudios: return "book.fill"
        case .testimonios: return "heart.text.square.fill"
        }
    }
}
