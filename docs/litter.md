# Ground litter

Ten presets (IDs 101–110) in litter.html use the existing CUDA surface-sampling renderer.

| ID | API key | Form |
|---|---|---|
| 101 | oak-leaf-litter | Curled brown leaves with lobed outlines. |
| 102 | maple-leaf-litter | Warm orange fallen leaves with notched edges. |
| 103 | birch-leaf-litter | Small golden pointed leaves. |
| 104 | pine-needle-litter | Thin dry needles scattered across the ground. |
| 105 | fallen-twigs | Short rounded woody fragments. |
| 106 | bark-chips | Rough curled bark fragments. |
| 107 | fallen-pine-cones | Rounded cones with corrugated scale approximations. |
| 108 | fallen-acorns | Small brown oval nut approximations. |
| 109 | pebble-scatter | Low rounded grey stones. |
| 110 | mixed-forest-litter | Leaves, needles, twigs, bark, cones, nuts and pebbles. |

Each preset contains 128 seeded debris objects across a flat ground patch. Count controls surface samples, not debris-object count. Increasing detail preserves previous samples and object placement. Mixed litter selects from all nine component types. Generation, grain, colour, depth and shared directional lighting remain in src/leaf.cu; the host API is unchanged.

```js
foliage.configure({preset: 'mixed-forest-litter', count: 100000, seed: 42, bins: 8});
foliage.render();
foliage.present(canvas);
```

Default camera tilt is -0.85 radians, focus height 0.1. Debris stays rigid under wind, with no unwanted branch geometry. Leaves use simplified curled silhouettes; twigs are cylindrical; cones have corrugated surfaces; acorns are simple oval nuts without separate caps. No decay, terrain conformance, collision settling or physical scattering simulation is included. All presets are illustrative approximations.

Validation: npm run build, npm test and node scripts/test-litter.mjs with the server running. The full suite covers 111 presets, deterministic seeds, stable lighting geometry, rigid debris, gallery images and live UI. The litter suite checks 200,000 samples per preset, stable count prefixes, finite above-ground geometry, valid lighting bins, absence of branches, light changes without regeneration, and inspection modes. Reports: artifacts/foliage-validation.json and artifacts/litter-validation.json. Gallery: artifacts/litter-gallery.png.
