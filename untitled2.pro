QT += quick quickcontrols2 charts qml sql core-private core5compat

SOURCES += \
    Classes/analysismanager.cpp \
    Classes/articlemanager.cpp \
    Classes/checklistmanager.cpp \
    Classes/dailytip.cpp \
    Classes/databasemanager.cpp \
    Classes/dietmanager.cpp \
    Classes/fetalkickmanager.cpp \
    Classes/pregnancycalendarmanager.cpp \
    Classes/pregnancyprogress.cpp \
    Classes/pregnancyweek.cpp \
    Classes/productmanager.cpp \
    Classes/profile.cpp \
    Classes/tipmanager.cpp \
    Classes/weightmanager.cpp \
    main.cpp

HEADERS += \
    Classes/analysismanager.h \
    Classes/articlemanager.h \
    Classes/checklistmanager.h \
    Classes/dailytip.h \
    Classes/databasemanager.h \
    Classes/dietmanager.h \
    Classes/fetalkickmanager.h \
    Classes/pregnancycalendarmanager.h \
    Classes/pregnancyprogress.h \
    Classes/pregnancyweek.h \
    Classes/productmanager.h \
    Classes/profile.h \
    Classes/tipmanager.h \
    Classes/weightmanager.h

RESOURCES += qml.qrc

CONFIG += c++17

# QML files
DISTFILES += \
    Screens/AnalizeScreen.qml \
    Screens/Home.qml \
    Screens/MainScreen.qml \
    Screens/PersonalDataScreen.qml \
    Screens/PlanningScreen.qml \
    Screens/PregnantScreen.qml \
    Screens/SplashScreen.qml \
    Screens/WelcomeScreen.qml \
    components/AnalysisSection.qml \
    components/CustomButton.qml \
    components/CustomComboBox.qml \
    components/CustomTextField.qml \
    components/FloatingActionButton.qml \
    components/Footer.qml \
    components/FooterButton.qml \
    components/NoteEditor.qml

# Android specific configuration
android {
    #ANDROID_EXTRA_LIBS = $$[QT_INSTALL_PLUGINS]/sqldrivers/libqtsql_sqlite.so
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    ANDROID_MIN_SDK_VERSION = 21
    ANDROID_TARGET_SDK_VERSION = 33

    # Make sure these files exist in your android directory
    DISTFILES += \
        android/AndroidManifest.xml \
        android/build.gradle \
        android/res/values/libs.xml \
        android/res/xml/qtprovider_paths.xml
}

# For other platforms
!android {
    target.path = /opt/$${TARGET}/bin
    INSTALLS += target
}
