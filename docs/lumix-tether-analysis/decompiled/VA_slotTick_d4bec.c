// __ZN12VideoAdapter8slotTickEv @ 0x1000d4bec (imagebase-relative)
void __fastcall VideoAdapter::slotTick(VideoAdapter *this)
{
  std::recursive_mutex *v2; // x19
  double v3; // d0
  double v4; // d1
  double v5; // d2
  double v6; // d3
  __int64 v7; // x0
  void *v8; // x21
  const void *v9; // x22
  size_t v10; // x0
  _BYTE v11[24]; // [xsp+8h] [xbp-48h] BYREF
  _BYTE v12[8]; // [xsp+20h] [xbp-30h] BYREF
  __int64 v13; // [xsp+28h] [xbp-28h] BYREF

  if ( !*((_QWORD *)this + 2) )
    return;
  v2 = (std::recursive_mutex *)((char *)this + 48);
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 48));
  if ( !*((_QWORD *)this + 14) || !*((_QWORD *)this + 2) )
    goto LABEL_13;
  v3 = *((double *)this + 18);
  if ( *((double *)this + 22) == v3 )
  {
    v4 = *((double *)this + 19);
    if ( *((double *)this + 23) == v4
      && *((double *)this + 24) == *((double *)this + 20)
      && *((double *)this + 25) == *((double *)this + 21) )
    {
      goto LABEL_10;
    }
  }
  else
  {
    v4 = *((double *)this + 19);
  }
  *((double *)this + 22) = v3;
  *((double *)this + 23) = v4;
  v5 = *((double *)this + 20);
  v6 = *((double *)this + 21);
  *((double *)this + 24) = v5;
  *((double *)this + 25) = v6;
  VideoAdapter::paintSizeChanged(this, v3, v4, v5, v6);
LABEL_10:
  v13 = *(_QWORD *)((char *)this + 124);
  v7 = QVideoFrameFormat::pixelFormatFromImageFormat(*((unsigned int *)this + 34));
  QVideoFrameFormat::QVideoFrameFormat(v11, &v13, v7);
  QVideoFrame::QVideoFrame((QVideoFrame *)v12, (const QVideoFrameFormat *)v11);
  QVideoFrameFormat::~QVideoFrameFormat((QVideoFrameFormat *)v11);
  if ( (unsigned int)QVideoFrame::isValid((QVideoFrame *)v12) && (QVideoFrame::map(v12, 2) & 1) != 0 )
  {
    QImage::QImage(
      v11,
      *((_QWORD *)this + 14),
      *((unsigned int *)this + 31),
      *((unsigned int *)this + 32),
      *((int *)this + 33),
      *((unsigned int *)this + 34),
      0,
      0);
    v8 = (void *)QVideoFrame::bits((QVideoFrame *)v12, 0);
    v9 = (const void *)QImage::bits((QImage *)v11);
    v10 = QImage::sizeInBytes((QImage *)v11);
    memcpy(v8, v9, v10);
    QVideoFrame::unmap((QVideoFrame *)v12);
    QVideoSink::setVideoFrame(*((QVideoSink **)this + 2), (const QVideoFrame *)v12);
    QImage::~QImage((QImage *)v11);
    QVideoFrame::~QVideoFrame((QVideoFrame *)v12);
LABEL_13:
    std::recursive_mutex::unlock(v2);
    return;
  }
  std::recursive_mutex::unlock(v2);
  QVideoFrame::~QVideoFrame((QVideoFrame *)v12);
}
