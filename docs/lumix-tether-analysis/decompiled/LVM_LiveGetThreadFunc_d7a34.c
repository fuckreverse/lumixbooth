// __ZN15LiveViewManager17LiveGetThreadFuncENSt3__16vectorI16_MULTIVIEW_PARAMNS0_9allocatorIS2_EEEE @ 0x1000d7a34 (imagebase-relative)
void __fastcall LiveViewManager::LiveGetThreadFunc(__int64 a1, __int64 *a2)
{
  unsigned __int8 v4; // w8
  std::chrono::duration<long long, std::ratio<1, 1000000000>>::rep v5; // x8
  unsigned __int8 v6; // w8
  __int64 v7; // x8
  unsigned __int64 v8; // x25
  double v9; // d9
  double v10; // d8
  double v11; // d10
  double v12; // d11
  __int64 v13; // x8
  atomic_ullong *v14; // x21
  unsigned int v15; // w23
  unsigned int v16; // w28
  __int64 v17; // x26
  int v18; // w21
  int v19; // w27
  unsigned int v20; // w22
  unsigned int v21; // w24
  int v22; // w9
  __int64 v23; // x27
  __int64 v24; // x28
  int v25; // w21
  int v26; // w24
  unsigned __int64 v27; // x10
  __int64 v28; // x9
  size_t v29; // x2
  __int64 v30; // x11
  int v31; // w12
  const void *v32; // x0
  unsigned __int8 *v33; // x1
  __int64 v34; // x9
  unsigned __int8 *v35; // x8
  unsigned __int8 *v36; // x10
  int v37; // w11
  int v38; // t1
  int v39; // t1
  __int64 v40; // x8
  unsigned __int64 v41; // x8
  const char *v42; // x3
  __int64 v43; // x8
  _DWORD *v44; // x8
  unsigned int v45; // w26
  unsigned int v46; // w27
  unsigned int v47; // w21
  unsigned int v48; // w22
  __int64 v49; // x0
  unsigned __int64 v50; // x8
  __int64 v51; // x8
  __int64 v52; // x9
  int v53; // w8
  int v54; // w24
  int v55; // w8
  int v56; // w28
  __int64 v57; // x26
  __int64 v58; // x27
  int v59; // w23
  int v60; // w28
  int v61; // w24
  int v62; // w21
  __int64 v63; // x22
  __int64 v64; // x0
  unsigned __int64 v65; // x10
  __int64 v66; // x9
  size_t v67; // x2
  __int64 v68; // x11
  int v69; // w12
  const void *v70; // x0
  unsigned __int8 *v71; // x1
  __int64 v72; // x9
  unsigned __int8 *v73; // x8
  unsigned __int8 *v74; // x10
  int v75; // w11
  int v76; // t1
  int v77; // t1
  __int128 v78; // q1
  __int128 v79; // q1
  unsigned __int16 v80; // w1
  __int16 v81; // w1
  __int16 v82; // w1
  VideoAdapter *v83; // x0
  double v84; // d0
  double v85; // d1
  double v86; // d2
  double v87; // d3
  __int64 v88; // x21
  __int64 v89; // x22
  __int64 v90; // x24
  __int64 v91; // x25
  __int64 v92; // x26
  __int64 v93; // x27
  __int64 v94; // x0
  __int64 v95; // x0
  int64x2_t v96; // [xsp+30h] [xbp-1E0h]
  std::recursive_mutex *v97; // [xsp+48h] [xbp-1C8h]
  char v98; // [xsp+54h] [xbp-1BCh]
  unsigned __int8 **v99; // [xsp+58h] [xbp-1B8h]
  QImage *v100; // [xsp+60h] [xbp-1B0h]
  std::recursive_mutex *v101; // [xsp+68h] [xbp-1A8h]
  QPaintDevice *v102; // [xsp+70h] [xbp-1A0h]
  std::string v103; // [xsp+78h] [xbp-198h] BYREF
  std::string v104; // [xsp+90h] [xbp-180h] BYREF
  char v105[8]; // [xsp+A8h] [xbp-168h] BYREF
  double v106; // [xsp+B0h] [xbp-160h] BYREF
  double v107; // [xsp+B8h] [xbp-158h]
  __int64 v108; // [xsp+C0h] [xbp-150h]
  _QWORD v109[3]; // [xsp+C8h] [xbp-148h] BYREF
  int64x2_t v110; // [xsp+E0h] [xbp-130h] BYREF
  int v111; // [xsp+FCh] [xbp-114h] BYREF
  int v112; // [xsp+100h] [xbp-110h] BYREF
  int v113; // [xsp+104h] [xbp-10Ch] BYREF
  unsigned __int16 v114[2]; // [xsp+108h] [xbp-108h] BYREF
  int v115; // [xsp+10Ch] [xbp-104h] BYREF
  int v116; // [xsp+110h] [xbp-100h] BYREF
  unsigned int v117; // [xsp+114h] [xbp-FCh] BYREF
  std::chrono::nanoseconds __ns; // [xsp+118h] [xbp-F8h] BYREF
  int v119; // [xsp+120h] [xbp-F0h]
  int v120; // [xsp+124h] [xbp-ECh]
  __int64 v121; // [xsp+128h] [xbp-E8h]
  _QWORD v122[11]; // [xsp+130h] [xbp-E0h] BYREF

  v100 = (QImage *)operator new[](0x100000u);
  v117 = 0x100000;
  memset(v122, 0, 76);
  v115 = 76;
  v114[0] = 0;
  v113 = 2;
  v111 = 4;
  v112 = 0;
  v4 = atomic_load((unsigned __int8 *)(a1 + 560));
  if ( (v4 & 1) == 0 )
  {
    v101 = (std::recursive_mutex *)(a1 + 80);
    v102 = (QPaintDevice *)(a1 + 568);
    v99 = (unsigned __int8 **)(a1 + 344);
    v97 = (std::recursive_mutex *)(a1 + 616);
    v96 = vdupq_n_s64(0x8000000000000000LL);
    do
    {
      v110 = v96;
      QElapsedTimer::start((QElapsedTimer *)&v110);
      v7 = *a2;
      if ( a2[1] != *a2 )
      {
        v98 = 0;
        v8 = 0;
        v9 = 0.0;
        v10 = 0.0;
        v11 = 0.0;
        v12 = 0.0;
        while ( 1 )
        {
          v13 = v7 + (v8 << 6);
          v14 = *(atomic_ullong **)(v13 + 24);
          v117 = 0x100000;
          if ( *(_BYTE *)(v13 + 48) )
            break;
          v40 = 0;
          atomic_compare_exchange_strong_explicit(
            v14,
            (unsigned __int64 *)&v40,
            1u,
            memory_order_acquire,
            memory_order_acquire);
          if ( v40 )
            QBasicMutex::lockInternal((QBasicMutex *)v14);
          v41 = *a2 + (v8 << 6);
          if ( *(char *)(v41 + 23) < 0 )
            v41 = *(_QWORD *)v41;
          LMX_func_api_Get_LiveView_data(v122, &v115, v114, &v113, &v112, &v111, v100, &v117, v41, &v116);
          v43 = 1;
          atomic_compare_exchange_strong_explicit(
            v14,
            (unsigned __int64 *)&v43,
            0,
            memory_order_release,
            memory_order_relaxed);
          if ( v43 != 1 )
            QBasicMutex::unlockInternal((QBasicMutex *)v14);
          if ( v116 == 262148 )
          {
            v98 = 1;
          }
          else if ( !v116 )
          {
            v44 = (_DWORD *)(*a2 + (v8 << 6));
            v46 = v44[10];
            v45 = v44[11];
            v47 = v44[8];
            v48 = v44[9];
            QImage::fromData(v109, v100, (const unsigned __int8 *)v117, (int)"JPG", v42);
            if ( *(_QWORD *)(a1 + 416) && (QImage::isNull((QImage *)v109) & 1) == 0 )
            {
              if ( !*(_DWORD *)(a1 + 524)
                && (v46 != (unsigned int)QImage::width((QImage *)v109)
                 || v45 != (unsigned int)QImage::height((QImage *)v109)) )
              {
                *(_DWORD *)(*a2 + (v8 << 6) + 40) = QImage::width((QImage *)v109);
                v49 = QImage::height((QImage *)v109);
                v45 = v49;
                v50 = *a2 + (v8 << 6);
                *(_DWORD *)(v50 + 44) = v49;
                v46 = *(_DWORD *)(v50 + 40);
                QImage::QImage(&v106, v46, v49, 5);
                QPaintDevice::QPaintDevice((QPaintDevice *)&__ns);
                v51 = v108;
                v108 = 0;
                v52 = *(_QWORD *)(a1 + 584);
                *(_QWORD *)(a1 + 584) = v51;
                __ns.__rep_ = (std::chrono::duration<long long, std::ratio<1, 1000000000>>::rep)&`vtable for'QImage + 16;
                v121 = v52;
                QImage::~QImage((QImage *)&__ns);
                QImage::~QImage((QImage *)&v106);
              }
              v106 = COERCE_DOUBLE(__PAIR64__(v45, v46));
              QImage::scaled(&__ns, v109, &v106, 1, 0);
              v53 = v46 - QImage::width((QImage *)&__ns);
              if ( v53 >= 0 )
                v54 = v53;
              else
                v54 = v53 + 1;
              v55 = v45 - QImage::height((QImage *)&__ns);
              if ( v55 >= 0 )
                v56 = v55;
              else
                v56 = v55 + 1;
              std::recursive_mutex::lock(v101);
              QPainter::QPainter((QPainter *)v105);
              QPainter::begin((QPainter *)v105, v102);
              QBrush::QBrush(&v106, 4, 1);
              QPainter::setBrush((QPainter *)v105, (const QBrush *)&v106);
              QBrush::~QBrush((QBrush *)&v106);
              QColor::QColor(&v106, 4);
              QPainter::setPen((QPainter *)v105, (const QColor *)&v106);
              v106 = COERCE_DOUBLE(__PAIR64__(v48, v47));
              LODWORD(v107) = v47 + v46 - 1;
              HIDWORD(v107) = v48 + v45 - 1;
              QPainter::drawRects(v105, &v106, 1);
              v57 = (v54 >> 1) + v47;
              v58 = (v56 >> 1) + v48;
              v106 = (double)(int)v57;
              v107 = (double)(int)v58;
              QPainter::drawImage(v105, &v106, &__ns);
              QPainter::end((QPainter *)v105);
              std::recursive_mutex::unlock(v101);
              v10 = 0.0;
              v9 = 0.0;
              if ( (int)v57 >= 1 )
                v9 = (double)(int)v57 / (double)(int)QImage::width(v102);
              if ( (int)v58 >= 1 )
                v10 = (double)(int)v58 / (double)(int)QImage::height(v102);
              v59 = QImage::width((QImage *)&__ns);
              v60 = QImage::height((QImage *)&__ns);
              v61 = QImage::width(v102);
              v62 = QImage::height(v102);
              std::string::basic_string(&v104, (const std::string *)(*a2 + (v8 << 6)));
              v63 = QImage::width((QImage *)&__ns);
              v64 = QImage::height((QImage *)&__ns);
              LiveViewManager::SetPaintSize(a1, &v104, v57, v58, v63, v64);
              if ( SHIBYTE(v104.__r_.__value_.__r.__words[2]) < 0 )
                operator delete(v104.__r_.__value_.__l.__data_);
              v11 = (double)v59 / (double)v61;
              v12 = (double)v60 / (double)v62;
              QPainter::~QPainter((QPainter *)v105);
              QImage::~QImage((QImage *)&__ns);
            }
            v65 = *a2 + (v8 << 6);
            v66 = *(unsigned __int8 *)(v65 + 23);
            if ( (v66 & 0x80u) == 0LL )
              v67 = *(unsigned __int8 *)(v65 + 23);
            else
              v67 = *(_QWORD *)(v65 + 8);
            v68 = *(unsigned __int8 *)(a1 + 367);
            v69 = (char)v68;
            if ( (v68 & 0x80u) != 0LL )
              v68 = *(_QWORD *)(a1 + 352);
            if ( v67 == v68 )
            {
              if ( (v66 & 0x80u) == 0LL )
                v70 = (const void *)(*a2 + (v8 << 6));
              else
                v70 = *(const void **)v65;
              if ( v69 >= 0 )
                v71 = (unsigned __int8 *)(a1 + 344);
              else
                v71 = *v99;
              if ( (v66 & 0x80) != 0 )
              {
                if ( !v67 || !memcmp(v70, v71, v67) )
                  goto LABEL_105;
              }
              else
              {
                if ( !v67 )
                  goto LABEL_105;
                if ( *v71 == (unsigned __int8)*(_QWORD *)v65 )
                {
                  v72 = v66 - 1;
                  v73 = (unsigned __int8 *)(*a2 + (v8 << 6) + 1);
                  v74 = v71 + 1;
                  while ( v72 )
                  {
                    v76 = *v73++;
                    v75 = v76;
                    v77 = *v74++;
                    --v72;
                    if ( v75 != v77 )
                      goto LABEL_114;
                  }
LABEL_105:
                  std::recursive_mutex::lock(v97);
                  *(_QWORD *)(a1 + 680) = v122[0];
                  *(_DWORD *)(a1 + 688) = v122[1];
                  v78 = *(_OWORD *)(((unsigned __int64)v122 | 0xC) + 0x10);
                  *(_OWORD *)(a1 + 692) = *(_OWORD *)((unsigned __int64)v122 | 0xC);
                  *(_OWORD *)(a1 + 708) = v78;
                  v79 = *(_OWORD *)(((unsigned __int64)v122 | 0xC) + 0x30);
                  *(_OWORD *)(a1 + 724) = *(_OWORD *)(((unsigned __int64)v122 | 0xC) + 0x20);
                  *(_OWORD *)(a1 + 740) = v79;
                  *(_DWORD *)(a1 + 756) = v115;
                  std::recursive_mutex::unlock(v97);
                  if ( v113 )
                  {
                    v80 = v114[0];
                    *(_WORD *)(a1 + 608) = v114[0];
                    LiveViewManager::postureChanged((LiveViewManager *)a1, v80);
                  }
                  if ( v111 )
                  {
                    v81 = HIWORD(v112);
                    *(_WORD *)(a1 + 612) = HIWORD(v112);
                    LiveViewManager::pitchChanged((LiveViewManager *)a1, v81);
                    v82 = v112;
                    *(_WORD *)(a1 + 610) = v112;
                    LiveViewManager::rollChanged((LiveViewManager *)a1, v82);
                  }
                  if ( *(double *)(a1 + 760) != v9
                    || *(double *)(a1 + 768) != v10
                    || *(double *)(a1 + 776) != v11
                    || *(double *)(a1 + 784) != v12 )
                  {
                    *(double *)(a1 + 760) = v9;
                    *(double *)(a1 + 768) = v10;
                    *(double *)(a1 + 776) = v11;
                    *(double *)(a1 + 784) = v12;
                    LiveViewManager::selctedPaintSizeChanged(
                      (LiveViewManager *)a1,
                      *(_DWORD *)(a1 + 524) != 0,
                      v9,
                      v10,
                      v11,
                      v12);
                  }
                }
              }
            }
LABEL_114:
            QImage::~QImage((QImage *)v109);
          }
LABEL_12:
          ++v8;
          v7 = *a2;
          if ( v8 >= (a2[1] - *a2) >> 6 )
            goto LABEL_116;
        }
        v15 = *(_DWORD *)(v13 + 40);
        v16 = *(_DWORD *)(v13 + 44);
        if ( (int)v15 >= (int)v16 )
          v17 = v16;
        else
          v17 = v15;
        if ( (int)(v15 - v17) >= 0 )
          v18 = v15 - v17;
        else
          v18 = v15 - v17 + 1;
        if ( (int)(v16 - v17) >= 0 )
          v19 = v16 - v17;
        else
          v19 = v16 - v17 + 1;
        if ( !*(_QWORD *)(a1 + 416) )
          goto LABEL_12;
        v20 = *(_DWORD *)(v13 + 32);
        v21 = *(_DWORD *)(v13 + 36);
        std::recursive_mutex::lock(v101);
        QPainter::QPainter((QPainter *)v109);
        QPainter::begin((QPainter *)v109, v102);
        QBrush::QBrush(&__ns, 4, 1);
        QPainter::setBrush((QPainter *)v109, (const QBrush *)&__ns);
        QBrush::~QBrush((QBrush *)&__ns);
        QColor::QColor(&__ns, 4);
        QPainter::setPen((QPainter *)v109, (const QColor *)&__ns);
        __ns.__rep_ = __PAIR64__(v21, v20);
        v119 = v15 + v20 - 1;
        v120 = v16 + v21 - 1;
        QPainter::drawRects(v109, &__ns, 1);
        QBrush::QBrush(&__ns, 2, 1);
        QPainter::setBrush((QPainter *)v109, (const QBrush *)&__ns);
        QBrush::~QBrush((QBrush *)&__ns);
        QColor::QColor(&__ns, 2);
        QPainter::setPen((QPainter *)v109, (const QColor *)&__ns);
        v22 = v19 >> 1;
        v23 = (v18 >> 1) + v20;
        v24 = v22 + v21;
        LODWORD(__ns.__rep_) = (v18 >> 1) + v20;
        HIDWORD(__ns.__rep_) = v24;
        v119 = v17 - 1 + v23;
        v120 = v17 - 1 + v24;
        QPainter::drawRects(v109, &__ns, 1);
        QPainter::end((QPainter *)v109);
        std::recursive_mutex::unlock(v101);
        v10 = 0.0;
        v9 = 0.0;
        if ( (int)v23 >= 1 )
          v9 = (double)(int)v23 / (double)(int)QImage::width(v102);
        if ( (int)v24 >= 1 )
          v10 = (double)(int)v24 / (double)(int)QImage::height(v102);
        v25 = QImage::width(v102);
        v26 = QImage::height(v102);
        std::string::basic_string(&v103, (const std::string *)(*a2 + (v8 << 6)));
        LiveViewManager::SetPaintSize(a1, &v103, v23, v24, v17, v17);
        if ( SHIBYTE(v103.__r_.__value_.__r.__words[2]) < 0 )
          operator delete(v103.__r_.__value_.__l.__data_);
        v11 = (double)(int)v17 / (double)v25;
        v27 = *a2 + (v8 << 6);
        v28 = *(unsigned __int8 *)(v27 + 23);
        if ( (v28 & 0x80u) == 0LL )
          v29 = *(unsigned __int8 *)(v27 + 23);
        else
          v29 = *(_QWORD *)(v27 + 8);
        v30 = *(unsigned __int8 *)(a1 + 367);
        v31 = (char)v30;
        if ( (v30 & 0x80u) != 0LL )
          v30 = *(_QWORD *)(a1 + 352);
        v12 = (double)(int)v17 / (double)v26;
        if ( v29 == v30 )
        {
          if ( (v28 & 0x80u) == 0LL )
            v32 = (const void *)(*a2 + (v8 << 6));
          else
            v32 = *(const void **)v27;
          if ( v31 >= 0 )
            v33 = (unsigned __int8 *)(a1 + 344);
          else
            v33 = *v99;
          if ( (v28 & 0x80) != 0 )
          {
            if ( !v29 || !memcmp(v32, v33, v29) )
              goto LABEL_9;
          }
          else
          {
            if ( !v29 )
              goto LABEL_9;
            if ( *v33 == (unsigned __int8)*(_QWORD *)v27 )
            {
              v34 = v28 - 1;
              v35 = (unsigned __int8 *)(*a2 + (v8 << 6) + 1);
              v36 = v33 + 1;
              while ( v34 )
              {
                v38 = *v35++;
                v37 = v38;
                v39 = *v36++;
                --v34;
                if ( v37 != v39 )
                  goto LABEL_11;
              }
LABEL_9:
              if ( *(double *)(a1 + 760) != v9
                || *(double *)(a1 + 768) != v10
                || *(double *)(a1 + 776) != v11
                || *(double *)(a1 + 784) != v12 )
              {
                *(double *)(a1 + 760) = v9;
                *(double *)(a1 + 768) = v10;
                *(double *)(a1 + 776) = v11;
                *(double *)(a1 + 784) = v12;
                LiveViewManager::selctedPaintSizeChanged(
                  (LiveViewManager *)a1,
                  *(_DWORD *)(a1 + 524) != 0,
                  v9,
                  v10,
                  (double)(int)v17 / (double)v25,
                  v12);
              }
            }
          }
        }
LABEL_11:
        QPainter::~QPainter((QPainter *)v109);
        goto LABEL_12;
      }
      v98 = 0;
      v12 = 0.0;
      v11 = 0.0;
      v10 = 0.0;
      v9 = 0.0;
LABEL_116:
      std::recursive_mutex::lock(v101);
      if ( *(_DWORD *)(a1 + 524) )
      {
        v83 = *(VideoAdapter **)(a1 + 416);
        v84 = 0.0;
        v85 = 0.0;
        v86 = 1.0;
        v87 = 1.0;
      }
      else
      {
        if ( v116 )
          goto LABEL_120;
        v83 = *(VideoAdapter **)(a1 + 416);
        v84 = v9;
        v85 = v10;
        v86 = v11;
        v87 = v12;
      }
      VideoAdapter::SetPaintOffset(v83, v84, v85, v86, v87);
LABEL_120:
      v88 = *(_QWORD *)(a1 + 416);
      v89 = QImage::bits(v102);
      v90 = QImage::sizeInBytes(v102);
      v91 = QImage::width(v102);
      v92 = QImage::height(v102);
      v93 = QImage::bytesPerLine(v102);
      v94 = QImage::format(v102);
      VideoAdapter::SetImage(v88, v89, v90, v91, v92, v93, v94);
      std::recursive_mutex::unlock(v101);
      v95 = QElapsedTimer::elapsed((QElapsedTimer *)&v110);
      if ( v95 <= 29 )
      {
        if ( (v98 & 1) != 0 )
        {
          v5 = 1000000;
        }
        else
        {
          v5 = 1000000 * (30 - v95);
          if ( (unsigned __int64)(30 - v95) >= 0x8637BD057A0LL )
            v5 = 0x7FFFFFFFFFFFFFFFLL;
        }
        __ns.__rep_ = v5;
        std::this_thread::sleep_for(&__ns);
      }
      v6 = atomic_load((unsigned __int8 *)(a1 + 560));
    }
    while ( (v6 & 1) == 0 );
  }
}
