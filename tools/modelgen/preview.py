"""Rough software previews of generated models (matplotlib), used to sanity-check geometry."""

import math

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from mpl_toolkits.mplot3d.art3d import Poly3DCollection  # noqa: E402

from rbx import CF, PartInst  # noqa: E402

LIGHT = np.array([0.4, 0.8, 0.45])
LIGHT /= np.linalg.norm(LIGHT)


def _box(sx, sy, sz):
    x, y, z = sx / 2, sy / 2, sz / 2
    v = np.array([[-x, -y, -z], [x, -y, -z], [x, y, -z], [-x, y, -z], [-x, -y, z], [x, -y, z], [x, y, z], [-x, y, z]])
    faces = [[0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [3, 2, 6, 7], [0, 3, 7, 4], [1, 5, 6, 2]]
    return [v[f] for f in faces]


def _cylinder(length, dia, n=18):
    r, h = dia / 2, length / 2
    ring = [(math.cos(2 * math.pi * i / n) * r, math.sin(2 * math.pi * i / n) * r) for i in range(n)]
    polys = [np.array([[-h, a, b] for a, b in ring]), np.array([[h, a, b] for a, b in reversed(ring)])]
    for i in range(n):
        (a1, b1), (a2, b2) = ring[i], ring[(i + 1) % n]
        polys.append(np.array([[-h, a1, b1], [-h, a2, b2], [h, a2, b2], [h, a1, b1]]))
    return polys


def _sphere(dia, n=12):
    r = dia / 2
    polys = []
    for i in range(n):
        t1, t2 = math.pi * i / n, math.pi * (i + 1) / n
        for j in range(2 * n):
            p1, p2 = 2 * math.pi * j / (2 * n), 2 * math.pi * (j + 1) / (2 * n)
            pts = [(t1, p1), (t1, p2), (t2, p2), (t2, p1)]
            polys.append(np.array([[r * math.sin(t) * math.cos(p), r * math.cos(t), r * math.sin(t) * math.sin(p)]
                                   for t, p in pts]))
    return polys


def part_polys(p: PartInst, offset: CF = CF()):
    if p.transparency >= 1:
        return []
    sx, sy, sz = p.size
    if p.shape == "Ball":
        local = _sphere(min(p.size))
    elif p.shape == "Cylinder":
        local = _cylinder(sx, min(sy, sz))
    else:
        local = _box(sx, sy, sz)
    cf = offset * p.cf
    color = np.array(p.color) / 255
    out = []
    for poly in local:
        w = np.array([cf.point(v) for v in poly])
        n = np.cross(w[1] - w[0], w[2] - w[0])
        if np.linalg.norm(n) < 1e-9 and len(w) > 3:
            n = np.cross(w[2] - w[0], w[3] - w[0])
        nn = np.linalg.norm(n)
        shade = 0.55 + 0.45 * abs(np.dot(n / nn, LIGHT)) if nn > 1e-9 else 0.8
        out.append((w, np.clip(color * shade, 0, 1)))
    return out


def _to_mpl(w):
    # Roblox (x, y-up, z-back) -> matplotlib (x, -z, y-up); keeps handedness.
    return np.column_stack([w[:, 0], -w[:, 2], w[:, 1]])


def draw(ax, polys, title, azim=55, elev=18):
    verts = [_to_mpl(w) for w, _ in polys]
    cols = [c for _, c in polys]
    coll = Poly3DCollection(verts, facecolors=cols, edgecolors=(0, 0, 0, 0.25), linewidths=0.3)
    ax.add_collection3d(coll)
    allv = np.vstack(verts)
    lo, hi = allv.min(0), allv.max(0)
    mid, span = (lo + hi) / 2, max((hi - lo).max(), 0.5) / 2
    ax.set_xlim(mid[0] - span, mid[0] + span)
    ax.set_ylim(mid[1] - span, mid[1] + span)
    ax.set_zlim(mid[2] - span, mid[2] + span)
    ax.set_box_aspect((1, 1, 1))
    ax.view_init(elev=elev, azim=azim)
    ax.set_axis_off()
    ax.set_title(title, fontsize=9)


def sheet(entries, path, cols=4, size=3.0):
    """entries: list of (title, polys, azim)."""
    rows = math.ceil(len(entries) / cols)
    fig = plt.figure(figsize=(cols * size, rows * size), facecolor="white")
    for i, (title, polys, azim) in enumerate(entries):
        ax = fig.add_subplot(rows, cols, i + 1, projection="3d")
        draw(ax, polys, title, azim=azim)
    fig.tight_layout()
    fig.savefig(path, dpi=110)
    plt.close(fig)


# ----------------------------------------------------------------- approximate R15 mailman

SKIN = (245, 205, 48)
SHIRT = (13, 105, 172)
PANTS = (0, 32, 96)


def _body_part(name, size, pos, color):
    from rbx import part
    p = part(name, size, pos, color=color)
    return p


def mailman_body():
    """Blocky R15-ish body (feet at y=0) and the attachment frames accessories snap to."""
    parts = [
        _body_part("LeftLeg", (1, 2, 1), (-0.5, 1, 0), PANTS),
        _body_part("RightLeg", (1, 2, 1), (0.5, 1, 0), PANTS),
        _body_part("LowerTorso", (2, 0.4, 1), (0, 2.2, 0), PANTS),
        _body_part("UpperTorso", (2, 1.6, 1), (0, 3.2, 0), SHIRT),
        _body_part("LeftUpperArm", (1, 0.9, 1), (-1.5, 3.55, 0), SHIRT),
        _body_part("RightUpperArm", (1, 0.9, 1), (1.5, 3.55, 0), SHIRT),
        _body_part("LeftLowerArm", (1, 1.1, 1), (-1.5, 2.55, 0), SKIN),
        _body_part("RightLowerArm", (1, 1.1, 1), (1.5, 2.55, 0), SKIN),
        _body_part("Head", (1.2, 1.2, 1.2), (0, 4.6, 0), SKIN),
        _body_part("ShoeL", (1.02, 0.3, 1.02), (-0.5, 0.15, 0), (27, 42, 53)),
        _body_part("ShoeR", (1.02, 0.3, 1.02), (0.5, 0.15, 0), (27, 42, 53)),
        _body_part("EyeL", (0.14, 0.24, 0.02), (-0.22, 4.7, -0.61), (17, 17, 17)),
        _body_part("EyeR", (0.14, 0.24, 0.02), (0.22, 4.7, -0.61), (17, 17, 17)),
        _body_part("Smile", (0.5, 0.06, 0.02), (0, 4.38, -0.61), (17, 17, 17)),
    ]
    attachments = {
        "HatAttachment": CF((0, 5.2, 0)),
        "BodyFrontAttachment": CF((0, 3.0, -0.5)),  # R15: UpperTorso centre + (0, -0.2, -0.5)
    }
    return parts, attachments


def accessory_polys(acc, attachments):
    handle = acc.find("Handle")
    att = next(c for c in handle.children if c.cls == "Attachment")
    # The accessory's attachment (model space) is snapped onto the body's attachment.
    offset = attachments[att.name] * att.world_cf.inverse()
    polys = []
    for p in acc.parts():
        polys += part_polys(p, offset)
    return polys
