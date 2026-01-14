# Building DeviceIDRotator Dylib with GitHub Actions

## 🚀 Quick Start

### Option 1: Manual Trigger (Recommended)

1. **Push the dylib source code to GitHub:**
   ```bash
   git add DeviceIDRotatorDylib/
   git commit -m "Add DeviceIDRotator dylib"
   git push origin main
   ```

2. **Go to GitHub Actions:**
   - Navigate to your repository
   - Click the **Actions** tab
   - Select **"Build DeviceIDRotator Dylib"** workflow
   - Click **"Run workflow"** → **"Run workflow"**

3. **Wait for build to complete** (~2-5 minutes)

4. **Download the dylib:**
   - Go to the completed workflow run
   - Scroll to **Artifacts** section
   - Download **deviceidrotator-dylib**
   - Extract to get `DeviceIDRotator.dylib`

### Option 2: Automatic Trigger

The workflow automatically runs when you push changes to:
- `DeviceIDRotatorDylib/**` files
- `.github/workflows/build-dylib.yml`

```bash
git add DeviceIDRotatorDylib/
git commit -m "Update dylib source"
git push origin main
# Workflow will run automatically
```

## 📥 Downloading the Built Dylib

After the workflow completes:

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll down to **Artifacts**
4. Download **deviceidrotator-dylib**
5. Extract the ZIP file
6. You'll get:
   - `DeviceIDRotator.dylib` - The compiled dylib
   - `DeviceIDRotator.h` - Header file

## 🔧 What the Workflow Does

1. ✅ Checks out your repository
2. ✅ Sets up Xcode (latest stable)
3. ✅ Verifies iOS SDK is available
4. ✅ Builds the dylib using clang
5. ✅ Verifies the dylib (architecture, dependencies)
6. ✅ Creates build information
7. ✅ Uploads dylib and header as artifacts
8. ✅ Uploads source files for reference

## 📋 Build Details

- **Platform:** macOS (macos-latest)
- **Architecture:** arm64 (64-bit iOS devices)
- **SDK:** Latest iOS SDK from Xcode
- **Compiler:** clang
- **Frameworks:** UIKit, Foundation
- **Output:** `DeviceIDRotator.dylib`

## ⚠️ Important Notes

### Artifact Retention

- **Dylib artifacts:** Retained for **30 days**
- **Source artifacts:** Retained for **7 days**
- Download promptly or re-run workflow to regenerate

### File Size

The dylib is typically **50-200 KB**, well within GitHub's limits.

### Build Time

- First build: ~3-5 minutes (Xcode setup)
- Subsequent builds: ~1-2 minutes

## 🐛 Troubleshooting

### Workflow Fails: "DeviceIDRotator.m not found"

**Solution:**
- Ensure `DeviceIDRotatorDylib/DeviceIDRotator.m` is committed
- Check file path is correct
- Verify files are pushed to GitHub

### Workflow Fails: "iOS SDK not found"

**Solution:**
- This shouldn't happen on macos-latest
- If it does, GitHub Actions may be having issues
- Try re-running the workflow

### Build Succeeds but No Artifact

**Solution:**
- Check artifact upload step in workflow logs
- Verify file exists: `ls -la DeviceIDRotator.dylib`
- Artifacts may take a few seconds to appear

### Dylib Architecture Mismatch

**Solution:**
- Current build is for `arm64` (64-bit devices)
- For simulator: modify workflow to build for `x86_64` or `arm64` simulator
- For universal: build multiple architectures and lipo them together

## 🔄 Using the Built Dylib

After downloading:

1. **Inject into IPA:**
   ```bash
   python DeviceIDRotatorDylib/inject_dylib.py \
     swiggy.ipa \
     DeviceIDRotator.dylib \
     swiggy_patched.ipa
   ```

2. **Or manually inject:**
   - Extract IPA
   - Copy dylib to `Payload/Swiggy.app/Frameworks/`
   - Use `insert_dylib` or `optool` to inject
   - Repackage and sign

## 📝 Workflow Configuration

The workflow (`build-dylib.yml`) is configured to:

- Run on `macos-latest` runners
- Use latest stable Xcode
- Build for iOS arm64 architecture
- Upload artifacts for 30 days
- Run on push to main branch
- Run on manual trigger (workflow_dispatch)

## 💡 Tips

1. **Version Control:** Tag releases for easy tracking
2. **Multiple Builds:** Can run multiple builds simultaneously
3. **Build History:** All builds are logged in Actions tab
4. **Notifications:** Enable GitHub notifications for build status

## 🔐 Security

- Source code is visible in workflow logs
- Dylib is unsigned (must sign after injection)
- No sensitive data should be in source files
- Artifacts are only accessible to repository collaborators

## 📊 Build Status Badge

Add a status badge to your README:

```markdown
![Build Dylib](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Build%20DeviceIDRotator%20Dylib/badge.svg)
```

## 🎯 Next Steps

1. ✅ Push dylib source to GitHub
2. ✅ Run GitHub Actions workflow
3. ✅ Download built dylib
4. ✅ Inject into IPA
5. ✅ Sign and install

For injection instructions, see `DeviceIDRotatorDylib/README_DYLIB.md`
