# 🔧 Guía de Configuración - MultimediaApp Taber

Esta guía te ayudará a configurar el proyecto correctamente para desarrollar y ejecutar la aplicación.

## Requisitos Previos

- **macOS** 12.0 o superior
- **Xcode** 15.0 o superior (descarga desde App Store)
- **Swift** 5.9 o superior (incluido en Xcode)
- **iOS** 17.0 o superior en el dispositivo de prueba

## Paso 1: Clonar el Repositorio

```bash
# Usando HTTPS
git clone https://github.com/tu-usuario/multimediaApp_taber.git

# O usando SSH
git clone git@github.com:tu-usuario/multimediaApp_taber.git

# Navegar al directorio
cd multimediaApp_taber
```

## Paso 2: Obtener una API Key

### 2.1 Registro en API.Bible

1. Ve a [scripture.api.bible](https://scripture.api.bible)
2. Haz clic en "Sign Up" (Registrarse)
3. Completa el formulario de registro
4. Verifica tu correo electrónico
5. Inicia sesión en tu cuenta

### 2.2 Generar tu API Key

1. En el dashboard, ve a "API Keys"
2. Haz clic en "Create new API Key"
3. Dale un nombre (ej: "MultimediaApp")
4. Copia la API Key generada

## Paso 3: Configurar la API Key en el Proyecto

### 3.1 Abrir el Proyecto en Xcode

```bash
# Desde la terminal, en el directorio del proyecto
open multimediaApp_taber.xcodeproj
```

O simplemente haz doble clic en `multimediaApp_taber.xcodeproj`

### 3.2 Modificar BibleService.swift

1. En Xcode, navega a: `multimediaApp_taber` > `BibleService.swift`
2. Busca la línea:
   ```swift
   private let apiKey = "lB1S138vRr8WXNuj88_f2"
   ```
3. Reemplázala con tu API Key:
   ```swift
   private let apiKey = "TU_API_KEY_AQUI"
   ```

## Paso 4: Ejecutar el Proyecto

### 4.1 Seleccionar el Scheme y Target

1. En Xcode, selecciona el scheme `multimediaApp_taber`
2. Elige un simulador iOS 17+ o tu dispositivo físico

### 4.2 Compilar y Ejecutar

```bash
# Desde Xcode: Cmd + R

# O desde terminal:
xcodebuild -scheme multimediaApp_taber build
```

## Paso 5: Ejecutar Tests (Opcional)

```bash
# Desde Xcode: Cmd + U

# O desde terminal:
xcodebuild test -scheme multimediaApp_taber
```

## Solución de Problemas Comunes

### Error: "No such file or directory"

```
Error: MultiMediaApp.xcodeproj: No such file or directory
```

**Solución:**

- Asegúrate de estar en el directorio correcto
- Verifica que el archivo `multimediaApp_taber.xcodeproj` existe
- Usa `pwd` para confirmar tu ubicación

### Error: "Invalid API Key"

```
API Key inválida o no autorizada
```

**Solución:**

1. Verifica que copiaste la API Key correctamente
2. Asegúrate de que no hay espacios al principio o final
3. Regenera la API Key en el dashboard de API.Bible
4. Verifica que el archivo esté guardado en Xcode (Cmd + S)

### Error: "Build Failed"

**Soluciones comunes:**

1. Limpia el build: `Cmd + Shift + K`
2. Elimina carpeta de derivados: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
3. Cierra Xcode y vuelve a abrir
4. Verifica que tienes la versión correcta de Xcode

### La app se congela al cargar la Biblia

**Soluciones:**

1. Verifica tu conexión a Internet
2. Comprueba que la API Key esté configurada correctamente
3. Revisa la consola de Xcode (View > Debug Area > Show Debug Area) para ver errores
4. Intenta limpiar la app y volver a ejecutarla

## Estructura del Proyecto después de la Configuración

```
multimediaApp_taber/
├── multimediaApp_taber/                # Código fuente
│   ├── Views/                         # Vistas SwiftUI
│   ├── Services/                      # Servicios (API, persistencia)
│   ├── Models/                        # Modelos de datos
│   ├── Resources/                     # Assets, localizaciones
│   └── multimediaApp_taberApp.swift  # Entry point
├── multimediaApp_taberTests/         # Tests unitarios
├── multimediaApp_taberUITests/       # Tests de UI
├── README.md                          # Documentación principal
├── CONTRIBUTING.md                    # Guía de contribución
├── LICENSE                            # Licencia MIT
└── CHANGELOG.md                       # Historial de cambios
```

## Arquitectura de la Aplicación

### Patrones Utilizados

- **MVVM**: Model-View-ViewModel con SwiftUI
- **Singleton**: BibleService, LocalizationManager
- **Combine**: Reactive programming para estado
- **Async/Await**: Networking asincrónico

### Flujo de Datos

```
API.Bible
    ↓
BibleService (Observable)
    ↓
SwiftUI Views (reactive)
    ↓
Usuario
```

## Desarrollo

### Agregar una Nueva Vista

1. Crea un archivo en `Views/NombreDeLaVista.swift`
2. Define tu estructura SwiftUI
3. Usa el preview para testing inmediato

### Agregar Nuevas Traducciones

1. Abre `Localizable.xcstrings`
2. Agrega nuevas claves en `LocalizationManager.swift`
3. Traduce las nuevas claves en cada idioma

### Debugging

Usa la consola de Xcode (View > Debug Area > Show Debug Area) para:

- Ver logs: `print("Debug message")`
- Inspeccionar variables durante pausa en breakpoints
- Monitorear performance

## Recursos Útiles

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [API.Bible Documentation](https://scripture.api.bible/docs)
- [Combine Framework Guide](https://developer.apple.com/documentation/combine)
- [iOS Development Tips](https://www.hackingwithswift.com)

## Obtener Ayuda

Si encuentras problemas:

1. **Revisa esta guía** - verifica Solución de Problemas
2. **Busca en Issues** - el problema podría estar ya reportado
3. **Abre un Issue** - con detalles de tu problema
4. **Consulta Stack Overflow** - con la etiqueta `swiftui` o `ios`

---

**¡Listo! Ya deberías poder ejecutar la aplicación. 🎉**

¿Tienes problemas? Abre un [Issue](https://github.com/tu-usuario/multimediaApp_taber/issues) en GitHub.
