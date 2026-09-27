# Crop collection

Open crops.html to compare ten crops and select a card to open the interactive renderer. Each preset has four rows of eight plants, rooted at ground level. IDs 71–80 extend the collection without changing existing preset IDs.

| ID | API key | Botanical source | Implemented form |
|---|---|---|---|
| 71 | wheat | [Triticum aestivum](https://plants.ces.ncsu.edu/plants/triticum-aestivum/) | Golden spikes with paired grain rows above narrow leaves. |
| 72 | barley | [Hordeum vulgare](https://plants.ces.ncsu.edu/plants/hordeum-vulgare/) | Grain spikes with extended awn samples. |
| 73 | oats | [Avena sativa](https://plants.ces.ncsu.edu/plants/avena-sativa/) | Open branching panicles above leafy stems. |
| 74 | rice | [Oryza sativa](https://www.kew.org/plants/asian-rice) | Narrow foliage and nodding grain panicles; dry display without water. |
| 75 | maize | [Zea mays](https://plants.ces.ncsu.edu/plants/zea-mays/) | Tall stalks, broad arching leaves, side ears and upper tassels. |
| 76 | grain-sorghum | [Sorghum bicolor](https://plants.ces.ncsu.edu/plants/sorghum-bicolor/) | Broad leaves below compact reddish grain heads. |
| 77 | pearl-millet | [Cenchrus americanus](https://plants.ces.ncsu.edu/plants/cenchrus-americanus/) | Upright cylindrical grain heads and strap leaves. |
| 78 | sugarcane | [Saccharum officinarum](https://plants.ces.ncsu.edu/plants/saccharum-officinarum/) | Thick upright canes with long arching leaves; vegetative display. |
| 79 | soybean | [Glycine max](https://plants.ces.ncsu.edu/plants/glycine-max/) | Short plants with three-part leaf groups and hanging pods. |
| 80 | cotton | [Gossypium hirsutum](https://plants.ces.ncsu.edu/plants/gossypium-hirsutum/) | Leafy rows with pale open cotton bolls. |

## Generation and reuse

```js
foliage.configure({ preset: 'maize', count: 100000, seed: 42, bins: 8 });
foliage.render({ time: 0, wind: 0.35 });
foliage.present(canvas);
```

Count means surface samples, not individual plants. Increasing count adds detail to the same 32 plants while preserving the existing sample prefix. Positions are generated from stable seed and group IDs. Each plant has eight connected stem segments; sampled foliage, grain heads and fruit share the stem's wind deformation. Wind remains zero at the ground roots. Default camera tilt is -0.35 radians, looking down from above, with focus height 1.15.

Generation, wind, stem shading and grouped light exposure are implemented in src/leaf.cu. The JavaScript API schedules the kernels and presents the image. Lighting updates reuse geometry and the existing cluster/normal exposure cache. Stem geometry uses the existing depth-tested branch renderer. All ten crops support the existing light and inspection controls.

These are species-inspired procedural approximations. They do not simulate growth stages, cultivation, crop yield, terrain, roots, water or botanical anatomy. Grain structures and fruit are sampled silhouettes rather than separate detailed organs. Cotton leaves are simplified broad leaves; maize ears omit detailed husks and silks. Sugarcane is shown vegetatively. Gallery counts are rendering stress tests, not botanical density estimates.

## Validation

Run npm run build, npm test and node scripts/test-crops.mjs with the local server running. The full suite checks all 81 presets, including deterministic geometry, wind response and browser UI. The crop suite checks 200,000 samples per preset, stable prefixes from 10,000 samples, finite positions, valid normal groups, 256 connected stem segments with ground-level roots, expected crop material presence, light response without regeneration, and alternate inspection modes.

Results are saved in artifacts/foliage-validation.json and artifacts/crop-validation.json. The comparison image is artifacts/crop-gallery.png. Screenshots were inspected locally; these checks do not establish botanical realism or performance on other GPUs.
