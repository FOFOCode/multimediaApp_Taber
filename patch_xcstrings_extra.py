import json

filepath = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/Localizable.xcstrings"

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "contact_us": {"es": "Comunícate con nosotros", "en": "Contact Us"},
    "general_pastor": {"es": "Pastor General Roger Barahona", "en": "General Pastor Roger Barahona"},
    "send_message": {"es": "Enviar mensaje", "en": "Send Message"},
    "legal_info": {"es": "Información Legal", "en": "Legal Information"},
    "privacy_policy": {"es": "Política de Privacidad", "en": "Privacy Policy"},
    "terms_of_service": {"es": "Términos de Servicio (EULA)", "en": "Terms of Service (EULA)"},
    "loading": {"es": "Cargando...", "en": "Loading..."},
    "video_load_error": {"es": "No se pudo cargar el video", "en": "Could not load video"},
    "offline_bible": {"es": "Biblia Offline", "en": "Offline Bible"},
    "download_bible_prompt": {"es": "Descarga la Biblia para leer sin conexión", "en": "Download the Bible to read offline"},
    "downloading": {"es": "Descargando...", "en": "Downloading..."},
    "bible_downloaded": {"es": "Biblia descargada", "en": "Bible downloaded"},
    "download_full_bible_prompt": {"es": "Descarga la Biblia completa para leer sin conexión", "en": "Download the full Bible to read offline"},
    "download_bible": {"es": "Descargar Biblia", "en": "Download Bible"},
    "reading_progress": {"es": "Progreso de lectura", "en": "Reading progress"},
    "continue_reading": {"es": "Continuar leyendo", "en": "Continue reading"},
    "no_progress_saved": {"es": "No hay progreso guardado", "en": "No progress saved"},
    "storage": {"es": "Almacenamiento", "en": "Storage"},
    "downloaded_chapters": {"es": "Capítulos descargados", "en": "Downloaded chapters"},
    "space_used": {"es": "Espacio usado", "en": "Space used"},
    "offline_mode_active": {"es": "Modo offline activo", "en": "Offline mode active"},
    "clear_cache": {"es": "Borrar caché", "en": "Clear cache"},
    "notifications_prompt": {"es": "Recibe recordatorios y el versículo diario", "en": "Receive reminders and the daily verse"},
    "add_reminder": {"es": "Agregar recordatorio", "en": "Add reminder"},
    "no_reminders_configured": {"es": "No hay recordatorios configurados", "en": "No reminders configured"},
    "splash_tagline": {"es": "Caminando por fe, no por vista", "en": "Walking by faith, not by sight"},
    "downloaded": {"es": "Descargada", "en": "Downloaded"},
    "download": {"es": "Descargar", "en": "Download"},
    "add_favorites_prompt": {"es": "Agrega capítulos o versículos para verlos aquí.", "en": "Add chapters or verses to see them here."},
    "go_back": {"es": "Regresar", "en": "Go back"},
    "choose_station": {"es": "Elige tu emisora", "en": "Choose your station"},
    "contact": {"es": "Contacto", "en": "Contact"},
    "notifications": {"es": "Notificaciones", "en": "Notifications"}
}

for key, langs in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
        
    for lang, text in langs.items():
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
            
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Updated Localizable.xcstrings with all new keys successfully.")
