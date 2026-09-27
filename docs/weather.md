# Sky, time and weather

Terrain > Sky, time & weather enables the environment system. Old maps retain manual lighting until enabled; the island example enables it. Scrub the 24-hour clock, toggle Play time, and set real minutes per full day (1–1440). Pausing freezes time-of-day, while clouds, rain and wetting/drying continue. Hidden tabs suspend environment updates.

Choose manual Clear, Cloudy, Rain or Storm, or Dynamic mode. Dynamic weather blends between deterministic seeded three-hour targets, repeating each day. The clock drives sun direction, dawn/dusk sky colour and night illumination, with a visible sun, moon and stars. Existing manual sun and water rain/wind-speed controls are disabled while this system owns them.

Rain adds screen-space rain streaks, world-space expanding rings on visible water, and accumulating terrain darkening/sheens. Terrain dries gradually after rain. Wetness, clock settings, weather mode and preset persist in map JSON; rain does not deform heights. Wetness accumulation is global, with its rendered strength modulated by local cloud coverage. This is material wetness, not water pooling, erosion, shelter occlusion or a fluid simulation. Falling streaks and water rings are independent procedural effects, not individually simulated droplet collisions. Clouds use an animated sky layer rather than volumetric ray marching. Weather changes cloud cover, rain and water wind strength; it also drives shared, height-weighted vegetation bending across leaf splats, branches and canopy triangle LODs. Roots remain fixed.

One CUDA fullscreen weather pass runs when enabled. Geometry is reused; the moving-sun ground cache uses quantized direction keys. This does not establish a worst-case frame-time guarantee for large scenes.

Validation: scripts/test-weather.mjs checks day/night changes, rain wetness, clock play/pause, weather modes, persistence and browser errors. All 20 CUDA kernels compile.

With Anime enabled, clouds use sharper silhouettes, four light/shadow bands and cloud-space brush detail controlled by the paint amount. Disabling Anime uses continuous cloud lighting. Sky colours, stars and celestial disks are preserved instead of replaced by the legacy sky gradient.



Rain has been reverted to the original lightweight screen-space streaks and world-space water rings. The scrolling sign is corrected to move down. Ring centres and timing are randomized and reseeded each event, with neighbouring cells checked to avoid clipped circles. Falling streaks and rings are separate effects again. Tree wind and anime clouds are retained.

Performance diagnostics: scripts/bench-storm.mjs isolates warmed Clear/Rain/Storm frame totals and synchronization-based pass timings. scripts/bench-weather-switch.mjs captures live preset switches. Environment-only edits retain scene references to avoid rebuilding grass placements and terrain/ground caches. Water writes a per-pixel mask reused by weather, avoiding duplicate polygon containment checks. Ring work is skipped without rain and wet-ground sampling is skipped at zero wetness. Local measurements did not reproduce the reported 50 ms storm stall; artifacts retain before/after data, including isolated live-switch outliers. These results do not establish a performance gain or a worst-case guarantee.
