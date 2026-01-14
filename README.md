# 📱 MultimediaApp Taber

[![Swift Version](https://img.shields.io/badge/swift-5.9+-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-17%2B-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Una aplicación iOS moderna y multifuncional para acceder a contenido multimedia religioso incluyendo la Biblia, radio, TV y más. Construida con **SwiftUI** y diseñada con una interfaz intuitiva y atractiva.

## 🌟 Características Principales

- 📖 **Lectura de la Biblia**: Acceso a múltiples versiones bíblicas mediante [API.Bible](https://scripture.api.bible)
- 🌍 **Multiidioma**: Soporte para español, inglés y más idiomas
- 🎙️ **Radio en Vivo**: Transmisión de contenido de radio religioso
- 📺 **TV**: Visualización de contenido de televisión
- ❤️ **Favoritos**: Sistema de guardado de versículos favoritos
- 🎨 **Interfaz Moderna**: Diseño elegante con colores personalizados y animaciones suaves
- 🌈 **Temas Visuales**: Paleta de colores profesional y coherente

## 📋 Requisitos

- iOS 17.0 o superior
- Xcode 15.0 o superior
- Swift 5.9 o superior
- CocoaPods (opcional, según dependencias)

## 🚀 Instalación

### Opción 1: Clonar desde GitHub

```bash
git clone https://github.com/tu-usuario/multimediaApp_taber.git
cd multimediaApp_taber
```

### Opción 2: Abrir en Xcode

1. Abre `multimediaApp_taber.xcodeproj` directamente en Xcode
2. Selecciona el scheme "multimediaApp_taber"
3. Presiona `Cmd + R` para ejecutar

## ⚙️ Configuración

### API Key

La aplicación utiliza [API.Bible](https://scripture.api.bible) para obtener contenido bíblico.

1. Regístrate en [scripture.api.bible](https://scripture.api.bible)
2. Obtén tu API Key
3. Abre `BibleService.swift` y reemplaza:

```swift
private let apiKey = "lB1S138vRr8WXNuj88_f2"
```

Con tu propia API Key.

## 📁 Estructura del Proyecto

```
multimediaApp_taber/
├── Views/
│   ├── ContentView.swift          # Vista principal
│   ├── HomeView.swift             # Pantalla de inicio
│   ├── BibleView.swift            # Lectura de la Biblia
│   ├── ChaptersView.swift         # Lista de capítulos
│   ├── RadioView.swift            # Transmisión de radio
│   ├── TVView.swift               # Contenido de TV
│   ├── ReaderView.swift           # Lector de versículos
│   ├── InfoView.swift             # Información
│   ├── SplashView.swift           # Pantalla de carga
│   └── LanguageSelectorView.swift # Selector de idioma
├── Services/
│   ├── BibleService.swift         # API de la Biblia
│   ├── FavoritesService.swift     # Gestión de favoritos
│   └── LocalizationManager.swift  # Gestión de idiomas
├── Models/
│   └── BibleModels.swift          # Modelos de datos
├── UI/
│   ├── ColorPalette.swift         # Colores personalizados
│   └── AppUI.swift                # Componentes de UI reutilizables
├── Resources/
│   ├── Localizable.xcstrings      # Traducciones
│   └── Assets.xcassets/           # Recursos gráficos
└── multimediaApp_taberApp.swift   # Punto de entrada

```

## 🛠️ Tecnologías Utilizadas

- **SwiftUI**: Framework moderno para construir interfaces de usuario
- **Combine**: Reactive programming para gestión de estado
- **URLSession**: Networking
- **UserDefaults**: Persistencia de datos
- **API.Bible**: API de contenido bíblico

## 📖 Uso

### Lectura de la Biblia

1. Navega a la sección de Biblia
2. Selecciona la versión bíblica deseada
3. Elige un libro y capítulo
4. Lee el contenido con facilidad

### Favoritos

Los versículos marcados como favoritos se guardan automáticamente en el dispositivo y pueden accederse desde cualquier momento.

### Cambio de Idioma

Toca el botón de idioma en la esquina superior para cambiar entre idiomas disponibles.

## 🎨 Personalización

### Colores

Los colores están centralizados en `ColorPalette.swift`:

```swift
extension Color {
    static let cobaltBlue = Color(red: 0.1, green: 0.3, blue: 0.8)
    static let aliceBlue = Color(red: 0.94, green: 0.97, blue: 1.0)
    // ... más colores
}
```

### Idiomas

Las traducciones se encuentran en `Localizable.xcstrings` y son gestionadas por `LocalizationManager.swift`.

## 🧪 Testing

Para ejecutar los tests:

```bash
# En Xcode
Cmd + U

# O desde terminal
xcodebuild test -scheme multimediaApp_taber
```

## 📝 Historial de Cambios

Ver [CHANGELOG.md](CHANGELOG.md) para detalles de versiones anteriores.

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor, lee [CONTRIBUTING.md](CONTRIBUTING.md) para detalles sobre nuestro código de conducta y proceso de pull requests.

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👨‍💻 Autor

**Rodolfo Rivas**

- GitHub: [@tu-usuario](https://github.com/tu-usuario)
- LinkedIn: [tu-perfil](https://linkedin.com/in/tu-perfil)
- Email: tu-email@ejemplo.com

## 🙏 Agradecimientos

- [API.Bible](https://scripture.api.bible) por proporcionar acceso a contenido bíblico
- Apple por SwiftUI y sus herramientas de desarrollo
- La comunidad de desarrolladores iOS

## 📞 Soporte

Si encuentras algún problema o tienes sugerencias, por favor abre un [issue](https://github.com/tu-usuario/multimediaApp_taber/issues) en GitHub.

---

**⭐ Si te gustó este proyecto, por favor dale una estrella en GitHub!**
