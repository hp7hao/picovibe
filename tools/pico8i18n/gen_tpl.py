#coding: utf-8
import re
import os
import sys

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

# Reconstruct cart_file path for consistent structure
translation_file = os.path.join(folder, '{}.texts.{}.txt'.format(cart_name, lang))

texts = set()
dictionary = {}
# read lua file
with open(p8_file_path, 'r') as inf:
    lines = inf.readlines()
    flag = False
    for line in lines:
        if '__lua__' in line:
            flag = True
            continue
        if '__gfx__' in line:
            break
        if flag:
            matched = re.findall('__text\("(.+?)"', line)
            print(matched)
            if len(matched) > 0:
                for m in matched:
                    texts.add(m)

# generate texts.zh.txt
# delete output file first
translations = {}
if os.path.exists(translation_file):
    with open(translation_file, 'r') as inf:
        lines = inf.readlines()
        for line in lines:
            kv = re.findall('"(.+?)"', line)
            translations[kv[0]] = kv[1]
    os.remove(translation_file)

lines = []
for text in texts:
    v = ""
    if text in translations:
        v = translations[text]
    lines.append('texts["{}"]="{}"\n'.format(text, v))

with open(translation_file, 'w') as outf:
    outf.writelines(lines)
