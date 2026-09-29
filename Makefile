# LUMIX Photobooth
.PHONY: build test run verify clean log

build:
	swift build

release:
	swift build -c release

test:
	swift test

run: build
	.build/debug/booth

# 全量验证：编译 + 测试
verify: build test

clean:
	swift package clean

# 跟踪今日日志（调试主力）
log:
	tail -f ~/Library/Logs/Booth/booth-$$(date +%F).log
