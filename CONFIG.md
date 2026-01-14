# 🔧 Archivos de Configuración

Este documento describe los archivos de configuración del proyecto.

## 📁 Archivos Principales

### `.gitignore`
Define qué archivos y carpetas deben ignorarse en Git. Incluye:
- Derivados de Xcode (`DerivedData/`, `xcuserdata/`)
- Dependencias (`Pods/`)
- Archivos de sistema (`**/DS_Store`)
- Archivos temporales

### `.editorconfig`
Mantiene la consistencia de estilos entre diferentes editores (Xcode, VS Code, etc.):
- Indentación: 4 espacios para Swift
- Conjunto de caracteres: UTF-8
- Largo máximo de línea: 120 caracteres

### `.env.example`
Template para variables de entorno. Contiene:
```
BIBLE_API_KEY=your_api_key_here
```

**Copia este archivo a `.env`** (no versionado) para usar en desarrollo local.

## 📋 Archivos en `.github/`

### `pull_request_template.md`
Template automático para nuevos pull requests. Incluye:
- Descripción del cambio
- Tipo de cambio
- Checklist de verificación

### `ISSUE_TEMPLATE/bug_report.md`
Template para reportes de bugs con campos estándar.

### `ISSUE_TEMPLATE/feature_request.md`
Template para solicitudes de características.

## 📝 Archivos de Documentación

### `README.md`
- Descripción general del proyecto
- Features principales
- Requisitos de instalación
- Estructura del proyecto
- Tecnologías utilizadas

### `SETUP.md`
Guía paso a paso para:
- Clonar el repositorio
- Obtener API Key
- Configurar el proyecto
- Ejecutar la aplicación
- Solución de problemas comunes

### `CONTRIBUTING.md`
Guía para contribuyentes incluyendo:
- Código de conducta
- Cómo reportar bugs
- Cómo sugerir mejoras
- Convenciones de código
- Proceso de pull requests

### `BEST_PRACTICES.md`
Estándares de codificación:
- Estructura de código Swift
- Convenciones de nombramiento
- SwiftUI best practices
- Async/Await patterns
- Testing
- Performance
- Seguridad

### `LICENSE`
Licencia MIT del proyecto.

### `CHANGELOG.md`
Historial de cambios y versiones.

## 🔐 Seguridad

### API Key Management
- Nunca comitees API keys reales
- Usa `.env` para desarrollo local
- El archivo `.env` está en `.gitignore`
- Usa `.env.example` como template

## 🚀 Cómo Usar

1. **Primer Setup**:
   ```bash
   cp .env.example .env
   # Edita .env con tus valores
   ```

2. **Para Contribuir**:
   - Lee `CONTRIBUTING.md`
   - Revisa `BEST_PRACTICES.md`
   - Usa el PR template automáticamente

3. **Para Problemas**:
   - Lee `SETUP.md` para troubleshooting
   - Lee `README.md` para info general

## 📊 Estructura Recomendada

```
proyecto/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
├── .gitignore
├── .editorconfig
├── .env.example          (sin .env)
├── README.md
├── SETUP.md
├── CONTRIBUTING.md
├── BEST_PRACTICES.md
├── CHANGELOG.md
├── LICENSE
└── [otros archivos]
```

## ✅ Checklist de Configuración

- [ ] `.gitignore` configurado correctamente
- [ ] `.editorconfig` presente para consistencia
- [ ] `.env.example` disponible (sin `.env`)
- [ ] `.github/` con templates
- [ ] `README.md` completo
- [ ] `SETUP.md` con instrucciones claras
- [ ] `CONTRIBUTING.md` con guía
- [ ] `LICENSE` presente
- [ ] `CHANGELOG.md` con versiones

---

Todos estos archivos trabajan juntos para crear un proyecto profesional y bien documentado. 🎯
