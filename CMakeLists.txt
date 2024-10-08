cmake_minimum_required(VERSION 3.16)

project(QtPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Sql)

# find_package(Qt6 REQUIRED COMPONENTS Sql)
# target_link_libraries(mytarget PRIVATE Qt6::Sql)

qt_standard_project_setup()

qt_add_executable(appQtPlayer
    main.cpp
    Resources.qrc
    ./src/cpp/PlayHistory/playhistory.h
    ./src/cpp/PlayHistory/playhistory.cpp
)

set(SOURCES
    src/qml/Main.qml
    src/qml/PlayPage/IconButton.qml
    src/qml/PlayPage/utils.js
    src/qml/PlayPage/VideoFooter.qml
    src/qml/PlayPage/PlayPage.qml
    src/qml/PlayPage/VideoBody.qml
    src/qml/PlayPage/EpisodeList.qml
    src/qml/PlayPage/ProgressBar.qml
    src/qml/PlayPage/PauseIcon.qml
)

qt_add_qml_module(appQtPlayer
    URI QtPlayer
    VERSION 1.0
    QML_FILES ${SOURCES}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appQtPlayer PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appQtPlayer
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQtPlayer
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appQtPlayer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
