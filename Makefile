# LUMIX Photobooth
.PHONY: build test run run-mock open-prints verify clean log

build:
	swift build

release:
	swift build -c release

test:
	swift test

run: build
	.build/debug/booth

# 无硬件演示：合成相机 + 视觉自动命中 + 打印落 PDF（不送打印机）
run-mock: build
	.build/debug/booth -mock

# 打包最小 .app（有 bundle id，可被辅助功能/自动化识别；双击即演示）
app: build
	mkdir -p .build/Booth.app/Contents/MacOS
	cp .build/debug/booth .build/Booth.app/Contents/MacOS/booth
	cp Resources/Info.plist .build/Booth.app/Contents/Info.plist

# 以 .app 形态跑 mock 演示（先杀旧实例，否则 open 只激活旧二进制）
run-mock-app: app
	-pkill -x booth
	open .build/Booth.app --args -mock

# 打开 dry-run 打印的 PDF 输出目录
open-prints:
	open ~/Library/Application\ Support/Booth/print-preview

# 全量验证：编译 + 测试
verify: build test

clean:
	swift package clean

# 跟踪今日日志（调试主力）
log:
	tail -f ~/Library/Logs/Booth/booth-$$(date +%F).log
