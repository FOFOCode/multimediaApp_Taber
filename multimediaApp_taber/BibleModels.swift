import Foundation

// MARK: - Bible Models

struct Bible: Codable, Identifiable {
    let id: String
    let name: String
    let nameLocal: String
    let abbreviation: String
    let abbreviationLocal: String
    let description: String
    let language: BibleLanguage
    
    struct BibleLanguage: Codable {
        let id: String
        let name: String
    }
}

struct Book: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameLong: String
    let abbreviation: String
    let chapters: [Chapter]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }
}

struct Chapter: Codable, Identifiable, Hashable {
    let id: String
    let number: String
    let reference: String
    let content: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        lhs.id == rhs.id
    }
}

struct Verse: Codable, Identifiable {
    let id: String
    let orgId: String
    let bookId: String
    let chapterId: String
    let text: String
    let reference: String
}

struct SearchResult: Codable, Identifiable {
    let id: String
    let bookId: String
    let chapterId: String
    let text: String
    let reference: String
}

// MARK: - API Response Models

struct BibleAPIResponse: Codable {
    let data: [Bible]
}

struct BooksAPIResponse: Codable {
    let data: [Book]
}

struct ChapterAPIResponse: Codable {
    let data: ChapterData
    
    struct ChapterData: Codable {
        let id: String
        let number: String
        let reference: String
        let content: String
        let next: NextChapter?
        let previous: PreviousChapter?
    }
    
    struct NextChapter: Codable {
        let id: String
    }
    
    struct PreviousChapter: Codable {
        let id: String
    }
}

struct SearchAPIResponse: Codable {
    let data: SearchData
    
    struct SearchData: Codable {
        let verses: [VerseResult]
    }
    
    struct VerseResult: Codable {
        let id: String
        let orgId: String
        let bookId: String
        let chapterId: String
        let text: String
        let reference: String
    }
}

// MARK: - Favorite Model

struct FavoriteVerse: Codable, Identifiable {
    let id: String
    let reference: String
    let text: String
    let bookName: String
    let timestamp: Date
}
