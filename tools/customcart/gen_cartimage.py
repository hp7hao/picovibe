from PIL import Image, ImageDraw, ImageFont
import os
import sys
import subprocess
import json

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
                'template': meta_data.get('template', '')
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


if __name__ == "__main__":
    # Make template argument optional by checking arg length
    if len(sys.argv) < 4:
        print("Usage: python gen_cartimage.py <target_folder> <cart_name> <lang> [template]")
        sys.exit(1)

    target_folder = sys.argv[1]
    cart_name = sys.argv[2]
    lang = sys.argv[3]
    cli_template = sys.argv[4] if len(sys.argv) > 4 else None  # Optional template argument

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
    output_image_path = "{}/release/{}.{}.p8.preview.png".format(target_folder, cart_name, lang)

    # write name and author to image
    write_text_to_image(meta_data, input_image_path, cart_template_path, output_image_path)

    # encode data in the output png file
    final_image_path = "{}/release/{}.{}.p8.png".format(target_folder, cart_name, lang)
    merge_images(input_image_path, output_image_path, final_image_path)

    if os.path.exists(output_image_path):
        os.remove(output_image_path)

    