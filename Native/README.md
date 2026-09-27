# Leaf native feasibility probe

This is a compilation and GPU execution probe, **not the native world player**.

Run `powershell -NoProfile -ExecutionPolicy Bypass -File Native/build-probe.ps1` from the repository. It builds all shared kernels into a static library, links a console executable, and checks deterministic positions for all 121 asset presets. CUDA Toolkit and Visual Studio C++ tools are required to build; the default GPU target is `sm_120`.

See [the export investigation](../docs/native-export.md) for measured results, proposed package structure, GPU compatibility and remaining native host work. Outputs go into ignored `Native/build/`.
