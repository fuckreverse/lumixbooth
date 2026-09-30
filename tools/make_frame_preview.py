#!/usr/bin/env python3
"""生成相框预览图：示例照片（天空渐变 + 两个人影）垫底，上面叠相框。

用法: python3 make_frame_preview.py <frame.png> <preview.png>
"""
import sys
from PIL import Image, ImageDraw


def make_sample_photo(w: int, h: int) -> Image.Image:
    img = Image.new("RGB", (w, h))
    px = img.load()
    top = (150, 190, 235)     # 天空蓝
    bottom = (245, 222, 200)  # 暖米色地面
    for y in range(h):
        t = y / (h - 1)
        for x in range(w):
            px[x, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    d = ImageDraw.Draw(img)
    dark = (70, 60, 75)
    # 两个人影（圆头 + 身体），按画布比例定位
    s = h / 1800.0
    for cx in (w * 0.42, w * 0.58):
        head_r = 85 * s
        head_cy = h * 0.22
        d.ellipse([cx - head_r, head_cy - head_r, cx + head_r, head_cy + head_r], fill=dark)
        body_w, body_h = 200 * s, 480 * s
        d.rectangle([cx - body_w / 2, head_cy + head_r * 0.8,
                     cx + body_w / 2, head_cy + head_r * 0.8 + body_h], fill=dark)
    return img


def main() -> None:
    frame_path, out_path = sys.argv[1], sys.argv[2]
    frame = Image.open(frame_path).convert("RGBA")
    photo = make_sample_photo(*frame.size).convert("RGBA")
    photo.alpha_composite(frame)
    photo.convert("RGB").save(out_path)
    print(f"✓ {out_path}")


if __name__ == "__main__":
    main()
