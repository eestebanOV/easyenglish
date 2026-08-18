import json

with open("assets/data/vocabulary.json", "r", encoding="utf-8") as f:
    data = json.load(f)

for cat in data["categories"]:
    if cat["id"] == "common_words":
        cat["cards"] = cat["cards"][:100]
        print(f"common_words recortadas a: {len(cat['cards'])}")
    if cat["id"] == "verb_tenses":
        print(f"verb_tenses: {len(cat['cards'])}")

with open("assets/data/vocabulary.json", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
