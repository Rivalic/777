# Makefile for DeviceIDRotator Dylib
# Usage: make (on macOS with Xcode)

ARCHS = arm64 arm64e
TARGET = iphone:clang:15.0:15.0
INSTALL_TARGET_PROCESSES = Swiggy

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = DeviceIDRotator

DeviceIDRotator_FILES = DeviceIDRotator.m
DeviceIDRotator_FRAMEWORKS = UIKit Foundation
DeviceIDRotator_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
DeviceIDRotator_INSTALL_PATH = /usr/lib

include $(THEOS)/makefiles/library.mk

# Alternative: Simple build without Theos
.PHONY: simple-build
simple-build:
	@echo "Building dylib without Theos..."
	clang -arch arm64 -arch arm64e \
		-isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) \
		-framework UIKit -framework Foundation \
		-dynamiclib -fobjc-arc \
		-install_name @rpath/DeviceIDRotator.dylib \
		-compatibility_version 1.0 -current_version 1.0 \
		-o DeviceIDRotator.dylib DeviceIDRotator.m
	@echo "✅ Built: DeviceIDRotator.dylib"
