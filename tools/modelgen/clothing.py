"""
Draws the mailman's classic Shirt / Pants textures on the standard 585x559 Roblox template.
Output: assets/clothing/MailmanShirt.png, MailmanPants.png (transparent = body colour shows).
"""

import os

from PIL import Image, ImageDraw

W, H = 585, 559

# Template regions (x, y, w, h).
TORSO = {"front": (231, 74, 128, 128), "back": (427, 74, 128, 128), "right": (165, 74, 64, 128),
         "left": (361, 74, 64, 128), "up": (231, 8, 128, 64), "down": (231, 204, 128, 64)}
# Right arm/leg = left half of the template, left arm/leg = right half.
LIMB_R = {"outer": (19, 355, 64, 128), "back": (85, 355, 64, 128), "inner": (151, 355, 64, 128),
          "front": (217, 355, 64, 128), "up": (217, 289, 64, 64), "down": (217, 485, 64, 64)}
LIMB_L = {"front": (308, 355, 64, 128), "outer": (374, 355, 64, 128), "back": (440, 355, 64, 128),
          "inner": (506, 355, 64, 128), "up": (308, 289, 64, 64), "down": (308, 485, 64, 64)}

BLUE = (13, 105, 172, 255)
BLUE_DARK = (9, 78, 130, 255)
NAVY = (0, 32, 96, 255)
NAVY_DARK = (0, 20, 64, 255)
WHITE = (242, 243, 243, 255)
GOLD = (239, 184, 56, 255)
RED = (196, 40, 28, 255)
BLACK = (27, 42, 53, 255)
SKY = (128, 187, 219, 255)
BROWN = (105, 64, 40, 255)


def rect(d, x, y, w, h, fill, outline=None):
    d.rectangle([x, y, x + w - 1, y + h - 1], fill=fill, outline=outline)


def envelope(d, cx, cy, w, h, body, line):
    x, y = cx - w // 2, cy - h // 2
    rect(d, x, y, w, h, body, outline=line)
    d.line([x, y, cx, cy + 1, x + w - 1, y], fill=line, width=2)


def shirt():
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    belt_gap = 12  # leave the bottom of the torso clear so the trousers' belt shows

    for name, (x, y, w, h) in TORSO.items():
        if name in ("front", "back", "left", "right"):
            rect(d, x, y, w, h - belt_gap, BLUE, outline=BLUE_DARK)
        else:
            rect(d, x, y, w, h, BLUE, outline=BLUE_DARK)

    # Front: collar, button placket, pocket with an envelope patch.
    x, y, w, h = TORSO["front"]
    cx = x + w // 2
    d.polygon([(cx - 22, y), (cx, y + 22), (cx + 22, y)], fill=WHITE)
    d.polygon([(cx - 22, y), (cx - 30, y + 14), (cx - 6, y + 16)], fill=WHITE, outline=BLUE_DARK)
    d.polygon([(cx + 22, y), (cx + 30, y + 14), (cx + 6, y + 16)], fill=WHITE, outline=BLUE_DARK)
    d.line([cx, y + 22, cx, y + h - belt_gap - 1], fill=BLUE_DARK, width=3)
    for i in range(4):
        by = y + 34 + i * 22
        d.ellipse([cx + 3, by - 3, cx + 9, by + 3], fill=GOLD, outline=BLACK)
    # Pocket on the character's left chest (image right). The 3D NameBadge covers the other side.
    px, py = x + 76, y + 34
    rect(d, px, py, 36, 34, BLUE, outline=BLUE_DARK)
    rect(d, px, py, 36, 10, BLUE_DARK)
    envelope(d, px + 18, py + 22, 18, 12, WHITE, RED)

    # Back: big retro envelope logo.
    x, y, w, h = TORSO["back"]
    rect(d, x, y, w, 18, BLUE_DARK)
    envelope(d, x + w // 2, y + 56, 64, 40, WHITE, BLUE_DARK)
    rect(d, x + w // 2 - 10, y + 62, 20, 12, RED)

    # Short sleeves with a dark cuff; the rest of the arm stays bare (body colour).
    sleeve = 58
    for limb in (LIMB_R, LIMB_L):
        for name in ("outer", "back", "inner", "front"):
            x, y, w, h = limb[name]
            rect(d, x, y, w, sleeve, BLUE, outline=BLUE_DARK)
            rect(d, x, y + sleeve - 6, w, 6, BLUE_DARK)
        x, y, w, h = limb["up"]
        rect(d, x, y, w, h, BLUE, outline=BLUE_DARK)
        # Shoulder patch on the outside of each sleeve.
        x, y, w, h = limb["outer"]
        rect(d, x + 16, y + 10, 32, 32, WHITE, outline=BLUE_DARK)
        envelope(d, x + 32, y + 24, 20, 14, BLUE, WHITE)
        rect(d, x + 16, y + 36, 32, 6, RED)
    return img


def pants():
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    belt = 12

    for name, (x, y, w, h) in TORSO.items():
        rect(d, x, y, w, h, NAVY)
        if name in ("front", "back", "left", "right"):
            rect(d, x, y + h - belt, w, belt, BLACK)
            d.line([x, y + h - belt + 2, x + w - 1, y + h - belt + 2], fill=BROWN)
    x, y, w, h = TORSO["front"]
    rect(d, x + w // 2 - 9, y + h - belt + 1, 18, belt - 2, GOLD, outline=BLACK)

    shoe = 18
    for limb in (LIMB_R, LIMB_L):
        for name in ("outer", "back", "inner", "front"):
            x, y, w, h = limb[name]
            rect(d, x, y, w, h, NAVY, outline=NAVY_DARK)
            rect(d, x, y + h - shoe, w, shoe, BLACK)
            rect(d, x, y + h - shoe, w, 3, (60, 60, 60, 255))
        x, y, w, h = limb["outer"]
        rect(d, x + w // 2 - 4, y, 8, h - shoe, SKY)  # side stripe
        x, y, w, h = limb["front"]
        d.line([x + w // 2, y + 8, x + w // 2, y + h - shoe - 4], fill=NAVY_DARK, width=2)  # crease
        rect(d, *limb["up"], NAVY)
        rect(d, *limb["down"], BLACK)
    return img


def main(out_dir):
    os.makedirs(out_dir, exist_ok=True)
    shirt().save(os.path.join(out_dir, "MailmanShirt.png"))
    pants().save(os.path.join(out_dir, "MailmanPants.png"))
    print(f"clothing    -> {out_dir}")


if __name__ == "__main__":
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    main(os.path.join(root, "assets", "clothing"))
