import json

filepath = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/Localizable.xcstrings"

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "radio_bautista_desc": {"es": "La señal tradicional directa desde la iglesia", "en": "The traditional signal direct from the church"},
    "radio_neuma_desc": {"es": "Digital", "en": "Digital"},
    "permissions_not_granted": {"es": "Permisos no concedidos", "en": "Permissions not granted"},
    "notifications_enabled": {"es": "Notificaciones activadas", "en": "Notifications enabled"},
    "enable": {"es": "Activar", "en": "Enable"},
    "every_day": {"es": "Todos los días", "en": "Every day"},
    "daily_verse": {"es": "Versículo Diario", "en": "Daily Verse"},
    "terms_title": {"es": "Términos y Condiciones", "en": "Terms and Conditions"},
    "terms_acceptance_title": {"es": "1. Aceptación de los términos", "en": "1. Acceptance of terms"},
    "terms_acceptance_text": {"es": "Al acceder y utilizar esta aplicación, usted acepta estar sujeto a estos términos y condiciones de uso, todas las leyes y regulaciones aplicables, y acepta que es responsable del cumplimiento de las leyes locales aplicables.", "en": "By accessing and using this application, you agree to be bound by these terms and conditions of use, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws."},
    "terms_license_title": {"es": "2. Licencia de Uso", "en": "2. Use License"},
    "terms_license_text": {"es": "Se concede permiso para descargar temporalmente una copia de la aplicación para visualización transitoria personal y no comercial solamente. Esta es la concesión de una licencia, no una transferencia de título.", "en": "Permission is granted to temporarily download one copy of the application for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title."},
    "terms_disclaimer_title": {"es": "3. Descargo de Responsabilidad", "en": "3. Disclaimer"},
    "terms_disclaimer_text": {"es": "Los materiales en la aplicación se proporcionan 'tal cual'. No otorgamos garantías, expresas o implícitas, y por la presente renunciamos y negamos todas las demás garantías.", "en": "The materials within the application are provided 'as is'. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties."},
    "terms_limitations_title": {"es": "4. Limitaciones", "en": "4. Limitations"},
    "terms_limitations_text": {"es": "En ningún caso nosotros o nuestros proveedores seremos responsables de ningún daño (incluidos, sin limitación, daños por pérdida de datos o ganancias, o debido a la interrupción del negocio) que surja del uso o la incapacidad de usar los materiales en la aplicación.", "en": "In no event shall we or our suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials within the application."},
    "terms_privacy_title": {"es": "5. Privacidad", "en": "5. Privacy"},
    "terms_privacy_text": {"es": "Su privacidad es importante para nosotros. Es nuestra política respetar su privacidad con respecto a cualquier información que podamos recopilar de usted a través de nuestra aplicación.", "en": "Your privacy is important to us. It is our policy to respect your privacy regarding any information we may collect from you across our application."},
    "terms_modifications_title": {"es": "6. Modificaciones de los Términos de Uso", "en": "6. Modifications of Terms of Use"},
    "terms_modifications_text": {"es": "Podemos revisar estos términos de uso para nuestra aplicación en cualquier momento sin previo aviso. Al utilizar esta aplicación, usted acepta estar sujeto a la versión actual de estos términos y condiciones de uso.", "en": "We may revise these terms of use for our application at any time without notice. By using this application you are agreeing to be bound by the then current version of these terms and conditions of use."}
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

print("Updated Localizable.xcstrings with terms and radio and notifications.")
