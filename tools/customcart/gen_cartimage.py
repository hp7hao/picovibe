from PIL import Image, ImageDraw, ImageFont
import os
import sys
import subprocess
import json
import segno  # Add segno for QR code generation
import configparser
import argparse

def open_image(file_path):
    try:
        return Image.open(file_path)
    except IOError as e:
        print(f"Error opening file {file_path}: {e}")
        sys.exit(1)

def validate_image(image, file_path):
    if image.format != 'PNG':
        print(f"{file_path} is not a PNG image.")
        sys.exit(1)
    if image.mode != 'RGBA':
        print(f"{file_path} is not in RGBA mode. Trying to convert...")
        return image.convert('RGBA')
    return image

def validate_dimensions(image, file_path):
    w, h = image.size
    if (w != 160) or (h != 205):
        print(f"{file_path} doesn't match PICO-8's dimensions. PICO-8 cartridge PNGs have a size of 160x205.")
        sys.exit(1)

def merge_images(data_image_path, picture_image_path, output_path):
    try:
        subprocess.run(['tools/customcart/p8png', data_image_path, picture_image_path, output_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running p8png: {e}")
        sys.exit(1)

def read_meta_file(meta_file_path):
    try:
        with open(meta_file_path, 'r', encoding='utf-8') as file:
            meta_data = json.load(file)
            return {
                'title': meta_data.get('title', ''),
                'author': meta_data.get('author', ''),
                'template': meta_data.get('template', ''),
                'qrdata': meta_data.get('qrdata', '')  # Add qrdata field
            }
    except json.JSONDecodeError as e:
        print(f"Error reading JSON file {meta_file_path}: {e}")
        sys.exit(1)
    except IOError as e:
        print(f"Error opening file {meta_file_path}: {e}")
        sys.exit(1)

def get_font_path():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(os.path.dirname(script_dir), "resources", "fonts", "BoutiqueBitmap7x7_1.7.ttf")

def get_cart_template_path(cart_template_name):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(os.path.dirname(script_dir), "resources", "imgs", "cart_templates", "{}.png".format(cart_template_name))

def generate_qr_code(qr_data, size=64):
    """Generate a QR code from the given data"""
    if not qr_data:
        return None
    
    # Create QR code
    qr = segno.make(qr_data, micro=False)
    
    # Convert to PIL Image - using the correct method
    # The segno library uses a different approach to create PIL images
    from io import BytesIO
    import PIL.Image
    
    # Save QR code to a BytesIO object
    buffer = BytesIO()
    qr.save(buffer, kind='png', scale=4, dark=(0, 0, 0), light=(255, 255, 255))
    buffer.seek(0)
    
    # Open the image from the buffer
    qr_img = PIL.Image.open(buffer)
    
    # Resize to desired size
    qr_img = qr_img.resize((size, size), Image.LANCZOS)
    
    # Convert to RGBA
    qr_img = qr_img.convert('RGBA')
    
    return qr_img

def write_text_to_image(meta_data, input_image_path, template_path, output_image_path):
    # 打开输入图像和模板图像
    input_image = Image.open(input_image_path)
    validate_image(input_image, input_image_path)
    template_image = Image.open(template_path)
    validate_image(template_image, template_path)
    draw = ImageDraw.Draw(template_image)
    
    # 定义要截取的区域
    crop_box = (16, 24, 144, 152)
    cropped_image = input_image.crop(crop_box)
    
    # 将截取的区域粘贴到模板图像的相同位置
    template_image.paste(cropped_image, crop_box)
    
    # 使用gen_lua.py中的字体和字号设置
    font_path = get_font_path()
    font = ImageFont.truetype(font_path, 8)
    
    # 写入文字
    text_position = (18, 166)
    text = f"{meta_data['title']}"
    draw.text(text_position, text, font=font, fill=(0xff, 0xff, 0xff))
    text = f"{meta_data['author']}"
    text_position = (18, 176)
    draw.text(text_position, text, font=font, fill=(0xff, 0xff, 0xff))
    
    # 保存图片
    template_image.save(output_image_path)

def add_qr_to_image(image_path, qr_img, output_path):
    """Add QR code to the center of the specified crop area"""
    if not qr_img:
        return
    
    # Open the image
    img = Image.open(image_path)
    
    # Define the crop area
    crop_box = (16, 24, 144, 152)
    crop_width = crop_box[2] - crop_box[0]
    crop_height = crop_box[3] - crop_box[1]
    
    # Calculate center position for QR code within the crop area
    qr_size = qr_img.size[0]
    center_x = crop_box[0] + (crop_width - qr_size) // 2
    center_y = crop_box[1] + (crop_height - qr_size) // 2
    
    # Create a new image with the same size as the original
    overlay_img = img.copy()
    
    # Paste QR code in the center of the crop area
    overlay_img.paste(qr_img, (center_x, center_y), qr_img)
    
    # Save the new image
    overlay_img.save(output_path)

if __name__ == "__main__":
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Generate PICO-8 cartridge image with optional QR code')
    parser.add_argument('target_folder', help='Target folder containing the cartridge files')
    parser.add_argument('cart_name', help='Name of the cartridge')
    parser.add_argument('lang', help='Language code')
    parser.add_argument('--template', help='Template name to use (overrides meta file)')
    parser.add_argument('--qrcode', choices=['inplace', 'newimg'], help='QR code mode: inplace or newimg')
    parser.add_argument('--config', help='Path to config file with additional parameters')
    
    args = parser.parse_args()
    
    # Load config file if provided
    config = configparser.ConfigParser()
    if args.config and os.path.exists(args.config):
        config.read(args.config)
    
    # Get parameters with priority: command line > config file > defaults
    target_folder = args.target_folder
    cart_name = args.cart_name
    lang = args.lang
    cli_template = args.template
    qrcode_mode = args.qrcode
    
    # Override with config values if not provided via command line
    if 'DEFAULT' in config:
        if not cli_template and 'template' in config['DEFAULT']:
            cli_template = config['DEFAULT']['template']
        if not qrcode_mode and 'qrcode' in config['DEFAULT']:
            qrcode_mode = config['DEFAULT']['qrcode']
    
    meta_file_path = "{}/{}.meta.{}.json".format(target_folder, cart_name, lang)
    print(meta_file_path)
    # check meta file exist or not
    if not os.path.exists(meta_file_path):
        print("meta file not exist")
        sys.exit(1)

    input_image_path = "{}/{}.p8.png".format(target_folder, cart_name)
    # check .orig file exist or not
    if not os.path.exists(input_image_path):
        print("input image not exist")
        sys.exit(1)
    
    # Read meta data to get the template
    meta_data = read_meta_file(meta_file_path)
    
    # Priority: CLI template > JSON template > default
    template_to_use = cli_template or meta_data['template'] or 'default'
    cart_template_path = get_cart_template_path(template_to_use)
    
    # check cart template exist or not
    if not os.path.exists(cart_template_path):
        print(f"Template {template_to_use} not found, trying default template")
        cart_template_path = get_cart_template_path('default')
        if not os.path.exists(cart_template_path):
            print("default template not exist")
            sys.exit(1)

    if not os.path.exists("{}/release".format(target_folder)):
        os.makedirs("{}/release".format(target_folder))
    
    # Define output paths
    output_image_path = "{}/release/{}.{}.p8.preview.png".format(target_folder, cart_name, lang)
    final_image_path = "{}/release/{}.{}.p8.png".format(target_folder, cart_name, lang)
    
    # Generate QR code if needed
    qr_img = None
    if qrcode_mode and meta_data.get('qrdata'):
        qr_img = generate_qr_code(meta_data['qrdata'])
    
    # Write text to image
    write_text_to_image(meta_data, input_image_path, cart_template_path, output_image_path)
    
    # Create QR version of preview image if needed
    qr_preview_path = None
    if qrcode_mode == 'newimg' and qr_img:
        qr_preview_path = "{}/release/{}.{}.p8.qr.preview.png".format(target_folder, cart_name, lang)
        add_qr_to_image(output_image_path, qr_img, qr_preview_path)
    
    # Add QR code to preview image for inplace mode
    if qrcode_mode == 'inplace' and qr_img:
        add_qr_to_image(output_image_path, qr_img, output_image_path)
    
    # Merge images to create final P8 PNG
    merge_images(input_image_path, output_image_path, final_image_path)
    
    # Create QR version of final P8 PNG if needed
    if qrcode_mode == 'newimg' and qr_preview_path:
        # Create a separate P8 PNG with QR code
        qr_final_path = "{}/release/{}.{}.qr.p8.png".format(target_folder, cart_name, lang)
        merge_images(input_image_path, qr_preview_path, qr_final_path)
    
    # Clean up temporary files
    if os.path.exists(output_image_path):
        os.remove(output_image_path)
    if qr_preview_path and os.path.exists(qr_preview_path):
        os.remove(qr_preview_path)

    