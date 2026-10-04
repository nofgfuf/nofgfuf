"""
Hats. Origin (0,0,0) = the character's HatAttachment (top-centre of the head).
The classic head is ~1.2 studs wide, so it occupies roughly x,z in [-0.6, 0.6], y in [-1.2, 0].
Stats (price, boosts, upgrades) live in ReplicatedStorage/Shared/Config/HatConfig, not here.
"""

import math

from rbx import accessory, ball, block_between, cyl_between, cyl_y, cyl_z, part, point_light, sparkles

CATEGORY = "Hats"


def hat(name, parts, extras=()):
    return accessory(name, "HatAttachment", parts, extras=extras, attrs={"Slot": "Hat", "HatId": name})


def _mail_cap(name, crown, band, visor, badge, emblem, material="SmoothPlastic", trim_material="SmoothPlastic",
              extras=()):
    return hat(name, [
        cyl_y("Crown", 0.42, 1.3, (0, -0.05, 0), color=crown, material=material),
        cyl_y("Top", 0.2, 1.52, (0, 0.24, 0.04), color=crown, material=material),
        cyl_y("Band", 0.14, 1.34, (0, -0.19, 0), color=band, material=trim_material),
        part("Visor", (1.05, 0.08, 0.5), (0, -0.25, -0.78), rot=(-12, 0, 0), color=visor, material=trim_material),
        part("Badge", (0.34, 0.26, 0.06), (0, 0.02, -0.67), color=badge, material=trim_material),
        part("BadgeEnvelope", (0.22, 0.13, 0.04), (0, 0.03, -0.71), color=emblem),
        part("BadgeFlap", (0.12, 0.12, 0.03), (0, 0.065, -0.725), rot=(0, 0, 45), color=badge),
    ], extras=extras)


def mailman_cap():
    return _mail_cap("MailmanCap", crown="Bright blue", band="Really black", visor="Really black",
                     badge="Gold", emblem="Institutional white")


def golden_mailman_cap():
    return _mail_cap("GoldenMailmanCap", crown="Gold", band="Institutional white", visor="Gold",
                     badge="New Yeller", emblem="Bright red", material="Foil", trim_material="Neon",
                     extras=(sparkles(), point_light("Gold", 1.5, 10)))


def newspaper_hat():
    return hat("NewspaperHat", [
        part("Fold", (1.15, 1.15, 0.32), (0, -0.12, 0), rot=(0, 0, 45), color="Light stone grey"),
        part("Brim", (1.42, 0.22, 0.38), (0, -0.08, 0), color="Institutional white"),
        part("Headline", (0.5, 0.08, 0.02), (0, 0.32, -0.17), color="Really black"),
        part("Column1", (0.36, 0.04, 0.02), (-0.05, 0.18, -0.17), color="Dark stone grey"),
        part("Column2", (0.5, 0.04, 0.02), (0, 0.1, -0.17), color="Dark stone grey"),
        part("Photo", (0.22, 0.16, 0.02), (0.22, 0.17, -0.17), color="Medium stone grey"),
        part("BrimPrint", (1.0, 0.04, 0.02), (0, -0.05, -0.2), color="Dark stone grey"),
    ])


def propeller_beanie():
    return hat("PropellerBeanie", [
        ball("Dome", 1.38, (0, -0.2, 0), color="Bright red"),
        cyl_y("Band", 0.16, 1.4, (0, -0.22, 0), color="Bright yellow"),
        part("StripeFront", (0.16, 0.04, 0.6), (0, 0.42, -0.2), rot=(-35, 0, 0), color="Bright blue"),
        part("StripeBack", (0.16, 0.04, 0.6), (0, 0.42, 0.2), rot=(35, 0, 0), color="Bright green"),
        cyl_y("Stem", 0.28, 0.1, (0, 0.6, 0), color="Medium stone grey"),
        ball("Hub", 0.2, (0, 0.76, 0), color="Bright yellow"),
        part("BladeA", (0.8, 0.05, 0.24), (0.45, 0.76, 0), rot=(0, 20, 8), color="Bright yellow"),
        part("BladeB", (0.8, 0.05, 0.24), (-0.45, 0.76, 0), rot=(0, 20, -8), color="Bright blue"),
    ])


def traffic_cone():
    tiers = [  # (diameter, height, colour)
        (1.3, 0.3, "Neon orange"),
        (1.08, 0.28, "Institutional white"),
        (0.88, 0.28, "Neon orange"),
        (0.68, 0.26, "Institutional white"),
        (0.48, 0.24, "Neon orange"),
        (0.3, 0.2, "Neon orange"),
    ]
    parts = [part("Base", (1.6, 0.12, 1.6), (0, -0.12, 0), color="Neon orange")]
    y = -0.06
    for i, (dia, h, color) in enumerate(tiers):
        parts.append(cyl_y(f"Tier{i + 1}", h, dia, (0, y + h / 2, 0), color=color))
        y += h
    return hat("TrafficCone", parts)


def cowboy_hat():
    brim = "Reddish brown"
    return hat("CowboyHat", [
        cyl_y("Brim", 0.08, 1.8, (0, -0.1, 0), color=brim),
        part("BrimFront", (1.0, 0.08, 0.6), (0, -0.12, -0.72), rot=(-8, 0, 0), color=brim),
        part("BrimBack", (1.0, 0.08, 0.6), (0, -0.12, 0.72), rot=(8, 0, 0), color=brim),
        part("BrimCurlL", (0.3, 0.08, 1.1), (-0.86, 0.0, 0), rot=(0, 0, -40), color=brim),
        part("BrimCurlR", (0.3, 0.08, 1.1), (0.86, 0.0, 0), rot=(0, 0, 40), color=brim),
        cyl_y("Crown", 0.62, 1.22, (0, 0.24, 0), color=brim),
        part("Crease", (0.18, 0.08, 1.0), (0, 0.56, 0), color="Pine Cone"),
        cyl_y("Band", 0.13, 1.25, (0, 0.0, 0), color="Really black"),
        part("Buckle", (0.2, 0.15, 0.05), (0, 0.0, -0.63), color="Gold"),
    ])


def top_hat():
    return hat("TopHat", [
        cyl_y("Brim", 0.08, 1.85, (0, -0.1, 0), color="Really black"),
        cyl_y("Tube", 1.05, 1.22, (0, 0.44, 0), color="Really black"),
        cyl_y("Lid", 0.06, 1.26, (0, 0.98, 0), color="Black"),
        cyl_y("Band", 0.2, 1.25, (0, 0.06, 0), color="Bright red"),
        part("Envelope", (0.32, 0.2, 0.04), (0.3, 0.07, -0.56), rot=(0, -28, 0), color="Institutional white"),
        part("Stamp", (0.08, 0.1, 0.02), (0.38, 0.1, -0.585), rot=(0, -28, 0), color="Bright red"),
    ])


def viking_helmet():
    parts = [
        ball("Dome", 1.46, (0, -0.22, 0), color="Medium stone grey", material="Metal"),
        cyl_y("Rim", 0.16, 1.5, (0, -0.28, 0), color="Gold"),
        part("RidgeF", (0.14, 0.07, 0.8), (0, 0.3, -0.18), rot=(-38, 0, 0), color="Gold"),
        part("RidgeB", (0.14, 0.07, 0.8), (0, 0.3, 0.18), rot=(38, 0, 0), color="Gold"),
        part("NoseGuard", (0.14, 0.42, 0.08), (0, -0.48, -0.72), color="Gold"),
    ]
    for side, label in ((1, "R"), (-1, "L")):
        a = (side * 0.62, -0.12, 0)
        b = (side * 1.0, 0.1, 0)
        c = (side * 1.12, 0.48, 0)
        d = (side * 1.0, 0.78, 0)
        parts += [
            cyl_between(f"Horn{label}1", a, b, 0.34, color="Brick yellow"),
            cyl_between(f"Horn{label}2", b, c, 0.26, color="Brick yellow"),
            cyl_between(f"Horn{label}3", c, d, 0.16, color="Light stone grey"),
            ball(f"Horn{label}Joint", 0.3, b, color="Brick yellow"),
            ball(f"Horn{label}Joint2", 0.22, c, color="Brick yellow"),
        ]
    return hat("VikingHelmet", parts)


def wizard_hat():
    purple = "Royal purple"
    parts = [cyl_y("Brim", 0.08, 1.9, (0, -0.1, 0), color=purple)]
    # A bent stepped cone: each tier shrinks and leans a bit further back.
    tiers = 7
    x = z = 0.0
    y = -0.06
    for i in range(tiers):
        t = i / (tiers - 1)
        dia = 1.25 * (1 - t) + 0.18 * t
        h = 0.26
        z += 0.03 + 0.06 * t * t
        parts.append(cyl_y(f"Cone{i + 1}", h, dia, (x, y + h / 2, z), color=purple))
        y += h - 0.02
    parts.append(ball("Tip", 0.2, (x, y + 0.05, z + 0.06), color="New Yeller", material="Neon"))
    parts.append(cyl_y("Band", 0.12, 1.27, (0, 0.0, 0.03), color="Gold"))
    for i, (sx, sy) in enumerate([(-0.32, 0.38), (0.25, 0.65), (-0.12, 0.95), (0.18, 0.2)]):
        zf = -0.62 + 0.25 * (sy / 1.0)
        parts.append(part(f"Star{i + 1}", (0.13, 0.13, 0.03), (sx, sy, zf), rot=(-12, 0, 45),
                          color="New Yeller", material="Neon"))
    return hat("WizardHat", parts, extras=(sparkles(),))


def royal_crown():
    parts = [
        cyl_y("Ring", 0.36, 1.38, (0, 0.0, 0), color="Gold", material="Foil", reflectance=0.15),
        cyl_y("Velvet", 0.32, 1.28, (0, 0.18, 0), color="Crimson", material="Fabric"),
        cyl_y("Fur", 0.12, 1.44, (0, -0.16, 0), color="Institutional white", material="Fabric"),
        ball("Orb", 0.24, (0, 0.62, 0), color="Gold", material="Foil", reflectance=0.15),
        part("CrossV", (0.07, 0.24, 0.07), (0, 0.84, 0), color="Gold"),
        part("CrossH", (0.18, 0.07, 0.07), (0, 0.86, 0), color="Gold"),
    ]
    gems = ["Bright red", "Bright blue", "Bright green", "Bright red", "Bright blue", "Bright green"]
    n = 6
    for i in range(n):
        a = 2 * math.pi * i / n
        x, z = math.sin(a) * 0.66, -math.cos(a) * 0.66
        parts.append(part(f"Spike{i + 1}", (0.3, 0.3, 0.08), (x, 0.24, z), rot=(0, -math.degrees(a), 45),
                          color="Gold", material="Foil", reflectance=0.15))
        parts.append(ball(f"Pearl{i + 1}", 0.12, (x * 1.0, 0.47, z * 1.0), color="Institutional white"))
        parts.append(part(f"Gem{i + 1}", (0.14, 0.14, 0.06), (x * 1.04, 0.0, z * 1.04), rot=(0, -math.degrees(a), 45),
                          color=gems[i], material="Glass"))
    # The arches over the velvet cap.
    parts.append(block_between("ArchA", (-0.6, 0.3, 0), (0, 0.55, 0), 0.08, 0.08, color="Gold"))
    parts.append(block_between("ArchB", (0.6, 0.3, 0), (0, 0.55, 0), 0.08, 0.08, color="Gold"))
    parts.append(block_between("ArchC", (0, 0.3, -0.6), (0, 0.55, 0), 0.08, 0.08, up_hint=(1, 0, 0), color="Gold"))
    parts.append(block_between("ArchD", (0, 0.3, 0.6), (0, 0.55, 0), 0.08, 0.08, up_hint=(1, 0, 0), color="Gold"))
    return hat("RoyalCrown", parts, extras=(sparkles(),))


def mailbox_hat():
    body = "Bright blue"
    return hat("MailboxHat", [
        part("Strap", (1.3, 0.1, 1.3), (0, -0.06, 0), color="Really black"),
        part("Body", (0.8, 0.5, 1.2), (0, 0.24, 0.05), color=body),
        cyl_z("Roof", 1.2, 0.8, (0, 0.49, 0.05), color=body),
        part("Door", (0.82, 0.5, 0.05), (0, 0.24, -0.57), color="Deep blue"),
        cyl_z("DoorArch", 0.05, 0.82, (0, 0.49, -0.57), color="Deep blue"),
        part("Latch", (0.2, 0.07, 0.07), (0, 0.58, -0.62), color="Light stone grey"),
        part("FlagPole", (0.06, 0.65, 0.08), (0.44, 0.48, 0.15), color="Light stone grey"),
        part("Flag", (0.05, 0.24, 0.36), (0.44, 0.7, -0.03), color="Bright red"),
        part("Letter", (0.5, 0.05, 0.4), (0, 0.35, -0.72), rot=(-70, 0, 0), color="Institutional white"),
        part("LetterStamp", (0.1, 0.06, 0.12), (0.15, 0.4, -0.74), rot=(-70, 0, 0), color="Bright red"),
    ], extras=(sparkles(),))


BUILDERS = [
    mailman_cap, newspaper_hat, propeller_beanie, traffic_cone, cowboy_hat, top_hat,
    viking_helmet, wizard_hat, royal_crown, mailbox_hat, golden_mailman_cap,
]
