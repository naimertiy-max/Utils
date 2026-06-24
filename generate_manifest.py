import json
from pathlib import Path

manifest = {
    "folders": []
}

root = Path(".")

for folder in sorted(root.iterdir()):

    # Ignora arquivos
    if not folder.is_dir():
        continue

    # Ignora pastas especiais
    if folder.name.startswith("."):
        continue

    scripts = []

    for file in sorted(folder.glob("*.lua")):

        scripts.append({
            "name": file.stem,
            "file": file.name
        })

    # Só adiciona a pasta se tiver scripts
    if scripts:

        manifest["folders"].append({
            "name": folder.name,
            "scripts": scripts
        })

with open(
    "manifest.json",
    "w",
    encoding="utf-8"
) as f:

    json.dump(
        manifest,
        f,
        indent=4,
        ensure_ascii=False
    )

print(
    f"Manifest atualizado com "
    f"{len(manifest['folders'])} pastas."
)
