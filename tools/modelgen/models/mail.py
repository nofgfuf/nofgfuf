"""
Mail you pick up and deliver. Each is a Model whose PrimaryPart is named "Handle", so it can
later be held as a Tool or welded to the hand. Gameplay values live in Config/MailConfig.
"""

from rbx import cyl_y, model, part

CATEGORY = "Mail"


def mail(name, handle, parts, mail_type):
    handle.name = "Handle"
    return model(name, [handle, *parts], primary=handle, attrs={"MailType": mail_type})


def letter():
    body = part("Envelope", (1.2, 0.05, 0.8), (0, 0, 0), color="Institutional white")
    return mail("Letter", body, [
        # Back: the flap "V" and a wax seal.
        part("FlapL", (0.72, 0.012, 0.04), (-0.3, 0.03, -0.17), rot=(0, -36, 0), color="Light stone grey"),
        part("FlapR", (0.72, 0.012, 0.04), (0.3, 0.03, -0.17), rot=(0, 36, 0), color="Light stone grey"),
        cyl_y("Seal", 0.04, 0.2, (0, 0.04, 0.05), color="Crimson"),
        # Front (underside): stamp and address lines.
        part("Stamp", (0.2, 0.012, 0.24), (0.43, -0.03, -0.22), color="Bright red"),
        part("StampInner", (0.12, 0.014, 0.14), (0.43, -0.035, -0.22), color="Bright yellow"),
        part("Address1", (0.5, 0.01, 0.05), (-0.05, -0.03, 0.05), color="Bright blue"),
        part("Address2", (0.42, 0.01, 0.05), (-0.09, -0.03, 0.15), color="Bright blue"),
        part("Address3", (0.32, 0.01, 0.05), (-0.14, -0.03, 0.25), color="Bright blue"),
    ], "Letter")


def mail_bundle():
    base = part("Envelope1", (1.2, 0.05, 0.8), (0, 0, 0), color="Institutional white")
    return mail("MailBundle", base, [
        part("Envelope2", (1.15, 0.05, 0.78), (0.04, 0.055, 0.02), rot=(0, 6, 0), color="Brick yellow"),
        part("Envelope3", (1.2, 0.05, 0.8), (-0.03, 0.11, -0.01), rot=(0, -4, 0), color="Pastel blue"),
        part("Envelope4", (1.1, 0.05, 0.74), (0.02, 0.165, 0.0), rot=(0, 3, 0), color="Institutional white"),
        part("BandA", (0.08, 0.26, 0.84), (-0.3, 0.08, 0), color="Bright red"),
        part("BandB", (1.24, 0.26, 0.08), (0, 0.08, 0.12), color="Bright red"),
        part("TopStamp", (0.18, 0.012, 0.22), (0.4, 0.195, -0.22), color="Bright green"),
    ], "MailBundle")


def parcel():
    box = part("Box", (1.4, 1.0, 1.2), (0, 0, 0), color="Nougat")
    return mail("Parcel", box, [
        part("TapeTop", (0.32, 0.02, 1.22), (0, 0.51, 0), color="Brick yellow"),
        part("TapeFront", (0.32, 0.3, 0.02), (0, 0.36, -0.61), color="Brick yellow"),
        part("TapeBack", (0.32, 0.3, 0.02), (0, 0.36, 0.61), color="Brick yellow"),
        part("Label", (0.6, 0.4, 0.02), (-0.3, -0.12, -0.61), color="Institutional white"),
        part("LabelLine1", (0.44, 0.05, 0.02), (-0.3, -0.04, -0.625), color="Really black"),
        part("LabelLine2", (0.32, 0.05, 0.02), (-0.36, -0.14, -0.625), color="Really black"),
        part("LabelBar", (0.44, 0.08, 0.02), (-0.3, -0.25, -0.625), color="Bright red"),
        part("ArrowStem", (0.06, 0.24, 0.02), (0.45, -0.08, -0.61), color="Really black"),
        part("ArrowHead", (0.14, 0.14, 0.02), (0.45, 0.05, -0.61), rot=(0, 0, 45), color="Really black"),
    ], "Parcel")


def big_package():
    box = part("Box", (2.0, 1.6, 2.0), (0, 0, 0), color="Brown")
    parts = [
        part("TapeTop", (2.02, 0.03, 0.34), (0, 0.81, 0), color="Bright yellow"),
        part("TapeTop2", (0.34, 0.03, 2.02), (0, 0.81, 0), color="Bright yellow"),
        part("TapeFront", (0.34, 1.62, 0.03), (0, 0, -1.01), color="Bright yellow"),
        part("TapeBack", (0.34, 1.62, 0.03), (0, 0, 1.01), color="Bright yellow"),
        part("TapeLeft", (0.03, 1.62, 0.34), (-1.01, 0, 0), color="Bright yellow"),
        part("TapeRight", (0.03, 1.62, 0.34), (1.01, 0, 0), color="Bright yellow"),
        part("FragileSticker", (0.62, 0.36, 0.02), (-0.55, 0.45, -1.02), color="Bright red"),
        part("FragileText", (0.46, 0.08, 0.02), (-0.55, 0.45, -1.035), color="Institutional white"),
        part("Label", (0.55, 0.4, 0.02), (0.55, -0.4, -1.02), color="Institutional white"),
        part("LabelBar", (0.4, 0.08, 0.02), (0.55, -0.48, -1.035), color="Really black"),
    ]
    for i, x in enumerate((-0.9, 0.9)):
        for j, z in enumerate((-0.9, 0.9)):
            parts.append(part(f"Corner{i}{j}", (0.24, 1.64, 0.24), (x, 0, z), color="Reddish brown"))
    return mail("BigPackage", box, parts, "BigPackage")


BUILDERS = [letter, mail_bundle, parcel, big_package]
