# Vines and ivy

Ten foliage presets use the existing CUDA instance system. Open vines.html and select a card to explore its lighting, seed and camera.

| ID | API key | Botanical reference | Implemented form |
|---|---|---|---|
| 51 | english-ivy | [English ivy — Hedera helix](https://plants.ces.ncsu.edu/plants/hedera-helix/) | Trailing curtains of five-lobed juvenile leaves. |
| 52 | canary-ivy | [Canary ivy — Hedera canariensis](https://plants.ces.ncsu.edu/plants/hedera-canariensis/) | Broad lobed leaves on hanging stems. |
| 53 | boston-ivy | [Boston ivy — Parthenocissus tricuspidata](https://plants.ces.ncsu.edu/plants/parthenocissus-tricuspidata/) | Upright spreading stems with three-lobed leaves. |
| 54 | virginia-creeper | [Virginia creeper — Parthenocissus quinquefolia](https://plants.ces.ncsu.edu/plants/parthenocissus-quinquefolia/) | Five radiating leaflets on climbing shoots. |
| 55 | grape-vine | [Grape vine — Vitis vinifera](https://plants.ces.ncsu.edu/plants/vitis-vinifera/) | Arching canes with broad lobed leaves; foliage-only display. |
| 56 | chinese-wisteria | [Chinese wisteria — Wisteria sinensis](https://plants.ces.ncsu.edu/plants/wisteria-sinensis/) | Arching leaders and hanging shoots carrying pinnate foliage. |
| 57 | coral-honeysuckle | [Coral honeysuckle — Lonicera sempervirens](https://plants.ces.ncsu.edu/plants/lonicera-sempervirens/) | Twining stems with paired oval leaves; foliage-only display. |
| 58 | virgins-bower | [Virgin’s bower — Clematis virginiana](https://plants.ces.ncsu.edu/plants/clematis-virginiana/) | Climbing shoots with three-part compound leaves. |
| 59 | morning-glory | [Morning glory — Ipomoea purpurea](https://plants.ces.ncsu.edu/plants/ipomoea-purpurea/) | Coiling stems with broad heart-like leaves; foliage-only display. |
| 60 | creeping-fig | [Creeping fig — Ficus pumila](https://plants.ces.ncsu.edu/plants/ficus-pumila/) | Wandering climbing shoots with small juvenile leaves. |

## Support-following growth revision

The earlier parallel hanging paths have been replaced with three procedural growth guides:

- English ivy, Canary ivy and creeping fig follow a cylindrical bark surface, representing root-clinging growth.
- Boston ivy and Virginia creeper follow the surface with simplified contact connectors representing adhesive-tendril attachment.
- Wisteria, honeysuckle and morning glory spiral their main stems around the cylindrical support.
- Grape and clematis spread over a visible trellis. Their connectors approximate tendril and leaf-stalk attachment respectively; they do not use the whole-stem spiral model.

References: [RHS climbing mechanisms](https://www.rhs.org.uk/plants/types/climbers/growing-guide), [RHS ivy aerial roots](https://www.rhs.org.uk/weeds/ivy-on-trees-ground-cover-weed), [NC State Boston ivy adhesive tendrils](https://plants.ces.ncsu.edu/plants/parthenocissus-tricuspidata/), and the species references above.

Each of eight leaders has 20 tapered segments. Eight secondary shoots attach at varied nodes on their parent leaders and also have 20 segments. There are 128 petioles and 56 simplified contact connectors. Trunk scenes add one solid support (505 active segments total); trellis scenes add eight rails/posts (512 total). The trunk is a separate continuous cylinder to avoid segment seams. Leaves are placed in outward-facing local frames, alternate sides along nodes, and use seeded spacing rather than identical horizontal rows.

Support and attached stems stay fixed. Leaf flutter is a small outward displacement using cached rest-pose shading. This avoids visibly sliding the support or peeling the entire plant off it. Seed, count, lighting and camera APIs are unchanged. Configure with preset keys such as english-ivy or chinese-wisteria. Count means surface samples, not leaf count.

## Scope

This is a species-informed static procedural model, not a time-stepped growth simulation. Supports are built-in trunk/trellis guides, not arbitrary imported meshes. There is no support collision solver, active tip search, actual rootlet/disc microgeometry, coiling tendril geometry, flowers or fruit. Contact connectors illustrate attachment locations. Leaflet connections and leaf shapes remain stylized.

## Validation

Run npm run build, npm test and node scripts/test-vines.mjs. The vine suite checks all ten at 200,000 samples, count-prefix preservation, lighting-bin bounds, expected active stem/support counts, continuous segments, varied-node lateral attachment, trunk clearance at segment endpoints, lighting response without regeneration and inspection modes. The general suite exercises all 61 presets and rebuilds the gallery.

Reports: artifacts/vine-validation.json and artifacts/foliage-validation.json. Gallery: artifacts/vine-gallery.png. GPU timestamp results exclude generation, display and host overhead.
