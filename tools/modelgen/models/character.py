"""
The mailman StarterCharacter: a standard R6 rig (same part names, sizes, Motor6D joints and
attachments as Roblox's default R6 character, so R6 animations and accessories just work).
Feet are at y = 0. Colours here are defaults; MailmanConfig.BodyColors overrides them at runtime.
Uniform pieces and the hat are added when the player spawns (see CharacterService).
"""

from rbx import CF, Inst, attachment, decal, model, motor6d, part, special_mesh

CATEGORY = "StarterCharacter"
OUTPUT_DIR = ("src", "StarterPlayer")  # written next to, not inside, ReplicatedStorage.Assets

SKIN = "Bright yellow"
SHIRT = "Bright blue"
PANTS = "Navy blue"

# Standard R6 joint frames.
_ROOT = (-1, 0, 0, 0, 0, 1, 0, 1, 0)
_RIGHT = (0, 0, 1, 0, 1, 0, -1, 0, 0)
_LEFT = (0, 0, -1, 0, 1, 0, 1, 0, 0)


def _cf(x, y, z, rot):
    return CF.components(x, y, z, *rot)


def _body(name, size, pos, color, collide):
    p = part(name, size, pos, color=color)
    p.anchored = False
    p.can_collide = collide
    return p


def starter_character():
    root = _body("HumanoidRootPart", (2, 2, 1), (0, 3, 0), "Medium stone grey", False)
    root.transparency = 1
    torso = _body("Torso", (2, 2, 1), (0, 3, 0), SHIRT, True)
    head = _body("Head", (2, 1, 1), (0, 4.5, 0), SKIN, True)
    right_arm = _body("Right Arm", (1, 2, 1), (1.5, 3, 0), SKIN, False)
    left_arm = _body("Left Arm", (1, 2, 1), (-1.5, 3, 0), SKIN, False)
    right_leg = _body("Right Leg", (1, 2, 1), (0.5, 1, 0), PANTS, False)
    left_leg = _body("Left Leg", (1, 2, 1), (-0.5, 1, 0), PANTS, False)

    head.preview_head = True  # drawn as the round classic head in previews
    head.add(
        special_mesh(0, (1.25, 1.25, 1.25)),
        decal("face", "rbxasset://textures/face.png"),
        attachment("FaceCenterAttachment", (0, 4.5, 0)),
        attachment("FaceFrontAttachment", (0, 4.5, -0.6)),
        attachment("HairAttachment", (0, 5.1, 0)),
        attachment("HatAttachment", (0, 5.1, 0)),
    )
    root.add(
        attachment("RootAttachment", (0, 3, 0)),
        motor6d("RootJoint", root, torso, _cf(0, 0, 0, _ROOT), _cf(0, 0, 0, _ROOT)),
    )
    torso.add(
        attachment("NeckAttachment", (0, 4, 0)),
        attachment("BodyFrontAttachment", (0, 3, -0.5)),
        attachment("BodyBackAttachment", (0, 3, 0.5)),
        attachment("LeftCollarAttachment", (-1, 4, 0)),
        attachment("RightCollarAttachment", (1, 4, 0)),
        attachment("WaistFrontAttachment", (0, 2, -0.5)),
        attachment("WaistCenterAttachment", (0, 2, 0)),
        attachment("WaistBackAttachment", (0, 2, 0.5)),
        motor6d("Neck", torso, head, _cf(0, 1, 0, _ROOT), _cf(0, -0.5, 0, _ROOT)),
        motor6d("Right Shoulder", torso, right_arm, _cf(1, 0.5, 0, _RIGHT), _cf(-0.5, 0.5, 0, _RIGHT)),
        motor6d("Left Shoulder", torso, left_arm, _cf(-1, 0.5, 0, _LEFT), _cf(0.5, 0.5, 0, _LEFT)),
        motor6d("Right Hip", torso, right_leg, _cf(1, -1, 0, _RIGHT), _cf(0.5, 1, 0, _RIGHT)),
        motor6d("Left Hip", torso, left_leg, _cf(-1, -1, 0, _LEFT), _cf(-0.5, 1, 0, _LEFT)),
    )
    right_arm.add(
        attachment("RightShoulderAttachment", (1.5, 4, 0)),
        attachment("RightGripAttachment", (1.5, 2, 0), rot=(-90, 0, 0)),
    )
    left_arm.add(
        attachment("LeftShoulderAttachment", (-1.5, 4, 0)),
        attachment("LeftGripAttachment", (-1.5, 2, 0), rot=(-90, 0, 0)),
    )
    right_leg.add(attachment("RightFootAttachment", (0.5, 0, 0)))
    left_leg.add(attachment("LeftFootAttachment", (-0.5, 0, 0)))

    humanoid = Inst("Humanoid", "Humanoid", props={"RigType": ("token", 0)}, children=[Inst("Animator", "Animator")])
    return model("StarterCharacter", [humanoid, root, torso, head, right_arm, left_arm, right_leg, left_leg],
                 primary=root, attrs={"MailmanRig": "R6"})


BUILDERS = [starter_character]
