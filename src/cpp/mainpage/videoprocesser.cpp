#include "videoprocesser.h"

VideoProcesser::VideoProcesser()
{

}

QImage VideoProcesser::getFrame(QString videoFilePath, long long position)
{
    qDebug() << "start with videoFilePath:" << videoFilePath << "position:" << position;


    const char *input_video = videoFilePath.toUtf8().constData();
    float time_seconds = position;
    const char *output_image = "cover.png";

    // 打开输入文件
    AVFormatContext *pFormatCtx = nullptr;
    if (avformat_open_input(&pFormatCtx, input_video, nullptr, nullptr) != 0)
    {
        QString errMsg = QString("Could not open input file: %1").arg(input_video);
        throw MyException(errMsg);
    }

    // 获取流信息
    if (avformat_find_stream_info(pFormatCtx, nullptr) < 0)
    {
        QString errMsg = QString("Could not find stream information");
        throw MyException(errMsg);
    }

    // 查找视频流
    int videoStream = -1;
    for (unsigned i = 0; i < pFormatCtx->nb_streams; i++)
    {
        if (pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO)
        {
            videoStream = i;
            break;
        }
    }
    if (videoStream == -1)
    {
        QString errMsg = QString("Could not find video stream");
        throw MyException(errMsg);
    }

    // 获取解码器参数
    AVCodecParameters *pCodecPar = pFormatCtx->streams[videoStream]->codecpar;
    const AVCodec *pCodec = avcodec_find_decoder(pCodecPar->codec_id);
    if (!pCodec)
    {
        QString errMsg = QString("Unsupported codec");
        throw MyException(errMsg);
    }

    // 打开解码器
    AVCodecContext *pCodecCtx = avcodec_alloc_context3(pCodec);
    avcodec_parameters_to_context(pCodecCtx, pCodecPar);
    if (avcodec_open2(pCodecCtx, pCodec, nullptr) < 0)
    {
        QString errMsg = QString("Could not open codec");
        throw MyException(errMsg);
    }

    // 创建帧和转换上下文
    AVFrame *pFrame = av_frame_alloc();
    AVFrame *pFrameRGB = av_frame_alloc();
    int numBytes = av_image_get_buffer_size(AV_PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height, 1);
    uint8_t *buffer = (uint8_t *)av_malloc(numBytes * sizeof(uint8_t));
    av_image_fill_arrays(pFrameRGB->data, pFrameRGB->linesize, buffer, AV_PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height, 1);

    SwsContext *swsCtx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
                                        pCodecCtx->width, pCodecCtx->height, AV_PIX_FMT_RGB24,
                                        SWS_BILINEAR, nullptr, nullptr, nullptr);

    // 查找指定时间点的帧
    AVPacket packet;
    int frameFinished = 0;
    int64_t seek_target = (int64_t)(time_seconds * AV_TIME_BASE);
    av_seek_frame(pFormatCtx, -1, seek_target, AVSEEK_FLAG_BACKWARD);
    QImage retImage;
    int findPackageCount = 1000;

    auto freeResource = [&]()
    {
        av_packet_unref(&packet);
        av_free(buffer);
        av_frame_free(&pFrameRGB);
        av_frame_free(&pFrame);
        avcodec_free_context(&pCodecCtx);
        avformat_close_input(&pFormatCtx);
    };

    while (av_read_frame(pFormatCtx, &packet) >= 0)
    {
        findPackageCount--;
        if(findPackageCount < 0)
        {
            freeResource();
            throw MyException("do not find video package");
        }
        if (packet.stream_index == videoStream)
        {
            // 发送 packet 到解码器
            int ret = avcodec_send_packet(pCodecCtx, &packet);
            if (ret < 0)
            {
                qDebug() << "Error sending packet to decoder";
                continue;
            }

            // 接收解码后的帧
            while (ret >= 0)
            {
                ret = avcodec_receive_frame(pCodecCtx, pFrame);
                if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
                {
                    continue;
                }
                else if (ret < 0)
                {
                    freeResource();
                    throw MyException("Error during decoding");
                }

                // 转换为 RGB 格式
                sws_scale(swsCtx, pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameRGB->data, pFrameRGB->linesize);


                int width = pCodecCtx->width;
                int height = pCodecCtx->height;
                retImage = QImage(pFrameRGB->data[0], pCodecCtx->width, pCodecCtx->height, pFrameRGB->linesize[0], QImage::Format_RGB888);

                qDebug() << "end with ret:" << retImage;

                QImage beforeFreeSaveImage = retImage.copy();

                freeResource();

                return beforeFreeSaveImage;
            }
        }
        av_packet_unref(&packet);
    }

    qDebug() << "end with ret:" << retImage;
    return retImage;
}

bool naturalCompare(const QFileInfo &file1, const QFileInfo &file2) {
    QString fileName1 = file1.baseName(); // 获取文件名（不含后缀）
    QString fileName2 = file2.baseName();

    if(fileName1.size() == fileName2.size())
    {
        return fileName1 < fileName2;
    }
    else
    {
        return fileName1.size() < fileName2.size();
    }

}

QStringList VideoProcesser::getVideoFiles(const QString &folderPath) {
    qDebug() << "start with folderPath:" << folderPath;
    QStringList videoFiles;

    // 如果路径是 file:/// 格式，转换为本地路径
    QString localPath = folderPath;
    if (folderPath.startsWith("file:///")) {
        QUrl url(folderPath);
        localPath = url.toLocalFile();
    }

    QDir dir(localPath);

    // 设置过滤器，只获取文件
    dir.setFilter(QDir::Files);

    // 定义视频文件的后缀
    QStringList videoFilters;
    videoFilters << "*.mp4" << "*.avi" << "*.mkv" << "*.mov" << "*.flv" << "*.wmv";

    // 获取符合条件的文件
    QFileInfoList fileList = dir.entryInfoList(videoFilters);

    // 对文件列表进行自然排序
    std::sort(fileList.begin(), fileList.end(), naturalCompare);

    // 遍历文件列表，获取文件路径
    for (const QFileInfo &fileInfo : fileList) {
        videoFiles.append(fileInfo.absoluteFilePath());
    }

    qDebug() << "end";

    return videoFiles;
}

QString VideoProcesser::qmlGetFrame(QString videoFilePath, long long position, bool isFolder)
{
    QString ret;
    qDebug() << "start with videoFilePath:" << videoFilePath << "position:" << position << "isFolder" << isFolder;
    // check parameters
    {
        if(isFolder)
        {
            QStringList videoFiles = getVideoFiles(videoFilePath);
            if(videoFiles.isEmpty())
            {
                qCritical() << "Do not exist any video file in this folder:" << videoFilePath;
                return "";
            }
            else
            {
                videoFilePath = videoFiles[0];
                qDebug() << "video file path is" << videoFilePath;
            }
        }

        if(!QFile::exists(videoFilePath))
        {
            qCritical() << "file" << videoFilePath << "do not exist!";
            return ret;
        }
        if(position < 0)
        {
            qCritical() << "postion" << position << "can not be negative!";
            return ret;
        }
    }

    // check if id exist
    {
        ret = m_myImageProvider->getImage(videoFilePath, position);
        if(ret != "")
        {
            qDebug() << "Image existed return ret:" << ret;
            return ret;
        }
    }

    // get a frame from video
    {
        try
        {
            QImage frame = getFrame(videoFilePath, position);

            m_myImageProvider->insert(videoFilePath, position, frame);

            ret = m_myImageProvider->getImage(videoFilePath, position);

            qDebug() << "ret is" << ret;
        }
        catch(MyException& e)
        {
            qCritical() << e.what();
        }
    }

    qDebug() << "end";

    return ret;

}
