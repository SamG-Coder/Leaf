const nc=slug=>`https://plants.ces.ncsu.edu/plants/${slug}/`;

export const PRESETS=Object.freeze([

 {id:0,key:'english-oak',name:'English oak',scientific:'Quercus robur',description:'Broad spreading crown, stout trunk and rounded lobed leaves.',source:nc('quercus-robur'),deciduous:true},

 {id:1,key:'red-maple',name:'Red maple',scientific:'Acer rubrum',description:'Ascending rounded crown and palmate foliage. Explore its red autumn colours.',source:nc('acer-rubrum'),deciduous:true},

 {id:2,key:'silver-birch',name:'Silver birch',scientific:'Betula pendula',description:'Light oval crown, small pointed leaves and pale marked bark.',source:nc('betula-pendula'),deciduous:true},

 {id:3,key:'weeping-willow',name:'Weeping willow',scientific:'Salix babylonica',description:'Spreading crown with long curtains of narrow leaves.',source:nc('salix-babylonica'),deciduous:true},

 {id:4,key:'norway-spruce',name:'Norway spruce',scientific:'Picea abies',description:'Tapered evergreen crown, tiered branches and short needles.',source:nc('picea-abies')},

 {id:5,key:'stone-pine',name:'Stone pine',scientific:'Pinus pinea',description:'Mature umbrella canopy, clear lower trunk and long needles.',source:nc('pinus-pinea')},

 {id:6,key:'lombardy-poplar',name:'Lombardy poplar',scientific:"Populus nigra â€˜Italicaâ€™",description:'Narrow upright cultivar with ascending branches and diamond-shaped foliage.',source:'https://landscapeplants.oregonstate.edu/plants/populus-nigra-italica',deciduous:true},

 {id:7,key:'italian-cypress',name:'Italian cypress',scientific:'Cupressus sempervirens',description:'Cultivated columnar form with dense evergreen sprays and a pointed crown.',source:nc('cupressus-sempervirens')},

 {id:8,key:'blue-gum',name:'Blue gum',scientific:'Eucalyptus globulus',description:'Open irregular crown, pale bark and elongated curved adult leaves.',source:'https://www.rhs.org.uk/plants/25081/eucalyptus-globulus/details'},

 {id:9,key:'canary-island-date-palm',name:'Canary Island date palm',scientific:'Phoenix canariensis',description:'Stout single trunk with arching fronds and narrow leaflets on either side.',source:nc('phoenix-canariensis')},

 {id:10,key:'grass',name:'Instanced grass',scientific:'Procedural blade emitter',description:'Root-anchored blades in 128 seeded ground patches. Wind bends blades toward their tips.',source:null},

 {id:11,key:'boxwood',name:'Boxwood',scientific:'Buxus sempervirens',description:'Dense rounded evergreen shrub with small oval leaves and low woody stems.',source:nc('buxus-sempervirens'),category:'bush'},

 {id:12,key:'english-lavender',name:'English lavender',scientific:'Lavandula angustifolia',description:'Low silver-green mound with narrow foliage and upright violet flowering spikes.',source:nc('lavandula-angustifolia'),category:'bush'},

 {id:13,key:'rosemary',name:'Rosemary',scientific:'Salvia rosmarinus',description:'Upright woody stems, narrow evergreen leaves and scattered pale blue flowers.',source:nc('salvia-rosmarinus'),category:'bush'},

 {id:14,key:'bigleaf-hydrangea',name:'Bigleaf hydrangea',scientific:'Hydrangea macrophylla',description:'Broad leaves on a rounded bush with pink mophead flower clusters; a selected flowering form.',source:nc('hydrangea-macrophylla'),category:'bush',deciduous:true},

 {id:15,key:'catawba-rhododendron',name:'Catawba rhododendron',scientific:'Rhododendron catawbiense',description:'Broad evergreen foliage with purple flower trusses above a spreading woody frame.',source:nc('rhododendron-catawbiense'),category:'bush'},

 {id:16,key:'southern-indian-azalea',name:'Southern Indian azalea',scientific:'Rhododendron indicum',description:'Compact branching shrub with small leaves and a dense pink-red flowering display.',source:nc('rhododendron-indicum'),category:'bush'},

 {id:17,key:'border-forsythia',name:'Border forsythia',scientific:'Forsythia \u00d7 intermedia',description:'Arching canes with yellow flowers. This preset represents its early flowering display.',source:nc('forsythia-x-intermedia'),category:'bush',deciduous:true},

 {id:18,key:'creeping-juniper',name:'Creeping juniper',scientific:'Juniperus horizontalis',description:'Low spreading evergreen mat, horizontal woody branches and fine blue-green foliage.',source:nc('juniperus-horizontalis'),category:'bush'},

 {id:19,key:'japanese-holly',name:'Japanese holly',scientific:'Ilex crenata',description:'Upright dense evergreen form with small rounded leaves; no spiny-leaf substitute.',source:nc('ilex-crenata'),category:'bush'},

 {id:20,key:'japanese-barberry',name:'Japanese barberry',scientific:'Berberis thunbergii',description:'Arching twiggy shrub shown in a purple-leaved horticultural form.',source:nc('berberis-thunbergii'),category:'bush',deciduous:true}


,
{"id": 21, "key": "sunflower", "name": "Sunflower", "scientific": "Helianthus annuus", "description": "Golden ray petals around a broad dark disk on tall leafy stems.", "source": "https://plants.ces.ncsu.edu/plants/helianthus-annuus/", "category": "flower"},
{"id": 22, "key": "shasta-daisy", "name": "Shasta daisy", "scientific": "Leucanthemum \u00d7 superbum", "description": "White narrow rays around a yellow centre.", "source": "https://plants.ces.ncsu.edu/plants/leucanthemum-x-superbum/", "category": "flower"},
{"id": 23, "key": "tulip", "name": "Tulip", "scientific": "Tulipa hybrids", "description": "Six overlapping pink-red tepals form an open upright cup.", "source": "https://plants.ces.ncsu.edu/plants/tulipa/", "category": "flower"},
{"id": 24, "key": "daffodil", "name": "Daffodil", "scientific": "Narcissus hybrids", "description": "Six pale yellow tepals surround a projecting golden trumpet.", "source": "https://plants.ces.ncsu.edu/plants/narcissus/", "category": "flower"},
{"id": 25, "key": "common-poppy", "name": "Common poppy", "scientific": "Papaver rhoeas", "description": "Four broad red petals form a shallow bowl around a dark centre.", "source": "https://plants.ces.ncsu.edu/plants/papaver-rhoeas/", "category": "flower"},
{"id": 26, "key": "garden-rose", "name": "Garden rose", "scientific": "Rosa hybrids", "description": "A selected double pink form with five staggered petal whorls.", "source": "https://plants.ces.ncsu.edu/plants/rosa/", "category": "flower"},
{"id": 27, "key": "cosmos", "name": "Cosmos", "scientific": "Cosmos bipinnatus", "description": "Eight broad pink rays, yellow centres and fine foliage.", "source": "https://plants.ces.ncsu.edu/plants/cosmos-bipinnatus/", "category": "flower"},
{"id": 28, "key": "purple-coneflower", "name": "Purple coneflower", "scientific": "Echinacea purpurea", "description": "Drooping pink rays surround a raised copper-coloured cone.", "source": "https://plants.ces.ncsu.edu/plants/echinacea-purpurea/", "category": "flower"},
{"id": 29, "key": "english-bluebell", "name": "English bluebell", "scientific": "Hyacinthoides non-scripta", "description": "One-sided racemes of pendent blue bells above straplike leaves.", "source": "https://www.kew.org/plants/bluebell", "category": "flower"},
{"id": 30, "key": "bearded-iris", "name": "Bearded iris", "scientific": "Iris \u00d7 germanica", "description": "Three upright standards and three drooping falls with golden beards.", "source": "https://plants.ces.ncsu.edu/plants/iris-x-germanica/", "category": "flower"},
{"id": 31, "key": "boston-fern", "name": "Boston fern", "scientific": "Nephrolepis exaltata", "description": "Long arching fronds with many narrow pinnae; a drooping garden form.", "source": "https://plants.ces.ncsu.edu/plants/nephrolepis-exaltata/", "category": "fern"},
{"id": 32, "key": "ostrich-fern", "name": "Ostrich fern", "scientific": "Onoclea struthiopteris", "description": "Tall upright shuttlecock crown with tapered feather-like fronds.", "source": "https://plants.ces.ncsu.edu/plants/onoclea-struthiopteris/", "category": "fern"},
{"id": 33, "key": "northern-maidenhair-fern", "name": "Northern maidenhair fern", "scientific": "Adiantum pedatum", "description": "Spreading horizontal fingers with small fan-shaped pinnules and dark stalks.", "source": "https://plants.ces.ncsu.edu/plants/adiantum-pedatum/", "category": "fern"},
{"id": 34, "key": "autumn-fern", "name": "Autumn fern", "scientific": "Dryopteris erythrosora", "description": "Twice-divided triangular fronds with copper-coloured young growth.", "source": "https://plants.ces.ncsu.edu/plants/dryopteris-erythrosora/", "category": "fern"},
{"id": 35, "key": "japanese-painted-fern", "name": "Japanese painted fern", "scientific": "Athyrium niponicum", "description": "Low arching divided fronds, shown in a silvery cultivated form with reddish stalks.", "source": "https://plants.ces.ncsu.edu/plants/athyrium-niponicum/", "category": "fern"},
{"id": 36, "key": "birds-nest-fern", "name": "Bird\u2019s nest fern", "scientific": "Asplenium nidus", "description": "Undivided wavy strap fronds radiate from an open central crown.", "source": "https://plants.ces.ncsu.edu/plants/asplenium-nidus/", "category": "fern"},
{"id": 37, "key": "japanese-holly-fern", "name": "Japanese holly fern", "scientific": "Cyrtomium falcatum", "description": "Broad pointed, sickle-like pinnae along open arching fronds.", "source": "https://plants.ces.ncsu.edu/plants/cyrtomium-falcatum/", "category": "fern"},
{"id": 38, "key": "christmas-fern", "name": "Christmas fern", "scientific": "Polystichum acrostichoides", "description": "Low evergreen lance-shaped fronds with closely spaced leathery pinnae.", "source": "https://plants.ces.ncsu.edu/plants/polystichum-acrostichoides/", "category": "fern"},
{"id": 39, "key": "royal-fern", "name": "Royal fern", "scientific": "Osmunda regalis", "description": "Tall branching fronds with separated broad pinnules. Sterile foliage display.", "source": "https://plants.ces.ncsu.edu/plants/osmunda-regalis/", "category": "fern"},
{"id": 40, "key": "sensitive-fern", "name": "Sensitive fern", "scientific": "Onoclea sensibilis", "description": "Broad, coarsely lobed triangular sterile fronds.", "source": "https://plants.ces.ncsu.edu/plants/onoclea-sensibilis/", "category": "fern"},
{"id": 41, "key": "pincushion-moss", "name": "Pincushion moss", "scientific": "Leucobryum glaucum", "description": "Rounded pale-green cushions formed from dense upright shoots.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/leucobryum-glaucum/", "category": "moss"},
{"id": 42, "key": "common-haircap-moss", "name": "Common haircap moss", "scientific": "Polytrichum commune", "description": "Tall upright shoots with narrow radiating leaves and starry tips.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/polytrichum-commune/", "category": "moss"},
{"id": 43, "key": "broom-fork-moss", "name": "Broom fork-moss", "scientific": "Dicranum scoparium", "description": "Dense tufts with fine leaves swept toward one side.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/dicranum-scoparium/", "category": "moss"},
{"id": 44, "key": "cypress-leaved-plait-moss", "name": "Cypress-leaved plait-moss", "scientific": "Hypnum cupressiforme", "description": "Low creeping mats with curved, overlapping leafy sprays.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/hypnum-cupressiforme/", "category": "moss"},
{"id": 45, "key": "tamarisk-moss", "name": "Tamarisk moss", "scientific": "Thuidium tamariscinum", "description": "Fine triangular branching sprays form a fern-like carpet.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/thuidium-tamariscinum/", "category": "moss"},
{"id": 46, "key": "glittering-wood-moss", "name": "Glittering wood-moss", "scientific": "Hylocomium splendens", "description": "Layered feathery growth with stepped spray heights.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/hylocomium-splendens/", "category": "moss"},
{"id": 47, "key": "springy-turf-moss", "name": "Springy turf-moss", "scientific": "Rhytidiadelphus squarrosus", "description": "Loose pale-green turf with outward-bent, starry leaves.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/rhytidiadelphus-squarrosus/", "category": "moss"},
{"id": 48, "key": "tree-moss", "name": "Tree moss", "scientific": "Climacium dendroides", "description": "Miniature branched crowns stand above slender upright stalks.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/climacium-dendroides/", "category": "moss"},
{"id": 49, "key": "blunt-leaved-bog-moss", "name": "Blunt-leaved bog-moss", "scientific": "Sphagnum palustre", "description": "Uneven hummocks of compact heads with clustered spreading branches.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/sphagnum-palustre/", "category": "moss"},
{"id": 50, "key": "silvery-thread-moss", "name": "Silvery thread-moss", "scientific": "Bryum argenteum", "description": "Short, densely packed shoots forming a low silvery-green mat.", "source": "https://www.britishbryologicalsociety.org.uk/learning/species-finder/bryum-argenteum/", "category": "moss"},
{"id": 51, "key": "english-ivy", "name": "English ivy", "scientific": "Hedera helix", "description": "Root-clinging shoots follow a trunk, with lobed juvenile leaves facing outward.", "source": "https://plants.ces.ncsu.edu/plants/hedera-helix/", "category": "vine"},
{"id": 52, "key": "canary-ivy", "name": "Canary ivy", "scientific": "Hedera canariensis", "description": "Broad lobed leaves on branching, trunk-following shoots.", "source": "https://plants.ces.ncsu.edu/plants/hedera-canariensis/", "category": "vine"},
{"id": 53, "key": "boston-ivy", "name": "Boston ivy", "scientific": "Parthenocissus tricuspidata", "description": "Surface-following shoots with adhesive contact guides and three-lobed leaves.", "source": "https://plants.ces.ncsu.edu/plants/parthenocissus-tricuspidata/", "category": "vine"},
{"id": 54, "key": "virginia-creeper", "name": "Virginia creeper", "scientific": "Parthenocissus quinquefolia", "description": "Surface-climbing shoots carry five radiating leaflets.", "source": "https://plants.ces.ncsu.edu/plants/parthenocissus-quinquefolia/", "category": "vine"},
{"id": 55, "key": "grape-vine", "name": "Grape vine", "scientific": "Vitis vinifera", "description": "Trellis-spreading canes with broad lobed leaves and attachment guides.", "source": "https://plants.ces.ncsu.edu/plants/vitis-vinifera/", "category": "vine"},
{"id": 56, "key": "chinese-wisteria", "name": "Chinese wisteria", "scientific": "Wisteria sinensis", "description": "Spiralling stems wind around a trunk, carrying pinnate foliage.", "source": "https://plants.ces.ncsu.edu/plants/wisteria-sinensis/", "category": "vine"},
{"id": 57, "key": "coral-honeysuckle", "name": "Coral honeysuckle", "scientific": "Lonicera sempervirens", "description": "Stems twine around a trunk, with paired oval leaves.", "source": "https://plants.ces.ncsu.edu/plants/lonicera-sempervirens/", "category": "vine"},
{"id": 58, "key": "virgins-bower", "name": "Virgin\u2019s bower", "scientific": "Clematis virginiana", "description": "Trellis-spreading shoots with three-part compound leaves.", "source": "https://plants.ces.ncsu.edu/plants/clematis-virginiana/", "category": "vine"},
{"id": 59, "key": "morning-glory", "name": "Morning glory", "scientific": "Ipomoea purpurea", "description": "Coiling stems wrap a trunk, with outward-facing heart-shaped leaves.", "source": "https://plants.ces.ncsu.edu/plants/ipomoea-purpurea/", "category": "vine"},
{"id": 60, "key": "creeping-fig", "name": "Creeping fig", "scientific": "Ficus pumila", "description": "Root-clinging shoots follow bark, with small juvenile leaves.", "source": "https://plants.ces.ncsu.edu/plants/ficus-pumila/", "category": "vine"},
{"id": 61, "key": "blue-fescue", "name": "Blue fescue", "scientific": "Festuca glauca", "description": "Low blue-grey clumps with fine outward-pointing blades.", "source": "https://plants.ces.ncsu.edu/plants/festuca-glauca/", "category": "grass"},
{"id": 62, "key": "red-fescue", "name": "Red fescue", "scientific": "Festuca rubra", "description": "Fine-textured green turf with longer arching blades.", "source": "https://plants.ces.ncsu.edu/plants/festuca-rubra/", "category": "grass"},
{"id": 63, "key": "kentucky-bluegrass", "name": "Kentucky bluegrass", "scientific": "Poa pratensis", "description": "Low blue-green turf with medium-width blades.", "source": "https://plants.ces.ncsu.edu/plants/poa-pratensis/", "category": "grass"},
{"id": 64, "key": "perennial-ryegrass", "name": "Perennial ryegrass", "scientific": "Lolium perenne", "description": "Upright dark-green turf with broader blades.", "source": "https://plants.ces.ncsu.edu/plants/lolium-perenne/", "category": "grass"},
{"id": 65, "key": "bermudagrass", "name": "Bermudagrass", "scientific": "Cynodon dactylon", "description": "Short fine-bladed turf with a spreading lean.", "source": "https://www.turffiles.ncsu.edu/grasses/bermudagrass/", "category": "grass"},
{"id": 66, "key": "zoysiagrass", "name": "Zoysiagrass", "scientific": "Zoysia japonica", "description": "Compact dense turf with stiff upright blades.", "source": "https://www.turffiles.ncsu.edu/grasses/zoysiagrass/", "category": "grass"},
{"id": 67, "key": "chinese-silvergrass", "name": "Chinese silvergrass", "scientific": "Miscanthus sinensis", "description": "Tall arching clumps with broad blades and pale plume approximations.", "source": "https://plants.ces.ncsu.edu/plants/miscanthus-sinensis/", "category": "grass"},
{"id": 68, "key": "switchgrass", "name": "Switchgrass", "scientific": "Panicum virgatum", "description": "Tall upright clumps with blue-green blades and light seed-head approximations.", "source": "https://plants.ces.ncsu.edu/plants/panicum-virgatum/", "category": "grass"},
{"id": 69, "key": "fountain-grass", "name": "Fountain grass", "scientific": "Cenchrus alopecuroides", "description": "Fountain-shaped clumps with arching blades and compact seed heads.", "source": "https://plants.ces.ncsu.edu/plants/cenchrus-alopecuroides/", "category": "grass"},
{"id": 70, "key": "mexican-feather-grass", "name": "Mexican feather grass", "scientific": "Nassella tenuissima", "description": "Fine flexible golden-green blades with slender seed heads.", "source": "https://www.rhs.org.uk/plants/202303/nassella-tenuissima/details", "category": "grass"},
{"id": 71, "key": "wheat", "name": "Wheat", "scientific": "Triticum aestivum", "description": "Golden spikes with paired grain rows above narrow leaves.", "source": "https://plants.ces.ncsu.edu/plants/triticum-aestivum/", "category": "crop"},
{"id": 72, "key": "barley", "name": "Barley", "scientific": "Hordeum vulgare", "description": "Grain spikes with extended awn samples.", "source": "https://plants.ces.ncsu.edu/plants/hordeum-vulgare/", "category": "crop"},
{"id": 73, "key": "oats", "name": "Oats", "scientific": "Avena sativa", "description": "Open branching panicles above leafy stems.", "source": "https://plants.ces.ncsu.edu/plants/avena-sativa/", "category": "crop"},
{"id": 74, "key": "rice", "name": "Rice", "scientific": "Oryza sativa", "description": "Narrow foliage and nodding grain panicles; dry display without water.", "source": "https://www.kew.org/plants/asian-rice", "category": "crop"},
{"id": 75, "key": "maize", "name": "Maize", "scientific": "Zea mays", "description": "Tall stalks, broad arching leaves, side ears and upper tassels.", "source": "https://plants.ces.ncsu.edu/plants/zea-mays/", "category": "crop"},
{"id": 76, "key": "grain-sorghum", "name": "Grain sorghum", "scientific": "Sorghum bicolor", "description": "Broad leaves below compact reddish grain heads.", "source": "https://plants.ces.ncsu.edu/plants/sorghum-bicolor/", "category": "crop"},
{"id": 77, "key": "pearl-millet", "name": "Pearl millet", "scientific": "Cenchrus americanus", "description": "Upright cylindrical grain heads and strap leaves.", "source": "https://plants.ces.ncsu.edu/plants/cenchrus-americanus/", "category": "crop"},
{"id": 78, "key": "sugarcane", "name": "Sugarcane", "scientific": "Saccharum officinarum", "description": "Thick upright canes with long arching leaves; vegetative display.", "source": "https://plants.ces.ncsu.edu/plants/saccharum-officinarum/", "category": "crop"},
{"id": 79, "key": "soybean", "name": "Soybean", "scientific": "Glycine max", "description": "Short plants with three-part leaf groups and hanging pods.", "source": "https://plants.ces.ncsu.edu/plants/glycine-max/", "category": "crop"},
{"id": 80, "key": "cotton", "name": "Cotton", "scientific": "Gossypium hirsutum", "description": "Leafy rows with pale open cotton bolls.", "source": "https://plants.ces.ncsu.edu/plants/gossypium-hirsutum/", "category": "crop"},
{"id": 81, "key": "fly-agaric", "name": "Fly agaric", "scientific": "Amanita muscaria", "description": "Red domed caps with pale flecks.", "source": "https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/fungi-and-lichens/fly-agaric/", "category": "mushroom"},
{"id": 82, "key": "porcini", "name": "Porcini", "scientific": "Boletus edulis", "description": "Broad brown caps and thick stems.", "source": "https://www.mushroomexpert.com/boletus_edulis.html", "category": "mushroom"},
{"id": 83, "key": "chanterelle", "name": "Chanterelle", "scientific": "Cantharellus cibarius", "description": "Golden wavy funnel caps.", "source": "https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/fungi-and-lichens/chanterelle/", "category": "mushroom"},
{"id": 84, "key": "amethyst-deceiver", "name": "Amethyst deceiver", "scientific": "Laccaria amethystina", "description": "Small violet caps and slender stems.", "source": "https://www.woodlandtrust.org.uk/blog/2025/11/types-of-mushroom/", "category": "mushroom"},
{"id": 85, "key": "shaggy-inkcap", "name": "Shaggy inkcap", "scientific": "Coprinus comatus", "description": "Tall pale bell caps with scale-like markings.", "source": "https://www.dorsetwildlifetrust.org.uk/wildlife-explorer/fungi/shaggy-inkcap", "category": "mushroom"},
{"id": 86, "key": "sulphur-tuft", "name": "Sulphur tuft", "scientific": "Hypholoma fasciculare", "description": "Compact yellow clusters around fallen wood.", "source": "https://www.yorkshiredales.org.uk/about/wildlife/species/fungi-lichens/fungi/common-fungi-of-the-dales/", "category": "mushroom"},
{"id": 87, "key": "oyster-mushroom", "name": "Oyster mushroom", "scientific": "Pleurotus ostreatus", "description": "Overlapping lateral fans on a fallen log.", "source": "https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/fungi-and-lichens/oyster-mushroom/", "category": "mushroom"},
{"id": 88, "key": "turkey-tail", "name": "Turkey tail", "scientific": "Trametes versicolor", "description": "Thin concentric-banded shelves on wood.", "source": "https://www.mushroomexpert.com/trametes_versicolor.html", "category": "mushroom"},
{"id": 89, "key": "common-puffball", "name": "Common puffball", "scientific": "Lycoperdon perlatum", "description": "Rounded pale fruiting bodies in scattered groups.", "source": "https://www.wildlondon.org.uk/fungi-spotter", "category": "mushroom"},
{"id": 90, "key": "fairy-ring-champignon", "name": "Fairy-ring champignon", "scientific": "Marasmius oreades", "description": "Small tan mushrooms forming a ring.", "source": "https://www.woodlandtrust.org.uk/blog/2019/08/what-is-a-fairy-ring/", "category": "mushroom"},
{"id": 91, "key": "granite-boulders", "name": "Granite boulders", "scientific": "Granite", "description": "Rounded rough boulders with mineral speckling.", "source": "https://www.nps.gov/subjects/geology/igneous.htm", "category": "mineral"},
{"id": 92, "key": "basalt-columns", "name": "Basalt columns", "scientific": "Basalt", "description": "Joined hexagonal columns with stepped tops.", "source": "https://www.nps.gov/subjects/volcanoes/columnar-jointing.htm", "category": "mineral"},
{"id": 93, "key": "sandstone-outcrop", "name": "Sandstone outcrop", "scientific": "Sandstone", "description": "Warm layered blocks with fine sediment bands.", "source": "https://www.nps.gov/subjects/geology/sedimentary.htm", "category": "mineral"},
{"id": 94, "key": "slate-slabs", "name": "Slate slabs", "scientific": "Slate", "description": "Thin overlapping blue-grey slabs.", "source": "https://www.nps.gov/subjects/geology/metamorphic.htm", "category": "mineral"},
{"id": 95, "key": "limestone-boulders", "name": "Limestone boulders", "scientific": "Limestone", "description": "Pale weathered boulder group.", "source": "https://www.nps.gov/subjects/geology/sedimentary.htm", "category": "mineral"},
{"id": 96, "key": "quartz-cluster", "name": "Quartz cluster", "scientific": "Quartz", "description": "Pale hexagonal prisms with pointed tips.", "source": "https://www.minerals.net/mineral/quartz", "category": "mineral"},
{"id": 97, "key": "amethyst-cluster", "name": "Amethyst cluster", "scientific": "Amethyst", "description": "Violet pointed quartz prisms.", "source": "https://www.minerals.net/mineral/amethyst", "category": "mineral"},
{"id": 98, "key": "smoky-quartz", "name": "Smoky quartz", "scientific": "Smoky quartz", "description": "Brown-grey pointed crystal cluster.", "source": "https://www.minerals.net/mineral/quartz", "category": "mineral"},
{"id": 99, "key": "pyrite-cubes", "name": "Pyrite cubes", "scientific": "Pyrite", "description": "Gold-coloured cubic crystal group.", "source": "https://www.minerals.net/mineral/pyrite", "category": "mineral"},
{"id": 100, "key": "fluorite-cubes", "name": "Fluorite cubes", "scientific": "Fluorite", "description": "Green cubic crystals with bright facets.", "source": "https://www.minerals.net/mineral/fluorite", "category": "mineral"},
{"id": 101, "key": "oak-leaf-litter", "name": "Oak leaf litter", "scientific": "Ground litter", "description": "Curled brown leaves with lobed outlines.", "category": "litter"},
{"id": 102, "key": "maple-leaf-litter", "name": "Maple leaf litter", "scientific": "Ground litter", "description": "Warm orange fallen leaves with notched edges.", "category": "litter"},
{"id": 103, "key": "birch-leaf-litter", "name": "Birch leaf litter", "scientific": "Ground litter", "description": "Small golden pointed leaves.", "category": "litter"},
{"id": 104, "key": "pine-needle-litter", "name": "Pine needle litter", "scientific": "Ground litter", "description": "Thin dry needles scattered across the ground.", "category": "litter"},
{"id": 105, "key": "fallen-twigs", "name": "Fallen twigs", "scientific": "Ground litter", "description": "Short rounded woody fragments.", "category": "litter"},
{"id": 106, "key": "bark-chips", "name": "Bark chips", "scientific": "Ground litter", "description": "Rough curled bark fragments.", "category": "litter"},
{"id": 107, "key": "fallen-pine-cones", "name": "Fallen pine cones", "scientific": "Ground litter", "description": "Rounded cones with corrugated scale approximations.", "category": "litter"},
{"id": 108, "key": "fallen-acorns", "name": "Fallen acorns", "scientific": "Ground litter", "description": "Small brown oval nut approximations.", "category": "litter"},
{"id": 109, "key": "pebble-scatter", "name": "Pebble scatter", "scientific": "Ground litter", "description": "Low rounded grey stones.", "category": "litter"},
{"id": 110, "key": "mixed-forest-litter", "name": "Mixed forest litter", "scientific": "Ground litter", "description": "Leaves, needles, twigs, bark, cones, nuts and pebbles.", "category": "litter"},
{"id": 111, "key": "fallen-log", "name": "Fallen log", "scientific": "Deadwood", "description": "Long tapered trunk with exposed end grain.", "category": "deadwood"},
{"id": 112, "key": "hollow-log", "name": "Hollow log", "scientific": "Deadwood", "description": "Open-ended trunk with inner walls and a thick rim.", "category": "deadwood"},
{"id": 113, "key": "cut-stump", "name": "Cut stump", "scientific": "Deadwood", "description": "Low stump with a flat exposed top.", "category": "deadwood"},
{"id": 114, "key": "snapped-stump", "name": "Snapped stump", "scientific": "Deadwood", "description": "Broken stump with an irregular splintered crown.", "category": "deadwood"},
{"id": 115, "key": "root-stump", "name": "Root stump", "scientific": "Deadwood", "description": "Stump with six spreading tapered roots.", "category": "deadwood"},
{"id": 116, "key": "driftwood", "name": "Driftwood", "scientific": "Deadwood", "description": "Pale trunk with branching weathered limbs.", "category": "deadwood"},
{"id": 117, "key": "fallen-birch-log", "name": "Fallen birch log", "scientific": "Deadwood", "description": "Pale marked bark around a fallen trunk.", "category": "deadwood"},
{"id": 118, "key": "split-log", "name": "Split log", "scientific": "Deadwood", "description": "Half-log with an exposed longitudinal split.", "category": "deadwood"},
{"id": 119, "key": "log-pile", "name": "Log pile", "scientific": "Deadwood", "description": "Five overlapping logs in two levels.", "category": "deadwood"},
{"id": 120, "key": "dead-snag", "name": "Dead snag", "scientific": "Deadwood", "description": "Tall broken trunk with short branch remnants.", "category": "deadwood"}
]);

export function presetFor(value){const p=PRESETS.find(p=>p.id===value||p.key===value);if(!p)throw new RangeError(`Unknown foliage preset: ${value}`);return p;}

