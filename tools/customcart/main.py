import os
import sys
from PIL import Image

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

def merge_images(data_image, picture_image, output_path):
    d_pixels = data_image.load()
    p_pixels = picture_image.load()
    o_pixels = picture_image.copy().load()

    for iy in range(205):
        for ix in range(160):
            o_pixels[ix, iy] = (
                (p_pixels[ix, iy][0] & 0xFC) | (d_pixels[ix, iy][0] & 0x03),
                (p_pixels[ix, iy][1] & 0xFC) | (d_pixels[ix, iy][1] & 0x03),
                (p_pixels[ix, iy][2] & 0xFC) | (d_pixels[ix, iy][2] & 0x03),
                (p_pixels[ix, iy][3] & 0xFC) | (d_pixels[ix, iy][3] & 0x03)
            )

    picture_image.save(output_path, 'PNG')

def main(argv):
    if len(argv) != 4:
        print(f"Usage: {argv[0]} [dfile.p8.png] [ifile.p8.png] [ofile.p8.png]")
        return 1

    dfname = argv[1]
    pfname = argv[2]
    ofname = argv[3]

    data_image = open_image(dfname)
    picture_image = open_image(pfname)

    data_image = validate_image(data_image, dfname)
    picture_image = validate_image(picture_image, pfname)

    validate_dimensions(data_image, dfname)
    validate_dimensions(picture_image, pfname)

    merge_images(data_image, picture_image, ofname)

    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))