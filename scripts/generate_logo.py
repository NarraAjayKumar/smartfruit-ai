import os
from PIL import Image, ImageDraw, ImageFont

def generate_logo():
    # Setup
    size = (1024, 1024)
    img = Image.new('RGBA', size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    forest_green = (34, 139, 34, 255)
    orange = (255, 140, 0, 255)
    black = (0, 0, 0, 255)
    white = (255, 255, 255, 255)
    light_ivory = (250, 250, 240, 255)
    
    # 1. Outer Ring
    ring_width = 120
    draw.ellipse([50, 50, 974, 974], fill=forest_green)
    
    # 2. Inner White Circle
    draw.ellipse([50 + ring_width, 50 + ring_width, 974 - ring_width, 974 - ring_width], fill=light_ivory)
    
    # 3. Horizon Line
    horizon_y = 750
    draw.line([50 + ring_width + 100, horizon_y, 974 - ring_width - 100, horizon_y], fill=black, width=8)
    
    # 4. Sun (Half Circle)
    sun_radius = 80
    sun_x = 700
    draw.chord([sun_x - sun_radius, horizon_y - sun_radius, sun_x + sun_radius, horizon_y + sun_radius], 180, 360, fill=orange)
    
    # 5. Farmer Silhouette (Simplified but recognizable)
    # Head
    draw.ellipse([450, 480, 500, 530], fill=black)
    # Body
    draw.line([475, 530, 475, 680], fill=black, width=30)
    # Legs (walking)
    draw.line([475, 680, 430, 750], fill=black, width=25)
    draw.line([475, 680, 520, 750], fill=black, width=25)
    # Arms holding plough
    draw.line([475, 580, 550, 550], fill=black, width=15)
    
    # 6. Wooden Plough on Shoulder
    # Main beam
    draw.line([300, 550, 800, 480], fill=black, width=20)
    # The actual plough blade part
    draw.polygon([(300, 550), (280, 650), (350, 600)], fill=black)
    
    # 7. Text "SmartFruit AI"
    # Note: Proper curved text requires more complex logic, we will use a clean placeholder approach 
    # or just omit if no font available, but for exactness, we'll try to find a system font.
    try:
        # Common Windows font
        font = ImageFont.truetype("arial.ttf", 80)
        # Simplified: Just draw on top for now as a placeholder for the curve
        # (This is better than nothing for a quick build)
        draw.text((512, 110), "SmartFruit AI", fill=white, font=font, anchor="mm")
    except:
        pass

    # Save
    output_path = os.path.join("assets", "images", "logo.png")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Logo generated at {output_path}")

if __name__ == "__main__":
    generate_logo()
