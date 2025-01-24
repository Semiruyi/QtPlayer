cmake_minimum_required(VERSION 3.16)

project(QtPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)
set(FFMPEG_INCLUDE_DIR "./dependency/ffmpeg-7.1-full_build-shared/include")
set(FFMPEG_LIB_DIR "./dependency/ffmpeg-7.1-full_build-shared/lib")

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Sql)

# find_package(Qt6 REQUIRED COMPONENTS Sql)
# target_link_libraries(mytarget PRIVATE Qt6::Sql)

set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/resources/icons/AppIcon.rc")

if (MINGW)
    message("sldekfj;asdfkj")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -mwindows")
endif()

set(SOURCE_H
    ./src/cpp/PlayHistory/playhistory.h
    ./src/cpp/configobject/configobject.h
    ./src/cpp/mainpage/mainpageconfig.h
    ./src/cpp/config/playpageconfig.h
    ./src/cpp/config/globalconfig.h
    ./src/cpp/configobject/mylistmodel.h
    ./src/cpp/mainpage/playcardmodel.h
    ./src/cpp/utilities/logger/logger.h
    ./src/cpp/utilities/exception/myexception.h
    ./src/cpp/utilities/imageprovider/myimageprovider.h
    ./src/cpp/mainpage/videoprocesser.cpp src/cpp/mainpage/videoprocesser.h
    ./src/cpp/utilities/utilities.h
)

set(SOURCE_CPP
    ./src/cpp/PlayHistory/playhistory.cpp
    ./src/cpp/configobject/configobject.cpp
    ./src/cpp/configobject/mylistmodel.cpp
    ./src/cpp/mainpage/playcardmodel.cpp
    ./src/cpp/utilities/logger/logger.cpp
    ./src/cpp/utilities/exception/myexception.cpp
    ./src/cpp/utilities/imageprovider/myimageprovider.cpp
    ./src/cpp/utilities/utilities.cpp
)

set(SOURCES_QML
    src/qml/Main.qml
    src/qml/PlayPage/utils.js
    src/qml/PlayPage/VideoFooter.qml
    src/qml/PlayPage/PlayPage.qml
    src/qml/PlayPage/VideoBody.qml
    src/qml/PlayPage/EpisodeList.qml
    src/qml/PlayPage/VideoProgressBar.qml
    src/qml/PlayPage/PauseIcon.qml
    src/qml/PlayPage/VideoHeader.qml
    src/qml/MyComponents/MyCardView.qml
    src/qml/MyComponents/MyGridView.qml
    src/qml/MyComponents/ImageButton.qml
    src/qml/MyComponents/MyPopup.qml
    src/qml/MyComponents/MyMenu.qml
    src/qml/MyComponents/IconButton.qml
    src/qml/MyComponents/MyStackView.qml
    src/qml/MyComponents/MyImage.qml
    src/qml/MyComponents/NotificationView.qml
    src/qml/MyComponents/MyListView.qml
)

qt_standard_project_setup()

qt_add_executable(QtPlayer
    main.cpp
    Resources.qrc
    ${SOURCE_H}
    ${SOURCE_CPP}
    ${app_icon_resource_windows}
)

qt_add_qml_module(QtPlayer
    URI QtPlayer
    VERSION 1.0
    QML_FILES ${SOURCES_QML}
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

# # translation relative
# set(TS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/translation")

# set(TS_FILES
#     "${TS_DIR}/${PROJECT_NAME}_chinese.ts"
# )

# find_program(LUPDATE_EXECUTABLE lupdate)
# find_program(LRELEASE_EXECUTABLE lrelease)

# foreach(_chinese_file ${TS_FILES})

#     execute_process(
#         COMMAND ${LUPDATE_EXECUTABLE} -recursive ${CMAKE_SOURCE_DIR} -ts ${_chinese_file})
#     execute_process(
#         COMMAND ${LRELEASE_EXECUTABLE} ${_chinese_file})

# endforeach()
