"""
Tiny toolkit for authoring Roblox models in Python and writing them as .rbxmx.

Every model in src/ReplicatedStorage/Assets is generated from tools/modelgen/models/*.py
by running:  python3 tools/modelgen/build.py

The .rbxmx files are normal Roblox model files: Rojo syncs them into Studio, and you can
also drag them straight into Studio, edit them, and "Save to File" over the original.

Conventions
  * Roblox axes: +Y is up, -Z is "front" (the way a character looks).
  * Rotations are in degrees and applied as CFrame.Angles(rx, ry, rz).
  * Parts are written Anchored. AssetPrepService welds + unanchors accessories and tools
    at runtime, so you can add/move parts in Studio without re-welding by hand.
"""

from __future__ import annotations

import base64
import math
import struct
from xml.sax.saxutils import escape

import numpy as np

# --------------------------------------------------------------------------- colors

BRICK = {
    "White": (242, 243, 243),
    "Institutional white": (248, 248, 248),
    "Light stone grey": (229, 228, 223),
    "Medium stone grey": (163, 162, 165),
    "Dark stone grey": (99, 95, 98),
    "Black": (27, 42, 53),
    "Really black": (17, 17, 17),
    "Bright red": (196, 40, 28),
    "Crimson": (151, 0, 0),
    "Persimmon": (255, 89, 89),
    "Bright orange": (218, 133, 65),
    "Neon orange": (213, 115, 61),
    "Bright yellow": (245, 205, 48),
    "New Yeller": (255, 255, 0),
    "Gold": (239, 184, 56),
    "Daisy orange": (248, 217, 109),
    "Brick yellow": (215, 197, 154),
    "Nougat": (204, 142, 105),
    "Brown": (124, 92, 70),
    "Reddish brown": (105, 64, 40),
    "Pine Cone": (108, 88, 75),
    "Bright green": (75, 151, 75),
    "Dark green": (40, 127, 71),
    "Lime green": (0, 255, 0),
    "Bright blue": (13, 105, 172),
    "Deep blue": (33, 84, 185),
    "Navy blue": (0, 32, 96),
    "Pastel blue": (128, 187, 219),
    "Cyan": (4, 175, 236),
    "Toothpaste": (0, 255, 255),
    "Royal purple": (98, 37, 209),
    "Bright violet": (107, 50, 124),
    "Magenta": (170, 0, 170),
    "Hot pink": (255, 0, 191),
}

MATERIAL = {
    "Plastic": 256,
    "SmoothPlastic": 272,
    "Neon": 288,
    "Wood": 512,
    "WoodPlanks": 528,
    "Marble": 784,
    "Slate": 800,
    "Concrete": 816,
    "Brick": 848,
    "CorrodedMetal": 1040,
    "DiamondPlate": 1056,
    "Foil": 1072,
    "Metal": 1088,
    "Fabric": 1312,
    "Glass": 1568,
}

SHAPE = {"Ball": 0, "Block": 1, "Cylinder": 2}


def rgb(color) -> tuple[int, int, int]:
    if isinstance(color, str):
        return BRICK[color]
    return tuple(int(c) for c in color)


# --------------------------------------------------------------------------- cframes


class CF:
    """Position + 3x3 rotation matrix (columns are the right/up/back vectors)."""

    def __init__(self, pos=(0, 0, 0), R=None):
        self.p = np.array(pos, dtype=float)
        self.R = np.eye(3) if R is None else np.array(R, dtype=float)

    @staticmethod
    def angles(rx=0.0, ry=0.0, rz=0.0) -> np.ndarray:
        rx, ry, rz = (math.radians(a) for a in (rx, ry, rz))
        cx, sx, cy, sy, cz, sz = math.cos(rx), math.sin(rx), math.cos(ry), math.sin(ry), math.cos(rz), math.sin(rz)
        Rx = np.array([[1, 0, 0], [0, cx, -sx], [0, sx, cx]])
        Ry = np.array([[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]])
        Rz = np.array([[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]])
        return Rx @ Ry @ Rz

    @classmethod
    def components(cls, x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22) -> "CF":
        """Same argument order as Roblox's CFrame.new(x, y, z, R00, R01, ...)."""
        return cls((x, y, z), [[r00, r01, r02], [r10, r11, r12], [r20, r21, r22]])

    @classmethod
    def at(cls, pos, rot=(0, 0, 0)) -> "CF":
        return cls(pos, cls.angles(*rot))

    def __mul__(self, other: "CF") -> "CF":
        return CF(self.p + self.R @ other.p, self.R @ other.R)

    def inverse(self) -> "CF":
        Rt = self.R.T
        return CF(-Rt @ self.p, Rt)

    def point(self, v) -> np.ndarray:
        return self.p + self.R @ np.array(v, dtype=float)


def basis_from_x(direction, up_hint=(0, 1, 0)) -> np.ndarray:
    """Rotation whose local +X points along `direction`."""
    x = np.array(direction, dtype=float)
    x /= np.linalg.norm(x)
    up = np.array(up_hint, dtype=float)
    if abs(np.dot(x, up)) > 0.99:
        up = np.array([0, 0, 1.0])
    z = np.cross(x, up)
    z /= np.linalg.norm(z)
    y = np.cross(z, x)
    return np.column_stack([x, y, z])


# --------------------------------------------------------------------------- instances


class Inst:
    def __init__(self, cls: str, name: str, props: dict | None = None, children=None, attrs: dict | None = None):
        self.cls = cls
        self.name = name
        self.props = dict(props or {})  # name -> (xml_type, value)
        self.children: list[Inst] = list(children or [])
        self.attrs = dict(attrs or {})
        self.ref = ""  # assigned in to_rbxmx so output is deterministic

    def add(self, *children: "Inst") -> "Inst":
        self.children.extend(children)
        return self

    def descendants(self):
        for c in self.children:
            yield c
            yield from c.descendants()

    def find(self, name: str) -> "Inst | None":
        for d in self.descendants():
            if d.name == name:
                return d
        return None

    def parts(self):
        return [d for d in self.descendants() if isinstance(d, PartInst)]


class PartInst(Inst):
    def __init__(self, cls, name, size, cf: CF, color, material, shape, transparency, reflectance, attrs=None):
        super().__init__(cls, name, attrs=attrs)
        self.size = np.array(size, dtype=float)
        self.cf = cf
        self.color = rgb(color)
        self.material = material
        self.shape = shape
        self.transparency = transparency
        self.reflectance = reflectance
        self.anchored = True
        self.can_collide = True
        self.can_touch = True
        self.can_query = True
        self.massless = False
        self.cast_shadow = True


def part(name, size, pos=(0, 0, 0), rot=(0, 0, 0), color="Medium stone grey", material="SmoothPlastic",
         shape="Block", transparency=0.0, reflectance=0.0, R=None, attrs=None) -> PartInst:
    cf = CF(pos, R) if R is not None else CF.at(pos, rot)
    return PartInst("Part", name, size, cf, color, material, shape, transparency, reflectance, attrs)


def ball(name, dia, pos, **kw) -> PartInst:
    return part(name, (dia, dia, dia), pos, shape="Ball", **kw)


def cyl_y(name, height, dia, pos, **kw) -> PartInst:
    """Upright cylinder (Roblox cylinders run along X, so we tip it onto Y)."""
    return part(name, (height, dia, dia), pos, rot=(0, 0, 90), shape="Cylinder", **kw)


def cyl_z(name, length, dia, pos, **kw) -> PartInst:
    """Cylinder running front-to-back along Z."""
    return part(name, (length, dia, dia), pos, rot=(0, 90, 0), shape="Cylinder", **kw)


def cyl_x(name, length, dia, pos, **kw) -> PartInst:
    return part(name, (length, dia, dia), pos, shape="Cylinder", **kw)


def cyl_between(name, a, b, dia, **kw) -> PartInst:
    a, b = np.array(a, float), np.array(b, float)
    return part(name, (np.linalg.norm(b - a), dia, dia), (a + b) / 2, R=basis_from_x(b - a), shape="Cylinder", **kw)


def block_between(name, a, b, width, thickness, up_hint=(0, 0, 1), **kw) -> PartInst:
    """Block whose long axis (X) runs from a to b. width = Y size, thickness = Z size."""
    a, b = np.array(a, float), np.array(b, float)
    return part(name, (np.linalg.norm(b - a), width, thickness), (a + b) / 2, R=basis_from_x(b - a, up_hint), **kw)


def attachment(name, pos=(0, 0, 0), rot=(0, 0, 0)) -> Inst:
    """Attachment given in *model* space; converted to its parent part's space on write."""
    a = Inst("Attachment", name)
    a.world_cf = CF.at(pos, rot)
    return a


def motor6d(name, part0: PartInst, part1: PartInst, c0: CF, c1: CF) -> Inst:
    return Inst("Motor6D", name, props={
        "Part0": ("InstRef", part0),
        "Part1": ("InstRef", part1),
        "C0": ("CoordinateFrame", c0),
        "C1": ("CoordinateFrame", c1),
        "MaxVelocity": ("float", 0.1),
    })


def special_mesh(mesh_type: int, scale=(1, 1, 1), name="Mesh") -> Inst:
    """mesh_type: Head=0, Torso=1, Wedge=2, Sphere=3, Cylinder=4, FileMesh=5, Brick=6."""
    return Inst("SpecialMesh", name, props={"MeshType": ("token", mesh_type), "Scale": ("Vector3", scale)})


def decal(name, texture: str, face: int = 5) -> Inst:
    """face: Right=0, Top=1, Back=2, Left=3, Bottom=4, Front=5."""
    return Inst("Decal", name, props={"Texture": ("Content", texture), "Face": ("token", face)})


def model(name, children, primary: PartInst | None = None, attrs=None) -> Inst:
    m = Inst("Model", name, children=children, attrs=attrs)
    m.primary = primary
    return m


def folder(name, children=()) -> Inst:
    return Inst("Folder", name, children=children)


def sparkles(name="Sparkles") -> Inst:
    return Inst("Sparkles", name)


def point_light(color, brightness=1.0, range_=8.0) -> Inst:
    r, g, b = rgb(color)
    return Inst("PointLight", "Glow", props={
        "Color": ("Color3", (r / 255, g / 255, b / 255)),
        "Brightness": ("float", brightness),
        "Range": ("float", range_),
    })


def _ghost(p: PartInst):
    """Accessory/tool parts must never collide, add mass or block raycasts."""
    p.can_collide = False
    p.can_touch = False
    p.can_query = False
    p.massless = True
    p.cast_shadow = True


def accessory(name, attach_to: str, parts: list[PartInst], extras=(), attrs=None, handle_pos=(0, 0, 0)) -> Inst:
    """
    An Accessory whose invisible Handle sits at `handle_pos` with an attachment named
    `attach_to` (e.g. "HatAttachment"). Author the visible parts in "attachment space":
    the origin is where the character's attachment of the same name will be.
    """
    handle = part("Handle", (0.2, 0.2, 0.2), handle_pos, transparency=1)
    handle.add(attachment(attach_to, (0, 0, 0)), *extras)
    acc = Inst("Accessory", name, children=[handle, *parts], attrs=attrs)
    for p in acc.parts():
        _ghost(p)
        p.cast_shadow = p.transparency < 1
    return acc


def tool(name, handle: PartInst, parts: list[PartInst], tooltip="", extras=(), attrs=None) -> Inst:
    """
    A Tool. Author it in "hand space": the hand grips the origin, +Y is up and -Z points
    forward while held. The Grip is derived from the handle so the tool is held as authored.
    """
    handle.name = "Handle"
    grip = handle.cf.inverse()
    handle.add(*extras)
    t = Inst("Tool", name, props={
        "ToolTip": ("string", tooltip),
        "CanBeDropped": ("bool", False),
        "RequiresHandle": ("bool", True),
        "Grip": ("CoordinateFrame", grip),
    }, children=[handle, *parts], attrs=attrs)
    for p in t.parts():
        _ghost(p)
        p.can_query = p.name == "Hitbox"
    return t


# --------------------------------------------------------------------------- attributes


def encode_attributes(attrs: dict) -> str:
    out = bytearray(struct.pack("<I", len(attrs)))
    for key, value in attrs.items():
        k = key.encode()
        out += struct.pack("<I", len(k)) + k
        if isinstance(value, bool):
            out += bytes([0x03, 1 if value else 0])
        elif isinstance(value, (int, float)):
            out += bytes([0x06]) + struct.pack("<d", float(value))
        elif isinstance(value, str):
            v = value.encode()
            out += bytes([0x02]) + struct.pack("<I", len(v)) + v
        else:
            raise TypeError(f"unsupported attribute type for {key}: {type(value)}")
    return base64.b64encode(bytes(out)).decode()


# --------------------------------------------------------------------------- xml writer


def _num(v: float) -> str:
    v = float(v)
    if abs(v) < 1e-9:
        v = 0.0
    s = f"{v:.6f}".rstrip("0").rstrip(".")
    return s if s not in ("", "-0") else "0"


def _cframe_xml(name: str, cf: CF) -> str:
    keys = ["X", "Y", "Z"]
    body = "".join(f"<{k}>{_num(v)}</{k}>" for k, v in zip(keys, cf.p))
    for r in range(3):
        for c in range(3):
            body += f"<R{r}{c}>{_num(cf.R[r, c])}</R{r}{c}>"
    return f'<CoordinateFrame name="{name}">{body}</CoordinateFrame>'


def _prop_xml(name, kind, value) -> str:
    if kind == "string":
        return f'<string name="{name}">{escape(str(value))}</string>'
    if kind == "bool":
        return f'<bool name="{name}">{"true" if value else "false"}</bool>'
    if kind == "float":
        return f'<float name="{name}">{_num(value)}</float>'
    if kind == "token":
        return f'<token name="{name}">{int(value)}</token>'
    if kind == "Vector3":
        return f'<Vector3 name="{name}"><X>{_num(value[0])}</X><Y>{_num(value[1])}</Y><Z>{_num(value[2])}</Z></Vector3>'
    if kind == "Color3":
        return f'<Color3 name="{name}"><R>{_num(value[0])}</R><G>{_num(value[1])}</G><B>{_num(value[2])}</B></Color3>'
    if kind == "Color3uint8":
        r, g, b = value
        return f'<Color3uint8 name="{name}">{0xFF000000 | (r << 16) | (g << 8) | b}</Color3uint8>'
    if kind == "CoordinateFrame":
        return _cframe_xml(name, value)
    if kind == "Ref":
        return f'<Ref name="{name}">{value}</Ref>'
    if kind == "InstRef":
        return f'<Ref name="{name}">{value.ref}</Ref>'
    if kind == "Content":
        return f'<Content name="{name}"><url>{escape(value)}</url></Content>'
    if kind == "BinaryString":
        return f'<BinaryString name="{name}">{value}</BinaryString>'
    raise ValueError(kind)


def _props_for(inst: Inst, parent: Inst | None) -> list[str]:
    out = [_prop_xml("Name", "string", inst.name)]
    if isinstance(inst, PartInst):
        out += [
            _prop_xml("Anchored", "bool", inst.anchored),
            _prop_xml("CanCollide", "bool", inst.can_collide),
            _prop_xml("CanTouch", "bool", inst.can_touch),
            _prop_xml("CanQuery", "bool", inst.can_query),
            _prop_xml("Massless", "bool", inst.massless),
            _prop_xml("CastShadow", "bool", inst.cast_shadow),
            _prop_xml("CFrame", "CoordinateFrame", inst.cf),
            _prop_xml("size", "Vector3", inst.size),
            _prop_xml("Color3uint8", "Color3uint8", inst.color),
            _prop_xml("Material", "token", MATERIAL[inst.material]),
            _prop_xml("Transparency", "float", inst.transparency),
            _prop_xml("Reflectance", "float", inst.reflectance),
            _prop_xml("shape", "token", SHAPE[inst.shape]),
        ]
        for face in ("TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface"):
            out.append(_prop_xml(face, "token", 0))
    elif inst.cls == "Attachment":
        local = parent.cf.inverse() * inst.world_cf if isinstance(parent, PartInst) else inst.world_cf
        out.append(_prop_xml("CFrame", "CoordinateFrame", local))
    elif inst.cls == "Model" and getattr(inst, "primary", None) is not None:
        out.append(_prop_xml("PrimaryPart", "Ref", inst.primary.ref))
    for name, (kind, value) in inst.props.items():
        out.append(_prop_xml(name, kind, value))
    if inst.attrs:
        out.append(_prop_xml("AttributesSerialize", "BinaryString", encode_attributes(inst.attrs)))
    return out


def _item_xml(inst: Inst, parent: Inst | None, depth: int) -> str:
    ind = "\t" * depth
    lines = [f'{ind}<Item class="{inst.cls}" referent="{inst.ref}">', f"{ind}\t<Properties>"]
    lines += [f"{ind}\t\t{p}" for p in _props_for(inst, parent)]
    lines.append(f"{ind}\t</Properties>")
    for c in inst.children:
        lines.append(_item_xml(c, inst, depth + 1))
    lines.append(f"{ind}</Item>")
    return "\n".join(lines)


def to_rbxmx(root: Inst) -> str:
    for i, inst in enumerate([root, *root.descendants()]):
        inst.ref = f"RBX{i}"
    header = ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
              'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
              'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">')
    return "\n".join([header, "\t<External>null</External>", "\t<External>nil</External>",
                      _item_xml(root, None, 1), "</roblox>", ""])
