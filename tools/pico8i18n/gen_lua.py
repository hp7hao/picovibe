#coding: utf-8

import re
import sys  # 导入sys模块以获取命令行参数
import os  # 导入os模块以获取文件路径
import json

from PIL import Image, ImageDraw, ImageFont
from typing import Tuple

class PILFont():
    def __init__(self, font_path: str, font_size: int) -> None:
        self.__font = ImageFont.FreeTypeFont(font_path, font_size)
    
    def render_text(self, text: str, offset: Tuple[int, int] = (0, 0)) -> Image:
        ''' 绘制文本图片
            > text: 待绘制文本
            > offset: 偏移量
        '''
        box = self.__font.getbbox(text)
        print(box)
        __left, __top, right, bottom = self.__font.getbbox(text)
        img = Image.new("1", (right, bottom), color=255)
        img_draw = ImageDraw.Draw(img)
        img_draw.text(offset, text, fill=0, font=self.__font, spacing=0)
        return img
    
    def to_bin_str(self, character: str, offset: Tuple[int, int] = (0, 0)) -> str:
        '''
            character: single chinese character
        '''
        print(character)
        __left, __top, right, bottom = self.__font.getbbox(character)
        if not is_ascii(character) and bottom < 8:
            bottom = 8
        img = Image.new("1", (right, bottom), color=255)
        img_draw = ImageDraw.Draw(img)
        img_draw.text(offset, character, fill=0, font=self.__font, spacing=0)
        # img.show()
        binstr = ''
        if is_ascii(character):
            binstr += '0000'
            # use next six bits to save width and height
            binstr += bin(right)[2:].zfill(4)
            binstr += bin(bottom)[2:].zfill(4)
            # build pixel map with bbox, if have dot, pupulate
            for y in range(0, bottom):
                for x in range(0, right):
                    pix = img.getpixel((x, y))
                    if pix == 0:
                        binstr += '1'
                    else:
                        binstr += '0'
        else:
            binstr += '0001'
            # a chinese character fits in a 4x8 bbox
            for y in range(0, 8):
                for x in range(0, 8):
                    pix = img.getpixel((x, y))
                    if pix == 0:
                        binstr += '1'
                    else:
                        binstr += '0'
        return binstr
    
# 获取脚本所在目录的绝对路径
script_dir = os.path.dirname(os.path.abspath(__file__))

def is_ascii(s):
    return all(ord(c) < 128 for c in s)

def build_bin_str(text):
    binstr = ''
    i = 0
    while i < len(text):
        ch = text[i]
        if is_ascii(ch):
            if text[i] == '\\':
                if text[i+1] == 'n':
                    binstr += '0010'
                    i += 2
                    continue
            # font_path = os.path.join(os.path.dirname(script_dir), "resources", "3x7-font.ttf")
            # offset = (0, -1)
            font_path = os.path.join(os.path.dirname(script_dir), "resources", "fonts", "3x7-font.ttf")
            offset = (0, 0)
        else:
            font_path = os.path.join(os.path.dirname(script_dir), "resources", "fonts", "BoutiqueBitmap7x7_1.7.ttf")
            offset = (0, 0)
        f = PILFont(font_path, 8)
        binstr += f.to_bin_str(ch, offset) 
        i += 1
    print(binstr)
    return binstr

def convert_bin_to_hex(bin_str):
    # 如果长度不是4的倍数，则在末尾补'0'
    while len(bin_str) % 4 != 0:
        bin_str += '0'
    
    # 将二进制字符串转换为16进制字符串
    hex_str = ''
    for i in range(0, len(bin_str), 4):
        hex_str += hex(int(bin_str[i:i+4], 2))[2:].zfill(1)
    print(hex_str)
    return hex_str

def build_hex_str(text):
    return convert_bin_to_hex(build_bin_str(text))

# read all texts
# Check if enough arguments are provided
if len(sys.argv) < 3:
    print("Usage: python gen_tpl.py <path_to_p8_file> <lang>")
    sys.exit(1)

# Extract information from the .p8 file path
p8_file_path = sys.argv[1]
lang = sys.argv[2]

# Validate file path has .p8 extension
if not p8_file_path.endswith('.p8'):
    print("Error: Input file must have a .p8 extension")
    sys.exit(1)

# Extract folder and cart_name from the p8 file path
folder = os.path.dirname(p8_file_path)

# Extract cart_name from filename (remove language and extension)
filename = os.path.basename(p8_file_path)
# Assuming format is cartname.lang.p8
if '.' in filename:
    cart_name = filename.split('.')[0]
else:
    print("Error: Invalid filename format, expected cartname.lang.p8")
    sys.exit(1)

# Read translations from meta file
meta_file = os.path.join(folder, '{}.meta.{}.json'.format(cart_name, lang))
translations = {}
with open(meta_file, 'r', encoding='utf-8') as inf:
    meta_data = json.load(inf)
    translations = meta_data.get('translations', {})

# save lua files
lua_file = os.path.join(folder, '{}.texts.{}.lua'.format(cart_name, lang))
lines = [
   'i18n.texts["' + lang + '"]={}',
]
for k, v in translations.items():
    lines.append('i18n.texts["{}"]["{}"]="{}"'.format(lang, k, build_hex_str(v)))

with open(lua_file, 'w') as outf:
    for line in lines:
       outf.write(line)
       outf.write('\n')