QT += quick quickcontrols2 charts qml sql

SOURCES += \
        Classes/backupmanager.cpp \
        Classes/databasehandler.cpp \
        Classes/pregnancydata.cpp \
        main.cpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += \
        qml.qrc \
        resources

CONFIG += c++17

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

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

HEADERS += \
    Classes/backupmanager.h \
    Classes/databasehandler.h \
    Classes/pregnancydata.h

