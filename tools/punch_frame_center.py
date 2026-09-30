#!/usr/bin/env python3
"""punch_frame_center — 把相框图中间留白区抠成透明。

做法：从图像中心点洪水填充近白色像素（min(r,g,b) >= 阈值），
只掏空与中心连通的留白，四角/边缘的装饰与底色不受影响；
mask 轻微腐蚀 + 高斯羽化，避免吃进白色花瓣等装饰、边缘生硬。
输出 1200x1800 RGBA PNG（与 booth 管线 frame.png 尺寸约定一致）。
"""
import os
import sys
from collections import deque

from PIL import Image, ImageChops, ImageDraw, ImageFilter

# 逗号分隔的 src 子串：命中的图片用「矩形模式」——旧纸纹理类留白
# 洪水填充会被深色斑点挡住产生锯齿边，直接取填充区外接矩形整体掏空
RECT_MODE = [s for s in os.environ.get("PUNCH_RECT", "").split(",") if s]

THRESH = 242      # 近白判定：三通道都 >= 242 才算留白
RIM_DELTA = 17    # 边缘浸色区阈值 = 主阈值 - RIM_DELTA
RIM_GROW = int(os.environ.get("PUNCH_GROW", "40"))  # 扩散轮数（每轮 1px）
# 距离模式（胶片暖光晕等大面积渐变留白）：与中心点色每通道差 <= TOL 即留白
TOL = int(os.environ.get("PUNCH_TOL", "0"))
RIM_TOL = int(os.environ.get("PUNCH_RIM_TOL", "0"))
ERODE = 2         # mask 腐蚀像素，防泄漏进白色装饰
FEATHER = 2       # 边缘羽化半径
# 输出尺寸：默认 1200x1800（竖版成片），PUNCH_SIZE=WxH 可覆盖（横版 1800x1200）
_ow, _oh = os.environ.get("PUNCH_SIZE", "1200x1800").split("x")
OUT_W, OUT_H = int(_ow), int(_oh)


def punch(src: str, dst: str) -> None:
    im = Image.open(src).convert("RGB")
    w, h = im.size
    px = im.load()

    # 自适应阈值：中心点即留白本色（旧纸风可能是米黄而不是纯白）
    seed = (w // 2, h // 2)
    sr, sg, sb = px[seed]
    thresh = min(THRESH, min(px[seed]) - 2)
    rim_thresh = thresh - RIM_DELTA

    def is_blank(p: tuple) -> bool:
        if TOL:
            return max(abs(p[0] - sr), abs(p[1] - sg), abs(p[2] - sb)) <= TOL
        return min(p) >= thresh

    # 洪水填充：从中心点出发，只标记与中心连通的近白区域
    mask = Image.new("L", (w, h), 0)
    mpx = mask.load()
    seen = bytearray(w * h)
    q = deque([seed])
    seen[seed[1] * w + seed[0]] = 1
    while q:
        x, y = q.popleft()
        mpx[x, y] = 255
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx]:
                if is_blank(px[nx, ny]):
                    seen[ny * w + nx] = 1
                    q.append((nx, ny))

    # 边缘浸色区扩散：装饰内侧的留白常被浸成粉/奶油色（某通道 < 242），
    # 从已定 mask 边缘向 >= 225 的像素逐轮生长，吃掉浸染边；
    # 轮数有限，不会跑进大面积的亮白装饰表面（如祥云、蝴蝶结高光）
    if TOL:
        rim_tol = RIM_TOL or TOL + 20
        seed_img = Image.new("RGB", (w, h), (sr, sg, sb))
        dr, dg, db = ImageChops.difference(im, seed_img).split()
        maxd = ImageChops.lighter(ImageChops.lighter(dr, dg), db)
        eligible = maxd.point(lambda v: 255 if v <= rim_tol else 0)
    else:
        r, g, b = im.split()
        minch = ImageChops.darker(ImageChops.darker(r, g), b)
        eligible = minch.point(lambda v: 255 if v >= rim_thresh else 0)
    for _ in range(RIM_GROW):
        dilated = mask.filter(ImageFilter.MaxFilter(3))
        mask = ImageChops.lighter(mask, ImageChops.darker(dilated, eligible))

    # 矩形模式：取洪水填充区的外接矩形整体掏空（适合旧纸/纹理留白）
    if any(s in src for s in RECT_MODE):
        bbox = mask.getbbox()
        if not bbox:
            raise SystemExit(f"{src}: 未找到留白区域")
        rect_mask = Image.new("L", (w, h), 0)
        ImageDraw.Draw(rect_mask).rectangle(bbox, fill=255)
        mask = rect_mask

    # 腐蚀（MinFilter）+ 羽化
    mask = mask.filter(ImageFilter.MinFilter(ERODE * 2 + 1))
    mask = mask.filter(ImageFilter.GaussianBlur(FEATHER))

    rgba = im.convert("RGBA")
    # 羽化后的 mask 直接做反相 alpha，过渡柔和
    alpha = mask.point(lambda v: max(0, 255 - v))
    rgba.putalpha(alpha)

    rgba = rgba.resize((OUT_W, OUT_H), Image.LANCZOS)
    rgba.save(dst)

    # 覆盖率统计
    hist = alpha.histogram()
    transparent = sum(hist[:16])
    print(f"  ✓ {dst}  透明像素 {transparent * 100 // (w * h)}%")


if __name__ == "__main__":
    pairs = list(zip(sys.argv[1::2], sys.argv[2::2]))
    for src, dst in pairs:
        punch(src, dst)
