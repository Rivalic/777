#!/usr/bin/env python3
"""
Script to sign Swiggy IPA (Windows/Cross-platform)
Note: Full signing requires macOS with Xcode. This script helps prepare the IPA.
"""

import os
import sys
import shutil
import zipfile
import subprocess
import platform

def find_certificates():
    """Find available code signing certificates"""
    if platform.system() != "Darwin":  # Not macOS
        print("Note: Full code signing requires macOS with Xcode.")
        print("On Windows, you can:")
        print("1. Use a macOS VM or remote Mac")
        print("2. Use online signing services")
        print("3. Use tools like AltStore/Sideloadly (they handle signing)")
        return []
    
    try:
        result = subprocess.run(
            ['security', 'find-identity', '-v', '-p', 'codesigning'],
            capture_output=True,
            text=True
        )
        certs = []
        for line in result.stdout.split('\n'):
            if ')' in line and '"' in line:
                certs.append(line.strip())
        return certs
    except:
        return []

def sign_ipa_windows(ipa_file, output_ipa=None):
    """Prepare IPA for signing on Windows"""
    print("=" * 50)
    print("IPA Signing Preparation (Windows)")
    print("=" * 50)
    print()
    print("Note: Full code signing requires macOS.")
    print("Options:")
    print("1. Use AltStore/Sideloadly - they handle signing automatically")
    print("2. Transfer to macOS and use sign_ipa.sh")
    print("3. Use online signing services")
    print()
    
    if output_ipa is None:
        output_ipa = ipa_file.replace('.ipa', '_prepared.ipa').replace('.zip', '_prepared.ipa')
    
    extract_dir = "temp_sign_prep"
    
    # Extract IPA
    print(f"Extracting IPA: {ipa_file}")
    if os.path.exists(extract_dir):
        shutil.rmtree(extract_dir)
    
    with zipfile.ZipFile(ipa_file, 'r') as zip_ref:
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
        if os.path.exists(os.path.join(extract_dir, "Info.plist")):
            app_bundle = extract_dir
    
    if app_bundle:
        print(f"Found app bundle: {os.path.basename(app_bundle)}")
        
        # Remove old signatures
        print("Removing old signatures...")
        for root, dirs, files in os.walk(app_bundle):
            if '_CodeSignature' in dirs:
                shutil.rmtree(os.path.join(root, '_CodeSignature'))
            for file in files:
                if file.endswith('.mobileprovision'):
                    os.remove(os.path.join(root, file))
        
        print("IPA prepared for signing.")
        print("Next: Transfer to macOS or use signing service")
    else:
        print("Warning: Could not find app bundle")
    
    # Repackage
    print(f"Repackaging: {output_ipa}")
    if os.path.exists(output_ipa):
        os.remove(output_ipa)
    
    app_name = os.path.basename(app_bundle) if app_bundle else "Swiggy.app"
    
    with zipfile.ZipFile(output_ipa, 'w', zipfile.ZIP_DEFLATED) as zipf:
        if os.path.exists(payload_dir):
            for root, dirs, files in os.walk(payload_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.join("Payload", os.path.relpath(file_path, payload_dir))
                    zipf.write(file_path, arcname)
    
    shutil.rmtree(extract_dir)
    
    print(f"\nPrepared IPA: {output_ipa}")
    return output_ipa

def sign_ipa_macos(ipa_file, cert_name, entitlements=None, output_ipa=None):
    """Sign IPA on macOS"""
    if platform.system() != "Darwin":
        print("Error: This function requires macOS")
        return None
    
    if output_ipa is None:
        output_ipa = ipa_file.replace('.ipa', '_signed.ipa')
    
    # Use the shell script
    script_path = os.path.join(os.path.dirname(__file__), 'sign_ipa.sh')
    cmd = ['bash', script_path, ipa_file, cert_name]
    
    if entitlements:
        cmd.append(entitlements)
    
    try:
        subprocess.run(cmd, check=True)
        return output_ipa
    except subprocess.CalledProcessError as e:
        print(f"Error signing IPA: {e}")
        return None

def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  Windows: python sign_ipa.py <ipa_file>")
        print("  macOS:   python sign_ipa.py <ipa_file> <certificate_name> [entitlements]")
        print()
        print("Example (macOS):")
        print("  python sign_ipa.py swiggy.ipa \"Apple Development: Name\" extracted/swiggy.entitlements")
        print()
        
        if platform.system() == "Darwin":
            print("Available certificates:")
            certs = find_certificates()
            for cert in certs[:5]:
                print(f"  {cert}")
        sys.exit(1)
    
    ipa_file = sys.argv[1]
    
    if not os.path.exists(ipa_file):
        print(f"Error: IPA file not found: {ipa_file}")
        sys.exit(1)
    
    if platform.system() == "Darwin":
        # macOS signing
        if len(sys.argv) < 3:
            print("Error: Certificate name required on macOS")
            print("\nAvailable certificates:")
            certs = find_certificates()
            for cert in certs[:10]:
                print(f"  {cert}")
            sys.exit(1)
        
        cert_name = sys.argv[2]
        entitlements = sys.argv[3] if len(sys.argv) > 3 else "extracted/swiggy.entitlements"
        
        result = sign_ipa_macos(ipa_file, cert_name, entitlements)
        if result:
            print(f"\nSigned IPA: {result}")
    else:
        # Windows - prepare for signing
        result = sign_ipa_windows(ipa_file)
        print(f"\nPrepared IPA: {result}")
        print("\nTo sign:")
        print("1. Transfer to macOS and run: ./sign_ipa.sh")
        print("2. Use AltStore/Sideloadly (automatic signing)")
        print("3. Use online signing service")

if __name__ == "__main__":
    main()
