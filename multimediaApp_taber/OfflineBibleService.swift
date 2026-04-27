import Foundation
import Combine

class OfflineBibleService: ObservableObject {
    static let shared = OfflineBibleService()

    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var downloadedChapters: Set<String> = []
    @Published var lastReadChapter: String?
    @Published var readingProgress: [String: ReadingProgress] = [:]
    @Published var isOfflineMode = false

    private let fileManager = FileManager.default
    private let cacheKey = "cached_bible_chapters"
    private let progressKey = "reading_progress"
    private let lastReadKey = "last_read_chapter"
    private let downloadDateKey = "bible_download_date"

    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadCacheInfo()
        checkNetworkStatus()
    }

    // MARK: - Network Status

    private func checkNetworkStatus() {
        NotificationCenter.default.publisher(for: NSNotification.Name("NetworkStatusChanged"))
            .sink { [weak self] notification in
                if let isConnected = notification.object as? Bool {
                    self?.isOfflineMode = !isConnected
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Cache Directory

    var cacheDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        var cacheDir = paths[0].appendingPathComponent("BibleCache", isDirectory: true)

        if !fileManager.fileExists(atPath: cacheDir.path) {
            do {
                try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
            } catch {
                print("Error creando directorio de caché: \(error)")
            }
        }
        
        // Prevenir constantemente que iCloud respalde este directorio (Requerimiento de App Store Guideline 2.23 para descargas)
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try cacheDir.setResourceValues(resourceValues)
        } catch {}

        return cacheDir
    }

    var chaptersCacheFile: URL {
        cacheDirectory.appendingPathComponent("chapters.json")
    }

    // MARK: - Load/Save Cache Info

    private func loadCacheInfo() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let chapters = try? JSONDecoder().decode(Set<String>.self, from: data) {
            downloadedChapters = chapters
        }

        if let data = UserDefaults.standard.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode([String: ReadingProgress].self, from: data) {
            readingProgress = progress
        }

        lastReadChapter = UserDefaults.standard.string(forKey: lastReadKey)
    }

    private func saveCacheInfo() {
        if let data = try? JSONEncoder().encode(downloadedChapters) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }

        if let data = try? JSONEncoder().encode(readingProgress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }

        if let lastRead = lastReadChapter {
            UserDefaults.standard.set(lastRead, forKey: lastReadKey)
        }
    }

    // MARK: - Download Bible

    func downloadBible(bibleId: String, books: [Book]) async {
        await MainActor.run {
            isDownloading = true
            downloadProgress = 0
        }

        let totalChapters = books.map { $0.computedChapterCount }.reduce(0, +)
        var downloaded = 0

        let bibleService = BibleService.shared

        for book in books {
            let chapterCount = book.computedChapterCount

            for number in 1...chapterCount {
                let chapterId = "\(book.id).\(number)"

                do {
                    let chapterData = try await bibleService.fetchChapter(bibleId: bibleId, chapterId: chapterId)

                    await saveChapterToCache(chapterId: chapterId, content: chapterData.content)

                    await MainActor.run {
                        downloadedChapters.insert(chapterId)
                        downloaded += 1
                        downloadProgress = Double(downloaded) / Double(totalChapters)
                    }
                } catch {
                    print("Error downloading chapter \(chapterId): \(error)")
                }
            }
        }

        UserDefaults.standard.set(Date(), forKey: downloadDateKey)

        await MainActor.run {
            isDownloading = false
        }

        saveCacheInfo()
    }

    private func saveChapterToCache(chapterId: String, content: String) async {
        let fileURL = cacheDirectory.appendingPathComponent("\(chapterId).json")

        if let data = try? JSONEncoder().encode(CachedChapter(id: chapterId, content: content, cachedAt: Date())) {
            try? data.write(to: fileURL)
        }
    }

    // MARK: - Load Chapter Offline

    func loadChapterOffline(chapterId: String) -> CachedChapter? {
        let fileURL = cacheDirectory.appendingPathComponent("\(chapterId).json")

        guard let data = try? Data(contentsOf: fileURL),
              let cached = try? JSONDecoder().decode(CachedChapter.self, from: data) else {
            return nil
        }

        return cached
    }

    func isChapterDownloaded(_ chapterId: String) -> Bool {
        downloadedChapters.contains(chapterId)
    }

    func hasFullBible() -> Bool {
        let minimumChapters = 300
        return downloadedChapters.count >= minimumChapters
    }

    func lastDownloadDate() -> Date? {
        UserDefaults.standard.object(forKey: downloadDateKey) as? Date
    }

    // MARK: - Reading Progress

    func updateReadingProgress(chapterId: String, verse: Int, percentage: Double) {
        if readingProgress[chapterId] == nil {
            readingProgress[chapterId] = ReadingProgress(chapterId: chapterId)
        }

        readingProgress[chapterId]?.currentVerse = verse
        readingProgress[chapterId]?.percentage = percentage
        readingProgress[chapterId]?.lastReadAt = Date()

        lastReadChapter = chapterId
        saveCacheInfo()
    }

    func getReadingProgress(chapterId: String) -> ReadingProgress? {
        readingProgress[chapterId]
    }

    func getContinueReadingChapter() -> String? {
        if let lastRead = lastReadChapter, isChapterDownloaded(lastRead) {
            return lastRead
        }

        let sorted = readingProgress.values.sorted { ($0.lastReadAt ?? Date.distantPast) > ($1.lastReadAt ?? Date.distantPast) }

        for progress in sorted {
            if isChapterDownloaded(progress.chapterId) {
                return progress.chapterId
            }
        }

        return nil
    }

    // MARK: - Clear Cache

    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        downloadedChapters.removeAll()
        readingProgress.removeAll()
        lastReadChapter = nil

        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: lastReadKey)
        UserDefaults.standard.removeObject(forKey: downloadDateKey)
    }

    func cacheSize() -> String {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 MB"
        }

        var totalSize: Int64 = 0

        while let fileURL = enumerator.nextObject() as? URL {
            if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
}

// MARK: - Models

struct CachedChapter: Codable {
    let id: String
    let content: String
    let cachedAt: Date
}

struct ReadingProgress: Codable {
    let chapterId: String
    var currentVerse: Int = 0
    var percentage: Double = 0
    var lastReadAt: Date?

    init(chapterId: String) {
        self.chapterId = chapterId
    }
}