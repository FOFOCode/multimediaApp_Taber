import Foundation
import SwiftData

@Model
final class VerseStudyData {
    @Attribute(.unique) var id: String
    
    var bibleId: String
    var bookId: String
    var chapterId: String
    var verseId: String
    
    var highlightColor: String?
    var noteText: String?
    
    var updatedAt: Date
    
    init(id: String, bibleId: String, bookId: String, chapterId: String, verseId: String, highlightColor: String? = nil, noteText: String? = nil) {
        self.id = id
        self.bibleId = bibleId
        self.bookId = bookId
        self.chapterId = chapterId
        self.verseId = verseId
        self.highlightColor = highlightColor
        self.noteText = noteText
        self.updatedAt = Date()
    }
}
