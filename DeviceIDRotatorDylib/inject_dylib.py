#!/usr/bin/env python3
"""
Script to inject DeviceIDRotator.dylib into Swiggy IPA
"""

import os
import sys
import shutil
import zipfile
import subprocess
from pathlib import Path

def find_app_bundle(ipa_path):
    """Extract IPA and find app bundle"""
    extract_dir = "temp_inject"
    
    if os.path.exists(extract_dir):
        shutil.rmtree(extract_dir)
    os.makedirs(extract_dir)
    
    print(f"📦 Extracting IPA: {ipa_path}")
    with zipfile.ZipFile(ipa_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)
    
    # Find .app bundle
    payload_dir = os.path.join(extract_dir, "Payload")
    if not os.path.exists(payload_dir):
        # Try direct extraction
        for root, dirs, files in os.walk(extract_dir):
            for d in dirs:
                if d.endswith('.app'):
                    return os.path.join(root, d), extract_dir
    
    if os.path.exists(payload_dir):
        for item in os.listdir(payload_dir):
            if item.endswith('.app'):
                return os.path.join(payload_dir, item), extract_dir
    
    raise Exception("Could not find .app bundle in IPA")

def inject_dylib(app_bundle_path, dylib_path):
    """Inject dylib into app bundle"""
    if not os.path.exists(dylib_path):
        raise Exception(f"Dylib not found: {dylib_path}")
    
    # Copy dylib to Frameworks directory
    frameworks_dir = os.path.join(app_bundle_path, "Frameworks")
    os.makedirs(frameworks_dir, exist_ok=True)
    
    dylib_name = os.path.basename(dylib_path)
    target_dylib = os.path.join(frameworks_dir, dylib_name)
    
    print(f"📋 Copying dylib to: {target_dylib}")
    shutil.copy2(dylib_path, target_dylib)
    
    # Get app executable name
    info_plist = os.path.join(app_bundle_path, "Info.plist")
    app_executable = None
    
    if os.path.exists(info_plist):
        try:
            import plistlib
            with open(info_plist, 'rb') as f:
                plist = plistlib.load(f)
                app_executable = plist.get('CFBundleExecutable', 'swiggy')
        except:
            app_executable = "swiggy"
    else:
        # Try to find executable
        for item in os.listdir(app_bundle_path):
            if not item.endswith(('.plist', '.nib', '.lproj', '.bundle', '.framework', '.appex')):
                if os.access(os.path.join(app_bundle_path, item), os.X_OK):
                    app_executable = item
                    break
    
    if not app_executable:
        app_executable = "swiggy"
    
    app_executable_path = os.path.join(app_bundle_path, app_executable)
    
    if not os.path.exists(app_executable_path):
        print(f"⚠️  Warning: App executable not found at {app_executable_path}")
        print("⚠️  You may need to manually inject the dylib using insert_dylib or optool")
        return False
    
    # Use insert_dylib or optool to inject
    print(f"🔧 Injecting dylib into: {app_executable}")
    
    # Try insert_dylib (if available)
    dylib_load_path = f"@rpath/{dylib_name}"
    
    try:
        # Check if insert_dylib is available
        result = subprocess.run(['which', 'insert_dylib'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("📋 Using insert_dylib...")
            subprocess.run([
                'insert_dylib',
                '--weak',
                '--all-yes',
                dylib_load_path,
                app_executable_path,
                app_executable_path + '.patched'
            ], check=True)
            shutil.move(app_executable_path + '.patched', app_executable_path)
            print("✅ Dylib injected successfully!")
            return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    
    # Try optool (if available)
    try:
        result = subprocess.run(['which', 'optool'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("📋 Using optool...")
            subprocess.run([
                'optool',
                'install',
                '-c', 'load',
                '-p', dylib_load_path,
                '-t', app_executable_path
            ], check=True)
            print("✅ Dylib injected successfully!")
            return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    
    print("⚠️  Warning: insert_dylib/optool not found")
    print("⚠️  Manual injection required:")
    print(f"   1. Use insert_dylib or optool to inject: {dylib_load_path}")
    print(f"   2. Or use: install_name_tool -add_rpath @executable_path/Frameworks {app_executable_path}")
    return False

def repackage_ipa(extract_dir, output_ipa, app_bundle_path):
    """Repackage IPA"""
    print(f"📦 Repackaging IPA: {output_ipa}")
    
    if os.path.exists(output_ipa):
        os.remove(output_ipa)
    
    app_name = os.path.basename(app_bundle_path)
    payload_dir = os.path.join(extract_dir, "Payload")
    
    with zipfile.ZipFile(output_ipa, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(payload_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.join("Payload", os.path.relpath(file_path, payload_dir))
                zipf.write(file_path, arcname)
    
    print(f"✅ IPA repackaged: {output_ipa}")

def main():
    if len(sys.argv) < 3:
        print("Usage: python inject_dylib.py <ipa_file> <dylib_file> [output_ipa]")
        print("Example: python inject_dylib.py swiggy.ipa DeviceIDRotator.dylib swiggy_patched.ipa")
        sys.exit(1)
    
    ipa_file = sys.argv[1]
    dylib_file = sys.argv[2]
    output_ipa = sys.argv[3] if len(sys.argv) > 3 else "swiggy_injected.ipa"
    
    if not os.path.exists(ipa_file):
        print(f"❌ Error: IPA file not found: {ipa_file}")
        sys.exit(1)
    
    if not os.path.exists(dylib_file):
        print(f"❌ Error: Dylib file not found: {dylib_file}")
        sys.exit(1)
    
    try:
        app_bundle, extract_dir = find_app_bundle(ipa_file)
        print(f"📱 Found app bundle: {app_bundle}")
        
        injected = inject_dylib(app_bundle, dylib_file)
        
        repackage_ipa(extract_dir, output_ipa, app_bundle)
        
        print("\n✅ Injection complete!")
        print(f"📁 Output IPA: {output_ipa}")
        
        if not injected:
            print("\n⚠️  Note: Dylib was copied but not automatically injected.")
            print("⚠️  You need to manually inject it using insert_dylib or optool.")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        # Cleanup
        if os.path.exists("temp_inject"):
            shutil.rmtree("temp_inject")

if __name__ == "__main__":
    main()
