# PowerShell script to build IPA from extracted app bundle
# Usage: .\build_ipa_local.ps1

$ErrorActionPreference = "Stop"

$extractedDir = "extracted"
$outputDir = "output"
$ipaName = "swiggy_device_rotator"

Write-Host "🔨 Building IPA from app bundle..." -ForegroundColor Cyan

# Check if extracted directory exists
if (-not (Test-Path $extractedDir)) {
    Write-Host "❌ Error: $extractedDir directory not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$extractedDir\Info.plist")) {
    Write-Host "❌ Error: $extractedDir\Info.plist not found" -ForegroundColor Red
    exit 1
}

# Determine app name from Info.plist
$appName = "Swiggy"
try {
    $plistContent = Get-Content "$extractedDir\Info.plist" -Raw
    if ($plistContent -match '<key>CFBundleName</key>\s*<string>(.*?)</string>') {
        $appName = $matches[1]
    }
} catch {
    Write-Host "⚠️  Could not parse Info.plist, using default: Swiggy" -ForegroundColor Yellow
}

# Ensure .app extension
if (-not $appName.EndsWith(".app")) {
    $appName = "$appName.app"
}

Write-Host "📱 App name: $appName" -ForegroundColor Green

# Create output directory
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Clean up old files
if (Test-Path "$outputDir\Payload") {
    Remove-Item -Recurse -Force "$outputDir\Payload"
}
Remove-Item -Force "$outputDir\*.ipa" -ErrorAction SilentlyContinue

# Create Payload structure
Write-Host "📦 Creating Payload structure..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path "$outputDir\Payload" | Out-Null
Copy-Item -Recurse -Force "$extractedDir" "$outputDir\Payload\$appName"

# Create IPA
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ipaFile = "$outputDir\${ipaName}_$timestamp.ipa"

Write-Host "📦 Creating IPA: $ipaFile" -ForegroundColor Cyan

# Use PowerShell's Compress-Archive (creates .zip, rename to .ipa)
$tempZip = "$outputDir\temp.zip"
Compress-Archive -Path "$outputDir\Payload\*" -DestinationPath $tempZip -Force
Move-Item -Force $tempZip $ipaFile

Write-Host ""
Write-Host "✅ IPA created successfully!" -ForegroundColor Green
Write-Host "📁 Location: $ipaFile" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  Next steps:" -ForegroundColor Yellow
Write-Host "1. Sign the IPA with your certificate"
Write-Host "2. Install on device using your preferred method"
Write-Host ""
Write-Host "To sign (on macOS):"
Write-Host "  unzip $ipaFile -d temp_sign"
Write-Host "  codesign --force --sign `"YOUR_CERT`" --entitlements extracted/swiggy.entitlements `"temp_sign/Payload/$appName`""
Write-Host "  cd temp_sign && zip -r ../signed_$(Split-Path $ipaFile -Leaf) Payload/"
