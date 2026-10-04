"""
Regenerates every model in src/ReplicatedStorage/Assets, the clothing textures in
assets/clothing, and the preview images in docs/previews.

    pip install numpy matplotlib pillow
    python3 tools/modelgen/build.py

Only needed if you change the Python model definitions. If you'd rather edit a model in
Studio, edit it there and "Save to File..." over the matching .rbxmx instead.
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)

from models import accessories, character, hats, mail, props, weapons  # noqa: E402
from rbx import to_rbxmx  # noqa: E402

ASSETS = os.path.join(ROOT, "src", "ReplicatedStorage", "Assets")
PREVIEWS = os.path.join(ROOT, "docs", "previews")
MODULES = [character, hats, accessories, mail, props, weapons]


def main(with_previews=True):
    built = {}
    for module in MODULES:
        custom_dir = getattr(module, "OUTPUT_DIR", None)
        out_dir = os.path.join(ROOT, *custom_dir) if custom_dir else os.path.join(ASSETS, module.CATEGORY)
        os.makedirs(out_dir, exist_ok=True)
        expected = set()
        for builder in module.BUILDERS:
            inst = builder()
            path = os.path.join(out_dir, f"{inst.name}.rbxmx")
            with open(path, "w", newline="\n") as f:
                f.write(to_rbxmx(inst))
            expected.add(f"{inst.name}.rbxmx")
            built.setdefault(module.CATEGORY, []).append(inst)
        for stale in set(os.listdir(out_dir)) - expected:
            if stale.endswith(".rbxmx") and not custom_dir:
                os.remove(os.path.join(out_dir, stale))
        print(f"{module.CATEGORY:12s} {len(module.BUILDERS)} models")

    import clothing

    clothing.main(os.path.join(ROOT, "assets", "clothing"))

    if with_previews:
        render_previews(built)


def render_previews(built):
    import preview

    os.makedirs(PREVIEWS, exist_ok=True)
    for category, insts in built.items():
        if category == "StarterCharacter":
            continue
        entries = []
        for inst in insts:
            polys = []
            for p in inst.parts():
                polys += preview.part_polys(p)
            entries.append((inst.name, polys, 55))
        preview.sheet(entries, os.path.join(PREVIEWS, f"{category}.png"), cols=4 if len(entries) > 3 else len(entries))

    # The real R6 StarterCharacter wearing the uniform + each hat, to check attachment offsets.
    rig = built["StarterCharacter"][0]
    attachments = {a.name: a.world_cf for a in rig.descendants() if a.cls == "Attachment"}
    body_polys = []
    for p in rig.parts():
        body_polys += preview.part_polys(p)
    uniform = []
    for acc in built["Accessories"]:
        uniform += preview.accessory_polys(acc, attachments)
    dressed = body_polys + uniform
    entries = [("Mailman (front)", dressed + preview.accessory_polys(built["Hats"][0], attachments), 70),
               ("Mailman (back)", dressed + preview.accessory_polys(built["Hats"][0], attachments), 235)]
    for hat in built["Hats"][1:]:
        entries.append((hat.name, dressed + preview.accessory_polys(hat, attachments), 60))
    preview.sheet(entries, os.path.join(PREVIEWS, "MailmanOutfits.png"), cols=4, size=3.4)
    print(f"previews -> {os.path.relpath(PREVIEWS, ROOT)}")


if __name__ == "__main__":
    main(with_previews="--no-previews" not in sys.argv)
