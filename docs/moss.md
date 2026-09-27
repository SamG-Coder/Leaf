# Procedural moss collection

Ten moss presets use the same CUDA generation, shared lighting, wind, visibility and pixel shading as existing foliage. Open moss.html and select a card for the interactive preset.

| ID | API key | Botanical reference | Implemented form |
|---|---|---|---|
| 41 | pincushion-moss | [Pincushion moss — Leucobryum glaucum](https://www.britishbryologicalsociety.org.uk/learning/species-finder/leucobryum-glaucum/) | Rounded pale-green cushions formed from dense upright shoots. |
| 42 | common-haircap-moss | [Common haircap moss — Polytrichum commune](https://www.britishbryologicalsociety.org.uk/learning/species-finder/polytrichum-commune/) | Tall upright shoots with narrow radiating leaves and starry tips. |
| 43 | broom-fork-moss | [Broom fork-moss — Dicranum scoparium](https://www.britishbryologicalsociety.org.uk/learning/species-finder/dicranum-scoparium/) | Dense tufts with fine leaves swept toward one side. |
| 44 | cypress-leaved-plait-moss | [Cypress-leaved plait-moss — Hypnum cupressiforme](https://www.britishbryologicalsociety.org.uk/learning/species-finder/hypnum-cupressiforme/) | Low creeping mats with curved, overlapping leafy sprays. |
| 45 | tamarisk-moss | [Tamarisk moss — Thuidium tamariscinum](https://www.britishbryologicalsociety.org.uk/learning/species-finder/thuidium-tamariscinum/) | Fine triangular branching sprays form a fern-like carpet. |
| 46 | glittering-wood-moss | [Glittering wood-moss — Hylocomium splendens](https://www.britishbryologicalsociety.org.uk/learning/species-finder/hylocomium-splendens/) | Layered feathery growth with stepped spray heights. |
| 47 | springy-turf-moss | [Springy turf-moss — Rhytidiadelphus squarrosus](https://www.britishbryologicalsociety.org.uk/learning/species-finder/rhytidiadelphus-squarrosus/) | Loose pale-green turf with outward-bent, starry leaves. |
| 48 | tree-moss | [Tree moss — Climacium dendroides](https://www.britishbryologicalsociety.org.uk/learning/species-finder/climacium-dendroides/) | Miniature branched crowns stand above slender upright stalks. |
| 49 | blunt-leaved-bog-moss | [Blunt-leaved bog-moss — Sphagnum palustre](https://www.britishbryologicalsociety.org.uk/learning/species-finder/sphagnum-palustre/) | Uneven hummocks of compact heads with clustered spreading branches. |
| 50 | silvery-thread-moss | [Silvery thread-moss — Bryum argenteum](https://www.britishbryologicalsociety.org.uk/learning/species-finder/bryum-argenteum/) | Short, densely packed shoots forming a low silvery-green mat. |

## Generation and reuse

Each magnified patch uses 128 seed groups. Most forms have 16 shoots per group; haircap has four, and the creeping/feathery and tree forms use one to keep branching visible. Count controls surface samples across those shoots and leaves, not moss plants or real-world area. Pincushion has seven rounded overlapping mounds. Stems are sampled in the same instance stream, with no additional tree/fern branch segments. Geometry is preserved under light/camera changes, and increasing sample count preserves its prefix.

Select a preset with foliage.configure({preset: "pincushion-moss", count: 100000, seed: 42, bins: 8}); then use render/present as usual. Default camera tilt is 0.65 radians and focus height is 0.3. Wind uses the existing height-dependent displacement with rest-pose shading.

These are stylized foliage-only approximations. Leaf cells, capsules, reproductive stages, moisture response, physically measured sizes, true self-shadowing and arbitrary mesh-surface attachment are not implemented. Colour is illustrative and fixed per preset with seeded variation. Shared lighting remains an approximate exposure model. Fine identification traits are not represented.

Botanical names and growth-form references are linked above. British Bryological Society pages were used where available through search; several direct page fetches were blocked. Additional references: [pincushion mosses, Missouri Department of Conservation](https://mdc.mo.gov/discover-nature/field-guide/pincushion-mosses-leucobryum-mosses), [silver moss, Flora of North America account via Bryophyte Portal](https://bryophyteportal.org/portal/taxa/index.php?clid=200&taxauthid=1&tid=158221), and [Sphagnum palustre field guide](https://www.britishbryologicalsociety.org.uk/wp-content/uploads/2020/12/Sphagnum-palustre.pdf).

## Validation

With the local server running: npm run build, npm test, node scripts/test-moss.mjs. The general suite covers all 51 presets, seeds, finite geometry, wind and galleries/UI. The moss suite checks 200,000 samples for each moss, 10,000-sample prefix preservation, valid lighting bins, foliage material tags, absence of unwanted branch geometry, visible lighting response without generation, and inspection modes at an alternate camera angle.

Reports: artifacts/foliage-validation.json and artifacts/moss-validation.json. Preview: artifacts/moss-gallery.png. GPU timestamps in the general report measure cached compute only and exclude generation, presentation and host overhead.
