import SwiftUI

struct BibleView: View {
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var bibleService = BibleService.shared
    @StateObject private var favoritesService = FavoritesService.shared
    @State private var appearAnimation = false
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showingSearch = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: L10n.bibleTitle.localized())
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Encabezado
                        VStack(spacing: 12) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.cobaltBlue, Color.twitterBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolEffect(.pulse)
                            
                            Text(L10n.bibleTitle.localized())
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.cobaltBlue)
                            
                            Text(L10n.bibleSubtitle.localized())
                                .font(.subheadline)
                                .foregroundStyle(Color.twitterBlue.opacity(0.7))
                        }
                        .padding(.top, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : -20)
                        
                        // Tabs
                        Picker("", selection: $selectedTab) {
                            Text(L10n.books.localized()).tag(0)
                            Text(L10n.search.localized()).tag(1)
                            Text(L10n.favorites.localized()).tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        
                        // Contenido según tab seleccionado
                        Group {
                            if selectedTab == 0 {
                                BooksListView()
                            } else if selectedTab == 1 {
                                SearchView()
                            } else {
                                FavoritesListView()
                            }
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.spring(response: 0.5), value: selectedTab)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Cargar libros de la Biblia según el idioma actual
            bibleService.loadBibleData(language: localization.currentLanguage)
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
        .onChange(of: localization.currentLanguage) { newLanguage in
            // Recargar cuando cambia el idioma
            bibleService.loadBibleData(language: newLanguage)
        }
    }
}

// MARK: - Books List View

struct BooksListView: View {
    @StateObject private var bibleService = BibleService.shared
    @StateObject private var localization = LocalizationManager.shared
    
    var oldTestament: [Book] {
        Array(bibleService.books.prefix(39))
    }
    
    var newTestament: [Book] {
        Array(bibleService.books.dropFirst(39))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if bibleService.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(40)
            } else if let error = bibleService.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.red)
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                VStack(spacing: 24) {
                    // Antiguo Testamento
                    if !oldTestament.isEmpty {
                        BooksSectionView(
                            title: L10n.oldTestament.localized(),
                            books: oldTestament,
                            color: .twitterBlue
                        )
                    }
                    
                    // Nuevo Testamento
                    if !newTestament.isEmpty {
                        BooksSectionView(
                            title: L10n.newTestament.localized(),
                            books: newTestament,
                            color: .dodgerBlue
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Books Section View

struct BooksSectionView: View {
    let title: String
    let books: [Book]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(books) { book in
                    NavigationLink(destination: ChaptersView(book: book)) {
                        BookCard(book: book, color: color)
                    }
                }
            }
        }
    }
}

// MARK: - Book Card

struct BookCard: View {
    let book: Book
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .font(.title3)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            Text(book.name)
                .font(.headline)
                .foregroundStyle(Color.cobaltBlue)
                .lineLimit(2)
            
            Text(book.abbreviation)
                .font(.caption)
                .foregroundStyle(Color.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Search View

struct SearchView: View {
    @StateObject private var bibleService = BibleService.shared
    @StateObject private var localization = LocalizationManager.shared
    @State private var searchText = ""
    @State private var searchResults: [SearchAPIResponse.VerseResult] = []
    @State private var isSearching = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Campo de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
                
                TextField(L10n.searchPlaceholder.localized(), text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 20)
            
            if isSearching {
                ProgressView()
                    .padding(40)
            } else if searchResults.isEmpty && !searchText.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.gray.opacity(0.5))
                    Text(L10n.noResults.localized())
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                }
                .padding(40)
            } else if !searchResults.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(searchResults, id: \.id) { result in
                            SearchResultCard(result: result)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.twitterBlue.opacity(0.5))
                    Text(L10n.searchPrompt.localized())
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        Task {
            do {
                let bibleId = bibleService.getBibleForLanguage(localization.currentLanguage)
                let results = try await bibleService.searchVerses(bibleId: bibleId, query: searchText)
                
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                }
            }
        }
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let result: SearchAPIResponse.VerseResult
    @StateObject private var favoritesService = FavoritesService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.reference)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.twitterBlue)
                
                Spacer()
                
                Button {
                    favoritesService.toggleFavorite(
                        id: result.id,
                        reference: result.reference,
                        text: result.text,
                        bookName: result.bookId
                    )
                } label: {
                    Image(systemName: favoritesService.isFavorite(id: result.id) ? "heart.fill" : "heart")
                        .foregroundStyle(favoritesService.isFavorite(id: result.id) ? Color.red : Color.gray)
                }
            }
            
            Text(cleanHTMLTags(from: result.text))
                .font(.body)
                .foregroundStyle(Color.primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
    
    private func cleanHTMLTags(from text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

// MARK: - Favorites List View

struct FavoritesListView: View {
    @StateObject private var favoritesService = FavoritesService.shared
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            if favoritesService.favorites.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.gray.opacity(0.5))
                    Text(L10n.noFavorites.localized())
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(favoritesService.favorites) { favorite in
                            FavoriteCard(favorite: favorite)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Favorite Card

struct FavoriteCard: View {
    let favorite: FavoriteVerse
    @StateObject private var favoritesService = FavoritesService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.reference)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.twitterBlue)
                    
                    Text(favorite.bookName)
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
                
                Button {
                    favoritesService.removeFavorite(id: favorite.id)
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color.red)
                }
            }
            
            Text(favorite.text)
                .font(.body)
                .foregroundStyle(Color.primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    NavigationStack {
        BibleView()
    }
}
