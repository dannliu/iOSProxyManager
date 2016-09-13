ARCHS=arm64 armv7 armv7s

TARGET=iphone::7.1

ADDITIONAL_OBJCFLAGS = -fobjc-arc

THEOS_DEVICE_IP=192.168.1.108

include theos/makefiles/common.mk

TOOL_NAME = test_proxy

test_proxy_FILES = main.mm WiFiProxy.m

test_proxy_FRAMEWORKS = UIKit Foundation SystemConfiguration

test_proxy_LDFLAGS = -undefined dynamic_lookup

test_proxy_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/tool.mk