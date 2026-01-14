# 📚 Mejores Prácticas del Proyecto

Esta guía documenta los estándares y prácticas de código seguidas en MultimediaApp Taber.

## 1. Estructura del Código Swift

### 1.1 Orden de Elementos en una Clase/Struct

```swift
import Foundation
import SwiftUI

/// Descripción de la clase
class MinServicio: ObservableObject {
    
    // MARK: - Tipos Internos
    
    enum Estado {
        case cargando
        case completado
        case error
    }
    
    // MARK: - Propiedades Estáticas
    
    static let shared = MinServicio()
    
    // MARK: - Propiedades Publicadas (SwiftUI)
    
    @Published var estado = Estado.completado
    @Published var datos: [String] = []
    
    // MARK: - Propiedades Privadas
    
    private let apiKey = "..."
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inicializadores
    
    private init() {}
    
    // MARK: - Métodos Públicos
    
    func cargarDatos() async throws {
        estado = .cargando
        // ...
    }
    
    // MARK: - Métodos Privados
    
    private func procesarDatos(_ datos: [String]) {
        // ...
    }
}

// MARK: - Extensiones

extension MinServicio {
    // Código adicional relacionado
}
```

### 1.2 Convenciones de Nombramiento

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Clases | PascalCase | `BibleService`, `HomeView` |
| Estructuras | PascalCase | `BibleModels`, `ChapterData` |
| Funciones | camelCase | `fetchChapter()`, `loadData()` |
| Variables | camelCase | `currentBible`, `isLoading` |
| Constantes | camelCase | `apiKey`, `baseURL` |
| Enums | PascalCase | `BibleError`, `ViewState` |
| Enum casos | camelCase | `.invalidURL`, `.networkError` |
| Métodos privados | camelCase | `_processData()`, `_validateInput()` |

### 1.3 Documentación con DocComments

```swift
/// Obtiene un capítulo de la Biblia
///
/// Realiza una solicitud HTTP a la API.Bible y decodifica
/// el contenido del capítulo especificado.
///
/// - Parameters:
///   - bibleId: Identificador único de la Biblia
///   - chapterId: Identificador del capítulo (ej: "GEN.1")
/// - Returns: Objeto con los datos del capítulo
/// - Throws: `BibleError` si la solicitud falla
/// - Complexity: O(n) donde n es el número de versículos
///
/// Ejemplo:
/// ```swift
/// do {
///     let chapter = try await service.fetchChapter(
///         bibleId: "123",
///         chapterId: "GEN.1"
///     )
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
func fetchChapter(bibleId: String, chapterId: String) async throws -> Chapter {
    // Implementación
}
```

## 2. SwiftUI Best Practices

### 2.1 Estructura de Vistas

```swift
struct MinVista: View {
    // MARK: - @State y @StateObject
    
    @State private var contador = 0
    @StateObject private var viewModel = MinViewModel()
    
    // MARK: - Propiedades Locales
    
    private var esMayorQueCinco: Bool {
        contador > 5
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Contenido principal
        }
        .onAppear {
            cargarDatos()
        }
    }
    
    // MARK: - Subvistas
    
    @ViewBuilder
    private var encabezado: some View {
        HStack {
            // ...
        }
    }
    
    // MARK: - Métodos Privados
    
    private func cargarDatos() {
        // ...
    }
}
```

### 2.2 Reactividad con @Published

```swift
class ViewModel: ObservableObject {
    // ✅ CORRECTO: Usa @Published para cambios que afecten la UI
    @Published var titulo: String = ""
    @Published var isLoading = false
    @Published var items: [Item] = []
    
    // ❌ INCORRECTO: No uses @Published para propiedades privadas
    private var contador = 0  // Esto está bien
}
```

### 2.3 Evitar Memory Leaks con @StateObject

```swift
// ✅ CORRECTO: Crea el observable en el padre
struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    
    var body: some View {
        BibleView()
            .environmentObject(viewModel)
    }
}

// ❌ INCORRECTO: Recrear cada vez
struct ContentView: View {
    var body: some View {
        BibleView()
            .environmentObject(BibleViewModel())  // Crea instancia nueva cada render
    }
}
```

## 3. Async/Await Patterns

### 3.1 Manejo de Tareas Asincrónicas

```swift
class BibleViewModel: ObservableObject {
    @Published var capitulo: Chapter?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func cargarCapitulo(id: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let cap = try await BibleService.shared.fetchChapter(id: id)
                
                await MainActor.run {
                    self.capitulo = cap
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
```

### 3.2 Usar @MainActor cuando sea necesario

```swift
// ✅ CORRECTO: Actualizar UI en MainActor
@MainActor
class ViewModel: ObservableObject {
    @Published var datos: String = ""
    
    func cargar() async {
        let resultado = await fetchDatos()
        self.datos = resultado  // Ya estamos en MainActor
    }
}

// O actualizar específicamente en MainActor
await MainActor.run {
    self.datos = resultado
}
```

## 4. Gestión de Errores

### 4.1 Crear Errores Descriptivos

```swift
enum MiError: LocalizedError {
    case invalidInput(String)
    case networkError(Error)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let campo):
            return "El campo \(campo) es inválido"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .decodingError:
            return "No se pudieron procesar los datos"
        }
    }
}
```

### 4.2 Manejar Errores de Red

```swift
func fetchData() async throws -> Data {
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return data
        case 401:
            throw AppError.unauthorized
        case 404:
            throw AppError.notFound
        default:
            throw AppError.unknownError(httpResponse.statusCode)
        }
    } catch {
        throw AppError.networkError(error)
    }
}
```

## 5. Testing

### 5.1 Estructura de Tests

```swift
import XCTest

final class BibleServiceTests: XCTestCase {
    
    var sut: BibleService!  // sut = System Under Test
    
    override func setUp() {
        super.setUp()
        sut = BibleService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_fetchBooks_withValidId_returnsBooks() async throws {
        // Arrange
        let bibleId = "592420522e16049f-01"
        
        // Act
        let books = try await sut.fetchBooks(bibleId: bibleId)
        
        // Assert
        XCTAssertFalse(books.isEmpty)
    }
}
```

### 5.2 Naming de Tests

```swift
// ✅ CORRECTO: Describe qué se prueba
func test_fetchBooks_withValidId_returnsBooks() { }

// ❌ INCORRECTO: Nombre ambiguo
func test_fetchBooks() { }

// Patrón: test_<método>_<condición>_<resultado>
```

## 6. Performance

### 6.1 Evitar Re-renders Innecesarios

```swift
// ✅ CORRECTO: Extrae subvistas para evitar re-renders
struct ParentView: View {
    @State var contador = 0
    
    var body: some View {
        VStack {
            Contador(contador: $contador)
            ItemListaQueSoloActualizaQueCambia()
        }
    }
}

// ❌ INCORRECTO: Todo se re-renderiza
struct ParentView: View {
    @State var contador = 0
    
    var body: some View {
        VStack {
            Text("\(contador)")
            List {
                // Esta lista se re-renderiza cada vez que contador cambia
            }
        }
    }
}
```

### 6.2 Lazy Loading

```swift
struct ListaGrande: View {
    @State var items: [Item] = []
    
    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                ItemRow(item: item)
                    .onAppear {
                        cargarMasItems()
                    }
            }
        }
    }
}
```

## 7. Seguridad

### 7.1 Gestión de Secretos

```swift
// ❌ NUNCA hagas esto
private let apiKey = "sk_live_abc123xyz"

// ✅ CORRECTO: Usa variables de entorno o configuración externa
// En Build Phases, agrega un script que lea desde archivo de configuración
private let apiKey = Configuration.apiKey
```

### 7.2 Validación de Entrada

```swift
func validarEmail(_ email: String) -> Bool {
    let patron = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let regex = try? NSRegularExpression(pattern: patron)
    let rango = NSRange(email.startIndex..., in: email)
    return regex?.firstMatch(in: email, range: rango) != nil
}
```

## 8. Localización

### 8.1 Usar Claves Consistentes

```swift
// ✅ CORRECTO: Usa la enumeración L10n
Text(L10n.appName.localized())
Text(L10n.bibleTitle.localized())

// ❌ INCORRECTO: Strings directos sin la enumeración
Text("app_name".localized())
```

### 8.2 Agregar Nuevas Traducciones

1. Agrega la clave en `LocalizationManager.swift` enum
2. Abre `Localizable.xcstrings`
3. Agrega la traducción en cada idioma
4. Usa la clave mediante `L10n`

## 9. Git Workflow

### 9.1 Mensajes de Commit

```bash
# ✅ CORRECTO
git commit -m "Agregar búsqueda en versículos de la Biblia"
git commit -m "Corregir error de carga de capítulos"
git commit -m "Mejorar UI de BibleView"

# ❌ INCORRECTO
git commit -m "fix"
git commit -m "update"
git commit -m "wip"
```

### 9.2 Ramas

```bash
# Crear rama para nueva feature
git checkout -b feature/nombre-feature

# Crear rama para corregir bug
git checkout -b bugfix/descripcion-bug

# Crear rama para mejorar código
git checkout -b refactor/descripcion
```

## 10. Checklist Antes de Hacer Commit

- [ ] El código compila sin errores
- [ ] No hay warnings nuevos
- [ ] Los tests pasan
- [ ] El código sigue las convenciones de estilo
- [ ] Agregué comentarios en funciones complejas
- [ ] Las funciones públicas tienen documentación
- [ ] No hay código comentado sin razón
- [ ] No hay API Keys o secretos en el código
- [ ] El mensaje de commit es descriptivo

---

Sigue estas prácticas para mantener el código limpio, mantenible y profesional. 🚀
