import SwiftUI

struct ChaptersView: View {
    let book: Book
    @ObservedObject private var localization = LocalizationManager.shared
    @ObservedObject private var bibleService = BibleService.shared
    @ObservedObject private var offlineService = OfflineBibleService.shared
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
        let chapterCount = book.computedChapterCount
        
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
}

// MARK: - Chapter Button

struct ChapterButton: View {
    let chapter: Chapter
    @ObservedObject private var offlineService = OfflineBibleService.shared
    
    var body: some View {
        ZStack {
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
            
            if offlineService.isChapterDownloaded(chapter.id) {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                            .background(Circle().fill(Color.white).frame(width: 10, height: 10))
                    }
                    Spacer()
                }
                .frame(width: 60, height: 60)
            }
        }
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
