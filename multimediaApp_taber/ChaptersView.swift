import SwiftUI

struct ChaptersView: View {
    let book: Book
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var bibleService = BibleService.shared
    @State private var appearAnimation = false
    @State private var chapters: [Chapter] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: book.name)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Encabezado del libro
                        VStack(spacing: 12) {
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.twitterBlue, Color.dodgerBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text(book.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.cobaltBlue)
                            
                            Text(book.abbreviation)
                                .font(.subheadline)
                                .foregroundStyle(Color.twitterBlue.opacity(0.7))
                        }
                        .padding(.top, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : -20)
                        
                        // Grid de capítulos
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(40)
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 60))
                            ], spacing: 12) {
                                ForEach(chapters) { chapter in
                                    NavigationLink(destination: ReaderView(
                                        bookName: book.name,
                                        chapter: chapter
                                    )) {
                                        ChapterButton(chapter: chapter)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .opacity(appearAnimation ? 1 : 0)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            loadChapters()
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
    
    private func loadChapters() {
        // Generar capítulos basados en el libro
        // La API no devuelve la lista de capítulos directamente, 
        // así que los generamos basándonos en el número típico de capítulos por libro
        let chapterCount = getChapterCount(for: book.id)
        
        chapters = (1...chapterCount).map { number in
            Chapter(
                id: "\(book.id).\(number)",
                number: "\(number)",
                reference: "\(book.name) \(number)",
                content: nil
            )
        }
        
        isLoading = false
    }
    
    private func getChapterCount(for bookId: String) -> Int {
        // Número de capítulos por libro (simplificado)
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
        
        return chapterCounts[bookId] ?? 50
    }
}

// MARK: - Chapter Button

struct ChapterButton: View {
    let chapter: Chapter
    
    var body: some View {
        Text(chapter.number)
            .font(.title3.weight(.semibold))
            .foregroundStyle(Color.white)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.twitterBlue, Color.dodgerBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.twitterBlue.opacity(0.3), radius: 4, x: 0, y: 2)
            )
    }
}

#Preview {
    NavigationStack {
        ChaptersView(book: Book(
            id: "GEN",
            name: "Génesis",
            nameLong: "Génesis",
            abbreviation: "Gén",
            chapters: nil
        ))
    }
}
