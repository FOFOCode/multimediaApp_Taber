import SwiftUI
import SwiftData

// MARK: - Reading Theme

enum ReadingTheme: String, CaseIterable {
    case light = "Claro"
    case sepia = "Sepia"
    case dark = "Oscuro"
    
    var backgroundColor: Color {
        switch self {
        case .light: return Color.white
        case .sepia: return Color(red: 0.98, green: 0.96, blue: 0.90)
        case .dark: return Color(red: 0.12, green: 0.12, blue: 0.14)
        }
    }
    
    var textColor: Color {
        switch self {
        case .light: return Color.black
        case .sepia: return Color(red: 0.25, green: 0.22, blue: 0.18)
        case .dark: return Color(red: 0.92, green: 0.92, blue: 0.95)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .light: return Color.twitterBlue
        case .sepia: return Color(red: 0.65, green: 0.45, blue: 0.25)
        case .dark: return Color(red: 0.4, green: 0.7, blue: 1.0)
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .sepia: return "book.fill"
        case .dark: return "moon.fill"
        }
    }
}

struct ReaderView: View {
    let bookName: String
    let chapter: Chapter
    
    @ObservedObject private var localization = LocalizationManager.shared
    @ObservedObject private var bibleService = BibleService.shared
    @ObservedObject private var offlineService = OfflineBibleService.shared
    @ObservedObject private var favoritesService = FavoritesService.shared
    
    @Environment(\.modelContext) private var modelContext
    @Query private var studyData: [VerseStudyData]
    @State private var selectedVerseForNote: String?
    @State private var noteDraft: String = ""
    
    @State private var appearAnimation = false
    @State private var verses: [VerseItem] = []
    @State private var isLoading = true
    @State private var fontSize: CGFloat = 18
    @State private var showControls = false
    @State private var lineSpacing: CGFloat = 8
    @State private var readingTheme: ReadingTheme = .light
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(
                    title: chapter.reference,
                    trailingButton: AnyView(
                        Button {
                            // Añadimos vibración sutil para feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                let isFav = favoritesService.isFavorite(id: chapter.id)
                                if isFav {
                                    favoritesService.removeFavorite(id: chapter.id)
                                } else {
                                    let previewText = verses.prefix(3).map { $0.text }.joined(separator: " ")
                                    favoritesService.addFavorite(
                                        id: chapter.id,
                                        reference: chapter.reference,
                                        text: previewText.isEmpty ? L10n.chapter.localized() : previewText + "...",
                                        bookName: bookName
                                    )
                                }
                            }
                        } label: {
                            Image(systemName: favoritesService.isFavorite(id: chapter.id) ? "heart.fill" : "heart")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(favoritesService.isFavorite(id: chapter.id) ? Color.red : Color.cobaltBlue)
                                .frame(width: 44, height: 44)
                                .accessibilityLabel("Favorito")
                        }
                    )
                )
                
                ZStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Referencia del capítulo
                            VStack(spacing: 8) {
                                Text(bookName)
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color.cobaltBlue)
                                
                                Text(L10n.chapter.localized() + " " + chapter.number)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.twitterBlue.opacity(0.7))
                            }
                            .padding(.top, 20)
                            .opacity(appearAnimation ? 1 : 0)
                            
                            // Contenido del capítulo
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding(40)
                            } else {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(verses) { verse in
                                        let studyItem = getStudyData(for: verse.id)
                                        let isHighlighted = studyItem?.highlightColor != nil
                                        let hasNote = studyItem?.noteText != nil
                                        
                                        VerseRow(
                                            verse: verse,
                                            fontSize: fontSize,
                                            lineSpacing: lineSpacing,
                                            theme: readingTheme
                                        )
                                        .background(isHighlighted ? Color.yellow.opacity(0.3) : Color.clear)
                                        .overlay(alignment: .topTrailing) {
                                            if hasNote {
                                                Image(systemName: "note.text")
                                                    .foregroundColor(readingTheme.accentColor)
                                                    .padding(.top, 8)
                                            }
                                        }
                                        .contextMenu {
                                            Button {
                                                toggleHighlight(for: verse)
                                            } label: {
                                                Label(isHighlighted ? "Quitar Resaltado" : "Resaltar", systemImage: "highlighter")
                                            }
                                            
                                            Button {
                                                let isFav = favoritesService.isFavorite(id: verse.id)
                                                if isFav {
                                                    favoritesService.removeFavorite(id: verse.id)
                                                } else {
                                                    favoritesService.addFavorite(
                                                        id: verse.id,
                                                        reference: "\(chapter.reference):\(verse.number)",
                                                        text: verse.text,
                                                        bookName: bookName
                                                    )
                                                }
                                            } label: {
                                                let isFav = favoritesService.isFavorite(id: verse.id)
                                                Label(isFav ? "Quitar de Favoritos" : "Marcar Favorito", systemImage: isFav ? "heart.fill" : "heart")
                                            }
                                            
                                            Button {
                                                selectedVerseForNote = verse.id
                                                noteDraft = studyItem?.noteText ?? ""
                                            } label: {
                                                Label(hasNote ? "Editar Nota" : "Agregar Nota", systemImage: "pencil")
                                            }
                                        }
                                    }
                                }
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(readingTheme.backgroundColor)
                                        .shadow(color: Color.black.opacity(readingTheme == .dark ? 0.3 : 0.08), radius: 8, x: 0, y: 4)
                                )
                                .padding(.horizontal, 16)
                                .opacity(appearAnimation ? 1 : 0)
                            }
                        }
                        .padding(.bottom, 100) // Espacio para los controles
                    }
                    
                    // Controles flotantes
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 16) {
                            // Tamaño de fuente
                            Button {
                                withAnimation {
                                    showControls.toggle()
                                }
                            } label: {
                                Image(systemName: "textformat.size")
                                    .font(.title3)
                                    .foregroundStyle(Color.white)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(Color.twitterBlue)
                                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    )
                            }
                            
                            Spacer()
                            
                            // Botón de tema
                            Button {
                                withAnimation {
                                    cycleTheme()
                                }
                            } label: {
                                Image(systemName: readingTheme.icon)
                                    .font(.title3)
                                    .foregroundStyle(Color.white)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(readingTheme.accentColor)
                                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    
                    // Panel de controles
                    if showControls {
                        VStack {
                            Spacer()
                            
                            VStack(spacing: 20) {
                                Text(L10n.fontSize.localized())
                                    .font(.headline)
                                    .foregroundStyle(Color.cobaltBlue)
                                
                                HStack(spacing: 20) {
                                    Button {
                                        if fontSize > 14 {
                                            fontSize -= 2
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.twitterBlue)
                                    }
                                    
                                    Text("\(Int(fontSize))")
                                        .font(.title2.weight(.bold))
                                        .foregroundStyle(Color.cobaltBlue)
                                        .frame(minWidth: 50)
                                    
                                    Button {
                                        if fontSize < 32 {
                                            fontSize += 2
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.twitterBlue)
                                    }
                                }
                                
                                Button {
                                    withAnimation {
                                        showControls = false
                                    }
                                } label: {
                                    Text(L10n.done.localized())
                                        .font(.headline)
                                        .foregroundStyle(Color.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(Color.twitterBlue)
                                        )
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: -4)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        .background(
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation {
                                        showControls = false
                                    }
                                }
                        )
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: Binding<Bool>(
            get: { selectedVerseForNote != nil },
            set: { if !$0 { selectedVerseForNote = nil } }
        )) {
            NavigationStack {
                TextEditor(text: $noteDraft)
                    .padding()
                    .navigationTitle("Nota al Versículo")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                selectedVerseForNote = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                if let verseId = selectedVerseForNote {
                                    saveNote(for: verseId, text: noteDraft)
                                }
                                selectedVerseForNote = nil
                            }
                        }
                    }
            }
        }
        .onAppear {
            loadChapter()
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                appearAnimation = true
            }
        }
    }
    
    private func loadChapter() {
        if let cached = offlineService.loadChapterOffline(chapterId: chapter.id) {
            verses = parseVerses(from: cached.content)
            isLoading = false
            saveReadingProgress()
            return
        }
        
        Task {
            do {
                let bibleId = bibleService.getBibleForLanguage(localization.currentLanguage)
                let chapterData = try await bibleService.fetchChapter(bibleId: bibleId, chapterId: chapter.id)
                
                await MainActor.run {
                    self.verses = parseVerses(from: chapterData.content)
                    self.isLoading = false
                }
                saveReadingProgress()
            } catch {
                if let cached = offlineService.loadChapterOffline(chapterId: chapter.id) {
                    await MainActor.run {
                        self.verses = parseVerses(from: cached.content)
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.verses = [VerseItem(id: "\(chapter.id).error", number: "1", text: L10n.errorLoadingChapter.localized())]
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func saveReadingProgress() {
        let progress = Double(verses.count) > 0 ? 0.5 : 0.0
        offlineService.updateReadingProgress(chapterId: chapter.id, verse: verses.count, percentage: progress)
    }
    
    // MARK: - Study Tools Helpers
    
    private func getStudyData(for verseId: String) -> VerseStudyData? {
        let currentBibleId = bibleService.getBibleForLanguage(localization.currentLanguage)
        let uniqueId = "\(currentBibleId)-\(verseId)"
        return studyData.first(where: { $0.id == uniqueId })
    }
    
    private func toggleHighlight(for verse: VerseItem) {
        let currentBibleId = bibleService.getBibleForLanguage(localization.currentLanguage)
        let uniqueId = "\(currentBibleId)-\(verse.id)"
        
        if let existing = getStudyData(for: verse.id) {
            existing.highlightColor = existing.highlightColor == nil ? "yellow" : nil
            existing.updatedAt = Date()
        } else {
            let newData = VerseStudyData(
                id: uniqueId,
                bibleId: currentBibleId,
                bookId: String(verse.id.split(separator: ".").first ?? ""),
                chapterId: chapter.id,
                verseId: verse.id,
                highlightColor: "yellow"
            )
            modelContext.insert(newData)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save highlight: \(error)")
        }
    }
    
    private func saveNote(for verseId: String, text: String) {
        let currentBibleId = bibleService.getBibleForLanguage(localization.currentLanguage)
        let uniqueId = "\(currentBibleId)-\(verseId)"
        
        // Remove empty strings fully
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existing = getStudyData(for: verseId) {
            existing.noteText = trimmed.isEmpty ? nil : trimmed
            existing.updatedAt = Date()
        } else {
            let newData = VerseStudyData(
                id: uniqueId,
                bibleId: currentBibleId,
                bookId: String(verseId.split(separator: ".").first ?? ""),
                chapterId: chapter.id,
                verseId: verseId,
                noteText: trimmed.isEmpty ? nil : trimmed
            )
            modelContext.insert(newData)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save note: \(error)")
        }
    }
    
    private func parseVerses(from content: String) -> [VerseItem] {
        var verses: [VerseItem] = []
        
        // Patrón más específico para extraer versículos con sus números
        // La API devuelve algo como: <span class="v">1</span>texto<span class="v">2</span>texto
        let pattern = #"<span[^>]*class="v"[^>]*>(\d+)</span>\s*([^<]*(?:<(?!span[^>]*class="v")[^>]*>[^<]*</[^>]*>)*[^<]*)"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = content as NSString
            let results = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in results {
                if match.numberOfRanges == 3 {
                    let numberRange = match.range(at: 1)
                    let textRange = match.range(at: 2)
                    
                    if let number = Range(numberRange, in: content),
                       let textR = Range(textRange, in: content) {
                        let verseNumber = String(content[number])
                        var verseText = String(content[textR])
                        
                        // Limpiar HTML restante
                        verseText = verseText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                        verseText = verseText.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression)
                        verseText = verseText.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !verseText.isEmpty {
                            verses.append(VerseItem(id: "\(chapter.id).\(verseNumber)", number: verseNumber, text: verseText))
                        }
                    }
                }
            }
        } catch {
            // Fallback: método simple
            let cleaned = content.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            let text = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                verses.append(VerseItem(id: "\(chapter.id).1", number: "1", text: text))
            }
        }
        
        return verses.isEmpty ? [VerseItem(id: "\(chapter.id).1", number: "1", text: content)] : verses
    }
    
    private func cycleTheme() {
        let themes: [ReadingTheme] = [.light, .sepia, .dark]
        if let currentIndex = themes.firstIndex(of: readingTheme) {
            let nextIndex = (currentIndex + 1) % themes.count
            readingTheme = themes[nextIndex]
        }
    }
}

// MARK: - Verse Item Model

struct VerseItem: Identifiable {
    let id: String
    let number: String
    let text: String
}

// MARK: - Verse Row

struct VerseRow: View {
    let verse: VerseItem
    let fontSize: CGFloat
    let lineSpacing: CGFloat
    let theme: ReadingTheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Número del versículo
            Text(verse.number)
                .font(.system(size: fontSize - 2, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accentColor)
                .frame(minWidth: 28, alignment: .trailing)
                .padding(.top, 3)
            
            // Texto del versículo
            Text(verse.text)
                .font(.system(size: fontSize, weight: .regular, design: .default))
                .foregroundStyle(theme.textColor)
                .lineSpacing(lineSpacing)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        ReaderView(
            bookName: "Génesis",
            chapter: Chapter(
                id: "GEN.1",
                number: "1",
                reference: "Génesis 1",
                content: nil
            )
        )
    }
}
