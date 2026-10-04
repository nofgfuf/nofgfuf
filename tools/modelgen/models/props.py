"""
World props. Origin = ground level under the prop; each model's PrimaryPart is an invisible
"Root" at the base, so `model:PivotTo(CFrame.new(spot))` puts it on the ground.
"""

from rbx import attachment, cyl_y, cyl_z, model, part

CATEGORY = "Props"


def _root(size_xz=(1.2, 1.2)):
    return part("Root", (size_xz[0], 0.2, size_xz[1]), (0, 0.1, 0), transparency=1)


def _delivery_zone(size, pos):
    zone = part("DeliveryZone", size, pos, transparency=1)
    zone.can_collide = False
    zone.can_query = False
    zone.cast_shadow = False
    return zone


def mailbox():
    """The house mailbox players deliver to. Raise `Flag` (hinge at FlagHinge) when it has mail."""
    body, wood = "Dark stone grey", "Reddish brown"
    root = _root()
    root.can_collide = False
    door = part("Door", (1.24, 0.9, 0.08), (0, 3.85, -1.13), color=body)
    door.add(attachment("PromptAttachment", (0, 3.9, -1.3)), attachment("DeliveryPoint", (0, 3.9, -1.6)))
    flag_pole = part("FlagPole", (0.08, 1.0, 0.12), (0.66, 4.15, 0.55), color="Bright red")
    flag_pole.add(attachment("FlagHinge", (0.66, 3.7, 0.55)))
    return model("Mailbox", [
        root,
        part("Post", (0.5, 3.4, 0.5), (0, 1.7, 0.2), color=wood, material="Wood"),
        part("PostFoot", (1.0, 0.3, 1.0), (0, 0.15, 0.2), color="Medium stone grey", material="Concrete"),
        part("Mount", (0.9, 0.2, 2.0), (0, 3.3, 0), color=wood, material="Wood"),
        part("Brace", (0.3, 0.9, 0.3), (0, 2.9, 0.6), rot=(-35, 0, 0), color=wood, material="Wood"),
        part("Body", (1.2, 0.9, 2.2), (0, 3.85, 0), color=body),
        cyl_z("Roof", 2.2, 1.2, (0, 4.3, 0), color=body),
        door,
        cyl_z("DoorArch", 0.08, 1.24, (0, 4.3, -1.13), color=body),
        part("DoorTrim", (1.26, 0.06, 0.1), (0, 3.4, -1.13), color="Black"),
        part("Latch", (0.34, 0.12, 0.12), (0, 4.5, -1.22), color="Light stone grey"),
        part("BackCap", (1.22, 0.92, 0.06), (0, 3.85, 1.12), color="Black"),
        cyl_z("BackCapArch", 0.06, 1.22, (0, 4.3, 1.12), color="Black"),
        flag_pole,
        part("Flag", (0.06, 0.4, 0.55), (0.66, 4.5, 0.25), color="Bright red"),
        part("FlagPivot", (0.14, 0.16, 0.16), (0.63, 3.7, 0.55), color="Light stone grey"),
        part("NumberPlate", (0.54, 0.34, 0.05), (0, 2.6, -0.06), color="Bright yellow"),
        part("NumberPlateBorder", (0.6, 0.4, 0.04), (0, 2.6, -0.04), color="Really black"),
        _delivery_zone((7, 6, 7), (0, 3, 0)),
    ], primary=root, attrs={"Prop": "Mailbox", "HouseNumber": 1, "FlagUp": False})


def post_box():
    """Blue collection box: where the mailman picks up mail at the depot."""
    blue = "Bright blue"
    root = _root((2.4, 2.4))
    root.can_collide = False
    slot = part("Slot", (1.3, 0.14, 0.1), (0, 3.3, -1.06), color="Really black")
    slot.add(attachment("PromptAttachment", (0, 3.2, -1.3)))
    parts = [
        root,
        part("Body", (2.0, 2.4, 2.0), (0, 2.0, 0), color=blue),
        cyl_z("Roof", 2.0, 2.0, (0, 3.2, 0), color=blue),
        part("Hood", (1.6, 0.42, 0.24), (0, 3.45, -1.1), color=blue),
        slot,
        part("PullPlate", (1.0, 0.3, 0.06), (0, 2.75, -1.03), color="Light stone grey"),
        part("Emblem", (0.7, 0.7, 0.05), (0, 1.9, -1.03), color="Institutional white"),
        part("EmblemEnvelope", (0.48, 0.3, 0.04), (0, 1.9, -1.06), color=blue),
        part("EmblemFlap", (0.26, 0.26, 0.03), (0, 1.98, -1.075), rot=(0, 0, 45), color="Institutional white"),
        part("Stripe", (2.04, 0.12, 2.04), (0, 1.1, 0), color="Bright red"),
        part("Base", (2.1, 0.12, 2.1), (0, 0.84, 0), color="Navy blue"),
        _delivery_zone((7, 6, 7), (0, 3, 0)),
    ]
    for i, x in enumerate((-0.85, 0.85)):
        for j, z in enumerate((-0.85, 0.85)):
            parts.append(part(f"Leg{i}{j}", (0.22, 0.8, 0.22), (x, 0.4, z), color="Navy blue"))
            parts.append(part(f"Foot{i}{j}", (0.4, 0.06, 0.4), (x, 0.03, z), color="Navy blue"))
    return model("PostBox", parts, primary=root, attrs={"Prop": "PostBox", "IsPickup": True})


def mail_sack():
    """A stuffed mail sack prop for the depot / delivery van."""
    sack = "Brick yellow"
    root = _root((1.6, 1.6))
    root.can_collide = False
    parts = [
        root,
        cyl_y("Bottom", 1.2, 1.6, (0, 0.6, 0), color=sack, material="Fabric"),
        cyl_y("Middle", 0.5, 1.4, (0, 1.4, 0), color=sack, material="Fabric"),
        cyl_y("Neck", 0.3, 0.7, (0, 1.75, 0), color=sack, material="Fabric"),
        cyl_y("Tie", 0.12, 0.74, (0, 1.72, 0), color="Bright red"),
        cyl_y("Top", 0.2, 0.9, (0, 1.98, 0), color=sack, material="Fabric"),
        part("Stencil", (0.9, 0.4, 0.04), (0, 0.8, -0.8), color="Bright blue"),
        part("StencilLine", (0.66, 0.08, 0.04), (0, 0.8, -0.82), color="Institutional white"),
        part("LetterPoke", (0.4, 0.3, 0.04), (0.15, 2.1, 0), rot=(0, 30, 10), color="Institutional white"),
    ]
    return model("MailSack", parts, primary=root, attrs={"Prop": "MailSack"})


BUILDERS = [mailbox, post_box, mail_sack]
