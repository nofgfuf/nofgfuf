"""
Weapons (Tools) for later. Authored in "hand space": the hand is at the origin, +Y is up and
-Z points forward while the tool is held out. Damage/cooldowns live in Config/WeaponConfig.
"""

from rbx import attachment, cyl_y, cyl_z, part, tool

CATEGORY = "Weapons"


def newspaper_bat():
    paper = "Light stone grey"
    handle = cyl_y("Handle", 0.9, 0.5, (0, 0, 0), color=paper)
    hitbox = part("Hitbox", (0.9, 2.6, 0.9), (0, 1.8, 0), transparency=1)
    parts = [
        hitbox,
        cyl_y("Roll", 2.6, 0.54, (0, 1.75, 0), color="Institutional white"),
        cyl_y("BandBottom", 0.14, 0.58, (0, 0.5, 0), color="Bright red"),
        cyl_y("BandTop", 0.14, 0.58, (0, 2.75, 0), color="Bright red"),
        cyl_y("Crumple", 0.18, 0.46, (0, 3.13, 0), color=paper),
        part("Headline", (0.22, 0.5, 0.04), (0, 2.1, -0.27), color="Really black"),
        part("Masthead", (0.1, 0.9, 0.04), (0, 1.55, -0.27), color="Bright blue"),
        part("Column1", (0.05, 0.6, 0.04), (0.13, 1.4, -0.255), rot=(0, 25, 0), color="Dark stone grey"),
        part("Column2", (0.05, 0.6, 0.04), (-0.13, 1.4, -0.255), rot=(0, -25, 0), color="Dark stone grey"),
        cyl_y("Grip", 0.6, 0.53, (0, -0.05, 0), color="Really black", material="Fabric"),
    ]
    handle.add(attachment("TrailTop", (0, 3.0, 0)), attachment("TrailBottom", (0, 0.6, 0)))
    return tool("NewspaperBat", handle, parts, tooltip="The Daily Whack", attrs={"WeaponId": "NewspaperBat"})


def parcel_launcher():
    blue, red = "Bright blue", "Bright red"
    handle = part("Handle", (0.3, 0.7, 0.36), (0, -0.05, 0), color="Really black")
    barrel = cyl_z("Barrel", 3.4, 0.8, (0, 0.55, -0.5), color=blue)
    barrel.add(attachment("Muzzle", (0, 0.55, -2.35)))
    parts = [
        barrel,
        cyl_z("MuzzleRing", 0.26, 0.98, (0, 0.55, -2.15), color="Bright yellow"),
        cyl_z("BackRing", 0.26, 0.98, (0, 0.55, 1.15), color="Bright yellow"),
        cyl_z("StripeRed1", 0.16, 0.84, (0, 0.55, -1.35), color=red),
        cyl_z("StripeWhite", 0.16, 0.84, (0, 0.55, -1.15), color="Institutional white"),
        cyl_z("StripeRed2", 0.16, 0.84, (0, 0.55, -0.95), color=red),
        part("LoadedParcel", (0.5, 0.5, 0.5), (0, 0.55, -2.35), color="Nougat"),
        part("LoadedParcelTape", (0.52, 0.12, 0.52), (0, 0.55, -2.35), color="Brick yellow"),
        part("TriggerGuard", (0.08, 0.06, 0.4), (0, 0.15, -0.3), color="Really black"),
        part("Trigger", (0.06, 0.18, 0.06), (0, 0.22, -0.25), color="Light stone grey"),
        part("FrontGrip", (0.26, 0.5, 0.3), (0, 0.05, -1.3), color="Really black"),
        part("Sight", (0.12, 0.25, 0.3), (0, 1.05, -0.9), color="Dark stone grey"),
        part("SightLens", (0.14, 0.14, 0.04), (0, 1.1, -1.06), color="Cyan", material="Neon"),
        part("Stamp", (0.04, 0.3, 0.36), (0.41, 0.55, 0.3), color=red),
        part("StampInner", (0.04, 0.18, 0.22), (0.425, 0.55, 0.3), color="Institutional white"),
    ]
    return tool("ParcelLauncher", handle, parts, tooltip="Special delivery!", attrs={"WeaponId": "ParcelLauncher"})


BUILDERS = [newspaper_bat, parcel_launcher]
