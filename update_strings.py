import json
import os

filepath = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/Localizable.xcstrings"

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_keys = {
    "home_tagline": {
        "es": "Palabra, radio y TV en un solo lugar",
        "en": "Word, radio and TV in one place",
        "pt": "Palavra, rádio e TV em um só lugar",
        "fr": "Parole, radio et TV au même endroit"
    },
    "daily_inspiration": {
        "es": "Inspiración diaria",
        "en": "Daily inspiration",
        "pt": "Inspiração diária",
        "fr": "Inspiration quotidienne"
    },
    "verse_of_the_day": {
        "es": "Versículo del día",
        "en": "Verse of the day",
        "pt": "Versículo do dia",
        "fr": "Verset du jour"
    },
    "quick_access": {
        "es": "Accesos rápidos",
        "en": "Quick access",
        "pt": "Acesso rápido",
        "fr": "Accès rapide"
    },
    "contact": {
        "es": "Contacto",
        "en": "Contact",
        "pt": "Contato",
        "fr": "Contact"
    },
    "communicate": {
        "es": "Comunícate",
        "en": "Communicate",
        "pt": "Comunique-se",
        "fr": "Communiquer"
    },
    "notifications": {
        "es": "Notificaciones",
        "en": "Notifications",
        "pt": "Notificações",
        "fr": "Notifications"
    },
    "reminders": {
        "es": "Recordatorios",
        "en": "Reminders",
        "pt": "Lembretes",
        "fr": "Rappels"
    },
    "spiritual_journey": {
        "es": "Tu jornada espiritual",
        "en": "Your spiritual journey",
        "pt": "Sua jornada espiritual",
        "fr": "Votre voyage spirituel"
    },
    "weekly_plan": {
        "es": "Plan Semanal",
        "en": "Weekly Plan",
        "pt": "Plano Semanal",
        "fr": "Plan hebdomadaire"
    },
    "daily_checkin": {
        "es": "Check-in diario en la aplicación",
        "en": "Daily app check-in",
        "pt": "Check-in diário no aplicativo",
        "fr": "Enregistrement quotidien sur l'application"
    },
    "time_in_word": {
        "es": "Tiempo en Palabra",
        "en": "Time in Word",
        "pt": "Tempo na Palavra",
        "fr": "Temps dans la Parole"
    },
    "accumulated_minutes": {
        "es": "Minutos acumulados en Radio y TV hoy",
        "en": "Accumulated minutes on Radio and TV today",
        "pt": "Minutos acumulados no Rádio e na TV hoje",
        "fr": "Minutes accumulées sur la radio et la télé aujourd'hui"
    }
}

for key, translations in new_keys.items():
    data['strings'][key] = {
        "extractionState": "manual",
        "localizations": {}
    }
    for lang, text in translations.items():
        data['strings'][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Updated Localizable.xcstrings successfully.")
