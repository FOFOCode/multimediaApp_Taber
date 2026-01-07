import SwiftUI
import SafariServices

struct YouTubeView: View {
    @StateObject private var youtubeService = YouTubeService()
    @StateObject private var localization = LocalizationManager.shared
    @State private var selectedCategory: YouTubeCategory = .himnos
    @State private var showSafari = false
    @State private var selectedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Atrás")
                                .font(.body.weight(.medium))
                        }
                        .foregroundStyle(Color.aliceBlue)
                    }
                    
                    Spacer()
                    
                    Text("YouTube")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.aliceBlue)
                    
                    Spacer()
                    
                    // Espacio para simetría
                    Color.clear.frame(width: 60)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(YouTubeCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                                Task {
                                    await youtubeService.searchByCategory(category)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(Color.black.opacity(0.1))
                
                // Content
                if let errorMessage = youtubeService.errorMessage {
                    ErrorView(message: errorMessage)
                } else if youtubeService.isLoading {
                    LoadingView()
                } else if youtubeService.videos.isEmpty {
                    EmptyStateView(category: selectedCategory)
                } else {
                    VideoListView(
                        videos: youtubeService.videos,
                        onVideoTap: { video in
                            if let url = youtubeService.getVideoURL(videoId: video.videoId) {
                                selectedVideoURL = url
                                showSafari = true
                            }
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSafari) {
            if let url = selectedVideoURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .task {
            await youtubeService.searchByCategory(selectedCategory)
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: YouTubeCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(category.rawValue)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? Color.white : Color.aliceBlue)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.dodgerBlue : Color.white.opacity(0.15))
                    .shadow(color: isSelected ? Color.dodgerBlue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Video List
struct VideoListView: View {
    let videos: [YouTubeVideo]
    let onVideoTap: (YouTubeVideo) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(videos) { video in
                    VideoCard(video: video) {
                        onVideoTap(video)
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Video Card
struct VideoCard: View {
    let video: YouTubeVideo
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Thumbnail
                AsyncImage(url: video.thumbnailImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    // Play button overlay
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.white)
                    }
                )
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(video.title)
                        .font(.headline)
                        .foregroundStyle(Color.aliceBlue)
                        .lineLimit(2)
                    
                    Text(video.channelTitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.aliceBlue.opacity(0.7))
                    
                    Text(video.description)
                        .font(.caption)
                        .foregroundStyle(Color.aliceBlue.opacity(0.6))
                        .lineLimit(2)
                }
                .padding(.horizontal, 4)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
            
            Text("Cargando videos...")
                .font(.headline)
                .foregroundStyle(Color.aliceBlue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.yellow)
                
                Text("Error")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.aliceBlue)
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(Color.aliceBlue.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 60)
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let category: YouTubeCategory
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.system(size: 60))
                .foregroundStyle(Color.aliceBlue.opacity(0.5))
            
            Text("No hay videos")
                .font(.headline)
                .foregroundStyle(Color.aliceBlue)
            
            Text("No se encontraron videos en esta categoría")
                .font(.subheadline)
                .foregroundStyle(Color.aliceBlue.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        return SFSafariViewController(url: url, configuration: config)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    YouTubeView()
}
