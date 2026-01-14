#!/usr/bin/env python3
"""
Script to add reset device ID button to Swiggy IPA
"""

import os
import sys
import shutil
import zipfile
from pathlib import Path

def add_reset_button_to_ipa(ipa_path, output_ipa=None):
    """Add reset button components to IPA"""
    
    if output_ipa is None:
        output_ipa = ipa_path.replace('.ipa', '_with_reset.ipa').replace('.zip', '_with_reset.ipa')
    
    extract_dir = "temp_reset_button"
    
    # Clean up
    if os.path.exists(extract_dir):
        shutil.rmtree(extract_dir)
    
    print(f"Extracting IPA: {ipa_path}")
    with zipfile.ZipFile(ipa_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)
    
    # Find app bundle
    app_bundle = None
    payload_dir = os.path.join(extract_dir, "Payload")
    
    if os.path.exists(payload_dir):
        for item in os.listdir(payload_dir):
            if item.endswith('.app'):
                app_bundle = os.path.join(payload_dir, item)
                break
    
    if not app_bundle:
        # Check if extract_dir itself is the app bundle (has Info.plist)
        if os.path.exists(os.path.join(extract_dir, "Info.plist")):
            app_bundle = extract_dir
        else:
            # Try direct search
            for root, dirs, files in os.walk(extract_dir):
                for d in dirs:
                    if d.endswith('.app'):
                        app_bundle = os.path.join(root, d)
                        break
                if app_bundle:
                    break
    
    if not app_bundle:
        # Last resort: use extracted directory if it has app-like structure
        if os.path.exists(os.path.join(extract_dir, "Info.plist")):
            app_bundle = extract_dir
        else:
            raise Exception("Could not find .app bundle")
    
    print(f"Found app bundle: {app_bundle}")
    
    # Ensure config/inject directory exists
    inject_dir = os.path.join(app_bundle, "config", "inject")
    os.makedirs(inject_dir, exist_ok=True)
    
    # Copy reset button script
    reset_script = "extracted/config/inject/reset_device_button.js"
    if os.path.exists(reset_script):
        target_script = os.path.join(inject_dir, "reset_device_button.js")
        shutil.copy2(reset_script, target_script)
        print(f"[OK] Added reset button script: {target_script}")
    else:
        # Create it inline
        reset_script_content = open("extracted/config/inject/reset_device_button.js", 'r', encoding='utf-8').read()
        target_script = os.path.join(inject_dir, "reset_device_button.js")
        with open(target_script, 'w', encoding='utf-8') as f:
            f.write(reset_script_content)
        print(f"[OK] Created reset button script: {target_script}")
    
    # Also add to existing custom.js if it exists
    custom_js = os.path.join(inject_dir, "custom.js")
    if os.path.exists(custom_js):
        with open(custom_js, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if reset button script is already included
        if 'reset_device_button' not in content:
            # Append script tag to load reset button
            reset_loader = "\n\n// Load reset device button script\n"
            reset_loader += "if (typeof window !== 'undefined') {\n"
            reset_loader += "    const script = document.createElement('script');\n"
            reset_loader += "    script.src = 'config/inject/reset_device_button.js';\n"
            reset_loader += "    script.onload = function() { console.log('[DeviceIDRotator] Reset button loaded'); };\n"
            reset_loader += "    document.head.appendChild(script);\n"
            reset_loader += "}\n"
            
            with open(custom_js, 'a', encoding='utf-8') as f:
                f.write(reset_loader)
            print(f"[OK] Updated custom.js to load reset button")
    
    # Repackage IPA
    print(f"Repackaging IPA: {output_ipa}")
    
    if os.path.exists(output_ipa):
        os.remove(output_ipa)
    
    app_name = os.path.basename(app_bundle)
    
    with zipfile.ZipFile(output_ipa, 'w', zipfile.ZIP_DEFLATED) as zipf:
        if os.path.exists(payload_dir):
            for root, dirs, files in os.walk(payload_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.join("Payload", os.path.relpath(file_path, payload_dir))
                    zipf.write(file_path, arcname)
        else:
            # Direct app bundle structure
            for root, dirs, files in os.walk(app_bundle):
                for file in files:
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, extract_dir)
                    arcname = os.path.join("Payload", app_name, rel_path)
                    zipf.write(file_path, arcname)
    
    print(f"[OK] IPA repackaged: {output_ipa}")
    
    # Cleanup
    shutil.rmtree(extract_dir)
    
    return output_ipa

def main():
    if len(sys.argv) < 2:
        print("Usage: python add_reset_button.py <ipa_file> [output_ipa]")
        print("Example: python add_reset_button.py swiggy.zip swiggy_with_reset.ipa")
        sys.exit(1)
    
    ipa_path = sys.argv[1]
    output_ipa = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not os.path.exists(ipa_path):
        print(f"Error: IPA file not found: {ipa_path}")
        sys.exit(1)
    
    try:
        result = add_reset_button_to_ipa(ipa_path, output_ipa)
        print(f"\n[SUCCESS] Reset button added to: {result}")
        print("\nNext steps:")
        print("1. Sign the IPA with your certificate")
        print("2. Install on device")
        print("3. Look for the 'Reset Device ID' button in the app")
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
