#!/usr/bin/env python3
"""Generate Zolai brand icons from source logo."""
import sys, os

def create_icon(src_path, size):
    """Create icon of given size using PIL if available."""
    try:
        from PIL import Image
        img = Image.open(src_path)
        img = img.resize((size, size), Image.LANCZOS)
        return img
    except ImportError:
        print(f"PIL not installed — skipping {size}x{size}")
        return None

def main():
    src = "zolai-tauri/src-tauri/icons/icon.png"
    out_dir = "assets/icons"
    
    if not os.path.exists(src):
        print(f"Source not found: {src}")
        print("Place your toucan logo at: zolai-tauri/src-tauri/icons/icon.png")
        return
    
    sizes = [16, 32, 48, 64, 128, 192, 512]
    for s in sizes:
        img = create_icon(src, s)
        if img:
            out = os.path.join(out_dir, f"icon-{s}x{s}.png")
            os.makedirs(os.path.dirname(out), exist_ok=True)
            img.save(out)
            print(f"  Created {out}")
    
    print(f"\nDone! Icons in {out_dir}/")

if __name__ == "__main__":
    main()
