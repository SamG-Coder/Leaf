# Procedural ferns

Ten fern presets use the existing CUDA instance buffers, shared exposure cache and tapered stem renderer. The gallery is ferns.html; click a card to open its live preset.

| ID | API key | Botanical reference | Implemented form |
|---|---|---|---|
| 31 | boston-fern | [Boston fern — Nephrolepis exaltata](https://plants.ces.ncsu.edu/plants/nephrolepis-exaltata/) | Long arching fronds with many narrow pinnae; a drooping garden form. |
| 32 | ostrich-fern | [Ostrich fern — Onoclea struthiopteris](https://plants.ces.ncsu.edu/plants/onoclea-struthiopteris/) | Tall upright shuttlecock crown with tapered feather-like fronds. |
| 33 | northern-maidenhair-fern | [Northern maidenhair fern — Adiantum pedatum](https://plants.ces.ncsu.edu/plants/adiantum-pedatum/) | Spreading horizontal fingers with small fan-shaped pinnules and dark stalks. |
| 34 | autumn-fern | [Autumn fern — Dryopteris erythrosora](https://plants.ces.ncsu.edu/plants/dryopteris-erythrosora/) | Twice-divided triangular fronds with copper-coloured young growth. |
| 35 | japanese-painted-fern | [Japanese painted fern — Athyrium niponicum](https://plants.ces.ncsu.edu/plants/athyrium-niponicum/) | Low arching divided fronds, shown in a silvery cultivated form with reddish stalks. |
| 36 | birds-nest-fern | [Bird’s nest fern — Asplenium nidus](https://plants.ces.ncsu.edu/plants/asplenium-nidus/) | Undivided wavy strap fronds radiate from an open central crown. |
| 37 | japanese-holly-fern | [Japanese holly fern — Cyrtomium falcatum](https://plants.ces.ncsu.edu/plants/cyrtomium-falcatum/) | Broad pointed, sickle-like pinnae along open arching fronds. |
| 38 | christmas-fern | [Christmas fern — Polystichum acrostichoides](https://plants.ces.ncsu.edu/plants/polystichum-acrostichoides/) | Low evergreen lance-shaped fronds with closely spaced leathery pinnae. |
| 39 | royal-fern | [Royal fern — Osmunda regalis](https://plants.ces.ncsu.edu/plants/osmunda-regalis/) | Tall branching fronds with separated broad pinnules. Sterile foliage display. |
| 40 | sensitive-fern | [Sensitive fern — Onoclea sensibilis](https://plants.ces.ncsu.edu/plants/onoclea-sensibilis/) | Broad, coarsely lobed triangular sterile fronds. |

## Generation

Each preset contains 16 seeded fronds. A shared curve drives foliage attachment and 16 tapered rachis segments per frond. Autumn, Japanese painted and royal fern also have 256 secondary pinna-stem segments. Other presets use 256 main segments. Foliage samples follow the local frond tangent; normals are wrapped and quantized into the existing light bins. Ferns share the root-anchored surface/stem wind function.

Count controls foliage surface samples, not plants or fronds. At 100,000 samples the gallery shows one procedural crown. Lower counts make surface coverage sparser. Seed changes alter orientation and relative frond size; increasing count preserves existing records. Lighting and camera changes do not regenerate geometry.

Use foliage.configure({preset: "boston-fern", count: 100000, seed: 42, bins: 8}), then render and present through the existing API. The default fern camera tilt is 0.4 radians. All geometry and rendering remain in src/leaf.cu.

## Scope

These are research-informed stylizations, with selected cultivated foliage for Boston and Japanese painted fern. Autumn fern includes copper young fronds. Ostrich fern uses the current name displayed by the linked NC State source, Onoclea struthiopteris (formerly Matteuccia struthiopteris). Royal and sensitive fern show sterile foliage. Proportions are composed for the demo rather than biological measurement. Spore structures, fiddlehead growth, fine veins, true self-shadowing and physical leaf translucency are not modeled. Maidenhair uses a simplified spreading finger arrangement rather than a full botanical branching reconstruction.

## Validation

Run npm run build, npm test and node scripts/test-ferns.mjs with the local server running. The general suite covers all 41 presets, deterministic seeds, finite geometry, visible wind, unchanged geometry under light changes and galleries/UI. The fern suite checks all ten at 200,000 samples, prefix preservation from 10,000, normal-bin bounds, foliage-only material tags, expected stem counts, visible lighting response without generation, and inspection modes at another camera angle.

Reports: artifacts/foliage-validation.json and artifacts/fern-validation.json. Preview: artifacts/fern-gallery.png. GPU timestamp values measure cached compute rendering only; they exclude generation, display and host overhead.
