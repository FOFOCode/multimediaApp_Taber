import json

filepath = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/Localizable.xcstrings"

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "min_today": {"es": "min hoy", "en": "min today"},
    "of_seven_days": {"es": "de 7 días", "en": "of 7 days"}
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

print("Updated Localizable.xcstrings with min_today and of_seven_days successfully.")
