#coding: utf-8
import re
import os
import sys
import json

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

# Reconstruct meta file path for consistent structure
meta_file = os.path.join(folder, '{}.meta.{}.json'.format(cart_name, lang))

texts = set()
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
            matched = re.findall('_p\("(.+?)"', line)
            print(matched)
            if len(matched) > 0:
                for m in matched:
                    texts.add(m)

# Read existing translations from meta file
translations = {}
if os.path.exists(meta_file):
    with open(meta_file, 'r', encoding='utf-8') as inf:
        meta_data = json.load(inf)
        translations = meta_data.get('translations', {})

# Update translations with new texts
for text in texts:
    if text not in translations:
        translations[text] = ""

# Read existing meta file
if not os.path.exists(meta_file):
    print(f"Error: Meta file {meta_file} does not exist")
    sys.exit(1)

with open(meta_file, 'r', encoding='utf-8') as inf:
    meta_data = json.load(inf)

if not meta_data:
    print(f"Error: Meta file {meta_file} is empty")
    sys.exit(1)

# Update only the translations section, keeping all other fields unchanged
meta_data['translations'] = dict(sorted(translations.items()))

with open(meta_file, 'w', encoding='utf-8') as outf:
    json.dump(meta_data, outf, ensure_ascii=False, indent=4)
