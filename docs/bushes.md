# Bush presets

Ten additional presets share the tree/grass CUDA instance engine, clustered exposures, deterministic seeds, wind and lit procedural bark. IDs 11–20 are appended; tree IDs 0–9 and grass ID 10 remain stable.

| Key | Botanical reference | Procedural representation |
|---|---|---|
| `boxwood` | [Buxus sempervirens](https://plants.ces.ncsu.edu/plants/buxus-sempervirens/) | Dense rounded evergreen form, small oval leaves |
| `english-lavender` | [Lavandula angustifolia](https://plants.ces.ncsu.edu/plants/lavandula-angustifolia/) | Low silver-green mound with narrow leaves and violet spikes |
| `rosemary` | [Salvia rosmarinus](https://plants.ces.ncsu.edu/plants/salvia-rosmarinus/) | Upright narrow-leaved shrub with scattered pale blue blooms |
| `bigleaf-hydrangea` | [Hydrangea macrophylla](https://plants.ces.ncsu.edu/plants/hydrangea-macrophylla/) | Broad foliage and pink mophead clusters, representing a selected horticultural form |
| `catawba-rhododendron` | [Rhododendron catawbiense](https://plants.ces.ncsu.edu/plants/rhododendron-catawbiense/) | Broad evergreen leaves and purple flower trusses |
| `southern-indian-azalea` | [Rhododendron indicum](https://plants.ces.ncsu.edu/plants/rhododendron-indicum/) | Compact branching with small foliage and pink-red flowers |
| `border-forsythia` | [Forsythia × intermedia](https://plants.ces.ncsu.edu/plants/forsythia-x-intermedia/) | Arching canes and predominantly yellow early-season flowers |
| `creeping-juniper` | [Juniperus horizontalis](https://plants.ces.ncsu.edu/plants/juniperus-horizontalis/) | Low horizontal branches with fine blue-green foliage sprays |
| `japanese-holly` | [Ilex crenata](https://plants.ces.ncsu.edu/plants/ilex-crenata/) | Upright evergreen form with small rounded leaves |
| `japanese-barberry` | [Berberis thunbergii](https://plants.ces.ncsu.edu/plants/berberis-thunbergii/) | Arching multi-stem form shown with purple horticultural foliage |

Sources accessed 27 September 2026. Shape, foliage and flowering cues guide stylized rendering; proportions are normalized, flowers are simplified petal splats, and instance counts are not botanical counts. These are visual assets, not planting recommendations. Flowering states are fixed presets, not a simulated seasonal cycle. Autumn tint affects foliage of hydrangea, forsythia and barberry without recolouring the flower instances.

Each shrub has 16 low woody stems and branches attached to them. There is no single tree trunk. Existing bark lighting and textures apply to these woody segments. All geometry remains CUDA-authored.

```js
foliage.configure({preset: 'bigleaf-hydrangea', count: 100000, seed: 42});
foliage.render({time: seconds, wind: 0.1});
```

Bush defaults use a closer camera (`scale: 150`, `focus: 1.15`). Built-in flowers share the regular instance records; `normal.z` in [1,2) denotes a flower and its fractional part controls variation. The public custom-upload contract remains foliage variation in [0,1]; no new custom-flower API is implied.

`bushes.html` shows generated previews with links back to interactive presets. `npm test` now exercises all 21 presets and regenerates both tree and bush galleries, with metrics saved in `artifacts/foliage-validation.json`.
