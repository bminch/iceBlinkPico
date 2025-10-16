
from math import *
from PIL import Image

def clip(x, lower, upper):
    x = x if x >= lower else lower
    x = x if x <= upper else upper
    return x

def H2R(x):
    return 0.5 + clip(cos(x), -0.5, 0.5)

def H2G(x):
    return 0.5 + clip(cos(x - 2 * pi / 3), -0.5, 0.5)

def H2B(x):
    return 0.5 + clip(cos(x - 4 * pi / 3), -0.5, 0.5)

red_file = open('red.txt', 'w')
green_file = open('green.txt', 'w')
blue_file = open('blue.txt', 'w')

size = 8
frames = 32

for t in range(frames):
    pixels = []
    for y in range(size):
        for x in range(size):
            px = x / (size - 1)
            py = y / (size - 1)
            delay = 0.5 * sqrt((px - 0.5) ** 2 + (py - 0.5) ** 2) + atan2(py - 0.5, px - 0.5) / (2 * pi)
            hue = 2 * pi * (t / frames - delay)
            r = int(255 * H2R(hue))
            g = int(255 * H2G(hue))
            b = int(255 * H2B(hue))
            pixels.append((r, g, b))

            red_file.write(f'{r:02X}\n')
            green_file.write(f'{g:02X}\n')
            blue_file.write(f'{b:02X}\n')

    img = Image.new('RGB', (size, size))
    img.putdata(pixels)
    img.save(f'spiral{t}.png')

red_file.close()
green_file.close()
blue_file.close()
