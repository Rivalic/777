# GitHub Actions IPA Build

This repository includes a GitHub Actions workflow to automatically build an IPA from the extracted app bundle.

## 🚀 Quick Start

### Option 1: Trigger via GitHub UI

1. Go to the **Actions** tab in your GitHub repository
2. Select **"Build IPA from App Bundle"** workflow
3. Click **"Run workflow"** button
4. Wait for the workflow to complete
5. Download the IPA from the **Artifacts** section

### Option 2: Push to Main Branch

The workflow automatically runs when you push changes to:
- `extracted/**` files
- `.github/workflows/build-ipa.yml`

```bash
git add extracted/
git commit -m "Update app bundle"
git push origin main
```

## 📋 Workflow Details

The workflow (`build-ipa.yml`) will:

1. ✅ Verify the extracted app bundle exists
2. 📱 Determine app name from Info.plist
3. 📦 Create proper Payload structure
4. 🔨 Package into IPA file
5. 📤 Upload IPA as artifact

## 📥 Downloading the IPA

After the workflow completes:

1. Go to the **Actions** tab
2. Click on the completed workflow run
3. Scroll down to **Artifacts**
4. Download **swiggy-device-rotator-ipa**
5. Extract the ZIP to get the IPA file

## ⚠️ Important Notes

### Signing Required

The generated IPA is **unsigned** and must be signed before installation:

```bash
# Extract IPA
unzip swiggy_device_rotator_*.ipa -d temp_sign

# Sign the app bundle (macOS only)
codesign --force --sign "YOUR_CERTIFICATE_NAME" \
  --entitlements extracted/swiggy.entitlements \
  "temp_sign/Payload/Swiggy.app"

# Repackage
cd temp_sign
zip -r ../signed_swiggy_device_rotator.ipa Payload/
```

### Local Building

You can also build locally:

**macOS/Linux:**
```bash
chmod +x build_ipa_local.sh
./build_ipa_local.sh
```

**Windows:**
```powershell
.\build_ipa_local.ps1
```

## 🔧 Workflow Configuration

The workflow runs on `macos-latest` and:
- Uses Python 3.11
- Creates timestamped IPA files
- Retains artifacts for 30 days
- Generates build information

## 📁 Output Structure

```
output/
└── swiggy_device_rotator_YYYYMMDD_HHMMSS.ipa
    └── Payload/
        └── Swiggy.app/
            ├── Info.plist
            ├── Frameworks/
            ├── config/
            └── ...
```

## 🐛 Troubleshooting

### Workflow Fails: "extracted/ directory not found"
- Ensure the `extracted/` directory is committed to the repository
- Check that `extracted/Info.plist` exists

### IPA Structure Invalid
- Verify the app bundle is complete
- Check that all frameworks are included

### Artifact Not Available
- Artifacts expire after 30 days
- Re-run the workflow to generate a new IPA

## 📝 Manual Build Steps

If you prefer to build manually:

1. **Create Payload structure:**
   ```bash
   mkdir -p Payload
   cp -R extracted Payload/Swiggy.app
   ```

2. **Create IPA:**
   ```bash
   zip -r swiggy_device_rotator.ipa Payload/
   ```

3. **Verify:**
   ```bash
   unzip -l swiggy_device_rotator.ipa | head -20
   ```

## 🔐 Security Notes

- Never commit signing certificates to the repository
- Use GitHub Secrets for sensitive information if needed
- The IPA must be signed with a valid certificate for installation
- Consider using a CI/CD service with secure signing capabilities
