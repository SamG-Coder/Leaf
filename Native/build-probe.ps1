param([string]$Architecture='sm_120')
$ErrorActionPreference='Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
node scripts/prepare-native-probe.mjs
if($LASTEXITCODE -ne 0){throw 'Source preparation failed'}
$nvcc=(Get-Command nvcc).Source
$vswhere=Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
$compiler=& $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find 'VC/Tools/MSVC/**/bin/Hostx64/x64/cl.exe' | Select-Object -First 1
if(-not $compiler){throw 'Visual Studio C++ compiler missing'}
$common=@('-std=c++17','-O3',"-arch=$Architecture",'-ccbin',(Split-Path $compiler),'-Xcompiler','/EHsc,/MT')
& $nvcc @common --lib Native/build/kernels.cu -o Native/build/LeafKernels.lib
if($LASTEXITCODE -ne 0){throw 'Native kernel library compilation failed'}
& $nvcc @common --cudart static Native/probe-main.cpp Native/build/LeafKernels.lib -o Native/build/LeafNativeProbe.exe
if($LASTEXITCODE -ne 0){throw 'Native probe link failed'}
& ./Native/build/LeafNativeProbe.exe
if($LASTEXITCODE -ne 0){throw 'Native GPU probe failed'}
