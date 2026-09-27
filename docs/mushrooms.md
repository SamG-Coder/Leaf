# Mushroom colonies

Ten fungus-inspired colony presets, IDs 81–90. Open mushrooms.html and select a card to load the live renderer.

| ID | API key | Species reference | Rendered form |
|---|---|---|---|
| 81 | fly-agaric | [Amanita muscaria](https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/fungi-and-lichens/fly-agaric/) | Red domed caps with pale flecks. |
| 82 | porcini | [Boletus edulis](https://www.mushroomexpert.com/boletus_edulis.html) | Broad brown caps and thick stems. |
| 83 | chanterelle | [Cantharellus cibarius](https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/fungi-and-lichens/chanterelle/) | Golden wavy funnel caps. |
| 84 | amethyst-deceiver | [Laccaria amethystina](https://www.woodlandtrust.org.uk/blog/2025/11/types-of-mushroom/) | Small violet caps and slender stems. |
| 85 | shaggy-inkcap | [Coprinus comatus](https://www.dorsetwildlifetrust.org.uk/wildlife-explorer/fungi/shaggy-inkcap) | Tall pale bell caps with scale-like markings. |
| 86 | sulphur-tuft | [Hypholoma fasciculare](https://www.yorkshiredales.org.uk/about/wildlife/species/fungi-lichens/fungi/common-fungi-of-the-dales/) | Compact yellow clusters around fallen wood. |
| 87 | oyster-mushroom | [Pleurotus ostreatus](https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/fungi-and-lichens/oyster-mushroom/) | Overlapping lateral fans on a fallen log. |
| 88 | turkey-tail | [Trametes versicolor](https://www.mushroomexpert.com/trametes_versicolor.html) | Thin concentric-banded shelves on wood. |
| 89 | common-puffball | [Lycoperdon perlatum](https://www.wildlondon.org.uk/fungi-spotter) | Rounded pale fruiting bodies in scattered groups. |
| 90 | fairy-ring-champignon | [Marasmius oreades](https://www.woodlandtrust.org.uk/blog/2019/08/what-is-a-fairy-ring/) | Small tan mushrooms forming a ring. |

## Instance integration

```js
foliage.configure({preset: 'fly-agaric', count: 100000, seed: 42, bins: 8});
foliage.render();
foliage.present(canvas);
```

Each colony contains 16 fruiting bodies. Count sets surface sampling detail, not the number of mushrooms. Seed controls size, height and colony variation; increasing count preserves existing sample records. Ground forms, compact groups, a ring and wood-supported shelves use separate distributions. The oyster and turkey-tail caps overlap along a procedural log.

Caps, stems and undersides are sampled surfaces generated in src/leaf.cu. Surface normals feed the shared cluster/direction lighting cache. Caps have species colours and procedural markings, including pale fly-agaric flecks and turkey-tail bands. The wood uses the existing depth-tested branch renderer. Unlike flexible foliage, mushroom samples and logs remain rigid under the wind control, including sample orientation. Default tilt is -0.5 radians and focus height is 0.45.

These are illustrative fruiting-body approximations, not botanical reconstructions. Underside ridges, scales, pores and cap anatomy are simplified; some cap/stem transitions are sampled rather than watertight meshes. No mycelium, growth simulation, spore simulation, decomposition or ecological population model is included. Relative scale is for display rather than a measured species comparison.

## Validation

With the server running: npm run build, npm test, node scripts/test-mushrooms.mjs.

The full suite covers all 91 presets, deterministic seed changes, lighting without regeneration, rigid mushroom behaviour under wind, preview generation and live UI. The mushroom suite exercises 200,000 samples per species, count-prefix preservation, finite above-ground positions, valid normal bins, expected log geometry, changing light and inspection modes.

Reports: artifacts/foliage-validation.json and artifacts/mushroom-validation.json. Preview: artifacts/mushroom-gallery.png.
