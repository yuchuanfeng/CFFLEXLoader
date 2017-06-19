THEOS_DEVICE_IP = 20.20.49.66
ARCHS = arm64
TARGET = iphone:latest:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 11CFFLEXLoader
11CFFLEXLoader_FILES = Tweak.xm

# 11CFFLEXLoader_LDFLAGS += /Library/Application\ Support/CFFLEXLoader/FLEX

include $(THEOS_MAKE_PATH)/tweak.mk

before-pachage:
	@echo "Run FLEX dylib build script"
	# ./build_dylib.sh
after-install::
	install.exec "killall -9 SpringBoard"
