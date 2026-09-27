# Public deployment validation

Repository: https://github.com/SamG-Coder/Leaf

Editor: https://samg-coder.github.io/Leaf/editor.html

The initial deployment passed GitHub Actions build and deploy jobs. A local headless Microsoft Edge WebGPU smoke test loaded the published editor, the 7,923-placement forest example (3,074 visible from its initial camera), and the rendering lab with no reported HTTP or runtime errors. Published scene CUDA source matched the local source after line-ending normalization. Runtime, generated triangle shader, license and oak preview requests succeeded.

Screenshot: [Published editor](../artifacts/pages-editor.png).

Run `node scripts/smoke-pages.mjs https://samg-coder.github.io/Leaf/` to repeat the browser check. This validates the tested WebGPU environment; it is not universal browser/GPU compatibility or a claim that all performance hitches are resolved.
