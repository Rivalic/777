# IPA Releases - Location Guide

## 📁 Release Folder Location

All signed/prepared IPAs are stored in:

```
releases/
```

## 🚀 How to Use GitHub Actions

### Option 1: Auto Sign (AltStore Ready) - Recommended

**Workflow:** `auto-sign-ipa.yml`

1. **Go to Actions tab** in your GitHub repository
2. **Select "Auto Sign IPA (AltStore Ready)"**
3. **Click "Run workflow"**
4. **Wait for completion** (~2-3 minutes)
5. **Download IPA:**
   - Go to completed workflow run
   - Scroll to **Artifacts**
   - Download **ipa-release**
   - Extract to get IPA file

**Location:** `releases/swiggy_altstore_ready_YYYYMMDD_HHMMSS.ipa`

### Option 2: Sign with Certificate

**Workflow:** `sign-and-release-ipa.yml`

1. **Go to Actions tab**
2. **Select "Sign and Release IPA"**
3. **Click "Run workflow"**
4. **Fill in:**
   - IPA file: `swiggy_with_reset_button.ipa`
   - Certificate name: `Apple Development: Your Name` (optional)
   - Use AltStore: `true` (recommended)
5. **Run workflow**

**Location:** `releases/swiggy_signed_YYYYMMDD_HHMMSS.ipa` or `releases/swiggy_prepared_YYYYMMDD_HHMMSS.ipa`

## 📥 Download Locations

### Method 1: GitHub Artifacts (Easiest)

1. Go to **Actions** tab
2. Click on completed workflow run
3. Scroll to **Artifacts** section
4. Download **ipa-release** or **signed-ipa-release**
5. Extract ZIP file
6. Get IPA file

### Method 2: Repository Folder

1. Go to repository root
2. Navigate to **`releases/`** folder
3. Download IPA file directly

### Method 3: Direct Link

If repository is public:
```
https://github.com/YOUR_USERNAME/YOUR_REPO/raw/main/releases/swiggy_altstore_ready_*.ipa
```

## 📋 File Naming Convention

- `swiggy_altstore_ready_YYYYMMDD_HHMMSS.ipa` - Prepared for AltStore
- `swiggy_prepared_YYYYMMDD_HHMMSS.ipa` - Prepared for signing
- `swiggy_signed_YYYYMMDD_HHMMSS.ipa` - Fully signed (if certificate provided)

## 🔄 Automatic Workflow Triggers

Workflows run automatically when:
- You push `*.ipa` files to the repository
- You push changes to workflow files
- You manually trigger via Actions tab

## 📱 Installation After Download

### Using AltStore

1. Download IPA from `releases/` folder
2. Open AltStore on iPhone
3. Tap "+" button
4. Select IPA file
5. AltStore signs and installs automatically

### Using Sideloadly

1. Download IPA from `releases/` folder
2. Open Sideloadly on computer
3. Connect iPhone via USB
4. Drag IPA into Sideloadly
5. Enter Apple ID
6. Click "Start"

## 📊 Workflow Summary

| Workflow | Purpose | Output Location |
|----------|---------|----------------|
| `auto-sign-ipa.yml` | Prepare for AltStore | `releases/swiggy_altstore_ready_*.ipa` |
| `sign-and-release-ipa.yml` | Sign with certificate | `releases/swiggy_signed_*.ipa` |

## 🔍 Finding Your IPA

### In Repository

```
YourRepo/
├── releases/                    ← IPA files stored here
│   ├── swiggy_altstore_ready_20240114_120000.ipa
│   ├── swiggy_prepared_20240114_120000.ipa
│   ├── swiggy_signed_20240114_120000.ipa
│   └── README.md
└── ...
```

### In GitHub Actions

1. Actions → Completed workflow
2. Artifacts section
3. Download artifact ZIP
4. Extract to get IPA

## ⚠️ Important Notes

- **Releases folder**: `releases/` in repository root
- **Artifact retention**: 30 days
- **File location**: Always check `releases/` folder
- **Latest file**: Most recent timestamp in filename

## 🎯 Quick Reference

**Folder Path:** `releases/`

**Full Repository Path:** `https://github.com/YOUR_USERNAME/YOUR_REPO/tree/main/releases`

**Download from Actions:** Actions → Artifacts → Download

The IPA files are always stored in the **`releases/`** folder!
