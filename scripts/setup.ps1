[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$SkipWhisper
)

$ErrorActionPreference = "Stop"

function Get-PythonCommand {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        return @("py", "-3")
    }

    if (Get-Command python -ErrorAction SilentlyContinue) {
        return @("python")
    }

    throw "Python 3 was not found. Install Python 3, then run this setup script again."
}

function Install-PythonPackage {
    param(
        [string[]]$PythonCommand,
        [string]$Package
    )

    Write-Host "Installing Python package: $Package"
    if ($PSCmdlet.ShouldProcess($Package, "Install or upgrade with pip")) {
        $arguments = @()
        if ($PythonCommand.Count -gt 1) {
            $arguments += $PythonCommand[1..($PythonCommand.Count - 1)]
        }
        $arguments += @("-m", "pip", "install", "--upgrade", $Package)
        & $PythonCommand[0] @arguments
        if ($LASTEXITCODE -ne 0) {
            throw "pip could not install $Package."
        }
    }
}

$python = Get-PythonCommand
Install-PythonPackage -PythonCommand $python -Package "yt-dlp"

if (-not $SkipWhisper) {
    Install-PythonPackage -PythonCommand $python -Package "openai-whisper"
}

if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    Write-Host "FFmpeg is already available."
}
elseif (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Installing FFmpeg with winget."
    if ($PSCmdlet.ShouldProcess("Gyan.FFmpeg", "Install with winget")) {
        winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) {
            throw "winget could not install FFmpeg."
        }
    }
}
else {
    throw "FFmpeg is missing and winget is unavailable. Install FFmpeg, then run this setup script again."
}

Write-Host ""
Write-Host "Dialog Campaign Engine video prerequisites are ready."
Write-Host "Whisper models download on first transcription, so that first fallback may take longer."
