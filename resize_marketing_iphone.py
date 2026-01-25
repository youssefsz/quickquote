#!/usr/bin/env python3
"""
Script to resize iPhone marketing screenshots to Apple's latest requirements.
Target Resolution: 1242 x 2688 pixels (iPhone 16 Pro Max / 6.9-inch Display).

Folder: Marketing/Iphone
"""

from PIL import Image
import os

# Target dimensions for iPhone 6.9" Display (Apple recommended)
TARGET_WIDTH = 1242
TARGET_HEIGHT = 2688

# Folder containing screenshots relative to script location
FOLDER = "Marketing/Iphone"

def resize_image(image_path: str) -> None:
    """Resize a single image to target dimensions and save."""
    try:
        with Image.open(image_path) as img:
            original_size = img.size
            original_mode = img.mode
            
            # Resize to target dimensions using high-quality resampling
            # LANCZOS is best for downscaling, and generally good for quality
            resized_img = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
            
            # Save the resized image as PNG (overwriting original)
            resized_img.save(image_path, "PNG")
            
            print(f"✓ Resized: {os.path.basename(image_path)}")
            print(f"  {original_size[0]}x{original_size[1]} ({original_mode}) -> {TARGET_WIDTH}x{TARGET_HEIGHT} (PNG)")
            
    except Exception as e:
        print(f"✗ Error processing {image_path}: {e}")

def main():
    """Main function to process images."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    folder_path = os.path.join(script_dir, FOLDER)
    
    print(f"Resizing iPhone marketing images to {TARGET_WIDTH}x{TARGET_HEIGHT}px...\n")
    
    if not os.path.exists(folder_path):
        print(f"⚠ Folder not found: {folder_path}")
        # Create it if it doesn't exist? valid, but better to warn.
        os.makedirs(folder_path, exist_ok=True)
        print(f"  Created empty folder: {folder_path}")
        return

    print(f"📁 Processing folder: {FOLDER}")
    print("-" * 50)
    
    total_processed = 0
    files = os.listdir(folder_path)
    
    if not files:
        print("  No files found to process.")
    
    for filename in files:
        if filename.lower().endswith(('.jpeg', '.jpg', '.png')):
            image_path = os.path.join(folder_path, filename)
            resize_image(image_path)
            total_processed += 1
    
    print("-" * 50)
    print(f"✅ Done! Processed {total_processed} iPhone images.")

if __name__ == "__main__":
    main()
