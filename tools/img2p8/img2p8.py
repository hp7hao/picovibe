from PIL import Image

# Pico-8 color palette
PICO8_PALETTE = [
    (0x1f, 0x1f, 0x1f), (0x0f, 0x10, 0x22), (0x28, 0x0f, 0x10), (0x3c, 0x28, 0x10),
    (0x28, 0x3c, 0x10), (0x10, 0x28, 0x3c), (0x10, 0x1f, 0x2f), (0x2f, 0x1f, 0x3f),
    (0x3f, 0x2f, 0x1f), (0x3f, 0x1f, 0x1f), (0x2f, 0x2f, 0x2f), (0x5f, 0x5f, 0x5f),
    (0x0f, 0xf0, 0xf0), (0xf0, 0x0f, 0xf0), (0xf0, 0xf0, 0x0f), (0xff, 0xff, 0xff)
]

def convert_to_pico8_palette(image):
    width, height = image.size
    new_image = Image.new("RGB", (width, height))
    pixels = new_image.load()
    for y in range(height):
        for x in range(width):
            r, g, b, _ = image.getpixel((x, y))
            closest_color = min(PICO8_PALETTE, key=lambda c: (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2)
            pixels[x, y] = closest_color
    return new_image

def process_image(input_path, output_path):
    # Open the image file
    with Image.open(input_path).convert("RGBA") as img:  # 修改: 使用 RGBA 模式打开图像
        # Calculate the aspect ratio
        width, height = img.size
        if width > height:
            new_width = 128
            new_height = int(height * (128 / width))
        else:
            new_width = int(width * (128 / height))
            new_height = 128
        
        # Resize the image to the new dimensions
        img = img.resize((new_width, new_height), Image.LANCZOS)
        
        # Calculate the center of the image
        left = (new_width - 128) / 2
        top = (new_height - 128) / 2
        right = (new_width + 128) / 2
        bottom = (new_height + 128) / 2
        
        # Crop the image to 128x128
        img = img.crop((left, top, right, bottom))
        
        # Convert the image to the Pico-8 palette
        img = convert_to_pico8_palette(img)
        
        # Save the processed image
        img.save(output_path)


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python img2p8.py <input> <output>")
        sys.exit(1)
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    process_image(input_path, output_path)