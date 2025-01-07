cmake_minimum_required(VERSION 3.16)

project(QtPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)
set(FFMPEG_INCLUDE_DIR C:/y/project/ffmpeg/ffmpeg-7.1-full_build-shared/include)
set(FFMPEG_LIB_DIR C:/y/project/ffmpeg/ffmpeg-7.1-full_build-shared/lib)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Sql)

# find_package(Qt6 REQUIRED COMPONENTS Sql)
# target_link_libraries(mytarget PRIVATE Qt6::Sql)

set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/resources/icons/AppIcon.rc")

qt_standard_project_setup()

qt_add_executable(QtPlayer
    main.cpp
    Resources.qrc
    ./src/cpp/PlayHistory/playhistory.h
    ./src/cpp/PlayHistory/playhistory.cpp
    ${app_icon_resource_windows}
)

set(SOURCES
    src/qml/Main.qml

    src/qml/PlayPage/utils.js
    src/qml/PlayPage/VideoFooter.qml
    src/qml/PlayPage/PlayPage.qml
    src/qml/PlayPage/VideoBody.qml
    src/qml/PlayPage/EpisodeList.qml
    src/qml/PlayPage/VideoProgressBar.qml
    src/qml/PlayPage/PauseIcon.qml
    src/qml/MyComponents/MyCardView.qml
    src/qml/MyComponents/MyGridView.qml
)

qt_add_qml_module(QtPlayer
    URI QtPlayer
    VERSION 1.0
    QML_FILES ${SOURCES}
    SOURCES src/cpp/configobject/configobject.cpp src/cpp/configobject/configobject.h
    SOURCES src/cpp/mainpage/mainpageconfig.h
    SOURCES src/cpp/config/playpageconfig.h src/cpp/configobject/configobject.cpp src/cpp/configobject/configobject.h src/cpp/mainpage/mainpageconfig.h src/cpp/PlayHistory/playhistory.cpp src/cpp/PlayHistory/playhistory.h
    SOURCES src/cpp/config/globalconfig.h
    QML_FILES src/qml/MyComponents/ImageButton.qml
    QML_FILES src/qml/PlayPage/VideoHeader.qml
    QML_FILES src/qml/MyComponents/MyPopup.qml
    QML_FILES src/qml/MyComponents/MyMenu.qml
    SOURCES src/cpp/configobject/mylistmodel.cpp src/cpp/configobject/mylistmodel.h
    SOURCES src/cpp/mainpage/playcardmodel.cpp src/cpp/mainpage/playcardmodel.h
    QML_FILES src/qml/MyComponents/IconButton.qml
    SOURCES src/cpp/utilities/logger/logger.cpp src/cpp/utilities/logger/logger.h
    SOURCES src/cpp/utilities/exception/myexception.cpp src/cpp/utilities/exception/myexception.h
    SOURCES src/cpp/utilities/imageprovider/myimageprovider.cpp src/cpp/utilities/imageprovider/myimageprovider.h
    SOURCES src/cpp/mainpage/videoprocesser.cpp src/cpp/mainpage/videoprocesser.h
    QML_FILES src/qml/MyComponents/MyStackView.qml
    QML_FILES src/qml/MyComponents/MyImage.qml
    QML_FILES src/qml/MyComponents/NotificationView.qml
    QML_FILES src/qml/MyComponents/MyListView.qml
    SOURCES src/cpp/utilities/utilities.cpp src/cpp/utilities/utilities.h
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(QtPlayer PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appQtPlayer
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(QtPlayer
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Sql
)

target_include_directories(QtPlayer PRIVATE ${FFMPEG_INCLUDE_DIR})
target_link_directories(QtPlayer PRIVATE ${FFMPEG_LIB_DIR})

# 链接 FFmpeg 库
target_link_libraries(QtPlayer PRIVATE avutil avformat avcodec swscale)

include(GNUInstallDirs)
install(TARGETS QtPlayer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# translation relative
set(TS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/translation")

set(TS_FILES
    "${TS_DIR}/${PROJECT_NAME}_chinese.ts"
)

find_program(LUPDATE_EXECUTABLE lupdate)
find_program(LRELEASE_EXECUTABLE lrelease)

foreach(_chinese_file ${TS_FILES})

    execute_process(
        COMMAND ${LUPDATE_EXECUTABLE} -recursive ${CMAKE_SOURCE_DIR} -ts ${_chinese_file})
    execute_process(
        COMMAND ${LRELEASE_EXECUTABLE} ${_chinese_file})

endforeach()
