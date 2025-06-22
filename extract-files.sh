#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=caza
VENDOR=nubia

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
    -n | --no-cleanup)
        CLEAN_VENDOR=false
        ;;
    -k | --kang)
        KANG="--kang"
        ;;
    -s | --section)
        SECTION="${2}"
        shift
        CLEAN_VENDOR=false
        ;;
    *)
        SRC="${1}"
        ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system/priv-app/NubiaCamera/NubiaCamera.apk)
            local temp_dir=$(mktemp -d)
            apktool d -f -r "${2}" -o "${temp_dir}"
            local smali_file=$(find "${temp_dir}" -name "*.smali" -exec grep -l "SettingHighFps" {} \; 2>/dev/null | head -1)
            if [[ -n "$smali_file" ]]; then
                sed -i 's/invoke-interface {p1, v0, v1}, Ljava\/util\/Map;->put(Ljava\/lang\/Object;Ljava\/lang\/Object;)Ljava\/lang\/Object;/invoke-interface {p1, v0, v2}, Ljava\/util\/Map;->put(Ljava\/lang\/Object;Ljava\/lang\/Object;)Ljava\/lang\/Object;/' "$smali_file"
            fi
            apktool b "${temp_dir}" -o "${2}"
            rm -rf "${temp_dir}"
            ;;
        system_ext/lib64/libwfdmmsrc_system.so)
            grep -q "libgui_shim.so" "${2}" || "${PATCHELF}" --add-needed "libgui_shim.so" "${2}"
            ;;
        system_ext/lib64/libwfdnative.so)
            grep -q "libinput_shim.so" "${2}" || "${PATCHELF}" --add-needed "libinput_shim.so" "${2}"
            ;;
        vendor/etc/wifi/wpa_supplicant_overlay.conf)
            sed -i 's/^driver_param="no_rrm=1"/driver_param="use_p2p_group_interface=1 no_rrm=1"/' "${2}"
            ;;
        vendor/lib64/hw/sensors.hal.tof.so)
            perl -i -pe 's/\x00input\x00/\x00fakei\x00/g' "${2}"
            ;;
        vendor/lib64/libqcodec2_core.so)
            grep -q "libcodec2_shim.so" "${2}" || "${PATCHELF}" --add-needed "libcodec2_shim.so" "${2}"
            ;;
        vendor/lib64/vendor.libdpmframework.so)
            grep -q "libhidlbase_shim.so" "${2}" || "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib64/libril-db.so)
            sed -i 's/persist\.vendor\.radio\.poweron_opt/persist.vendor.radio.poweron_ign/g' "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
