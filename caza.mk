#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from the Neoteric configuration.
$(call inherit-product, vendor/neoteric/target/product/neoteric-target.mk)

# Inherit from aurora device.
$(call inherit-product, device/nubia/caza/pineapple.mk)

# Device identifier
PRODUCT_DEVICE := caza
PRODUCT_NAME := caza
PRODUCT_BRAND := Nubia
PRODUCT_MODEL := NX721J
PRODUCT_MANUFACTURER := ZTE

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="PQ83A01-UN PQ83A01 14 UKQ1.230917.001 20240203.100147 release-keys" \
    BuildFingerprint=nubia/PQ83A01-UN/PQ83A01:14/UKQ1.230917.001/20240203.100147:user/release-keys \
    DeviceName=PQ83A01-UN \
    DeviceProduct=PQ83A01-UN

PRODUCT_GMS_CLIENTID_BASE := android-zte
