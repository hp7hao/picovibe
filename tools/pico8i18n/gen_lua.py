#coding: utf-8

import re
import sys  # 导入sys模块以获取命令行参数
import os  # 导入os模块以获取文件路径

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
    
    def tohex(self, character: str, offset: Tuple[int, int] = (0, 0)) -> str:
        '''
            character: single chinese character
        '''
        print(character)
        __left, __top, right, bottom = self.__font.getbbox(character)
        if right <= 4:
            width = 4
        else:
            width = 8
        # 确保字符的高度不低于9
        bottom = 8
        img = Image.new("1", (right, bottom), color=255)
        img_draw = ImageDraw.Draw(img)
        img_draw.text(offset, character, fill=0, font=self.__font, spacing=0)
        hexstr = ''
        for y in range(0, bottom):
            line = ''
            for x in range(0, right):
                pix = img.getpixel((x, y))
                if pix == 0:
                    line += '1'
                else:
                    line += '0'
            for x in range(len(line), width):
                line += '0'
            print(line)
            if width == 8:
                hexstr += str(hex(int(line, 2)))[2:].zfill(2)
            else:
                hexstr += str(hex(int(line, 2)))[2:]

        if width == 8:
            hexstr = hexstr[::-1].zfill(16)[::-1]
            hexstr = self.cut(hexstr)
        else:
            hexstr = hexstr[::-1].zfill(8)[::-1]
        print(hexstr)
        return hexstr
    
    def cut(self, hexstr):
        ret = ""
        for i in range(0, 16, 2):
            ret += hexstr[i]
        for i in range(1, 16, 2):
            ret += hexstr[i]
        return ret

# 获取脚本所在目录的绝对路径
script_dir = os.path.dirname(os.path.abspath(__file__))

def is_ascii(s):
    return all(ord(c) < 128 for c in s)

def to_hex(text):
    hexstr = ''
    for ch in text:
        if is_ascii(ch):
            font_path = os.path.join(script_dir, "3x7-font.ttf")
            if ch == 'g':
                offset = (0, -2)
            else:
                offset = (0, -1)
        else:
            font_path = os.path.join(script_dir, "BoutiqueBitmap7x7_1.7.ttf")
            offset = (0, 0)
        f = PILFont(font_path, 8)
        # f.render_text(ch, offset).show()
        hexstr += f.tohex(ch, offset) 
    return hexstr

# read all texts
lang = 'zh_CN'
translation_path = sys.argv[1]  # 使用命令行参数获取翻译文件路径
translations = {}
with open(translation_path, 'r') as inf:  # 使用传入的路径
  lines = inf.readlines()
  for line in lines:
    if line:
      kv = re.findall('"(.+?)"', line)
      translations[kv[0]] = to_hex(kv[1])
      print(translations[kv[0]])

# save lua files
# 获取翻译文件所在的目录
translation_dir = os.path.dirname(translation_path)
lua_file = os.path.join(translation_dir, 'texts.lua')
lines = [
   'lang="{}"'.format(lang),
   'texts={}'
]
for k, v in translations.items():
    lines.append('texts["{}"]="{}"'.format(k, v))

with open(lua_file, 'w') as outf:
    for line in lines:
       outf.write(line)
       outf.write('\n')