import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var favoritesService = FavoritesService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: "Mis Favoritos")
                
                if favoritesService.favorites.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.twitterBlue.opacity(0.5))
                        
                        Text("No tienes favoritos")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.cobaltBlue)
                        
                        Text("Agrega capítulos o versículos para verlos aquí.")
                            .font(.subheadline)
                            .foregroundStyle(Color.twitterBlue.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(favoritesService.favorites) { favorite in
                            NavigationLink(destination: ReaderView(
                                bookName: favorite.bookName,
                                chapter: createChapter(from: favorite)
                            )) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(favorite.bookName)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Color.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.cobaltBlue)
                                            .clipShape(Capsule())
                                        
                                        Spacer()
                                        
                                        Text(favorite.reference)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.twitterBlue)
                                    }
                                    
                                    Text(favorite.text)
                                        .font(.body)
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                        .foregroundStyle(Color.primary)
                                    
                                    Text(favorite.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(Color.secondary.opacity(0.7))
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .onDelete(perform: deleteFavorite)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func createChapter(from favorite: FavoriteVerse) -> Chapter {
        let parts = favorite.id.split(separator: ".")
        let chapterId = parts.count >= 2 ? "\(parts[0]).\(parts[1])" : favorite.id
        let chapterNumber = parts.count >= 2 ? String(parts[1]) : "1"
        return Chapter(id: String(chapterId), number: chapterNumber, reference: "\(favorite.bookName) \(chapterNumber)", content: nil)
    }
    
    private func deleteFavorite(at offsets: IndexSet) {
        offsets.forEach { index in
            let fav = favoritesService.favorites[index]
            favoritesService.removeFavorite(id: fav.id)
        }
    }
}
