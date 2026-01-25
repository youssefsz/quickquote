#!/usr/bin/env python3
"""
Script to resize all screenshots to 1242 × 2688px (iPhone 14 Pro Max resolution).
Processes images in both dark and light theme folders.

Note: The source files are PNG images.
"""

from PIL import Image
import os

# Target dimensions
TARGET_WIDTH = 1242
TARGET_HEIGHT = 2688

# Folders containing screenshots
FOLDERS = [
    "landing-page/imgs/screenshots/dark",
    "landing-page/imgs/screenshots/light"
]

def resize_image(image_path: str) -> None:
    """Resize a single image to target dimensions and save as proper JPEG."""
    try:
        with Image.open(image_path) as img:
            original_size = img.size
            original_mode = img.mode
            
            # Resize to target dimensions using high-quality resampling
            resized_img = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
            
            # Save the resized image as PNG
            resized_img.save(image_path, "PNG")
            
            print(f"✓ Resized: {os.path.basename(image_path)}")
            print(f"  {original_size[0]}x{original_size[1]} ({original_mode}) → {TARGET_WIDTH}x{TARGET_HEIGHT} (PNG)")
            
    except Exception as e:
        print(f"✗ Error processing {image_path}: {e}")

def main():
    """Main function to process all images in specified folders."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    print(f"Resizing screenshots to {TARGET_WIDTH}x{TARGET_HEIGHT}px...\n")
    
    total_processed = 0
    total_success = 0
    
    for folder in FOLDERS:
        folder_path = os.path.join(script_dir, folder)
        
        if not os.path.exists(folder_path):
            print(f"⚠ Folder not found: {folder_path}")
            continue
            
        print(f"📁 Processing folder: {folder}")
        print("-" * 50)
        
        for filename in os.listdir(folder_path):
            if filename.lower().endswith(('.jpeg', '.jpg', '.png')):
                image_path = os.path.join(folder_path, filename)
                resize_image(image_path)
                total_processed += 1
        
        print()
    
    print(f"✅ Done! Processed {total_processed} images.")

if __name__ == "__main__":
    main()
