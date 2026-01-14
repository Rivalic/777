#!/usr/bin/env python3
"""
Script to integrate DeviceIDRotator framework into Swiggy IPA
"""

import os
import shutil
import zipfile
import plistlib
import subprocess
import sys
from pathlib import Path

def extract_ipa(ipa_path, extract_dir):
    """Extract IPA file"""
    print(f"Extracting IPA: {ipa_path}")
    with zipfile.ZipFile(ipa_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)
    print("IPA extracted successfully")

def get_payload_dir(extract_dir):
    """Find Payload directory or app bundle"""
    # Check for standard IPA structure (Payload/.app)
    payload_path = os.path.join(extract_dir, "Payload")
    if os.path.exists(payload_path):
        app_dirs = [d for d in os.listdir(payload_path) if d.endswith('.app')]
        if app_dirs:
            return os.path.join(payload_path, app_dirs[0])
    
    # Check if extract_dir itself is the app bundle (has Info.plist)
    if os.path.exists(os.path.join(extract_dir, "Info.plist")):
        return extract_dir
    
    # Try to find .app directory directly
    for root, dirs, files in os.walk(extract_dir):
        for d in dirs:
            if d.endswith('.app'):
                return os.path.join(root, d)
    
    raise Exception("Could not find app bundle directory")

def add_framework_to_app(app_dir, framework_name):
    """Add framework to app's Frameworks directory"""
    frameworks_dir = os.path.join(app_dir, "Frameworks")
    os.makedirs(frameworks_dir, exist_ok=True)
    
    framework_path = os.path.join(frameworks_dir, framework_name)
    if os.path.exists(framework_path):
        print(f"Framework {framework_name} already exists, skipping...")
        return
    
    print(f"Note: Framework {framework_name} needs to be built separately")
    print(f"Place the compiled framework at: {framework_path}")

def modify_info_plist(app_dir):
    """Modify Info.plist if needed"""
    info_plist_path = os.path.join(app_dir, "Info.plist")
    if not os.path.exists(info_plist_path):
        print("Info.plist not found, skipping modification")
        return
    
    print("Info.plist found - framework will be loaded at runtime")

def create_injection_script(app_dir):
    """Create JavaScript injection script for web views"""
    inject_dir = os.path.join(app_dir, "config", "inject")
    os.makedirs(inject_dir, exist_ok=True)
    
    device_rotator_js = """// Device ID Rotator Injection
(function() {
    // Add device ID rotator button to settings
    function addRotatorButton() {
        // This will be called when settings page loads
        const button = document.createElement('button');
        button.textContent = '🔄 Rotate Device ID';
        button.style.cssText = 'padding: 12px 24px; background: #FF6B35; color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; margin: 20px;';
        button.onclick = function() {
            // Call native method to rotate device ID
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.deviceIDRotator) {
                window.webkit.messageHandlers.deviceIDRotator.postMessage({action: 'rotate'});
            } else {
                alert('Device ID rotation requires native app support');
            }
        };
        
        // Try to find settings container
        const settingsContainer = document.querySelector('.settings-container') || 
                                  document.querySelector('[class*="Settings"]') ||
                                  document.body;
        if (settingsContainer) {
            settingsContainer.insertBefore(button, settingsContainer.firstChild);
        }
    }
    
    // Try to add button when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', addRotatorButton);
    } else {
        addRotatorButton();
    }
    
    // Also try after a delay
    setTimeout(addRotatorButton, 1000);
})();
"""
    
    js_path = os.path.join(inject_dir, "device_rotator.js")
    with open(js_path, 'w', encoding='utf-8') as f:
        f.write(device_rotator_js)
    print(f"Created injection script: {js_path}")

def repackage_ipa(extract_dir, app_dir, output_ipa):
    """Repackage IPA"""
    print(f"Repackaging IPA: {output_ipa}")
    
    # Remove old IPA if exists
    if os.path.exists(output_ipa):
        os.remove(output_ipa)
    
    # Determine app name
    app_name = os.path.basename(app_dir)
    if not app_name.endswith('.app'):
        app_name = "Swiggy.app"
    
    # Create new IPA with proper Payload structure
    with zipfile.ZipFile(output_ipa, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Walk the app directory and add files to Payload/AppName.app/...
        app_dir_abs = os.path.abspath(app_dir)
        for root, dirs, files in os.walk(app_dir_abs):
            for file in files:
                file_path = os.path.join(root, file)
                # Get relative path from app_dir
                rel_path = os.path.relpath(file_path, app_dir_abs)
                # Create proper IPA structure: Payload/AppName.app/...
                arcname = os.path.join("Payload", app_name, rel_path).replace('\\', '/')
                zipf.write(file_path, arcname)
    
    print(f"IPA repackaged: {output_ipa}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python integrate_device_rotator.py <path_to_ipa> [output_ipa]")
        print("Example: python integrate_device_rotator.py swiggy.ipa swiggy_patched.ipa")
        sys.exit(1)
    
    ipa_path = sys.argv[1]
    output_ipa = sys.argv[2] if len(sys.argv) > 2 else "swiggy_device_rotator.ipa"
    
    if not os.path.exists(ipa_path):
        print(f"Error: IPA file not found: {ipa_path}")
        sys.exit(1)
    
    extract_dir = "temp_extract"
    
    try:
        # Clean up old extraction
        if os.path.exists(extract_dir):
            shutil.rmtree(extract_dir)
        
        # Extract IPA
        extract_ipa(ipa_path, extract_dir)
        
        # Get app directory
        app_dir = get_payload_dir(extract_dir)
        print(f"App directory: {app_dir}")
        
        # Add framework (note: needs to be built first)
        add_framework_to_app(app_dir, "DeviceIDRotator.framework")
        
        # Modify Info.plist if needed
        modify_info_plist(app_dir)
        
        # Create injection script
        create_injection_script(app_dir)
        
        # Repackage IPA
        repackage_ipa(extract_dir, app_dir, output_ipa)
        
        print("\n✅ Integration complete!")
        print(f"Output IPA: {output_ipa}")
        print("\n⚠️  Note: You still need to:")
        print("1. Build DeviceIDRotator.framework")
        print("2. Copy it to the app's Frameworks directory")
        print("3. Sign the IPA with your certificate")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        # Clean up
        if os.path.exists(extract_dir):
            shutil.rmtree(extract_dir)

if __name__ == "__main__":
    main()
