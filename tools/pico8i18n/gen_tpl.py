#coding: utf-8
import re
import os
import sys

folder = sys.argv[1]
cart_name = sys.argv[2]
lang = sys.argv[3]
cart_file = "carts/pico8pixelbomb/{}/{}.{}.p8".format(folder, cart_name, lang)
translation_file = os.path.join(os.path.dirname(cart_file), '{}.texts.{}.txt'.format(cart_name, lang))

texts = set()
dictionary = {}
# read lua file
with open(cart_file, 'r') as inf:
    lines = inf.readlines()
    flag = False
    for line in lines:
        if '__lua__' in line:
            flag = True
            continue
        if '__gfx__' in line:
            break
        if flag:
            matched = re.findall('_t\("(.+?)"', line)
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
