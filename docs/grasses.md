# Grass species collection

Ten species-inspired presets extend the original grass emitter (ID 10), which remains available. Open grasses.html for the comparison gallery and click a card to enter the live renderer.

| ID | API key | Botanical reference | Implemented form |
|---|---|---|---|
| 61 | blue-fescue | [Blue fescue — Festuca glauca](https://plants.ces.ncsu.edu/plants/festuca-glauca/) | Low blue-grey clumps with fine outward-pointing blades. |
| 62 | red-fescue | [Red fescue — Festuca rubra](https://plants.ces.ncsu.edu/plants/festuca-rubra/) | Fine-textured green turf with longer arching blades. |
| 63 | kentucky-bluegrass | [Kentucky bluegrass — Poa pratensis](https://plants.ces.ncsu.edu/plants/poa-pratensis/) | Low blue-green turf with medium-width blades. |
| 64 | perennial-ryegrass | [Perennial ryegrass — Lolium perenne](https://plants.ces.ncsu.edu/plants/lolium-perenne/) | Upright dark-green turf with broader blades. |
| 65 | bermudagrass | [Bermudagrass — Cynodon dactylon](https://www.turffiles.ncsu.edu/grasses/bermudagrass/) | Short fine-bladed turf with a spreading lean. |
| 66 | zoysiagrass | [Zoysiagrass — Zoysia japonica](https://www.turffiles.ncsu.edu/grasses/zoysiagrass/) | Compact dense turf with stiff upright blades. |
| 67 | chinese-silvergrass | [Chinese silvergrass — Miscanthus sinensis](https://plants.ces.ncsu.edu/plants/miscanthus-sinensis/) | Tall arching clumps with broad blades and pale plume approximations. |
| 68 | switchgrass | [Switchgrass — Panicum virgatum](https://plants.ces.ncsu.edu/plants/panicum-virgatum/) | Tall upright clumps with blue-green blades and light seed-head approximations. |
| 69 | fountain-grass | [Fountain grass — Cenchrus alopecuroides](https://plants.ces.ncsu.edu/plants/cenchrus-alopecuroides/) | Fountain-shaped clumps with arching blades and compact seed heads. |
| 70 | mexican-feather-grass | [Mexican feather grass — Nassella tenuissima](https://www.rhs.org.uk/plants/202303/nassella-tenuissima/details) | Fine flexible golden-green blades with slender seed heads. |

## Generation

Turf presets distribute rooted blades over 128 ground patches. Blue fescue and the four tall ornamental presets use seven clump centres with seeded radial root offsets. Blade length, width, lean and colour vary by preset. Each instance stores a ground root, blade length and lean vector. The existing six-segment rasterizer bends blades quadratically away from the root. Time-dependent wind is zero at the root and increases toward the tip. No tree or vine branches are generated or drawn.

The ornamental presets (67–70) devote a deterministic small fraction of instances to taller seed-bearing stalks. Their upper sections have species-dependent head widths, with pale seed-head colouring. These are simplified silhouettes: switchgrass branching panicles and individual florets/awns are not modeled. Seed-stalk colour currently applies to the entire stalk.

Count means whole blades/stalks, not leaf surface samples. Gallery captures use 100,000 instances and identical camera settings. Increasing count preserves existing blades. Light changes update shared exposure without regeneration. This is a rendering stress test rather than a measured botanical planting density. Turf proportions represent short maintained or illustrative growth; no mowing simulation, rhizome/stolon network or seasonal growth is implemented.

## Reuse

Call foliage.configure({preset: "blue-fescue", count: 100000, seed: 42, bins: 8}), then render and present. Default camera tilt is -0.5 radians, focus height 0.65 and scale 150. The existing generic grass/custom GPU emitter API is unchanged. All generation, wind, seed-head expansion and lighting are in src/leaf.cu.

## Validation

With the local server running, execute npm run build, npm test and node scripts/test-grasses.mjs. The full suite covers 71 presets. The grass suite tests 200,000 instances per new grass, stable prefixes from 10,000 instances, finite geometry, ground-root y coordinates, valid normal bins, ornamental seed-stalk presence, no unwanted branch geometry, lighting response without generation, and all inspection modes from another camera angle.

Reports: artifacts/foliage-validation.json and artifacts/grass-validation.json. Gallery: artifacts/grass-gallery.png. GPU timestamps measure cached compute work and exclude generation, canvas presentation and host overhead.
