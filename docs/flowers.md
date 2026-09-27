# Procedural flower collection

Ten flower presets share the existing CUDA generation, lighting, visibility and rendering system. Open `flowers.html` and click a card to explore the preset interactively.

| ID | Key | Form and botanical reference |
|---|---|---|
| 21 | `sunflower` | [Helianthus annuus](https://plants.ces.ncsu.edu/plants/helianthus-annuus/): golden rays and a broad dark disk. |
| 22 | `shasta-daisy` | [Leucanthemum × superbum](https://plants.ces.ncsu.edu/plants/leucanthemum-x-superbum/): narrow white rays and a yellow centre. |
| 23 | `tulip` | [Tulipa hybrids](https://plants.ces.ncsu.edu/plants/tulipa/): six overlapping upright tepals forming an open cup. |
| 24 | `daffodil` | [Narcissus hybrids](https://plants.ces.ncsu.edu/plants/narcissus/): six pale tepals and a projecting golden trumpet. |
| 25 | `common-poppy` | [Papaver rhoeas](https://plants.ces.ncsu.edu/plants/papaver-rhoeas/): four broad red petals and a dark centre. |
| 26 | `garden-rose` | [Rosa hybrids](https://plants.ces.ncsu.edu/plants/rosa/): selected double pink form with five staggered petal whorls. |
| 27 | `cosmos` | [Cosmos bipinnatus](https://plants.ces.ncsu.edu/plants/cosmos-bipinnatus/): eight broad pink rays, yellow centres and fine leaves. |
| 28 | `purple-coneflower` | [Echinacea purpurea](https://plants.ces.ncsu.edu/plants/echinacea-purpurea/): drooping rays and a raised copper-coloured cone. |
| 29 | `english-bluebell` | [Hyacinthoides non-scripta](https://www.kew.org/plants/bluebell): one-sided racemes with six pendent bells per stem. |
| 30 | `bearded-iris` | [Iris × germanica](https://plants.ces.ncsu.edu/plants/iris-x-germanica/): three upright standards, three drooping falls and golden beards. |

## Rendering and reuse

Each bed contains 16 seeded plants and eight lighting clusters per plant, preserving the 128-cluster contract. **Count means petal and leaf surface samples, not plants or flower heads.** 100,000 samples fill the surfaces at the gallery scale. Lower counts produce sparser surfaces; increasing count preserves the existing sample prefix.

Petals and leaves use the same position, normal and shape buffers as existing foliage. Green stems use the tapered, lit branch segments. Bluebells have connecting flower stalks. Flower stems and surfaces share a height-dependent wind displacement that is zero at ground height. Shading retains rest-pose normals and shared exposure groups.

```js
const flowers = await FoliageSystem.create({width:1280,height:896});
flowers.configure({preset:'tulip',count:100000,seed:42,bins:8});
flowers.setLight({azimuth:305,elevation:40});
flowers.render({time:seconds,wind:0.1});
flowers.present(context);
```

These are stylized, research-informed approximations. Garden rose, tulip and daffodil represent selected garden forms, without claiming a specific cultivar. Sizes are composed for a comparison bed rather than measured biological scale. Petals use opaque sampled surfaces. Transparency, subsurface scattering, true self-shadowing, fine veins, growth stages and mixed-species world composition are outside this implementation.

## Validation

With the local server running, use `npm run build`, `npm test` and `node scripts/test-flowers.mjs`.

The general suite checks all 31 presets and captures the galleries. The flower suite exercises 200,000 instances per preset, stable prefixes from 10,000 samples, valid lighting bins, petal/leaf material presence, lighting response without regeneration, and all inspection modes with an alternate camera and wind setting.

Reports: `artifacts/foliage-validation.json` and `artifacts/flower-validation.json`. Gallery capture: `artifacts/flower-gallery.png`. GPU timestamps in the general report measure cached compute rendering at 768 × 768; they exclude generation, presentation and host overhead and are not browser FPS.
