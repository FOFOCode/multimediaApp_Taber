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
    
    var computedChapterCount: Int {
        let chapterCounts: [String: Int] = [
            "GEN": 50, "EXO": 40, "LEV": 27, "NUM": 36, "DEU": 34,
            "JOS": 24, "JDG": 21, "RUT": 4, "1SA": 31, "2SA": 24,
            "1KI": 22, "2KI": 25, "1CH": 29, "2CH": 36, "EZR": 10,
            "NEH": 13, "EST": 10, "JOB": 42, "PSA": 150, "PRO": 31,
            "ECC": 12, "SNG": 8, "ISA": 66, "JER": 52, "LAM": 5,
            "EZK": 48, "DAN": 12, "HOS": 14, "JOL": 3, "AMO": 9,
            "OBA": 1, "JON": 4, "MIC": 7, "NAM": 3, "HAB": 3,
            "ZEP": 3, "HAG": 2, "ZEC": 14, "MAL": 4,
            "MAT": 28, "MRK": 16, "LUK": 24, "JHN": 21, "ACT": 28,
            "ROM": 16, "1CO": 16, "2CO": 13, "GAL": 6, "EPH": 6,
            "PHP": 4, "COL": 4, "1TH": 5, "2TH": 3, "1TI": 6,
            "2TI": 4, "TIT": 3, "PHM": 1, "HEB": 13, "JAS": 5,
            "1PE": 5, "2PE": 3, "1JN": 5, "2JN": 1, "3JN": 1,
            "JUD": 1, "REV": 22
        ]
        return chapterCounts[id] ?? 50
    }
    
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
        let verses: [VerseResult]?
        let passages: [VerseResult]?
    }
    
    struct VerseResult: Codable {
        let id: String
        let orgId: String?
        let bookId: String
        let chapterId: String
        let text: String?
        let content: String?
        let reference: String
        
        // Helper variable for unified text from verses (text) or passages (content)
        var displayText: String {
            return text ?? content ?? ""
        }
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
