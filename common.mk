#
# SPDX-FileCopyrightText: Paranoid Android
# SPDX-License-Identifier: Apache-2.0
#

QCOM_COMMON_PATH := device/qcom/common

ifeq ($(TARGET_BOARD_PLATFORM),)
$(error "TARGET_BOARD_PLATFORM is not defined yet, please define in your device makefile so it's accessible to QCOM common.")
endif

# List of QCOM targets.
MSMSTEPPE := sm6150
TRINKET := trinket

QCOM_BOARD_PLATFORMS += \
    $(MSMSTEPPE) \
    $(TRINKET) \
    atoll \
    bengal \
    blair \
    crow \
    holi \
    kona \
    kalama \
    lahaina \
    lito \
    monaco \
    msm8937 \
    msm8953 \
    msm8996 \
    msm8998 \
    msmnile \
    parrot \
    pineapple \
    sdm660 \
    sdm710 \
    sdm845 \
    sun \
    taro \
    volcano

# List of targets that use video hardware.
MSM_VIDC_TARGET_LIST ?= \
    $(MSMSTEPPE) \
    $(TRINKET) \
    atoll \
    kona \
    lito \
    msm8937 \
    msm8953 \
    msm8996 \
    msm8998 \
    msmnile \
    sdm660 \
    sdm710 \
    sdm845

ifneq (,$(filter 3.18 4.4 4.9 4.14 4.19, $(TARGET_KERNEL_VERSION)))
# List of targets that use master side content protection.
MASTER_SIDE_CP_TARGET_LIST := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    atoll \
    bengal \
    kona \
    lito \
    msm8996 \
    msm8998 \
    msmnile \
    sdm660 \
    sdm710 \
    sdm845
endif

# Include QCOM board utilities.
ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
include vendor/qcom/opensource/core-utils/build/utils.mk
endif

# Kernel Families
6_6_FAMILY := \
    sun

6_1_FAMILY := \
    blair \
    pineapple \
    volcano

5_15_FAMILY := \
    crow \
    kalama \
    monaco

5_10_FAMILY := \
    parrot \
    taro

5_4_FAMILY := \
    holi \
    lahaina

4_19_FAMILY := \
    bengal \
    kona \
    lito

4_14_FAMILY := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    atoll \
    msmnile

4_9_FAMILY := \
    msm8953 \
    qcs605 \
    sdm710 \
    sdm845

4_4_FAMILY := \
    msm8998 \
    sdm660

3_18_FAMILY := \
    msm8937 \
    msm8996

ifeq ($(call is-board-platform-in-list,$(6_6_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 6.6
QCOM_HARDWARE_VARIANT := sm8750
else ifeq ($(call is-board-platform-in-list,$(6_1_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 6.1
QCOM_HARDWARE_VARIANT := sm8650
else ifeq ($(call is-board-platform-in-list,$(5_15_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 5.15
QCOM_HARDWARE_VARIANT := sm8550
else ifeq ($(call is-board-platform-in-list,$(5_10_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 5.10
QCOM_HARDWARE_VARIANT := sm8450
else ifeq ($(call is-board-platform-in-list,$(5_4_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 5.4
QCOM_HARDWARE_VARIANT := sm8350
else ifeq ($(call is-board-platform-in-list,$(4_19_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 4.19
QCOM_HARDWARE_VARIANT := sm8250
else ifeq ($(call is-board-platform-in-list,$(4_14_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 4.14
QCOM_HARDWARE_VARIANT := sm8150
else ifeq ($(call is-board-platform-in-list,$(4_9_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 4.9
QCOM_HARDWARE_VARIANT := sdm845
else ifeq ($(call is-board-platform-in-list,$(4_4_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 4.4
QCOM_HARDWARE_VARIANT := sdm660
else ifeq ($(call is-board-platform-in-list,$(3_18_FAMILY)),true)
TARGET_KERNEL_VERSION ?= 3.18
QCOM_HARDWARE_VARIANT := msm8996
else
QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM)
endif

# Pass board platform to kernel build
TARGET_KERNEL_ADDITIONAL_FLAGS += TARGET_BOARD_PLATFORM=$(TARGET_BOARD_PLATFORM)

# Allow a device to opt-out hardset of PRODUCT_SOONG_NAMESPACES
QCOM_SOONG_NAMESPACE ?= hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)
PRODUCT_SOONG_NAMESPACES += $(QCOM_SOONG_NAMESPACE)

# Add bootctrl to PRODUCT_SOONG_NAMESPACES
PRODUCT_SOONG_NAMESPACES += hardware/qcom/bootctrl

# Add display-commonsys to PRODUCT_SOONG_NAMESPACES
ifeq ($(call is-board-platform-in-list, $(4_9_FAMILY) $(4_14_FAMILY) $(4_19_FAMILY) $(5_4_FAMILY) $(5_10_FAMILY) $(5_15_FAMILY) $(6_1_FAMILY) $(6_6_FAMILY)),true)
    PRODUCT_SOONG_NAMESPACES += \
        vendor/qcom/opensource/commonsys/display \
        vendor/qcom/opensource/commonsys-intf/display

    ifneq ($(call is-board-platform-in-list, $(5_10_FAMILY) $(5_15_FAMILY) $(6_1_FAMILY) $(6_6_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += \
            vendor/qcom/opensource/display
    endif
    $(call soong_config_set,qtidisplay,headers_namespace,vendor/qcom/opensource/commonsys-intf/display)
else
    $(call soong_config_set,qtidisplay,headers_namespace,$(QCOM_SOONG_NAMESPACE)/display)
endif

# Add data-ipa-cfg-mgr to PRODUCT_SOONG_NAMESPACES if needed
ifneq ($(USE_DEVICE_SPECIFIC_DATA_IPA_CFG_MGR),true)
    ifeq ($(call is-board-platform-in-list, $(3_18_FAMILY) $(4_4_FAMILY) $(4_9_FAMILY) $(4_14_FAMILY) $(4_19_FAMILY) $(5_4_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/data-ipa-cfg-mgr-legacy-um
    else ifeq ($(call is-board-platform-in-list, $(5_10_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/sm8450/data-ipa-cfg-mgr
    else ifeq ($(call is-board-platform-in-list, $(5_15_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/sm8550/data-ipa-cfg-mgr
    else ifeq ($(call is-board-platform-in-list, $(6_1_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/sm8650/data-ipa-cfg-mgr
    else ifeq ($(call is-board-platform-in-list, $(6_6_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/sm8750/data-ipa-cfg-mgr
    endif
endif

# Add dataservices to PRODUCT_SOONG_NAMESPACES if needed
ifneq ($(USE_DEVICE_SPECIFIC_DATASERVICES),true)
    PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/dataservices
endif

# Add sound trigger HAL to PRODUCT_SOONG_NAMESPACES if needed
ifeq ($(BOARD_SUPPORTS_OPENSOURCE_STHAL),true)
    ifeq ($(call is-board-platform-in-list, $(3_18_FAMILY) $(4_4_FAMILY) $(4_9_FAMILY) $(4_14_FAMILY) $(4_19_FAMILY) $(5_4_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/audio-hal/st-hal
    else ifeq ($(call is-board-platform-in-list, $(5_10_FAMILY) $(5_15_FAMILY) $(6_1_FAMILY)),true)
        PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/audio-hal/st-hal-ar-legacy
        $(call soong_config_set,qtiaudio,legacy_headers_namespace,$(QCOM_SOONG_NAMESPACE))
        $(call soong_config_set,qtiaudio,legacy_libarpal_namespace,$(QCOM_SOONG_NAMESPACE))
    else
        PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/audio-hal/st-hal-ar
        $(call soong_config_set,qtiaudio,headers_namespace,$(QCOM_SOONG_NAMESPACE))
        $(call soong_config_set,qtiaudio,libarpal_namespace,$(QCOM_SOONG_NAMESPACE))
    endif
endif

# Add thermal HAL to PRODUCT_SOONG_NAMESPACES
ifeq ($(call is-board-platform-in-list, $(3_18_FAMILY) $(4_4_FAMILY) $(4_9_FAMILY) $(4_14_FAMILY) $(4_19_FAMILY) $(5_4_FAMILY)),true)
    PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/thermal-legacy-um
else
    PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/thermal
endif

# Disable thermal HAL netlink framework on platforms that do not support it
ifneq (,$(filter 3.18 4.4 4.9 4.14 4.19 5.4, $(TARGET_KERNEL_VERSION)))
$(call soong_config_set,qti_thermal,netlink,false)
endif

ifeq ($(call is-board-platform-in-list,$(QCOM_BOARD_PLATFORMS)),true)
ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
# Compatibility matrix
DEVICE_MATRIX_FILE += \
    device/qcom/vendor-common/compatibility_matrix.xml

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml

DEVICE_FRAMEWORK_MANIFEST_FILE += \
    device/qcom/qssi/framework_manifest.xml
endif

# Opt out of 16K alignment changes
PRODUCT_MAX_PAGE_SIZE_SUPPORTED ?= 4096

# Components
include $(QCOM_COMMON_PATH)/components.mk

# Filesystem
TARGET_FS_CONFIG_GEN += $(QCOM_COMMON_PATH)/config.fs
ifneq (,$(filter 3.18 4.4 4.9 4.14 4.19 5.4 5.10 5.15, $(TARGET_KERNEL_VERSION)))
TARGET_FS_CONFIG_GEN += $(QCOM_COMMON_PATH)/config.legacy.fs
endif

# GPS
PRODUCT_PACKAGES += \
    libcurl

# Media
TARGET_DYNAMIC_64_32_MEDIASERVER := true

# Partition source order for Product/Build properties pickup.
PRODUCT_SYSTEM_PROPERTIES += \
    ro.product.property_source_order=odm,vendor,product,system_ext,system

# Power
ifneq ($(TARGET_PROVIDES_POWERHAL),true)
$(call inherit-product-if-exists, vendor/qcom/opensource/power/power-vendor-product.mk)
endif

# Enable adpf cpu hint session for SurfaceFlinger and HWUI
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    debug.sf.enable_adpf_cpu_hint=true \
    debug.hwui.use_hint_manager=true

# Public Libraries
PRODUCT_COPY_FILES += \
    device/qcom/qssi/public.libraries.product-qti.txt:$(TARGET_COPY_OUT_PRODUCT)/etc/public.libraries-qti.txt \
    device/qcom/qssi/public.libraries.system_ext-qti.txt:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/public.libraries-qti.txt

# Permissions
PRODUCT_COPY_FILES += \
    device/qcom/qssi/privapp-permissions-qti.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-qti.xml \
    device/qcom/qssi/privapp-permissions-qti-system-ext.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-qti-system-ext.xml \
    device/qcom/qssi/qti_whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/qti_whitelist.xml \
    device/qcom/qssi/qti_whitelist_system_ext.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/qti_whitelist_system_ext.xml \
    device/qcom/qssi_64/qti_broadcast_whitelist.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/qti_broadcast_whitelist.xml

# QSPA
PRODUCT_PACKAGES += \
    qspa_system.rc \
    qspa_default.rc

# usbudev service for usb ip assigment
PRODUCT_PACKAGES += \
    usbudev

# Vendor Service Manager
PRODUCT_PACKAGES += \
    vndservicemanager

# SoC
PRODUCT_VENDOR_PROPERTIES += \
    ro.soc.manufacturer=QTI

# System Enable QCOM enhanced feature
PRODUCT_SYSTEM_PROPERTIES += \
    ro.vendor.qti.va_aosp.support=1

PRODUCT_ODM_PROPERTIES += \
    ro.vendor.qti.va_odm.support=1

# RFS APQ GNSS symlinks
PRODUCT_PACKAGES += \
    rfs_apq_gnss_hlos_symlink \
    rfs_apq_gnss_ramdumps_symlink \
    rfs_apq_gnss_readonly_firmware_symlink \
    rfs_apq_gnss_readonly_vendor_firmware_symlink \
    rfs_apq_gnss_readwrite_symlink \
    rfs_apq_gnss_shared_symlink

# RFS MDM ADSP symlinks
PRODUCT_PACKAGES += \
    rfs_mdm_adsp_hlos_symlink \
    rfs_mdm_adsp_ramdumps_symlink \
    rfs_mdm_adsp_readonly_firmware_symlink \
    rfs_mdm_adsp_readonly_vendor_firmware_symlink \
    rfs_mdm_adsp_readwrite_symlink \
    rfs_mdm_adsp_shared_symlink

# RFS MDM CDSP symlinks
PRODUCT_PACKAGES += \
    rfs_mdm_cdsp_hlos_symlink \
    rfs_mdm_cdsp_ramdumps_symlink \
    rfs_mdm_cdsp_readonly_firmware_symlink \
    rfs_mdm_cdsp_readonly_vendor_firmware_symlink \
    rfs_mdm_cdsp_readwrite_symlink \
    rfs_mdm_cdsp_shared_symlink

# RFS MDM MPSS symlinks
PRODUCT_PACKAGES += \
    rfs_mdm_mpss_hlos_symlink \
    rfs_mdm_mpss_ramdumps_symlink \
    rfs_mdm_mpss_readonly_firmware_symlink \
    rfs_mdm_mpss_readonly_vendor_firmware_symlink \
    rfs_mdm_mpss_readwrite_symlink \
    rfs_mdm_mpss_shared_symlink

# RFS MDM OIS symlinks
PRODUCT_PACKAGES += \
    rfs_mdm_ois_hlos_symlink \
    rfs_mdm_ois_ramdumps_symlink \
    rfs_mdm_ois_readonly_firmware_symlink \
    rfs_mdm_ois_readonly_vendor_firmware_symlink \
    rfs_mdm_ois_readwrite_symlink \
    rfs_mdm_ois_shared_symlink

# RFS MDM SLPI symlinks
PRODUCT_PACKAGES += \
    rfs_mdm_slpi_hlos_symlink \
    rfs_mdm_slpi_ramdumps_symlink \
    rfs_mdm_slpi_readonly_firmware_symlink \
    rfs_mdm_slpi_readonly_vendor_firmware_symlink \
    rfs_mdm_slpi_readwrite_symlink \
    rfs_mdm_slpi_shared_symlink

# RFS MDM TN symlinks
PRODUCT_PACKAGES += \
    rfs_mdm_tn_hlos_symlink \
    rfs_mdm_tn_ramdumps_symlink \
    rfs_mdm_tn_readonly_firmware_symlink \
    rfs_mdm_tn_readonly_vendor_firmware_symlink \
    rfs_mdm_tn_readwrite_symlink \
    rfs_mdm_tn_shared_symlink

# RFS MDM WPSS symlinks
PRODUCT_PACKAGES += \
    rfs_mdm_wpss_hlos_symlink \
    rfs_mdm_wpss_ramdumps_symlink \
    rfs_mdm_wpss_readonly_firmware_symlink \
    rfs_mdm_wpss_readonly_vendor_firmware_symlink \
    rfs_mdm_wpss_readwrite_symlink \
    rfs_mdm_wpss_shared_symlink

# RFS MSM ADSP symlinks
PRODUCT_PACKAGES += \
    rfs_msm_adsp_hlos_symlink \
    rfs_msm_adsp_ramdumps_symlink \
    rfs_msm_adsp_readonly_firmware_symlink \
    rfs_msm_adsp_readonly_vendor_firmware_symlink \
    rfs_msm_adsp_readwrite_symlink \
    rfs_msm_adsp_shared_symlink

# RFS MSM CDSP symlinks
PRODUCT_PACKAGES += \
    rfs_msm_cdsp_hlos_symlink \
    rfs_msm_cdsp_ramdumps_symlink \
    rfs_msm_cdsp_readonly_firmware_symlink \
    rfs_msm_cdsp_readonly_vendor_firmware_symlink \
    rfs_msm_cdsp_readwrite_symlink \
    rfs_msm_cdsp_shared_symlink

# RFS MSM MPSS symlinks
PRODUCT_PACKAGES += \
    rfs_msm_mpss_hlos_symlink \
    rfs_msm_mpss_ramdumps_symlink \
    rfs_msm_mpss_readonly_firmware_symlink \
    rfs_msm_mpss_readonly_vendor_firmware_symlink \
    rfs_msm_mpss_readwrite_symlink \
    rfs_msm_mpss_shared_symlink

# RFS MSM OIS symlinks
PRODUCT_PACKAGES += \
    rfs_msm_ois_hlos_symlink \
    rfs_msm_ois_ramdumps_symlink \
    rfs_msm_ois_readonly_firmware_symlink \
    rfs_msm_ois_readonly_vendor_firmware_symlink \
    rfs_msm_ois_readwrite_symlink \
    rfs_msm_ois_shared_symlink

# RFS MSM SLPI symlinks
PRODUCT_PACKAGES += \
    rfs_msm_slpi_hlos_symlink \
    rfs_msm_slpi_ramdumps_symlink \
    rfs_msm_slpi_readonly_firmware_symlink \
    rfs_msm_slpi_readonly_vendor_firmware_symlink \
    rfs_msm_slpi_readwrite_symlink \
    rfs_msm_slpi_shared_symlink

# RFS MSM WPSS symlinks
PRODUCT_PACKAGES += \
    rfs_msm_wpss_hlos_symlink \
    rfs_msm_wpss_ramdumps_symlink \
    rfs_msm_wpss_readonly_firmware_symlink \
    rfs_msm_wpss_readonly_vendor_firmware_symlink \
    rfs_msm_wpss_readwrite_symlink \
    rfs_msm_wpss_shared_symlink

# Add rfs to soong config namespaces
SOONG_CONFIG_NAMESPACES += rfs

# Add supported variables to rfs config
SOONG_CONFIG_rfs += \
    mpss_firmware_symlink_target

# Set default values for rfs config
SOONG_CONFIG_rfs_mpss_firmware_symlink_target ?= firmware_mnt

# Add wlan to PRODUCT_SOONG_NAMESPACES
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom/wlan \
    hardware/qcom/wlan/qcwcn

endif # QCOM_BOARD_PLATFORMS
