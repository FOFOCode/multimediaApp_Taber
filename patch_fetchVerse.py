import re

file_path = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/BibleService.swift"

with open(file_path, "r") as f:
    text = f.read()

new_func = """
    func fetchVerse(bibleId: String, verseId: String) async throws -> SearchAPIResponse.VerseResult {
        guard apiKey != "TU_API_KEY_AQUI" && !apiKey.isEmpty else {
            throw BibleError.apiKeyNotConfigured
        }
        
        let urlString = "\\(baseURL)/bibles/\\(bibleId)/verses/\\(verseId)?content-type=text&include-notes=false&include-titles=false&include-chapter-numbers=false&include-verse-numbers=false&include-verse-spans=false"
        
        guard let url = URL(string: urlString) else {
            throw BibleError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BibleError.invalidResponse("No se pudo obtener respuesta del servidor")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw BibleError.invalidResponse("Código \\(httpResponse.statusCode)")
        }
        
        let decodedResponse = try JSONDecoder().decode(colocateVerseAPIResponse.self, from: data)
        return decodedResponse.data
    }
"""

new_func = new_func.replace("colocateVerseAPIResponse", "VerseAPIResponse")

# find line: func searchVerses(bibleId: String, query: String) async throws -> [SearchAPIResponse.VerseResult] {
index = text.find("    func searchVerses")
if index != -1:
    text = text[:index] + new_func + "\n" + text[index:]
    with open(file_path, "w") as f:
        f.write(text)
    print("Success")
else:
    print("Not found")

