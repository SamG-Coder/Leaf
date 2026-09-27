# Native Windows export investigation

## Decision

Build a reusable Windows x64 player ahead of time, link the shared Leaf CUDA kernels into it, and export maps as data. Map authors and players should not need nvcc, Visual Studio, Node, WebGPU, or a shader compiler. A supported NVIDIA GPU and compatible installed driver are required. This is a proposed export architecture, not an implemented native world player.

## Verified locally

On 2026-09-28, CUDA 13.3 and MSVC built all 31 current kernels from the original `.cu` files into `Native/build/LeafKernels.lib` without rewriting shader bodies. Generated forward declarations allow the native C++ compiler to resolve helper functions defined later in the browser source concatenation.

A separate executable linked to that library and generated all 121 presets twice, checking 4,096 positions per preset for finite values and repeatability. It passed on NVIDIA GeForce RTX 5080, compute capability 12.0, driver 616.64. It also passed with `CUDA_DISABLE_PTX_JIT=1`, proving that this probe uses precompiled machine code on this GPU.

- Kernel static library: 3,660,256 bytes.
- Probe executable: 3,626,496 bytes.
- Executable SHA256: `F08D2D64AC44B6EB8D1B610A122B062B927D8E8C7D605C1274457F8071F1D032`.
- `cuobjdump --list-elf` confirms embedded `sm_120` cubins.
- `dumpbin /dependents` lists only `KERNEL32.dll`; CUDA and MSVC runtimes are statically linked. CUDA still loads the installed NVIDIA driver dynamically. This does not remove the GPU/driver requirement.

The probe is console-only and does not load a world or draw a window. Only geometry generation was executed; compiling all kernels does not prove native image parity, rasterization correctness, FFT correctness, or performance. Its size is not an estimate for a complete multi-architecture player.

Build and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Native/build-probe.ps1
```

Default target is `sm_120` for the local RTX 5080. `-Architecture` selects another target, but the build script also runs the probe and requires compatible hardware. Build outputs are ignored by Git. Native builds remain local; existing Pages CI is unaffected.

## Build once, package many worlds

Recommended player structure:

```text
LeafPlayer.exe          native window, input, physics, scheduling, linked CUDA kernels
world.leaf             versioned map JSON initially; compact binary sections later
player.json            start location, graphics defaults, player/package version
licenses/              applicable Leaf, ClearWater and redistributable notices
```

`LeafKernels.lib` is a build-time static library and becomes part of the executable; it does not need to ship as a separate runtime file. A DLL backend can be introduced later if independent engine updates or optional backends justify it. Existing custom FFT kernels can be retained; cuFFT is not required just to create a native version.

The browser editor's Export Windows action should fetch a versioned prebuilt player template and package it with the validated world. It should never upload a private map merely to compile it. A browser can download the package but cannot launch an `.exe`. Initially export a folder/ZIP; a single-file data container can follow once package versioning is established. Map export performs no shader compilation. Custom changes to `.cu` files still require publishing a new engine build.

Keep authoritative data: asset identifiers/seeds, placement transforms, terrain base and sparse tiles, water/grass polygon control points and smoothing/seed options, ocean, wind, environment/time/weather state, spawn and settings. Do not ship transient generated leaf arrays or editor history. Current renderer-only preferences such as anime style need an explicit export settings section because they are not all in map JSON today.

## Native host work still required

1. **World loader and validation.** Match `map-model.js`, `plan-model.js`, `water-model.js` and `environment.js`; support terrain tiles, seeded grass plans and water outlines. Version the package and reject unsupported engine/world versions.
2. **GPU buffer/dispatch backend.** Port the orchestration in `map-renderer.js` and `foliage-system.js`, including cached seeded geometry, near/far LOD, culling, shadows, water FFT, weather, anime and underwater passes. Preserve source kernel ownership; add native API wrappers and explicit parameter layouts.
3. **Presentation.** Adapt the design in `D:/ClearWater/Native/main.cu`: Win32 plus D3D11 swap chain, persistent CUDA-registered offscreen RGBA texture, map/copy/unmap on GPU, then present. No per-frame CPU image readback. Register textures once per allocation/resize and select a D3D device matching the CUDA adapter.
4. **Player loop.** Port fixed-step controller, collision spatial cells, interpolated camera, walking/sprinting/jumping/swimming, underwater transitions, pause and restart. Use raw mouse input and frame pacing. The web editor can remain the authoring UI; its DOM and JavaScript are not compiled by nvcc.
5. **Exporter.** Select player version/architecture support, validate map and spawn, package data plus prebuilt engine and notices, and give a supported-GPU message before export/run.
6. **Parity and performance gates.** Compare fixed seed geometry and images, near/far trees, all anime styles, ground cover, shadows, ocean/pond/river, weather, night/day and underwater. Replay movement/collision inputs. Profile kernels and total frame pacing at 1080p; do not assume native fixes existing algorithmic stalls.

## GPU compatibility

The shipping build should include cubins for explicitly supported architectures, for example `sm_75`, `sm_86`, `sm_89`, and `sm_120` for selected Turing/Ampere/Ada/Blackwell targets. This is a proposed test matrix, not validation on those GPUs. Add other architectures where the product's hardware support policy requires them.

A PTX fallback can provide a forward-compatibility route, but may invoke driver JIT and needs a driver that understands that PTX version. If the requirement is strictly no first-run compilation, use verified matching cubins and reject unsupported targets with a clear message. Do not market the current `sm_120` probe as a universal executable. CUDA 13 removed offline compilation for architectures before Turing; older-GPU support requires a separate toolchain policy.

NVIDIA documents CUDA 13.x minor-version compatibility on the R580+ driver family with feature restrictions. Choose and test an explicit Windows driver baseline for the eventual build; PTX and newer features can require newer drivers. AMD/Intel support would require a separate graphics/compute backend rather than these CUDA binaries.

## Sources

- [NVIDIA NVCC compiler guide: static libraries, cubins, fatbins and target architectures](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/)
- [NVIDIA graphics interoperability guide](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/graphics-interop.html)
- [CUDA minor-version compatibility](https://docs.nvidia.com/deploy/cuda-compatibility/minor-version-compatibility.html)
- [CUDA 13 architecture support changes](https://developer.nvidia.com/blog/whats-new-and-important-in-cuda-toolkit-13-0/)
- [CUDA redistribution terms and listed runtime components](https://docs.nvidia.com/cuda/eula/index.html)

Only redistributable runtime components needed by the chosen build should be packaged. Do not bundle the CUDA Toolkit or copy the machine's NVIDIA driver into an export.
