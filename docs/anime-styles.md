# Three anime shader styles

Choose **Anime style** in the right inspector, beneath **Anime finish**. The checkbox bypasses the stylized finish; the dropdown chooses one of three modes. Selection is a viewport setting, like the existing style sliders, and does not change saved map geometry.

| Mode | Visual treatment | Implementation |
| --- | --- | --- |
| Painted Background | Soft painted clusters, warm highlights, cool shaded foliage, restrained ink | Existing default retained. Object/depth/light-aware filtering, brush dabs and broad foliage lighting. |
| Cel Animation | Clear light/shadow regions, stronger silhouette lines and saturated colours | Quantized foliage and terrain illumination, stronger contour ink, luminance bands with less quantization on water and smooth sky gradients. Paint/softness controls are disabled because this mode bypasses their sampling work. |
| Ink & Watercolour | Pale translucent-looking washes, warmer paper, subtle grain and broken contours | Wider edge-aware colour filtering, desaturated wash, exposure-dependent paper lift and irregular ink opacity. Dark lighting is retained rather than replacing the scene with white paper. |

## Research and translation

These are original real-time shader interpretations, not a claim to reproduce a studio's artwork or proprietary renderer.

**Painted Background.** The [Ghibli Museum background-art exhibition](https://www.ghibli-museum.jp/en/exhibitions/013790/) describes background light, shadow and colour as products of hand work, paper, paint and water. Leaf interprets this through broad lit colour masses and pigment variation, retaining the existing painted mode. [Barbara Meier's painterly rendering paper](https://disneyanimation.com/publications/painterly-rendering-for-animation/) provides additional technical context for surface-associated brush strokes. Leaf's finish remains screen-space and is not an implementation of that paper's temporal-coherence method.

**Cel Animation.** [Arc System Works' Guilty Gear Xrd presentation](https://www.ggxrd.com/Motomura_Junya_GuiltyGearXrd.pdf) discusses pursuing an anime appearance in a 3D game. [Blender's Shader to RGB documentation](https://docs.blender.org/manual/en/latest/render/shader_nodes/converter/shader_to_rgb.html) documents remapping lighting through a colour ramp for toon shading. Leaf translates the broad approach into explicit light thresholds and outlines. It does not implement character-specific normal editing or authored facial shadows.

**Ink & Watercolour.** The [Ghibli Museum's Princess Kaguya exhibition](https://www.ghibli-museum.jp/exhibition/009448/) describes pale watercolour backgrounds, expressive pencil lines and areas deliberately left unpainted. Leaf translates these characteristics into pale colour washes, paper pigment and interrupted contours. It retains solid scene silhouettes; it does not erase geometric areas or generate hand-drawn strokes.

## Lighting, performance and limits

Modes share the existing geometry, depth and picking buffers. Near samples and distant tree canopy triangles use the same foliage lighting helper. Changing the dropdown does not regenerate plants, alter polygon shapes or change sample budgets.

The CUDA finish processes the selected style for terrain, vegetation, props, water and atmospheric sky. Weather remains animated and day/night illumination is preserved. Cel skips brush dabs and the blur-tap loops; no additional full-screen pass is introduced. No universal frame-time improvement is claimed.

Paper texture and brush placement are screen-space, so camera movement can change their placement. Outlines use depth and object boundaries, rather than drawn anatomical lines. The watercolour look is an appearance treatment, not fluid pigment simulation. Existing depth-dependent water transparency remains unchanged.

Build: `npm run build`. Browser validation: start the local server, then `node scripts/test-anime-styles.mjs`. The test checks distinct renders, the real dropdown and bypass control, geometry reuse, unchanged map data, and fixed-time day/night lighting across all three modes. Comparisons are in `artifacts/anime-painted.png`, `anime-cel.png` and `anime-watercolour.png`.
