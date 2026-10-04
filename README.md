# Mailman Delivery (untitled)

A retro (2019-style) Roblox game where you play a mailman delivering mail to houses.
This repo is a [Rojo](https://rojo.space) project: it syncs straight into your place in Roblox Studio.

**Done so far:** models, the R6 mailman StarterCharacter, parkour movement (slide, air slide,
double jump, ledge grab + climb, landing roll). Next up: delivery, shop and UI.

![Mailman outfits](docs/previews/MailmanOutfits.png)

## Getting it into Studio

1. In the repo folder run `rojo serve` (or `.\rojo.exe serve` if you downloaded rojo.exe into the folder).
2. In Studio: **Plugins → Rojo → Connect**. Rojo needs the *Script Injection* permission
   (Plugins → Manage Plugins → Rojo).
3. After pulling updates (`git pull`), Rojo syncs them live. **Save/Publish the place** to keep them.

Rojo only manages the folders listed below. Anything else in your place (your animation folder,
your map, and so on) is left alone.

## Where everything lives

```
ReplicatedStorage
├── Shared
│   ├── Config                <- tweak the game here
│   │   ├── GameConfig            Studio self-test on/off
│   │   ├── MailmanConfig         body colours, clothing, uniform pieces, starting hat, respawn time
│   │   ├── MovementConfig        walk/jump speed + every parkour move's tuning and keys
│   │   ├── AnimationConfig       where your animation folder is + which names map to which move
│   │   ├── HatConfig             every hat: price, rarity, boosts, upgrade levels/costs
│   │   ├── MailConfig            mail types: payout, XP, bag space, spawn chance
│   │   └── WeaponConfig          weapon stats (disabled for now)
│   └── Util                  AssetUtil, WeldUtil, AccessoryUtil, AnimationFinder
└── Assets                    <- all models (.rbxmx)
    ├── Accessories           MailSatchel, NameBadge, MailmanTie
    ├── Hats                  11 hats (MailmanCap ... GoldenMailmanCap)
    ├── Mail                  Letter, MailBundle, Parcel, BigPackage
    ├── Props                 Mailbox, PostBox, MailSack
    └── Weapons               NewspaperBat, ParcelLauncher (Tools)
ServerScriptService
└── Server
    ├── Main                  boots the services below in order
    └── Services
        ├── AssetPrepService      welds hats/uniform/weapons at startup, warns about config/model mismatches
        ├── AnimationService      puts your run/idle/jump/... animations into every character
        ├── HatService            equipped hat + boosts (player attributes)
        ├── CharacterService      sets up the mailman, spawns/respawns players, puts on the uniform
        └── SelfTestService       Studio-only PASS/FAIL checks after every spawn
StarterPlayer
├── StarterCharacter          the R6 mailman (visible/editable in Studio)
└── StarterPlayerScripts
    └── Client
        ├── Main              starts client systems
        └── Movement          MovementController, Mover, AnimPlayer, Abilities/ (one file per move)
```

Source: `src/` mirrors the tree above. Mapping: `default.project.json`.

## The mailman (R6)

`StarterPlayer.StarterCharacter` is a standard R6 rig: the same part names, joints and
attachments as Roblox's default R6 character, so R6 animations and accessories work on it.
At server start its colours and clothing are set from `MailmanConfig`. Every time a player
spawns, the uniform (satchel, badge, tie) and their equipped hat are put on with
`Humanoid:AddAccessory`.

- **Shirt/Pants textures:** `assets/clothing/MailmanShirt.png` and `MailmanPants.png` are standard
  585×559 templates. Upload them in Studio (Asset Manager → Bulk Import), copy each **image** id, and
  paste them into `MailmanConfig.Clothing` as `"rbxassetid://<id>"`.

## Movement (parkour)

| Move | PC | Gamepad | Mobile |
|---|---|---|---|
| Slide (on the ground, while moving) | Ctrl or C | B | Slide button |
| Air slide / dive (in the air; landing during it turns into a slide) | Ctrl or C | B | Slide button |
| Double jump | Space in the air | A | Jump |
| Ledge grab | jump at a wall while holding toward it | | |
| Climb up / let go (while hanging) | Space / Ctrl or C (or walk away from the wall) | A / B | Jump / Slide |
| Landing roll | automatic when landing from 14+ studs | | |

Speeds, durations, reach, keys and on/off switches for every move are in `MovementConfig`.
Hat boosts apply: `HatBoost_Speed` scales WalkSpeed, `HatBoost_Jump` scales JumpPower and the
double jump. Each move is its own file in `Client/Movement/Abilities`, so moves can be added or
removed without touching the others.

## Animations (your folder)

Keep your animation folder in **ReplicatedStorage**, named `Animations` or `Anims`. The movement
animations are played by the client, which can't see ServerStorage. Animations must be **R6** and owned
by you or the group that owns the game. Animation objects are matched by name (case-insensitive,
subfolders are fine):

| Used for | Names it looks for |
|---|---|
| running (also used for walking, see `UseRunForWalk`) | Run, Running, RunAnim, Sprint |
| idle / jump / fall / climb / swim / sit | Idle, Jump, Fall, Climb, Swim, Sit (+ "…Anim" variants) |
| **Slide** | Slide, SlideAnim, Sliding |
| **AirSlide** (falls back to Slide) | AirSlide, Dive, DiveAnim |
| **DoubleJump** | DoubleJump, AirJump, Flip |
| **LedgeHang** | LedgeHang, Hang, LedgeGrab, LedgeIdle |
| **ClimbUp** | ClimbUp, LedgeClimb, Mantle |
| **Roll** | Roll, LandingRoll, RollAnim |

The movement animations are **placeholders** until you add them. The moves already work; they
just don't animate yet. You can also paste ids straight into `AnimationConfig.MoveIds` instead of
using the folder. Updated animations apply on the next spawn, with no code changes.

## Testing in Studio

Press Play and open **View → Output**. With `GameConfig.SelfTestInStudio` on (the default), you get:

- `[SelfTest] PASS/FAIL ...` lines, 3 seconds after each spawn. They cover the R6 rig, joints, body
  colours, the Animate script, each uniform piece and the hat (welded to the body and at the right
  spot), and whether your Run animation was found.
- `[Movement] Ready ...` with your speeds and which move animations were found vs still placeholders.
- `[AnimationService] Using ... | found: ... | default: ...`, showing which character animations came from your folder.

If something looks wrong, send a screenshot of these lines.

## Hats & boosts

`HatConfig` holds all 11 hats, from Starter up to Mythic. Each hat has a price, base boosts
(`Speed`, `Jump`, `Cash`, `XP`) and 5 upgrade levels (each level adds 25% of the base boost).
Upgrade cost grows ×1.6 per level. `HatService` writes the final numbers to player attributes
(`EquippedHat`, `EquippedHatLevel`, `HatBoost_Speed`, `HatBoost_Cash`, …).

**Try hats now:** in Play mode switch to the Server view, select your Player, and change the
`EquippedHat` attribute (e.g. `TopHat`).

| Hat | Rarity | Price | Boosts |
|---|---|---|---|
| Mailman Cap | Starter | free | +5% cash |
| Newspaper Hat | Common | 250 | +10% XP |
| Propeller Beanie | Common | 400 | +8% jump |
| Traffic Cone | Uncommon | 1,200 | +6% speed |
| Rodeo Courier | Uncommon | 1,800 | +4% speed, +6% cash |
| Postmaster's Top Hat | Rare | 5,000 | +20% cash |
| Viking Helmet | Rare | 6,500 | +12% jump, +5% speed |
| Stamp Wizard | Epic | 15,000 | +25% XP, +10% jump |
| Royal Mail Crown | Epic | 25,000 | +30% cash, +10% XP |
| Mailbox Head | Legendary | 60,000 | +35% cash, +10% speed, +15% XP |
| Golden Mailman Cap | Mythic | 150,000 | +50% cash, +15% speed, +15% jump, +25% XP |

![Hats](docs/previews/Hats.png)

## Mail, mailboxes, weapons

![Mail](docs/previews/Mail.png)
![Props](docs/previews/Props.png)
![Weapons](docs/previews/Weapons.png)

- **Mailbox:** pivot is at ground level (`PrimaryPart` = invisible `Root`), so `mailbox:PivotTo(CFrame.new(pos))`
  places it on the ground. It has a `Door`, a `Flag` + `FlagPole` (hinge attachment `FlagHinge`), a
  `NumberPlate`, `PromptAttachment`/`DeliveryPoint` attachments and an invisible `DeliveryZone`.
  Attributes: `HouseNumber`, `FlagUp`.
- **PostBox:** the blue pickup box at the depot (`IsPickup = true`). **MailSack** is a decoration.
- **Mail** models have a `Handle` PrimaryPart and a `MailType` attribute, ready to become carryable.
- **Weapons:** `NewspaperBat` ("The Daily Whack", has a `Hitbox` part) and `ParcelLauncher`
  (has a `Muzzle` attachment). Combat comes later.

## Editing models

All parts in the `.rbxmx` asset files are anchored and unwelded. `AssetPrepService` welds them at
runtime, so you can move or add parts freely.

- **In Studio:** edit the model, then right-click → *Save to File…* over the matching
  `.rbxmx` in `src/...` (Rojo then keeps it in sync).
- **From code:** every model, including the StarterCharacter, is generated by `tools/modelgen`
  (Python). Edit `tools/modelgen/models/*.py` and run `python3 tools/modelgen/build.py`. That
  rewrites the `.rbxmx` files, the clothing PNGs and the previews in `docs/previews`. Running it
  overwrites edits made in Studio, so use one workflow per model.
