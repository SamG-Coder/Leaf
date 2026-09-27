# Rock and crystal formations

Ten presets, IDs 91–100, extend the existing instance API. Open rocks.html and select a formation to enter the live renderer.

| ID | API key | Reference | Implemented form |
|---|---|---|---|
| 91 | granite-boulders | [Granite](https://www.nps.gov/subjects/geology/igneous.htm) | Rounded rough boulders with mineral speckling. |
| 92 | basalt-columns | [Basalt](https://www.nps.gov/subjects/volcanoes/columnar-jointing.htm) | Joined hexagonal columns with stepped tops. |
| 93 | sandstone-outcrop | [Sandstone](https://www.nps.gov/subjects/geology/sedimentary.htm) | Warm layered blocks with fine sediment bands. |
| 94 | slate-slabs | [Slate](https://www.nps.gov/subjects/geology/metamorphic.htm) | Thin overlapping blue-grey slabs. |
| 95 | limestone-boulders | [Limestone](https://www.nps.gov/subjects/geology/sedimentary.htm) | Pale weathered boulder group. |
| 96 | quartz-cluster | [Quartz](https://www.minerals.net/mineral/quartz) | Pale hexagonal prisms with pointed tips. |
| 97 | amethyst-cluster | [Amethyst](https://www.minerals.net/mineral/amethyst) | Violet pointed quartz prisms. |
| 98 | smoky-quartz | [Smoky quartz](https://www.minerals.net/mineral/quartz) | Brown-grey pointed crystal cluster. |
| 99 | pyrite-cubes | [Pyrite](https://www.minerals.net/mineral/pyrite) | Gold-coloured cubic crystal group. |
| 100 | fluorite-cubes | [Fluorite](https://www.minerals.net/mineral/fluorite) | Green cubic crystals with bright facets. |

## Generation and reuse

```js
foliage.configure({preset: 'amethyst-cluster', count: 100000, seed: 42, bins: 8});
foliage.render();
foliage.present(canvas);
```

Each formation has 16 pieces. Count controls surface sampling detail; it does not increase piece count. Seed controls size, rotation and height. Increasing count preserves existing sample positions. Rounded boulders, overlapping slabs, flat-topped hexagonal columns, pointed hexagonal prisms and cubic forms use different procedural geometry. All positions, surface normals, textures, depth testing and shading are implemented in src/leaf.cu.

Rocks use object-space mineral speckling, roughness variation or sediment bands. Crystal faces use grouped directional light and a view-dependent highlight. They are opaque surface approximations: no refraction, transmission, internal inclusions or physically based metal response is implemented. The shapes illustrate broad geological forms rather than reconstructing measured specimens. Flat-face normal quantization, finite surface sampling and simplified tips remain visible at close zoom.

The formations stay rigid under wind. They have no tree branches or fungal supports. Default camera tilt is -0.5 and focus height 0.8. Existing light controls and inspection modes remain available.

## Validation

With the local server running, use npm run build, npm test and node scripts/test-rocks.mjs. The full suite covers 101 presets and the new gallery/live UI. The formation suite checks 200,000 samples per preset, stable prefixes from 10,000 samples, finite above-ground geometry, valid normal groups, absence of branch geometry, lighting response without regeneration, and alternate camera/inspection modes.

Reports: artifacts/foliage-validation.json and artifacts/rock-validation.json. Preview: artifacts/rock-gallery.png.
