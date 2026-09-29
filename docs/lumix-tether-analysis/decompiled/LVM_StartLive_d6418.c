// __ZN15LiveViewManager9StartLiveEb @ 0x1000d6418 (imagebase-relative)
void __fastcall LiveViewManager::StartLive(LiveViewManager *this, char a2)
{
  int v4; // w20
  int v5; // w23
  unsigned __int64 v6; // x22
  unsigned __int64 v7; // x24
  int v8; // w28
  int v9; // w26
  int v10; // w25
  int v11; // w23
  int v12; // w24
  int v13; // w10
  __int64 v14; // x10
  unsigned __int64 v15; // x8
  unsigned __int64 v16; // x9
  __int64 v17; // x24
  __int64 v18; // x8
  std::string *v19; // x21
  std::string *v20; // x23
  signed __int64 v21; // x0
  unsigned __int64 v22; // x22
  void **v23; // x21
  void **v24; // x8
  void *v25; // x0
  void **v26; // x22
  int v27; // w22
  int v28; // w0
  __int64 v29; // x22
  __int64 v30; // x23
  __int64 v31; // x24
  __int64 v32; // x25
  __int64 v33; // x26
  __int64 v34; // x27
  __int64 v35; // x0
  char v36; // w0
  void **v37; // x19
  void **v38; // x8
  void *v39; // x0
  void **v40; // x20
  void **v41; // x19
  void **v42; // x8
  char *v43; // x0
  void **v44; // x20
  void **v45; // x19
  void **v46; // x8
  char *v47; // x0
  void **v48; // x20
  void **v49; // x19
  void **v50; // x8
  char *v51; // x0
  void **v52; // x20
  __int64 v53; // x22
  __int64 v54; // x23
  __int64 v55; // x24
  __int64 v56; // x25
  __int64 v57; // x26
  __int64 v58; // x27
  __int64 v59; // x0
  int v60; // [xsp+30h] [xbp-140h]
  int v61; // [xsp+38h] [xbp-138h]
  LiveViewManager *v62; // [xsp+48h] [xbp-128h] BYREF
  std::thread v63; // [xsp+50h] [xbp-120h] BYREF
  char v64[8]; // [xsp+58h] [xbp-118h] BYREF
  void *__p; // [xsp+60h] [xbp-110h] BYREF
  void **v66; // [xsp+68h] [xbp-108h]
  char *v67; // [xsp+70h] [xbp-100h] BYREF
  std::string __str; // [xsp+78h] [xbp-F8h] BYREF
  __int64 v69; // [xsp+90h] [xbp-E0h]
  unsigned int v70; // [xsp+98h] [xbp-D8h]
  unsigned int v71; // [xsp+9Ch] [xbp-D4h]
  int v72; // [xsp+A0h] [xbp-D0h]
  int v73; // [xsp+A4h] [xbp-CCh]
  char v74; // [xsp+A8h] [xbp-C8h]
  __int64 v75; // [xsp+ACh] [xbp-C4h]
  void *v76; // [xsp+B8h] [xbp-B8h] BYREF
  void **v77; // [xsp+C0h] [xbp-B0h]
  __int64 v78; // [xsp+C8h] [xbp-A8h]
  char *v79; // [xsp+D0h] [xbp-A0h] BYREF
  void **v80; // [xsp+D8h] [xbp-98h]
  __int64 v81; // [xsp+E0h] [xbp-90h]
  char *v82; // [xsp+E8h] [xbp-88h] BYREF
  void **v83; // [xsp+F0h] [xbp-80h]
  __int64 v84; // [xsp+F8h] [xbp-78h]
  char *v85; // [xsp+100h] [xbp-70h] BYREF
  void **v86; // [xsp+108h] [xbp-68h]
  __int64 v87; // [xsp+110h] [xbp-60h]

  if ( *((_QWORD *)this + 66) || *((_QWORD *)this + 67) || *((_QWORD *)this + 68) || *((_QWORD *)this + 69) )
    return;
  *((_BYTE *)this + 592) = 1;
  v85 = nullptr;
  v86 = nullptr;
  v87 = 0;
  v82 = nullptr;
  v83 = nullptr;
  v84 = 0;
  v79 = nullptr;
  v80 = nullptr;
  v81 = 0;
  v76 = nullptr;
  v77 = nullptr;
  v78 = 0;
  if ( *((_BYTE *)this + 880) )
  {
    v4 = 9;
    v5 = 6;
    LODWORD(v6) = 4;
    LODWORD(v7) = 12;
    switch ( *((_DWORD *)this + 221) )
    {
      case 1:
        goto LABEL_12;
      case 2:
        goto LABEL_10;
      case 3:
        goto LABEL_11;
      case 4:
        goto LABEL_9;
      case 5:
      case 6:
        goto LABEL_7;
      default:
        goto LABEL_13;
    }
  }
  v6 = 0x8E38E38E38E38E39LL * ((__int64)(*((_QWORD *)this + 35) - *((_QWORD *)this + 34)) >> 3);
  v5 = v6;
  v4 = v6;
  switch ( (int)v6 )
  {
    case 0:
      *((_DWORD *)this + 131) = 0;
      QImage::QImage(&__str, 640, 640, 5);
      sub_1000D54A4((char *)this + 568, &__str);
      QImage::~QImage((QImage *)&__str);
      LODWORD(v6) = 0;
      v10 = 0;
      goto LABEL_15;
    case 1:
LABEL_13:
      *((_DWORD *)this + 131) = 0;
      QImage::QImage(&__str, 1280, 960, 5);
      sub_1000D54A4((char *)this + 568, &__str);
      QImage::~QImage((QImage *)&__str);
      v10 = 0;
      LODWORD(v6) = 1;
LABEL_15:
      v9 = 1;
      v8 = 1;
      break;
    case 2:
LABEL_12:
      *((_DWORD *)this + 131) = 1;
      QImage::QImage(&__str, 1280, 480, 5);
      sub_1000D54A4((char *)this + 568, &__str);
      QImage::~QImage((QImage *)&__str);
      v8 = 1;
      LODWORD(v6) = 2;
      v10 = 2;
      v9 = 2;
      break;
    case 3:
    case 4:
LABEL_10:
      *((_DWORD *)this + 131) = 2;
      QImage::QImage(&__str, 1280, 960, 5);
      sub_1000D54A4((char *)this + 568, &__str);
      QImage::~QImage((QImage *)&__str);
      v10 = 2;
      v9 = 2;
      v8 = 2;
      break;
    case 5:
    case 6:
LABEL_11:
      *((_DWORD *)this + 131) = 3;
      QImage::QImage(&__str, 1280, 1080, 5);
      sub_1000D54A4((char *)this + 568, &__str);
      QImage::~QImage((QImage *)&__str);
      v8 = 3;
      v10 = 2;
      LODWORD(v6) = v5;
      v9 = 2;
      break;
    case 7:
    case 8:
    case 9:
LABEL_9:
      *((_DWORD *)this + 131) = 4;
      QImage::QImage(&__str, 1280, 720, 5);
      sub_1000D54A4((char *)this + 568, &__str);
      QImage::~QImage((QImage *)&__str);
      v9 = 3;
      v10 = 2;
      LODWORD(v6) = v4;
      v8 = 3;
      break;
    default:
      v7 = 0x8E38E38E38E38E39LL * ((__int64)(*((_QWORD *)this + 35) - *((_QWORD *)this + 34)) >> 3);
LABEL_7:
      *((_DWORD *)this + 131) = 5;
      QImage::QImage(&__str, 1280, 960, 5);
      sub_1000D54A4((char *)this + 568, &__str);
      QImage::~QImage((QImage *)&__str);
      v8 = 4;
      v9 = 3;
      v10 = 2;
      LODWORD(v6) = v7;
      break;
  }
  v11 = QImage::width((LiveViewManager *)((char *)this + 568));
  v12 = QImage::height((LiveViewManager *)((char *)this + 568));
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 144));
  v13 = *((_DWORD *)this + 131) - 1;
  if ( (unsigned int)v13 > 5 )
    v14 = 1;
  else
    v14 = qword_100148A88[v13];
  v15 = 0x8E38E38E38E38E39LL * ((__int64)(*((_QWORD *)this + 35) - *((_QWORD *)this + 34)) >> 3);
  if ( *((_BYTE *)this + 880) )
  {
    v16 = *((int *)this + 222) * (__int64)(int)v6;
    if ( v15 >= v16 + (int)v6 )
      v15 = v16 + (int)v6;
  }
  else
  {
    v16 = 0;
  }
  if ( v16 < v15 )
  {
    v61 = v12 / v8;
    v60 = v12 / v8 - 2 * v10;
    v17 = 72 * v16;
    if ( v14 )
    {
      memset(&__str, 0, sizeof(__str));
      v70 = v10 + v11 / v9 * (0u % v9);
      v71 = v10 + v61 * (0u / v9);
      v72 = v11 / v9 - 2 * v10;
      v73 = v60;
      std::string::operator=(&__str, (const std::string *)(*((_QWORD *)this + 34) + v17));
      v18 = *((_QWORD *)this + 34) + v17;
      v69 = *(_QWORD *)(v18 + 32);
      v75 = *(_QWORD *)(v18 + 60);
      v74 = *(_BYTE *)(v18 + 56);
      __asm { BR              X9 }
    }
  }
  if ( (a2 & 1) == 0 )
  {
    __p = nullptr;
    v66 = nullptr;
    v67 = nullptr;
    v20 = *((std::string **)this + 34);
    v19 = *((std::string **)this + 35);
    v21 = (char *)v19 - (char *)v20;
    if ( v19 != v20 )
    {
      v22 = 0x8E38E38E38E38E39LL * (v21 >> 3);
      if ( v22 >= 0x38E38E38E38E38FLL )
        sub_1000AA1F4(&__p);
      __p = operator new(v21);
      v67 = (char *)__p + 72 * v22;
      v66 = (void **)sub_1000AA208((int)&v67, v20, (int)v19, (std::string *)__p);
    }
    LiveViewManager::MultiCmd_Start(this, &__p);
    v23 = (void **)__p;
    if ( __p )
    {
      v24 = v66;
      if ( v66 == __p )
      {
        v25 = __p;
      }
      else
      {
        do
        {
          v26 = v24 - 9;
          if ( *((char *)v24 - 49) < 0 )
            operator delete(*(v24 - 9));
          v24 = v26;
        }
        while ( v26 != v23 );
        v25 = __p;
      }
      v66 = v23;
      operator delete(v25);
    }
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 144));
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 80));
  QPainter::QPainter((QPainter *)v64);
  QPainter::begin((QPainter *)v64, (LiveViewManager *)((char *)this + 568));
  if ( *((_QWORD *)this + 35) == *((_QWORD *)this + 34) )
  {
    QBrush::QBrush(&__str, 2, 1);
    QPainter::setBrush((QPainter *)v64, (const QBrush *)&__str);
    QBrush::~QBrush((QBrush *)&__str);
    QColor::QColor(&__str, 2);
  }
  else
  {
    QBrush::QBrush(&__str, 4, 1);
    QPainter::setBrush((QPainter *)v64, (const QBrush *)&__str);
    QBrush::~QBrush((QBrush *)&__str);
    QColor::QColor(&__str, 4);
  }
  QPainter::setPen((QPainter *)v64, (const QColor *)&__str);
  v27 = QImage::width((LiveViewManager *)((char *)this + 568));
  v28 = QImage::height((LiveViewManager *)((char *)this + 568));
  __str.__r_.__value_.__r.__words[0] = 0;
  LODWORD(__str.__r_.__value_.__r.__words[1]) = v27 - 1;
  HIDWORD(__str.__r_.__value_.__r.__words[1]) = v28 - 1;
  QPainter::drawRects(v64, &__str, 1);
  QPainter::end((QPainter *)v64);
  v29 = *((_QWORD *)this + 52);
  v30 = QImage::bits((LiveViewManager *)((char *)this + 568));
  v31 = QImage::sizeInBytes((LiveViewManager *)((char *)this + 568));
  v32 = QImage::width((LiveViewManager *)((char *)this + 568));
  v33 = QImage::height((LiveViewManager *)((char *)this + 568));
  v34 = QImage::bytesPerLine((LiveViewManager *)((char *)this + 568));
  v35 = QImage::format((LiveViewManager *)((char *)this + 568));
  v36 = VideoAdapter::SetImage(v29, v30, v31, v32, v33, v34, v35);
  if ( *((_QWORD *)this + 35) == *((_QWORD *)this + 34) )
  {
    while ( (v36 & 1) == 0 && (VideoAdapter::getVideoOutVisibleStatus(*((VideoAdapter **)this + 52)) & 1) != 0 )
    {
      __str.__r_.__value_.__r.__words[0] = 30000000;
      std::this_thread::sleep_for((const std::chrono::nanoseconds *)&__str);
      v53 = *((_QWORD *)this + 52);
      v54 = QImage::bits((LiveViewManager *)((char *)this + 568));
      v55 = QImage::sizeInBytes((LiveViewManager *)((char *)this + 568));
      v56 = QImage::width((LiveViewManager *)((char *)this + 568));
      v57 = QImage::height((LiveViewManager *)((char *)this + 568));
      v58 = QImage::bytesPerLine((LiveViewManager *)((char *)this + 568));
      v59 = QImage::format((LiveViewManager *)((char *)this + 568));
      v36 = VideoAdapter::SetImage(v53, v54, v55, v56, v57, v58, v59);
    }
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 80));
  if ( *((double *)this + 95) != 0.0
    || *((double *)this + 96) != 0.0
    || *((double *)this + 97) != 0.0
    || *((double *)this + 98) != 0.0 )
  {
    *(_OWORD *)((char *)this + 760) = 0u;
    *(_OWORD *)((char *)this + 776) = 0u;
    LiveViewManager::selctedPaintSizeChanged(this, *((_DWORD *)this + 131) != 0, 0.0, 0.0, 0.0, 0.0);
  }
  atomic_store(0, (unsigned __int8 *)this + 560);
  if ( v86 != (void **)v85 )
  {
    *(_OWORD *)&__str.__r_.__value_.__l.__data_ = (unsigned __int64)LiveViewManager::LiveGetThreadFunc;
    v62 = this;
    sub_1000D966C(&v63, &__str, &v62, &v85);
    if ( *((_QWORD *)this + 66) )
      goto LABEL_97;
    *((std::thread *)this + 66) = v63;
    v63.__t_ = nullptr;
    std::thread::~thread(&v63);
  }
  if ( v83 != (void **)v82 )
  {
    *(_OWORD *)&__str.__r_.__value_.__l.__data_ = (unsigned __int64)LiveViewManager::LiveGetThreadFunc;
    v62 = this;
    sub_1000D966C(&v63, &__str, &v62, &v82);
    if ( *((_QWORD *)this + 67) )
      goto LABEL_97;
    *((std::thread *)this + 67) = v63;
    v63.__t_ = nullptr;
    std::thread::~thread(&v63);
  }
  if ( v80 != (void **)v79 )
  {
    *(_OWORD *)&__str.__r_.__value_.__l.__data_ = (unsigned __int64)LiveViewManager::LiveGetThreadFunc;
    v62 = this;
    sub_1000D966C(&v63, &__str, &v62, &v79);
    if ( *((_QWORD *)this + 68) )
      goto LABEL_97;
    *((std::thread *)this + 68) = v63;
    v63.__t_ = nullptr;
    std::thread::~thread(&v63);
  }
  if ( v77 != v76 )
  {
    *(_OWORD *)&__str.__r_.__value_.__l.__data_ = (unsigned __int64)LiveViewManager::LiveGetThreadFunc;
    v62 = this;
    sub_1000D966C(&v63, &__str, &v62, &v76);
    if ( !*((_QWORD *)this + 69) )
    {
      *((std::thread *)this + 69) = v63;
      v63.__t_ = nullptr;
      std::thread::~thread(&v63);
      goto LABEL_60;
    }
LABEL_97:
    std::terminate();
  }
LABEL_60:
  QPainter::~QPainter((QPainter *)v64);
  v37 = (void **)v76;
  if ( v76 )
  {
    v38 = v77;
    if ( v77 == v76 )
    {
      v39 = v76;
    }
    else
    {
      do
      {
        v40 = v38 - 8;
        if ( *((char *)v38 - 41) < 0 )
          operator delete(*(v38 - 8));
        v38 = v40;
      }
      while ( v40 != v37 );
      v39 = v76;
    }
    v77 = v37;
    operator delete(v39);
  }
  v41 = (void **)v79;
  if ( v79 )
  {
    v42 = v80;
    if ( v80 == (void **)v79 )
    {
      v43 = v79;
    }
    else
    {
      do
      {
        v44 = v42 - 8;
        if ( *((char *)v42 - 41) < 0 )
          operator delete(*(v42 - 8));
        v42 = v44;
      }
      while ( v44 != v41 );
      v43 = v79;
    }
    v80 = v41;
    operator delete(v43);
  }
  v45 = (void **)v82;
  if ( v82 )
  {
    v46 = v83;
    if ( v83 == (void **)v82 )
    {
      v47 = v82;
    }
    else
    {
      do
      {
        v48 = v46 - 8;
        if ( *((char *)v46 - 41) < 0 )
          operator delete(*(v46 - 8));
        v46 = v48;
      }
      while ( v48 != v45 );
      v47 = v82;
    }
    v83 = v45;
    operator delete(v47);
  }
  v49 = (void **)v85;
  if ( v85 )
  {
    v50 = v86;
    if ( v86 == (void **)v85 )
    {
      v51 = v85;
    }
    else
    {
      do
      {
        v52 = v50 - 8;
        if ( *((char *)v50 - 41) < 0 )
          operator delete(*(v50 - 8));
        v50 = v52;
      }
      while ( v52 != v49 );
      v51 = v85;
    }
    v86 = v49;
    operator delete(v51);
  }
}
