# Deadwood and stumps

Ten presets, IDs 111–120. Open deadwood.html to compare them and select a live preview.

| ID | API key | Form |
|---|---|---|
| 111 | fallen-log | Long tapered trunk with exposed end grain. |
| 112 | hollow-log | Open-ended trunk with inner walls and a thick rim. |
| 113 | cut-stump | Low stump with a flat exposed top. |
| 114 | snapped-stump | Broken stump with an irregular splintered crown. |
| 115 | root-stump | Stump with six spreading tapered roots. |
| 116 | driftwood | Pale trunk with branching weathered limbs. |
| 117 | fallen-birch-log | Pale marked bark around a fallen trunk. |
| 118 | split-log | Half-log with an exposed longitudinal split. |
| 119 | log-pile | Five overlapping logs in two levels. |
| 120 | dead-snag | Tall broken trunk with short branch remnants. |

## Reuse

```js
foliage.configure({preset: 'root-stump', count: 100000, seed: 42, bins: 8});
foliage.render();
foliage.present(canvas);
```

Count controls surface detail, not the number of trunks or branches. Stable seed/group offsets preserve sample prefixes when count increases. All geometry, material variation, lighting and depth rendering remain in src/leaf.cu. Default camera tilt is -0.45 and focus height 0.8. Geometry remains rigid under wind.

Sampled tapered cylinders provide trunks, branches and roots. Hollow logs include an inner wall and annular end rims; split logs expose a longitudinal plane. Bark, exposed wood and dark interior materials share the existing lighting cache. Wood rings and bark markings are procedural approximations. Trunk and branch intersections overlap rather than forming watertight mesh junctions. No physical decay, terrain fitting, collision settling, growth history or automatic moss/fungi attachment is implemented.

## Validation

Run npm run build, npm test and node scripts/test-deadwood.mjs with the server running. The full suite covers 121 presets, deterministic seeds, rigid wind behaviour, light changes without regeneration, previews and live UI. The dedicated suite checks 200,000 samples per preset, stable prefixes from 10,000 samples, finite above-ground positions, valid normal bins, exposed-wood material presence, no legacy branch overlays, lighting response and inspection modes.

Reports: artifacts/foliage-validation.json and artifacts/deadwood-validation.json. Preview: artifacts/deadwood-gallery.png.
