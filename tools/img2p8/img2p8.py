from PIL import Image

# Pico-8 color palette
PICO8_PALETTE = [
    (0x00, 0x00, 0x00), (0x1D, 0x2B, 0x53), (0x7E, 0x25, 0x53), (0x00, 0x87, 0x51),
    (0xAB, 0x52, 0x36), (0x5F, 0x57, 0x4F), (0xC2, 0xC3, 0xC7), (0xFF, 0xF1, 0xE8),
    (0xFF, 0x00, 0x4D), (0xFF, 0xA3, 0x00), (0xFF, 0xEC, 0x27), (0x00, 0xE4, 0x36),
    (0x29, 0xAD, 0xFF), (0x83, 0x76, 0x9C), (0xFF, 0x77, 0xA8), (0xFF, 0xCC, 0xAA)
]

P8SCII = \
      "                " \
    + "▮■□⁙⁘‖◀▶「」¥•、。゛゜" \
    + " !@#$%&'()*+,-./" \
    + "0123456789:;<=>?" \
    + "@ABCDEFGHIJKLMNO" \
    + "PQRSTUVWXYZ[\\]^" \
    + "_`abcdefghijklmn" \
    + "opqrstuvwxyz{|}~" \
    + "○█▒🐱⬇░✽●♥☉웃⌂⬅😐" \
    + "♪🅾◆…⬇★⧗⬆ˇ∧❎▤▥" \
    + "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんっゃゅょ" \
    + "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンッャュョ" \
    + "◜◝"

def convert_to_pico8_palette(image):
    width, height = image.size
    new_image = Image.new("RGB", (width, height))
    color_matrix = []
    pixels = new_image.load()
    for y in range(height):
        line = []
        for x in range(width):
            r, g, b, _ = image.getpixel((x, y))
            closest_color = min(PICO8_PALETTE, key=lambda c: (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2)
            pixels[x, y] = closest_color
            closest_color_index = PICO8_PALETTE.index(closest_color)
            line.append(closest_color_index)
        color_matrix.append(line)
    return new_image, color_matrix

def encode_string(color_matrix):
    w, h = 128, 128
    token_list = []
    x, y = 0, 0
    length = 1

    while y < h:
        curcol = color_matrix[y][x]
        if x < w - 1:
            nxtcol = color_matrix[y][x + 1]
            if nxtcol == curcol:
                length += 1
            else:
                token_list.append(curcol)
                token_list.append(length)
                length = 1
            x += 1
        else:
            token_list.append(curcol)
            token_list.append(length)
            length = 1
            x = 0
            y += 1

    new_s = '`' + get_p8scii(w - 1 + 96) + '`' + get_p8scii(h - 1 + 96)
    print(new_s)
    # convert every char to int
    print(ord(new_s[1]))
    for i in range(0, len(token_list), 2):
        color = token_list[i]
        count = token_list[i + 1]
        delta_color = get_p8scii(color + 96)
        delta_count = get_p8scii(count + 96)
        new_s += delta_color + delta_count
    return new_s

def get_p8scii(index):
    if index == 131:
        return "⬇️"
    elif index == 139:
        return "⬅️"
    elif index == 142:
        return "🅾️"
    elif index == 145:
        return "➡️"
    elif index == 148:
        return "⬆️"
    else:
        return P8SCII[index]

def process_image(input_path, output_path):
    # Open the image file
    with Image.open(input_path).convert("RGBA") as img:  # 修改: 使用 RGBA 模式打开图像
        # Calculate the aspect ratio
        width, height = img.size
        if width > height:
            new_width = int(width * (128 / height))
            new_height = 128
        else:
            new_width = 128
            new_height = int(height * (128 / width))
        
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
        img, color_matrix = convert_to_pico8_palette(img)
        
        # Save the processed image
        img.save(output_path)
        print(encode_string(color_matrix))


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python img2p8.py <input> <output>")
        sys.exit(1)
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    process_image(input_path, output_path)