from PIL import Image, ImageDraw, ImageFont
import os
import sys
import subprocess

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
    with open(meta_file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
        meta_data = {}
        for line in lines:
            key, value = line.strip().split('=')
            meta_data[key] = value.strip('"')
        return meta_data

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
    text = f"{meta_data['name']}"
    draw.text(text_position, text, font=font, fill=(0xff, 0xff, 0xff))
    text = f"{meta_data['author']}"
    text_position = (18, 176)
    draw.text(text_position, text, font=font, fill=(0xff, 0xff, 0xff))
    
    # 保存图片
    template_image.save(output_image_path)


if __name__ == "__main__":
    target_folder = sys.argv[1]
    cart_name = sys.argv[2]
    lang = sys.argv[3]
    cart_template = sys.argv[4]

    meta_file_path = "{}/{}.meta.{}.txt".format(target_folder, cart_name, lang)
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
    
    cart_template_path = get_cart_template_path(cart_template)
    # check cart template exist or not
    if not os.path.exists(cart_template_path):
        print("cart template not exist")
        sys.exit(1)

    if not os.path.exists("{}/output".format(target_folder)):
        os.makedirs("{}/output".format(target_folder))
    output_image_path = "{}/output/{}.{}.p8.preview.png".format(target_folder, cart_name, lang)

    # write name and author to image
    meta_data = read_meta_file(meta_file_path)
    write_text_to_image(meta_data, input_image_path, cart_template_path, output_image_path)

    # encode data in the output png file
    final_image_path = "{}/output/{}.{}.p8.png".format(target_folder, cart_name, lang)
    merge_images(input_image_path, output_image_path, final_image_path)

    if os.path.exists(output_image_path):
        os.remove(output_image_path)

    