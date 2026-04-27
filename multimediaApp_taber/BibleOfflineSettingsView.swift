import SwiftUI

struct BibleOfflineSettingsView: View {
    @StateObject private var offlineService = OfflineBibleService.shared
    @StateObject private var bibleService = BibleService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPressed = false

    var body: some View {
        ZStack {
            AppBackground(style: .detail)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    downloadSection
                    progressSection
                    cacheInfoSection
                    actionsSection
                }
                .padding(20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if bibleService.books.isEmpty {
                bibleService.loadBibleData(language: LocalizationManager.shared.currentLanguage)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.cobaltBlue.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Circle()
                        .stroke(Color.cobaltBlue.opacity(0.3), lineWidth: 1)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.cobaltBlue)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Biblia Offline")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.cobaltBlue)

                Text("Descarga la Biblia para leer sin conexión")
                    .font(.subheadline)
                    .foregroundStyle(Color.cobaltBlue.opacity(0.78))
            }
            
            Spacer()
        }
    }

    private var downloadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if offlineService.isDownloading {
                downloadingView
            } else if offlineService.hasFullBible() {
                downloadedStatusView
            } else {
                startDownloadView
            }
        }
    }

    private var downloadingView: some View {
        VStack(spacing: 16) {
            HStack {
                ProgressView()
                    .tint(Color.cobaltBlue)

                Text("Descargando...")
                    .font(.headline)
                    .foregroundStyle(Color.cobaltBlue)

                Spacer()

                Text("\(Int(offlineService.downloadProgress * 100))%")
                    .font(.headline)
                    .foregroundStyle(Color.cobaltBlue)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.cobaltBlue.opacity(0.2))

                    Capsule()
                        .fill(Color.cobaltBlue)
                        .frame(width: geo.size.width * offlineService.downloadProgress)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aliceBlue)
        )
    }

    private var downloadedStatusView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("Biblia descargada")
                    .font(.headline)
                    .foregroundStyle(Color.cobaltBlue)

                if let date = offlineService.lastDownloadDate() {
                    Text("Última actualización: \(date.formatted())")
                        .font(.caption)
                        .foregroundStyle(Color.cobaltBlue.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aliceBlue)
        )
    }

    private var startDownloadView: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.cobaltBlue)
                
                Text("Descarga la Biblia completa para leer sin conexión")
                    .font(.subheadline)
                    .foregroundStyle(Color.cobaltBlue.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("\(bibleService.books.count) libros · 66 libros")
                    .font(.caption)
                    .foregroundStyle(Color.cobaltBlue.opacity(0.6))
            }
            
            Button {
                startDownload()
            } label: {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Descargar Biblia")
                }
                .font(.headline)
                .foregroundStyle(Color.aliceBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.cobaltBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(offlineService.isDownloading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aliceBlue)
        )
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progreso de lectura")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.cobaltBlue)

            if let chapter = offlineService.getContinueReadingChapter() {
                HStack {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Color.cobaltBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Continuar leyendo")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.cobaltBlue)

                        Text(chapter)
                            .font(.caption)
                            .foregroundStyle(Color.cobaltBlue.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.cobaltBlue.opacity(0.5))
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.aliceBlue)
                )
            } else {
                Text("No hay progreso guardado")
                    .font(.subheadline)
                    .foregroundStyle(Color.cobaltBlue.opacity(0.6))
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.aliceBlue.opacity(0.5))
                    )
            }
        }
    }

    private var cacheInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Almacenamiento")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.cobaltBlue)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Capítulos descargados")
                        .font(.subheadline)
                        .foregroundStyle(Color.cobaltBlue.opacity(0.8))

                    Text("\(offlineService.downloadedChapters.count)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.cobaltBlue)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Espacio usado")
                        .font(.subheadline)
                        .foregroundStyle(Color.cobaltBlue.opacity(0.8))

                    Text(offlineService.cacheSize())
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.cobaltBlue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.aliceBlue)
            )

            if offlineService.isOfflineMode {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("Modo offline activo")
                }
                .font(.subheadline)
                .foregroundStyle(.orange)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.orange.opacity(0.15))
                )
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                offlineService.clearCache()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Borrar caché")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    private func startDownload() {
        if offlineService.hasFullBible() || offlineService.isDownloading {
            return
        }
        
        offlineService.isDownloading = true

        if bibleService.books.isEmpty {
            bibleService.loadBibleData(language: LocalizationManager.shared.currentLanguage)
            
            Task {
                do {
                    // Try waiting until books load (up to 5s)
                    for _ in 0..<10 {
                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                        let loaded = await MainActor.run { !bibleService.books.isEmpty }
                        if loaded { break }
                    }
                } catch {}
                
                await MainActor.run {
                    if !bibleService.books.isEmpty {
                        let bibleId = bibleService.currentBible?.id ?? bibleService.getBibleForLanguage(LocalizationManager.shared.currentLanguage)
                        Task {
                            await offlineService.downloadBible(bibleId: bibleId, books: bibleService.books)
                        }
                    } else {
                        offlineService.isDownloading = false
                    }
                }
            }
            return
        }

        let bibleId = bibleService.currentBible?.id ?? bibleService.getBibleForLanguage(LocalizationManager.shared.currentLanguage)

        Task {
            await offlineService.downloadBible(bibleId: bibleId, books: bibleService.books)
        }
    }
}

struct BibleOfflineSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BibleOfflineSettingsView()
    }
}