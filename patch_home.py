import re

file_path = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/HomeDashboardService.swift"

with open(file_path, "r") as f:
    text = f.read()

old_block = """    private func queryForToday(languageCode: String) -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1

        let spanishQueries = ["esperanza", "amor", "fe", "gracia", "paz", "fortaleza", "misericordia"]
        let englishQueries = ["hope", "love", "faith", "grace", "peace", "strength", "mercy"]
        let portugueseQueries = ["esperança", "amor", "fé", "graça", "paz", "força", "misericórdia"]
        let frenchQueries = ["espérance", "amour", "foi", "grâce", "paix", "force", "miséricorde"]

        let source: [String]
        switch languageCode {
        case "en": source = englishQueries
        case "pt": source = portugueseQueries
        case "fr": source = frenchQueries
        default: source = spanishQueries
        }
        
        return source[day % source.count]
    }

    private func pickVerse(for date: Date, from results: [SearchAPIResponse.VerseResult]) -> SearchAPIResponse.VerseResult? {
        guard !results.isEmpty else { return nil }
        let day = Calendar.current.component(.day, from: date)
        let index = day % results.count
        return results[index]
    }"""

new_block = """    private func verseIdForToday() -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        let dailyVerses = [
            "JHN.3.16", "PSA.23.1", "PHP.4.13", "ROM.8.28", "PRO.3.5",
            "ISA.41.10", "JER.29.11", "MAT.6.33", "HEB.11.1", "1COR.13.4",
            "JAM.1.2", "1PET.5.7", "1JN.5.7", "1TH.5.7" // Some common ones
        ]
        
        let index = (day - 1) % dailyVerses.count
        return dailyVerses[index]
    }"""

text = text.replace(old_block, new_block)

with open(file_path, "w") as f:
    f.write(text)
print("done")
