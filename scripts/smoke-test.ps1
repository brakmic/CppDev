param(
    [string]$Image = "brakmic/cppdev:latest",
    [int]$ExpectedGccMajor = 14
)

$ErrorActionPreference = "Stop"

function Get-ImageOutput {
    param([string[]]$Arguments)
    $output = & docker run --rm $Image @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "docker run failed: $($Arguments -join ' ')"
    }
    return ($output -join "`n").Trim()
}

function Invoke-Checked {
    param([string[]]$Arguments)
    & docker run --rm $Image @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "docker run failed: $($Arguments -join ' ')"
    }
}

Write-Host "Smoke testing $Image"

$gccVersion = Get-ImageOutput @("gcc", "-dumpfullversion")
$gppVersion = Get-ImageOutput @("g++", "-dumpfullversion")
$cmakeVersion = (Get-ImageOutput @("cmake", "--version")).Split("`n")[0]
$ninjaVersion = Get-ImageOutput @("ninja", "--version")

Write-Host "gcc:   $gccVersion"
Write-Host "g++:   $gppVersion"
Write-Host "cmake: $cmakeVersion"
Write-Host "ninja: $ninjaVersion"

if (-not $gccVersion.StartsWith("$ExpectedGccMajor.")) {
    throw "Expected GCC $ExpectedGccMajor, found $gccVersion"
}
if (-not $gppVersion.StartsWith("$ExpectedGccMajor.")) {
    throw "Expected G++ $ExpectedGccMajor, found $gppVersion"
}

foreach ($tool in @("make", "valgrind", "gdb", "strace", "git", "ccache", "python3")) {
    & docker run --rm $Image $tool --version *> $null
    if ($LASTEXITCODE -ne 0) {
        & docker run --rm $Image $tool -V *> $null
        if ($LASTEXITCODE -ne 0) {
            throw "Missing $tool"
        }
    }
}

if ((Get-ImageOutput @("id", "-un")) -ne "cppdev") {
    throw "Expected user cppdev"
}

Invoke-Checked @("bash", "-lc", "sudo -n true")

$loginEditor = & docker run --rm $Image bash -lic 'printf %s "$EDITOR"' 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Login shell check failed"
}
if (($loginEditor -join "").Trim() -ne "nano") {
    throw "EDITOR is not set in an interactive login shell"
}

$interactiveEditor = & docker run --rm $Image bash -ic 'printf %s "$EDITOR"' 2>$null
if (($interactiveEditor -join "").Trim() -ne "nano") {
    throw "EDITOR is not set in an interactive shell"
}

Invoke-Checked @("bash", "-lc", "python3 -m venv /tmp/venv-check && /tmp/venv-check/bin/python -m pip --version >/dev/null")
Invoke-Checked @("bash", "-lc", "grep -q nano-syntax /etc/nanorc && test -f /usr/share/doc/nanorc-syntax/LICENSE")

$example = Join-Path (Split-Path -Parent $PSScriptRoot) "examples/cmake-hello"
$work = Join-Path $env:TEMP ("cppdev-smoke-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $work | Out-Null

try {
    Copy-Item -Path (Join-Path $example "*") -Destination $work -Recurse
    Write-Host "Building examples/cmake-hello with the release preset"
    & docker run --rm -v "${work}:/workspace" -w /workspace $Image bash -lc "cmake --preset release && cmake --build --preset release && ctest --preset release"
    if ($LASTEXITCODE -ne 0) {
        throw "Example build failed"
    }
}
finally {
    & docker run --rm -v "${work}:/workspace" $Image rm -rf /workspace/build *> $null
    Remove-Item -Path $work -Recurse -Force
}

Write-Host "Smoke test passed."
