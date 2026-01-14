# Setting Up GitHub Actions for IPA Building

## 📋 Prerequisites

1. A GitHub repository (public or private)
2. The `extracted/` directory with your app bundle
3. GitHub Actions enabled (enabled by default)

## 🚀 Quick Setup

### Step 1: Initialize Git Repository

```bash
# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit with device rotator and GitHub Actions"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push to GitHub
git push -u origin main
```

### Step 2: Verify Workflow File

Ensure `.github/workflows/build-ipa.yml` exists and is committed:

```bash
git add .github/workflows/build-ipa.yml
git commit -m "Add GitHub Actions workflow"
git push
```

### Step 3: Trigger the Workflow

**Option A: Via GitHub UI**
1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Select **"Build IPA from App Bundle"** workflow
4. Click **"Run workflow"** → **"Run workflow"**
5. Wait for completion (~2-5 minutes)

**Option B: Push Changes**
```bash
# Make any change to extracted/ directory
touch extracted/.gitkeep
git add extracted/
git commit -m "Trigger IPA build"
git push
```

### Step 4: Download the IPA

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download **swiggy-device-rotator-ipa**
5. Extract the ZIP file to get the `.ipa`

## 📁 Repository Structure

Your repository should look like:

```
.
├── .github/
│   └── workflows/
│       └── build-ipa.yml          # GitHub Actions workflow
├── DeviceIDRotator/                # Framework source code
├── extracted/                      # App bundle (must be committed)
│   ├── Info.plist
│   ├── Frameworks/
│   ├── config/
│   └── ...
├── build_ipa_local.sh              # Local build script (macOS/Linux)
├── build_ipa_local.ps1             # Local build script (Windows)
├── integrate_device_rotator.py      # Integration script
└── README files
```

## ⚠️ Important Notes

### File Size Considerations

The `extracted/` directory may be large. GitHub has limits:
- **Free accounts**: 1GB repository size, 100MB file size limit
- **Pro accounts**: 50GB repository size, 100MB file size limit

If your app bundle is too large:
1. Use Git LFS for large files:
   ```bash
   git lfs install
   git lfs track "extracted/**/*.framework"
   git lfs track "extracted/**/*.bundle"
   git add .gitattributes
   git commit -m "Add Git LFS tracking"
   ```

2. Or exclude large frameworks and add them manually after build

### Private vs Public Repository

- **Private**: Only you can access artifacts
- **Public**: Anyone can see the workflow (but not download artifacts without access)

## 🔄 Workflow Triggers

The workflow runs automatically when:
- ✅ You push changes to `extracted/**` files
- ✅ You push changes to `.github/workflows/build-ipa.yml`
- ✅ You manually trigger it via GitHub UI

## 📥 Downloading Artifacts

Artifacts are available for **30 days** after the workflow completes.

To download:
1. Go to **Actions** → Select workflow run
2. Scroll to **Artifacts**
3. Click **swiggy-device-rotator-ipa**
4. Download the ZIP
5. Extract to get the `.ipa` file

## 🐛 Troubleshooting

### Workflow Fails: "extracted/ directory not found"
- Ensure `extracted/` is committed to the repository
- Check that files are pushed: `git ls-files extracted/`

### Workflow Fails: "Info.plist not found"
- Verify `extracted/Info.plist` exists
- Check file permissions

### Artifact Not Available
- Artifacts expire after 30 days
- Re-run the workflow to generate a new IPA

### Large Repository Size
- Use Git LFS for large binaries
- Or compress frameworks before committing

## 🔐 Security Best Practices

1. **Never commit**:
   - Signing certificates
   - Private keys
   - Passwords or API keys

2. **Use GitHub Secrets** for sensitive data (if needed)

3. **Consider repository visibility**:
   - Private repo = private artifacts
   - Public repo = public workflow logs

## 📝 Next Steps After Building

1. **Download the IPA** from artifacts
2. **Sign the IPA** with your certificate (see BUILD_INFO.md)
3. **Install** on your device
4. **Test** the device ID rotation feature

## 💡 Tips

- Workflow runs on `macos-latest` (free tier: 2000 minutes/month)
- Each build takes ~2-5 minutes
- Artifacts are retained for 30 days
- You can download multiple times within retention period
