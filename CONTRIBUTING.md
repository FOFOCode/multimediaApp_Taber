# 🤝 Guía de Contribución

¡Agradecemos tu interés en contribuir a MultimediaApp Taber! Esta guía te ayudará a entender nuestro proceso de desarrollo.

## Código de Conducta

Este proyecto adhiere a un Código de Conducta que esperamos que todos los contribuyentes respeten.

### Nuestro Compromiso

Estamos comprometidos a proporcionar un entorno abierto y acogedor para todos, independientemente de:

- Edad, tamaño corporal, discapacidad visible o invisible
- Etnicidad, identidad y expresión de género
- Nivel de experiencia
- Nacionalidad, identidad personal
- Raza, religión
- Sexo, identidad sexual u orientación

## Cómo Contribuir

### Reportar Bugs

Los bugs se reportan mediante GitHub Issues. Antes de crear un reporte, por favor:

1. **Verifica el registro de problemas** para asegurar que el bug no ha sido reportado
2. **Describe el problema exacto** incluyendo pasos para reproducirlo
3. **Proporciona ejemplos específicos** para demonstrar los pasos
4. **Describe el comportamiento observado** y lo que esperabas ver
5. **Incluye capturas de pantalla** si es posible
6. **Menciona tu entorno**: iOS version, Xcode version, dispositivo

```
Título: Resumen breve del problema

Descripción:
- Pasos para reproducir
- Comportamiento esperado
- Comportamiento actual
- Capturas de pantalla (opcional)

Entorno:
- iOS: [versión]
- Xcode: [versión]
- Dispositivo: [modelo]
```

### Sugerir Mejoras

Las sugerencias de mejora también se rastrean mediante GitHub Issues. Al crear una sugerencia, incluye:

- **Caso de uso** claro y detallado
- **Ejemplo específico** del comportamiento actual
- **Por qué crees que sería una mejora**
- **Posible alternativa** (si es aplicable)

### Pull Requests

1. **Fork el repositorio** y crea tu rama desde `main`

   ```bash
   git checkout -b feature/mi-feature
   ```

2. **Haz cambios significativos**

   - Asegúrate de que el código siga las convenciones del proyecto
   - Añade comentarios donde sea necesario

3. **Escribe mensajes de commit claros**

   ```bash
   git commit -m "Agregar nueva funcionalidad de búsqueda"
   ```

4. **Empuja a tu fork**

   ```bash
   git push origin feature/mi-feature
   ```

5. **Abre un Pull Request**
   - Describe los cambios realizados
   - Referencia cualquier issue relacionado (#123)
   - Proporciona detalles sobre cómo probar los cambios

## Convenciones de Código

### Swift Style Guide

Seguimos las convenciones estándar de Swift:

```swift
// ✅ CORRECTO
class BibleService {
    func fetchChapter(bibleId: String, chapterId: String) async throws -> ChapterData {
        // Implementación
    }
}

// ❌ INCORRECTO
class BibleService{
    func fetchChapter(bibleId:String,chapterId:String)async throws->ChapterData{
        // Implementación
    }
}
```

### Nombramiento

- **Clases y Structs**: `PascalCase` (ej: `BibleService`, `HomeView`)
- **Funciones y Variables**: `camelCase` (ej: `fetchBooks`, `currentBible`)
- **Constantes**: `camelCase` (ej: `apiKey`, `baseURL`)
- **Enums**: `PascalCase` (ej: `BibleError`, `ViewState`)

### Estructura de Archivos

```
Archivo: NombreClase.swift

// 1. Importes
import SwiftUI
import Combine

// 2. Declaración de clase
class NombreClase {
    // 3. Propiedades estatales

    // 4. Propiedades de instancia

    // 5. Inicializadores

    // MARK: - Métodos Públicos

    // 6. Métodos públicos

    // MARK: - Métodos Privados

    // 7. Métodos privados
}

// 8. Extensiones
extension NombreClase { }
```

### Documentación

Documenta funciones públicas y clases complejas:

```swift
/// Obtiene los capítulos de un libro específico.
///
/// - Parameters:
///   - bibleId: Identificador único de la Biblia
///   - bookId: Identificador del libro
/// - Returns: Array de capítulos
/// - Throws: BibleError si la solicitud falla
func fetchChapters(bibleId: String, bookId: String) async throws -> [Chapter] {
    // Implementación
}
```

## Proceso de Revisión

Todos los pull requests serán revisados por los mantenedores. Esperamos:

- ✅ Código limpio y bien estructurado
- ✅ Comentarios claros donde sea necesario
- ✅ Tests unitarios para nuevas funcionalidades
- ✅ Mensajes de commit descriptivos
- ✅ No hay conflictos con la rama `main`

## Preguntas o Necesitas Ayuda?

- Abre un Issue con la etiqueta `question`
- Revisa las Issues existentes
- Lee la documentación en el README

## Licencia

Al contribuir a este proyecto, aceptas que tus contribuciones serán licenciadas bajo la licencia MIT del proyecto.

---

**¡Gracias por tu contribución! 🎉**
