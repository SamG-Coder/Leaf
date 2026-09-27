# Species research and procedural interpretation

Research accessed 27 September 2026. Sources below informed silhouette, foliage and bark. These are stylized render presets, not growth simulations or measured specimens. All trees use a normalized scene scale; foliage counts are stress-test counts, not botanical estimates. In particular, palm instances represent leaflets, and cypress instances approximate foliage sprays rather than individual scale leaves.

| Preset | Research basis | Implemented interpretation |
|---|---|---|
| English oak — *Quercus robur* | [NC State](https://plants.ces.ncsu.edu/plants/quercus-robur/): spreading rounded crown, short stout trunk, rounded leaf lobes | Broad low crown, thicker trunk, repeated lobes in the leaf mask |
| Red maple — *Acer rubrum* | [NC State](https://plants.ces.ncsu.edu/plants/acer-rubrum/): rounded crown, ascending branches, lobed leaves and variable red autumn colour | Taller rounded crown, palmate mask; explicit autumn tint rather than red summer leaves |
| Silver birch — *Betula pendula* | [NC State](https://plants.ces.ncsu.edu/plants/betula-pendula/): maturing oval crown, white peeling bark, pendulous branches | Slender pale marked trunk, narrow oval crown and small pointed leaves; bark markings approximate peeling |
| Weeping willow — *Salix babylonica* | [NC State](https://plants.ces.ncsu.edu/plants/salix-babylonica/): pendulous branchlets and narrow lanceolate leaves | Long vertical leaf curtains, fine hanging woody stems and thin downward-facing leaf geometry |
| Norway spruce — *Picea abies* | [NC State](https://plants.ces.ncsu.edu/plants/picea-abies/): conical crown, mature pendulous branches and short needles | Tiered tapered crown, central leader and short narrow needles; no cones |
| Stone pine — *Pinus pinea* | [NC State](https://plants.ces.ncsu.edu/plants/pinus-pinea/): mature umbrella crown, high radiating branches, loss of lower branches | Wide shallow high canopy, clear trunk and narrow needle shapes |
| Lombardy poplar — *Populus nigra* ‘Italica’ | [Oregon State](https://landscapeplants.oregonstate.edu/plants/populus-nigra-italica): columnar cultivar with rhombic-ovate leaves | Tall narrow deciduous crown, ascending branches and diamond leaf mask. This cultivar is not representative of all black poplars |
| Italian cypress — *Cupressus sempervirens* | [NC State](https://plants.ces.ncsu.edu/plants/cupressus-sempervirens/): cultivated columnar forms, dense evergreen foliage | Dark narrow pointed column and upright foliage sprays. Represents a cultivated columnar form, not every wild tree |
| Blue gum — *Eucalyptus globulus* | [RHS](https://www.rhs.org.uk/plants/25081/eucalyptus-globulus/details), [Kew](https://powo.science.kew.org/taxon/urn%3Alsid%3Aipni.org%3Anames%3A592965-1/general-information): juvenile and adult leaves differ; adult foliage is elongated and curved | Pale trunk, irregular upper crown, green elongated curved adult leaves; no juvenile blue-white leaves |
| Canary Island date palm — *Phoenix canariensis* | [NC State](https://plants.ces.ncsu.edu/plants/phoenix-canariensis/): stout trunk with leaf-base scars, arching pinnate fronds and narrow leaflets along a rachis | Banded trunk, 32 arched frond paths, paired lateral leaflets. Scar bands approximate the real diamond pattern |

The generic grass preset is not labelled as a botanical species. It demonstrates the shared renderer with rooted tapered blades, six curved segments per blade, seeded patch placement and tip-weighted wind.

Camera projection, leaf masks, colour choices, normalized proportions and random distributions are rendering decisions. Light shelter remains an analytic approximation. Research descriptions should not be read as claims of exact anatomical reconstruction.
