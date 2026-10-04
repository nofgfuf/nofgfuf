"""
Mailman uniform pieces. Origin = the character's BodyFrontAttachment (front-centre of the chest).
The torso sits behind it: x in [-1, 1], z in [0, 1], top of the shoulders at about y = +1.
The character's right side is +X.
"""

from rbx import accessory, block_between, cyl_y, part

CATEGORY = "Accessories"


def uniform(name, parts):
    return accessory(name, "BodyFrontAttachment", parts, attrs={"Slot": "Uniform"})


def mail_satchel():
    leather, flap = "Reddish brown", "Brown"
    shoulder_f = (-0.62, 1.0, -0.06)
    shoulder_b = (-0.62, 1.0, 1.06)
    hip_f = (1.12, -0.86, -0.06)
    hip_b = (1.12, -0.86, 1.06)
    return uniform("MailSatchel", [
        block_between("StrapFront", shoulder_f, hip_f, 0.28, 0.06, color=leather),
        block_between("StrapBack", shoulder_b, hip_b, 0.28, 0.06, color=leather),
        part("StrapShoulder", (0.28, 0.06, 1.18), (-0.62, 1.03, 0.5), color=leather),
        part("Bag", (0.42, 0.9, 1.15), (1.22, -1.3, 0.5), color=leather),
        part("Flap", (0.06, 0.52, 1.19), (1.46, -1.06, 0.5), color=flap),
        part("FlapTop", (0.5, 0.06, 1.19), (1.24, -0.82, 0.5), color=flap),
        part("Buckle", (0.06, 0.2, 0.22), (1.5, -1.26, 0.5), color="Gold"),
        part("Patch", (0.04, 0.22, 0.34), (1.45, -1.52, 0.5), color="Bright blue"),
        part("LetterA", (0.05, 0.36, 0.6), (1.14, -0.78, 0.35), rot=(0, 0, 0), color="Institutional white"),
        part("LetterB", (0.05, 0.3, 0.5), (1.27, -0.8, 0.62), rot=(12, 0, -6), color="Brick yellow"),
        part("LetterStamp", (0.06, 0.08, 0.1), (1.14, -0.66, 0.15), color="Bright red"),
    ])


def name_badge():
    return uniform("NameBadge", [
        part("Pocket", (0.5, 0.42, 0.04), (0.5, 0.42, -0.02), color="Deep blue"),
        part("PocketFlap", (0.52, 0.12, 0.05), (0.5, 0.6, -0.04), color="Navy blue"),
        part("Badge", (0.34, 0.24, 0.05), (0.5, 0.82, -0.04), color="Gold"),
        part("BadgeInner", (0.24, 0.14, 0.03), (0.5, 0.82, -0.07), color="Bright blue"),
        part("Pen", (0.05, 0.3, 0.05), (0.66, 0.6, -0.07), color="Bright red"),
        part("PenClip", (0.04, 0.12, 0.03), (0.66, 0.68, -0.1), color="Light stone grey"),
    ])


def mailman_tie():
    navy = "Navy blue"
    return uniform("MailmanTie", [
        part("CollarL", (0.38, 0.12, 0.05), (-0.2, 0.96, -0.03), rot=(0, 0, -25), color="Institutional white"),
        part("CollarR", (0.38, 0.12, 0.05), (0.2, 0.96, -0.03), rot=(0, 0, 25), color="Institutional white"),
        part("Knot", (0.18, 0.16, 0.06), (0, 0.9, -0.05), color=navy),
        part("Blade", (0.2, 0.62, 0.05), (0, 0.5, -0.04), color=navy),
        part("Tip", (0.15, 0.15, 0.05), (0, 0.18, -0.04), rot=(0, 0, 45), color=navy),
        part("Clip", (0.26, 0.05, 0.06), (0, 0.4, -0.06), color="Gold"),
    ])


BUILDERS = [mail_satchel, name_badge, mailman_tie]
