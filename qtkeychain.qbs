import qbs

Product
{
    name: "qtkeychain"
    type: buildStatic ? "staticlibrary" : "dynamiclibrary"
    targetName: "qtkeychain"

    property bool buildTranslations: false
    property bool buildStatic: false
    property bool libsecretSupport: false

    Depends { name: "cpp" }
    Depends { name: "Qt.core" }
    Depends { name: "Qt.dbus"; condition: qbs.targetOS.contains("linux") }
    Depends { name: "Quarks"; required: false }

    condition: !Quarks.present || Quarks.enabledQuarks.contains("qtkeychain")

    cpp.defines: [ buildStatic ? "QKEYCHAIN_STATICLIB" : "QKEYCHAIN_SHAREDLIB" ]

    cpp.includePaths:
    [
        "."
    ]

    Group
    {
        name: "Source"
        files:
        [
            "keychain.cpp",
            "keychain.h",
            "keychain_p.h",
            "qkeychain_export.h"
        ]
    }

    Group
    {
        condition: buildTranslations
        name: "Translations"
        files: [ "translations/*.ts" ]
    }

    Export
    {
        Depends { name: "cpp" }
        Depends { name: "Qt.core" }
        Depends { name: "Qt.dbus"; condition: qbs.targetOS.contains("linux") }

        cpp.includePaths:
        [
            "."
        ]
    }

    // linux support
    Group
    {
        condition: qbs.targetOS.contains("linux")
        name: "Linux Support"
        files:
        [
            "keychain_unix.cpp",
            "gnomekeyring.cpp",
            "gnomekeyring_p.h",
            "plaintextstore.cpp",
            "plaintextstore_p.h",
            "libsecret.cpp",
            "libsecret_p.h"
        ]
    }

    Group
    {
        condition: qbs.targetOS.contains("linux")
        name: "DBus interface generation"
        files: "org.kde.KWallet.xml"
        fileTags: ["qt.dbus.interface"]
    }

    // Libsecret support
    Properties
    {
        condition: qbs.targetOS.contains("linux") && libsecretSupport
        cpp.defines: outer.concat(["HAVE_LIBSECRET=1"])
    }

    // Windows configuration (defaults to use Windows Credential Store for Win7+)
    Properties
    {
        condition: qbs.targetOS.contains("windows")
        cpp.defines: outer.concat(["USE_CREDENTIAL_STORE=1"])
    }

    Group
    {
        condition: qbs.targetOS.contains("windows")
        name: "Windows Support"
        files:
        [
            "keychain_win.cpp",
            "plaintextstore.cpp",
            "plaintextstore_p.h"
        ]
    }

    // macOS / iOS configuration
    Properties
    {
        condition: qbs.targetOS.contains("macos") || qbs.targetOS.contains("ios")
        cpp.frameworks:
        [
            "Security",
            "Foundation"
        ]
    }

    Group
    {
        condition: qbs.targetOS.contains("macos")
        name: "macOS"
        files: ["keychain_mac.cpp"]
    }

    Group
    {
        condition: qbs.targetOS.contains("ios")
        name: "iOS"
        files: ["keychain_ios.mm"]
    }

    Group
    {
        fileTagsFilter: "dynamiclibrary"
        qbs.install: true
    }
}
