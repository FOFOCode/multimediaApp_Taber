import SwiftUI

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
    
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var bibleService = BibleService.shared
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
                AppHeaderBar(title: chapter.reference)
                
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
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(verses) { verse in
                                        VerseRow(
                                            verse: verse,
                                            fontSize: fontSize,
                                            lineSpacing: lineSpacing,
                                            theme: readingTheme
                                        )
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
        .onAppear {
            loadChapter()
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                appearAnimation = true
            }
        }
    }
    
    private func loadChapter() {
        Task {
            do {
                let bibleId = bibleService.getBibleForLanguage(localization.currentLanguage)
                let chapterData = try await bibleService.fetchChapter(bibleId: bibleId, chapterId: chapter.id)
                
                await MainActor.run {
                    self.verses = parseVerses(from: chapterData.content)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.verses = [VerseItem(number: "1", text: L10n.errorLoadingChapter.localized())]
                    self.isLoading = false
                }
            }
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
                            verses.append(VerseItem(number: verseNumber, text: verseText))
                        }
                    }
                }
            }
        } catch {
            // Fallback: método simple
            let cleaned = content.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            let text = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                verses.append(VerseItem(number: "1", text: text))
            }
        }
        
        return verses.isEmpty ? [VerseItem(number: "1", text: content)] : verses
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
    let id = UUID()
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
