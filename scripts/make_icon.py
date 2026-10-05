#!/usr/bin/env python3
"""Рисует иконку приложения и раскладывает PNG по AppIcon.appiconset.

Запуск: python3 scripts/make_icon.py   (нужен Pillow: pip install pillow)
"""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "NorskKort", "Assets.xcassets", "AppIcon.appiconset")

S = 4096  # рисуем крупно, потом уменьшаем — так края получаются гладкими
K = S / 1024

RED_TOP = (214, 32, 62)
RED_BOTTOM = (160, 12, 42)
BLUE = (0, 40, 104)
WHITE = (255, 255, 255)

FONT_CANDIDATES = [
    "/System/Library/Fonts/SFNSRounded.ttf",
    "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]


def px(v):
    return int(round(v * K))


def font(size):
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            return ImageFont.truetype(path, px(size))
    sys.exit("Не найден жирный шрифт, добавьте путь в FONT_CANDIDATES")


def vertical_gradient(size, top, bottom):
    w, h = size
    grad = Image.new("RGB", (1, h))
    for y in range(h):
        t = y / (h - 1)
        grad.putpixel((0, y), tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    return grad.resize((w, h))


def rounded_mask(size, box, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(box, radius=radius, fill=255)
    return mask


def shadow(size, box, radius, blur, opacity, offset_y):
    x0, y0, x1, y1 = box
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle(
        (x0, y0 + offset_y, x1, y1 + offset_y), radius=radius, fill=(0, 0, 0, int(255 * opacity))
    )
    return layer.filter(ImageFilter.GaussianBlur(blur))


def card(width, height, radius, fill, draw_content=None):
    """Карточка с тенью, повёрнутая потом целиком."""
    pad = px(80)
    w, h = width + 2 * pad, height + 2 * pad
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    box = (pad, pad, pad + width, pad + height)
    layer.alpha_composite(shadow((w, h), box, radius, px(18), 0.35, px(14)))
    ImageDraw.Draw(layer).rounded_rectangle(box, radius=radius, fill=fill)
    if draw_content:
        draw_content(layer, box)
    return layer


def flag_stripe(layer, box):
    """Норвежский флаг в верхней части карточки."""
    x0, y0, x1, _ = box
    fh = px(118)
    flag = Image.new("RGBA", (x1 - x0, fh), RED_TOP + (255,))
    d = ImageDraw.Draw(flag)
    cx = int((x1 - x0) * 0.32)
    # пропорции флага по высоте: красный 6 – белый 1 – синий 2 – белый 1 – красный 6
    white, blue = fh * 2 / 16, fh * 1 / 16
    d.rectangle((cx - white, 0, cx + white, fh), fill=WHITE)
    d.rectangle((0, fh / 2 - white, x1 - x0, fh / 2 + white), fill=WHITE)
    d.rectangle((cx - blue, 0, cx + blue, fh), fill=BLUE)
    d.rectangle((0, fh / 2 - blue, x1 - x0, fh / 2 + blue), fill=BLUE)
    # верхние углы флага скругляем вместе с карточкой
    mask = Image.new("L", flag.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, flag.width, fh + px(60)), radius=px(44), fill=255)
    layer.paste(flag, (x0, y0), mask)


def front_content(layer, box):
    flag_stripe(layer, box)
    x0, y0, x1, y1 = box
    d = ImageDraw.Draw(layer)
    f = font(250)
    cx, cy = (x0 + x1) / 2, y0 + px(280)
    d.text((cx, cy), "Å", font=f, fill=BLUE, anchor="mm")
    # две «строчки текста» под буквой
    line_w = [px(250), px(170)]
    for i, lw in enumerate(line_w):
        ly = y1 - px(112) + i * px(44)
        d.rounded_rectangle((cx - lw / 2, ly, cx + lw / 2, ly + px(22)), radius=px(11), fill=(205, 212, 226))


def draw_icon():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))

    # Подложка в сетке macOS: 824×824 по центру холста 1024×1024
    bg_box = (px(100), px(100), px(924), px(924))
    radius = px(185)
    img.alpha_composite(shadow((S, S), bg_box, radius, px(14), 0.30, px(10)))
    bg = vertical_gradient((S, S), RED_TOP, RED_BOTTOM).convert("RGBA")
    img.paste(bg, (0, 0), rounded_mask((S, S), bg_box, radius))

    # Мягкий блик сверху
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((px(40), px(-260), px(984), px(460)), fill=(255, 255, 255, 22))
    glow = glow.filter(ImageFilter.GaussianBlur(px(110)))
    clipped = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    clipped.paste(glow, (0, 0), rounded_mask((S, S), bg_box, radius))
    img.alpha_composite(clipped)

    cw, ch, cr = px(440), px(560), px(52)

    back = card(cw, ch, cr, (238, 241, 247)).rotate(14, resample=Image.BICUBIC, expand=True)
    img.alpha_composite(back, (px(560) - back.width // 2, px(505) - back.height // 2))

    front = card(cw, ch, cr, WHITE, front_content).rotate(-7, resample=Image.BICUBIC, expand=True)
    img.alpha_composite(front, (px(470) - front.width // 2, px(520) - front.height // 2))

    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    master = draw_icon()

    images = []
    for points in (16, 32, 128, 256, 512):
        for scale in (1, 2):
            pixels = points * scale
            name = f"icon_{points}x{points}{'@2x' if scale == 2 else ''}.png"
            master.resize((pixels, pixels), Image.LANCZOS).save(os.path.join(OUT, name))
            images.append({"idiom": "mac", "size": f"{points}x{points}", "scale": f"{scale}x", "filename": name})

    with open(os.path.join(OUT, "Contents.json"), "w") as f:
        json.dump({"images": images, "info": {"author": "xcode", "version": 1}}, f, indent=2)
    with open(os.path.join(os.path.dirname(OUT), "Contents.json"), "w") as f:
        json.dump({"info": {"author": "xcode", "version": 1}}, f, indent=2)

    print("Готово:", OUT)


if __name__ == "__main__":
    main()
