import json

filepath = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/Localizable.xcstrings"

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "good_morning": {"pt": "Bom dia!", "fr": "Bonjour!"},
    "good_afternoon": {"pt": "Boa tarde!", "fr": "Bon après-midi!"},
    "good_evening": {"pt": "Boa noite!", "fr": "Bonsoir!"},
    "app_name": {"pt": "Taber Móvel", "fr": "Taber Mobile"},
    "select_content": {"pt": "Selecionar conteúdo", "fr": "Sélectionner le contenu"},
    "radio_title": {"pt": "Rádio", "fr": "Radio"},
    "radio_subtitle": {"pt": "Ao vivo", "fr": "En direct"},
    "radio_description": {"pt": "Ouça nossa rádio", "fr": "Écoutez notre radio"},
    "radio": {"pt": "Rádio", "fr": "Radio"},
    "tv_title": {"pt": "TV Taber", "fr": "TV Taber"},
    "tv_subtitle": {"pt": "Streaming", "fr": "En streaming"},
    "tv_description": {"pt": "Assista nossa TV", "fr": "Regardez notre TV"},
    "tv": {"pt": "TV", "fr": "TV"},
    "info_title": {"pt": "Informação", "fr": "Information"},
    "info_subtitle": {"pt": "Horários e Local", "fr": "Horaires et Lieu"},
    "info_description": {"pt": "Informações gerais", "fr": "Informations générales"},
    "bible_title": {"pt": "Bíblia", "fr": "Bible"},
    "bible_subtitle": {"pt": "Leia e estude", "fr": "Lisez et estutiez"},
    "bible_description": {"pt": "A Palavra de Deus", "fr": "La Parole de Dieu"},
    "live": {"pt": "Ao vivo", "fr": "En direct"},
    "paused": {"pt": "Pausado", "fr": "En pause"},
    "tap_to_play": {"pt": "Toque para reproduzir", "fr": "Appuyez pour lire"},
    "tap_to_stop": {"pt": "Toque para parar", "fr": "Appuyez pour arrêter"},
    "connecting": {"pt": "Conectando...", "fr": "Connexion..."},
    "connection_error": {"pt": "Erro de conexão", "fr": "Erreur de connexion"},
    "retry": {"pt": "Tentar novamente", "fr": "Réessayer"},
    "service_schedule": {"pt": "Horários dos cultos", "fr": "Horaires des cultes"},
    "our_location": {"pt": "Nossa localização", "fr": "Notre emplacement"},
    "church_name": {"pt": "Igreja Batista Taber", "fr": "Église Baptiste Taber"},
    "language": {"pt": "Idioma", "fr": "Langue"},
    "settings": {"pt": "Configurações", "fr": "Paramètres"},
    "streaming": {"pt": "Streaming", "fr": "Streaming"},
    "airplay": {"pt": "AirPlay", "fr": "AirPlay"},
    "christian_tv_24": {"pt": "TV Cristã 24h", "fr": "TV Chrétienne 24h"},
    "location_address": {"pt": "Endereço da igreja", "fr": "Adresse de l'église"},
    "monday": {"pt": "Segunda-feira", "fr": "Lundi"},
    "tuesday": {"pt": "Terça-feira", "fr": "Mardi"},
    "wednesday": {"pt": "Quarta-feira", "fr": "Mercredi"},
    "thursday": {"pt": "Quinta-feira", "fr": "Jeudi"},
    "friday": {"pt": "Sexta-feira", "fr": "Vendredi"},
    "saturday": {"pt": "Sábado", "fr": "Samedi"},
    "sunday": {"pt": "Domingo", "fr": "Dimanche"},
    "fasting_prayer": {"pt": "Jejum e Oração", "fr": "Jeûne et Prière"},
    "victory_families": {"pt": "Famílias Vitoriosas", "fr": "Familles Victorieuses"},
    "prayer_tower": {"pt": "Torre de Oração", "fr": "Tour de Prière"},
    "guest_tuesday": {"pt": "Terça de Convidados", "fr": "Mardi des Invités"},
    "dawn_with_god": {"pt": "Amanhecer com Deus", "fr": "Aube avec Dieu"},
    "bible_study_night": {"pt": "Noite de Estudo Bíblico", "fr": "Nuit d'Étude Biblique"},
    "worship_night": {"pt": "Noite de Adoração", "fr": "Nuit d'Adoration"},
    "miracle_night": {"pt": "Noite de Milagres", "fr": "Nuit de Miracles"},
    "young_jev": {"pt": "Jovens JEV", "fr": "Jeunes JEV"},
    "miracle_saturday": {"pt": "Sábado de Milagres", "fr": "Samedi de Miracles"},
    "worship_prayer": {"pt": "Adoração e Oração", "fr": "Adoration et Prière"},
    "books": {"pt": "Livros", "fr": "Livres"},
    "search": {"pt": "Buscar", "fr": "Recherche"},
    "favorites": {"pt": "Favoritos", "fr": "Favoris"},
    "old_testament": {"pt": "Antigo Testamento", "fr": "Ancien Testament"},
    "new_testament": {"pt": "Novo Testamento", "fr": "Nouveau Testament"},
    "chapter": {"pt": "Capítulo", "fr": "Chapitre"},
    "search_placeholder": {"pt": "Buscar na Bíblia...", "fr": "Chercher dans la Bible..."},
    "no_results": {"pt": "Nenhum resultado", "fr": "Aucun résultat"},
    "search_prompt": {"pt": "Digite para buscar", "fr": "Tapez pour chercher"},
    "no_favorites": {"pt": "Nenhum favorito", "fr": "Aucun favori"},
    "font_size": {"pt": "Tamanho da fonte", "fr": "Taille de police"},
    "done": {"pt": "Concluído", "fr": "Terminé"},
    "error_loading_chapter": {"pt": "Erro ao carregar capítulo", "fr": "Erreur de chargement du chapitre"},
    
    # Dashboard fallbacks
    "verse_load_error": {
        "es": "No fue posible cargar el versículo de hoy. Intenta nuevamente con conexión a internet.",
        "en": "It was not possible to load today's verse. Please try again with an internet connection.",
        "pt": "Não foi possível carregar o versículo de hoje. Tente novamente com conexão à internet.",
        "fr": "Il n'a pas été possible de charger le verset d'aujourd'hui. Veuillez réessayer avec une connexion internet."
    },
    "no_connection": {
        "es": "Sin conexão",
        "en": "No connection",
        "pt": "Sem conexão",
        "fr": "Pas de connexion"
    },
    "no_content_found": {
        "es": "No se encontró contenido para hoy.",
        "en": "No content found for today.",
        "pt": "Nenhum conteúdo encontrado para hoje.",
        "fr": "Aucun contenu trouvé pour aujourd'hui."
    },
    "reading_of_day": {
        "es": "Lectura del día",
        "en": "Reading of the day",
        "pt": "Leitura do dia",
        "fr": "Lecture du jour"
    }
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

print("Updated Localizable.xcstrings with missing pt and fr keys successfully.")
