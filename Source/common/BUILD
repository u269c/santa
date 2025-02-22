load("@rules_cc//cc:defs.bzl", "cc_proto_library")
load("//:helper.bzl", "santa_unit_test")

package(
    default_visibility = ["//:santa_package_group"],
)

licenses(["notice"])

proto_library(
    name = "santa_proto",
    srcs = ["santa.proto"],
    deps = [
        "@com_google_protobuf//:any_proto",
        "@com_google_protobuf//:timestamp_proto",
    ],
)

cc_proto_library(
    name = "santa_cc_proto",
    deps = [":santa_proto"],
)

# Note: Simple wrapper for a `cc_proto_library` target which cannot be directly
# depended upon by an `objc_library` target.
cc_library(
    name = "santa_cc_proto_library_wrapper",
    hdrs = ["santa_proto_include_wrapper.h"],
    deps = [
        ":santa_cc_proto",
    ],
)

objc_library(
    name = "SystemResources",
    srcs = ["SystemResources.mm"],
    hdrs = ["SystemResources.h"],
    deps = [
        ":SNTLogging",
    ],
)

cc_library(
    name = "SantaCache",
    hdrs = ["SantaCache.h"],
    deps = [":BranchPrediction"],
)

santa_unit_test(
    name = "SantaCacheTest",
    srcs = ["SantaCacheTest.mm"],
    deps = [
        ":SantaCache",
    ],
)

objc_library(
    name = "BranchPrediction",
    hdrs = ["BranchPrediction.h"],
)

objc_library(
    name = "SantaVnode",
    hdrs = ["SantaVnode.h"],
)

objc_library(
    name = "Platform",
    hdrs = ["Platform.h"],
)

objc_library(
    name = "String",
    hdrs = ["String.h"],
)

objc_library(
    name = "SantaVnodeHash",
    srcs = ["SantaVnodeHash.mm"],
    hdrs = ["SantaVnodeHash.h"],
    deps = [
        ":SantaCache",
        ":SantaVnode",
    ],
)

objc_library(
    name = "CertificateHelpers",
    srcs = ["CertificateHelpers.m"],
    hdrs = ["CertificateHelpers.h"],
    deps = [
        "@MOLCertificate",
    ],
)

objc_library(
    name = "SNTBlockMessage",
    srcs = ["SNTBlockMessage.m"],
    hdrs = ["SNTBlockMessage.h"],
    deps = [
        ":SNTConfigurator",
        ":SNTFileAccessEvent",
        ":SNTLogging",
        ":SNTStoredEvent",
        ":SNTSystemInfo",
    ],
)

objc_library(
    name = "SNTBlockMessage_SantaGUI",
    srcs = ["SNTBlockMessage.m"],
    hdrs = ["SNTBlockMessage.h"],
    defines = ["SANTAGUI"],
    deps = [
        ":SNTConfigurator",
        ":SNTFileAccessEvent",
        ":SNTLogging",
        ":SNTStoredEvent",
        ":SNTSystemInfo",
    ],
)

objc_library(
    name = "SNTCachedDecision",
    srcs = ["SNTCachedDecision.mm"],
    hdrs = ["SNTCachedDecision.h"],
    deps = [
        ":SNTCommonEnums",
        ":SantaVnode",
    ],
)

objc_library(
    name = "SNTDeviceEvent",
    srcs = ["SNTDeviceEvent.m"],
    hdrs = ["SNTDeviceEvent.h"],
    module_name = "santa_common_SNTDeviceEvent",
    sdk_frameworks = [
        "Foundation",
    ],
    deps = [
        ":SNTCommonEnums",
    ],
)

objc_library(
    name = "SNTFileAccessEvent",
    srcs = ["SNTFileAccessEvent.m"],
    hdrs = ["SNTFileAccessEvent.h"],
    module_name = "santa_common_SNTFileAccessEvent",
    sdk_frameworks = [
        "Foundation",
    ],
    deps = [
        ":CertificateHelpers",
        "@MOLCertificate",
    ],
)

objc_library(
    name = "SNTCommonEnums",
    textual_hdrs = ["SNTCommonEnums.h"],
)

objc_library(
    name = "SNTConfigurator",
    srcs = ["SNTConfigurator.m"],
    hdrs = ["SNTConfigurator.h"],
    module_name = "santa_common_SNTConfigurator",
    sdk_frameworks = [
        "Foundation",
    ],
    deps = [
        ":SNTCommonEnums",
        ":SNTRule",
        ":SNTStrengthify",
        ":SNTSystemInfo",
    ],
)

objc_library(
    name = "SNTKVOManager",
    srcs = ["SNTKVOManager.mm"],
    hdrs = ["SNTKVOManager.h"],
    deps = [
        ":SNTLogging",
    ],
)

santa_unit_test(
    name = "SNTKVOManagerTest",
    srcs = ["SNTKVOManagerTest.mm"],
    deps = [
        ":SNTKVOManager",
    ],
)

objc_library(
    name = "SNTDropRootPrivs",
    srcs = ["SNTDropRootPrivs.m"],
    hdrs = ["SNTDropRootPrivs.h"],
)

objc_library(
    name = "SNTFileInfo",
    srcs = ["SNTFileInfo.m"],
    hdrs = ["SNTFileInfo.h"],
    deps = [
        ":SNTLogging",
        "@FMDB",
        "@MOLCodesignChecker",
    ],
)

objc_library(
    name = "SNTLogging",
    srcs = ["SNTLogging.m"],
    hdrs = ["SNTLogging.h"],
    deps = [":SNTConfigurator"],
)

objc_library(
    name = "PrefixTree",
    hdrs = ["PrefixTree.h"],
    deps = [
        ":SNTLogging",
        "@com_google_absl//absl/synchronization",
    ],
)

objc_library(
    name = "Unit",
    hdrs = ["Unit.h"],
)

objc_library(
    name = "SNTRule",
    srcs = ["SNTRule.m"],
    hdrs = ["SNTRule.h"],
    sdk_frameworks = [
        "Foundation",
    ],
    deps = [
        ":SNTCommonEnums",
        ":SNTSyncConstants",
    ],
)

santa_unit_test(
    name = "SNTRuleTest",
    srcs = ["SNTRuleTest.m"],
    deps = [
        ":SNTCommonEnums",
        ":SNTRule",
        ":SNTSyncConstants",
    ],
)

objc_library(
    name = "SNTStoredEvent",
    srcs = ["SNTStoredEvent.m"],
    hdrs = ["SNTStoredEvent.h"],
    deps = [
        ":SNTCommonEnums",
        "@MOLCertificate",
    ],
)

cc_library(
    name = "SNTStrengthify",
    hdrs = ["SNTStrengthify.h"],
)

objc_library(
    name = "SNTSyncConstants",
    srcs = ["SNTSyncConstants.m"],
    hdrs = ["SNTSyncConstants.h"],
    sdk_frameworks = [
        "Foundation",
    ],
)

objc_library(
    name = "SNTSystemInfo",
    srcs = ["SNTSystemInfo.m"],
    hdrs = ["SNTSystemInfo.h"],
    sdk_frameworks = [
        "Foundation",
        "IOKit",
    ],
)

objc_library(
    name = "SNTXPCBundleServiceInterface",
    srcs = ["SNTXPCBundleServiceInterface.m"],
    hdrs = ["SNTXPCBundleServiceInterface.h"],
    deps = [
        ":SNTStoredEvent",
        "@MOLXPCConnection",
    ],
)

objc_library(
    name = "SNTXPCMetricServiceInterface",
    srcs = ["SNTXPCMetricServiceInterface.m"],
    hdrs = ["SNTXPCMetricServiceInterface.h"],
    deps = [
        "@MOLXPCConnection",
    ],
)

objc_library(
    name = "SNTXPCControlInterface",
    srcs = ["SNTXPCControlInterface.m"],
    hdrs = ["SNTXPCControlInterface.h"],
    defines = select({
        "//:adhoc_build": ["SANTAADHOC"],
        "//conditions:default": None,
    }),
    deps = [
        ":SNTCommonEnums",
        ":SNTConfigurator",
        ":SNTRule",
        ":SNTStoredEvent",
        ":SNTXPCUnprivilegedControlInterface",
        "@MOLCodesignChecker",
        "@MOLXPCConnection",
    ],
)

objc_library(
    name = "SNTXPCNotifierInterface",
    srcs = ["SNTXPCNotifierInterface.m"],
    hdrs = ["SNTXPCNotifierInterface.h"],
    deps = [
        ":SNTCommonEnums",
        ":SNTXPCBundleServiceInterface",
    ],
)

objc_library(
    name = "SNTMetricSet",
    srcs = ["SNTMetricSet.m"],
    hdrs = ["SNTMetricSet.h"],
    deps = [":SNTCommonEnums"],
)

objc_library(
    name = "SNTXPCSyncServiceInterface",
    srcs = ["SNTXPCSyncServiceInterface.m"],
    hdrs = ["SNTXPCSyncServiceInterface.h"],
    deps = [
        ":SNTCommonEnums",
        ":SNTStoredEvent",
        "@MOLXPCConnection",
    ],
)

objc_library(
    name = "SNTXPCUnprivilegedControlInterface",
    srcs = ["SNTXPCUnprivilegedControlInterface.m"],
    hdrs = ["SNTXPCUnprivilegedControlInterface.h"],
    deps = [
        ":SNTCommonEnums",
        ":SNTRule",
        ":SNTStoredEvent",
        ":SNTXPCBundleServiceInterface",
        ":SantaVnode",
        "@MOLCertificate",
        "@MOLXPCConnection",
    ],
)

santa_unit_test(
    name = "SNTFileInfoTest",
    srcs = ["SNTFileInfoTest.m"],
    resources = [
        "testdata/32bitplist",
        "testdata/bad_pagezero",
        "testdata/missing_pagezero",
    ],
    structured_resources = glob([
        "testdata/BundleExample.app/**",
        "testdata/DirectoryBundle/**",
    ]),
    deps = [":SNTFileInfo"],
)

santa_unit_test(
    name = "PrefixTreeTest",
    srcs = ["PrefixTreeTest.mm"],
    deps = [":PrefixTree"],
)

santa_unit_test(
    name = "SNTMetricSetTest",
    srcs = ["SNTMetricSetTest.m"],
    deps = [":SNTMetricSet"],
)

santa_unit_test(
    name = "SNTCachedDecisionTest",
    srcs = ["SNTCachedDecisionTest.mm"],
    deps = [
        "//Source/common:SNTCachedDecision",
        "//Source/common:TestUtils",
        "@OCMock",
    ],
)

santa_unit_test(
    name = "SNTBlockMessageTest",
    srcs = ["SNTBlockMessageTest.m"],
    deps = [
        ":SNTBlockMessage",
        ":SNTConfigurator",
        ":SNTFileAccessEvent",
        ":SNTStoredEvent",
        ":SNTSystemInfo",
        "@OCMock",
    ],
)

test_suite(
    name = "unit_tests",
    tests = [
        ":PrefixTreeTest",
        ":SNTBlockMessageTest",
        ":SNTCachedDecisionTest",
        ":SNTFileInfoTest",
        ":SNTKVOManagerTest",
        ":SNTMetricSetTest",
        ":SNTRuleTest",
        ":SantaCacheTest",
    ],
    visibility = ["//:santa_package_group"],
)

objc_library(
    name = "TestUtils",
    testonly = 1,
    srcs = ["TestUtils.mm"],
    hdrs = ["TestUtils.h"],
    sdk_dylibs = [
        "bsm",
    ],
    deps = [
        ":SystemResources",
        "@OCMock",
        "@com_google_googletest//:gtest",
    ],
)
