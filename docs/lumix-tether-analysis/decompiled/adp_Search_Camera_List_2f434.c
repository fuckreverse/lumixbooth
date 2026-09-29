// __ZN11lumixtether13DeviceAdapter35adp_LMX_func_api_Search_Camera_ListEb @ 0x10002f434 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Search_Camera_List(atomic_ullong *this, int a2)
{
  __int64 v2; // x8
  QBasicMutex *v3; // x20
  bool v4; // w8
  std::recursive_mutex **v5; // x24
  int v6; // w21
  __int64 v7; // x9
  bool v8; // zf
  __int64 v10; // x26
  __int64 v11; // x8
  __int64 v12; // x28
  __int64 v13; // x8
  int v14; // w22
  __int64 v15; // x8
  __int64 v16; // x9
  __int64 v17; // x21
  __int64 v18; // x23
  atomic_uint *v19; // x0
  _QWORD *v20; // x19
  char *v21; // x23
  atomic_uint *v22; // x0
  void *v23; // x0
  _QWORD *v24; // x8
  __int64 v25; // x8
  __int64 v26; // x9
  _QWORD *v27; // t1
  std::recursive_mutex *v28; // x19
  size_t v29; // x0
  size_t v30; // x0
  atomic_uint *v31; // x21
  bool v32; // w22
  __int64 v33; // x8
  size_t v34; // x0
  std::recursive_mutex *v35; // x19
  size_t v36; // x0
  __int64 v37; // x22
  __int128 v38; // q0
  __int128 v39; // q1
  atomic_uint *v40; // x8
  void **v41; // x8
  void *v42; // x0
  int v43; // w0
  std::recursive_mutex *v44; // x8
  size_t v45; // x0
  atomic_uint *v46; // x21
  size_t v47; // x0
  atomic_uint *v48; // x21
  std::recursive_mutex *v49; // x19
  size_t v50; // x0
  __int64 v51; // x19
  __int64 v52; // x21
  __int64 v53; // x8
  int v54; // w28
  __int64 v55; // x20
  atomic_uint *v56; // x0
  _QWORD *v57; // x22
  char *v58; // x20
  atomic_uint *v59; // x0
  __int64 v60; // x0
  _QWORD *v61; // x8
  __int64 v62; // x8
  __int64 v63; // x9
  _QWORD *v64; // t1
  __int64 v65; // [xsp+50h] [xbp-280h]
  unsigned __int64 v67; // [xsp+68h] [xbp-268h]
  atomic_uint *v68; // [xsp+70h] [xbp-260h] BYREF
  __int128 v69; // [xsp+78h] [xbp-258h]
  __int128 v70; // [xsp+88h] [xbp-248h] BYREF
  __int64 v71; // [xsp+98h] [xbp-238h]
  __int128 v72; // [xsp+A0h] [xbp-230h] BYREF
  __int64 v73; // [xsp+B0h] [xbp-220h]
  atomic_uint *v74[3]; // [xsp+B8h] [xbp-218h] BYREF
  _BYTE v75[24]; // [xsp+D0h] [xbp-200h] BYREF
  __int128 v76; // [xsp+E8h] [xbp-1E8h] BYREF
  __int128 v77; // [xsp+F8h] [xbp-1D8h]
  _OWORD v78[3]; // [xsp+108h] [xbp-1C8h] BYREF
  _OWORD v79[3]; // [xsp+138h] [xbp-198h] BYREF
  __int128 v80; // [xsp+168h] [xbp-168h]
  _BYTE v81[32]; // [xsp+178h] [xbp-158h]
  __int128 v82; // [xsp+198h] [xbp-138h] BYREF
  __int64 v83; // [xsp+1A8h] [xbp-128h]
  __int128 v84; // [xsp+1B0h] [xbp-120h] BYREF
  __int64 v85; // [xsp+1C0h] [xbp-110h]
  __int128 v86; // [xsp+1C8h] [xbp-108h] BYREF
  __int64 v87; // [xsp+1D8h] [xbp-F8h]
  __int128 v88; // [xsp+1E0h] [xbp-F0h] BYREF
  __int64 v89; // [xsp+1F0h] [xbp-E0h]
  __int128 v90; // [xsp+1F8h] [xbp-D8h] BYREF
  __int64 v91; // [xsp+208h] [xbp-C8h]
  atomic_uint *v92[3]; // [xsp+210h] [xbp-C0h] BYREF
  __int128 v93; // [xsp+228h] [xbp-A8h] BYREF
  __int64 v94; // [xsp+238h] [xbp-98h]
  char __s[16]; // [xsp+240h] [xbp-90h] BYREF
  _BYTE v96[21]; // [xsp+250h] [xbp-80h] BYREF

  v2 = 0;
  v3 = (QBasicMutex *)(this + 141);
  atomic_compare_exchange_strong_explicit(
    this + 141,
    (unsigned __int64 *)&v2,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  v4 = v2 == 0;
  if ( a2 )
  {
    if ( !v4 )
      return 0;
  }
  else if ( !v4 )
  {
    QBasicMutex::lockInternal((QBasicMutex *)(this + 141));
  }
  LMX_func_api_ptpip_StopGetDeviceInfo(nullptr);
  v5 = (std::recursive_mutex **)(this + 140);
  v6 = LMX_func_api_Search_Device(*(this + 140) + 160120, 0);
  v7 = 1;
  atomic_compare_exchange_strong_explicit(
    this + 141,
    (unsigned __int64 *)&v7,
    0,
    memory_order_release,
    memory_order_relaxed);
  if ( v7 != 1 )
    QBasicMutex::unlockInternal(v3);
  v67 = *(unsigned int *)&(*v5)[2501].__m_.__opaque[48];
  v8 = v6 != 1 || *(_DWORD *)&(*v5)[2501].__m_.__opaque[48] == 0;
  if ( v8 )
    return 0;
  v10 = 0;
  v65 = 0;
  do
  {
    v11 = (__int64)&(*v5)[2501].__m_.__opaque[48];
    v12 = *(unsigned int *)(v11 + 2060 * v10 + 520);
    QString::fromUcs4(v92, *(_QWORD *)(v11 + 8 * v10 + 8), -1);
    v13 = 0;
    *(_OWORD *)__s = 0u;
    memset(v96, 0, sizeof(v96));
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)v3,
      (unsigned __int64 *)&v13,
      1u,
      memory_order_acquire,
      memory_order_acquire);
    if ( v13 )
      QBasicMutex::lockInternal(v3);
    v14 = LMX_func_api_SelectPnPDevice(v12, &(*v5)[2501].__m_.__opaque[48], __s, 0, 0, 0, 0);
    v15 = 1;
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)v3,
      (unsigned __int64 *)&v15,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v15 != 1 )
      QBasicMutex::unlockInternal(v3);
    if ( v14 == 1 )
    {
      v16 = *(_QWORD *)&(*v5)[6410].__m_.__opaque[24];
      if ( v16 )
        v17 = *(_QWORD *)(v16 + 24);
      else
        LODWORD(v17) = 0;
      std::recursive_mutex::lock(*v5 + 6411);
      v18 = (__int64)&(*v5)[6410].__m_.__opaque[24];
      if ( *(_QWORD *)v18 )
      {
        sub_1000A9464(&(*v5)[6410].__m_.__opaque[24]);
      }
      else
      {
        v19 = (atomic_uint *)operator new(0x20u);
        *v19 = 0;
        *((_QWORD *)v19 + 3) = 0;
        *((_QWORD *)v19 + 2) = 0;
        *((_QWORD *)v19 + 1) = v19 + 4;
        *(_QWORD *)v18 = v19;
        atomic_fetch_add(v19, 1u);
      }
      v20 = *(_QWORD **)(*(_QWORD *)v18 + 8LL);
      while ( 1 )
      {
        v21 = &(*v5)[6410].__m_.__opaque[24];
        if ( *(_QWORD *)v21 )
        {
          sub_1000A9464(&(*v5)[6410].__m_.__opaque[24]);
        }
        else
        {
          v22 = (atomic_uint *)operator new(0x20u);
          *v22 = 0;
          *((_QWORD *)v22 + 3) = 0;
          *((_QWORD *)v22 + 2) = 0;
          *((_QWORD *)v22 + 1) = v22 + 4;
          *(_QWORD *)v21 = v22;
          atomic_fetch_add(v22, 1u);
        }
        if ( v20 == (_QWORD *)(*(_QWORD *)v21 + 16LL) )
        {
          std::recursive_mutex::unlock(*v5 + 6411);
          goto LABEL_42;
        }
        v23 = v20[5] ? (void *)v20[5] : &QString::_empty;
        if ( !(unsigned int)QString::compare_helper(v23, v20[6], __s, -1, 1) )
          break;
        v24 = (_QWORD *)v20[1];
        if ( v24 )
        {
          do
          {
            v20 = v24;
            v24 = (_QWORD *)*v24;
          }
          while ( v24 );
        }
        else
        {
          v25 = (__int64)(v20 + 2);
          v8 = *(_QWORD *)v20[2] == (_QWORD)v20;
          v20 = (_QWORD *)v20[2];
          if ( !v8 )
          {
            do
            {
              v26 = *(_QWORD *)v25;
              v27 = *(_QWORD **)(*(_QWORD *)v25 + 16LL);
              v25 = *(_QWORD *)v25 + 16LL;
              v20 = v27;
            }
            while ( *v27 != v26 );
          }
        }
      }
      if ( *((_DWORD *)v20 + 14) != v12 && v67 >= (int)v17 )
        *((_DWORD *)v20 + 14) = v12;
      v41 = (void **)&(*v5)[4810].__m_.__opaque[8];
      if ( *v41 )
        v42 = *v41;
      else
        v42 = &QString::_empty;
      v43 = QString::compare_helper(v42, *(_QWORD *)&(*v5)[4810].__m_.__opaque[16], __s, -1, 1);
      v44 = *v5;
      if ( !v43 )
        LODWORD(v44[4810].__m_.__sig) = v12;
      std::recursive_mutex::unlock(v44 + 6411);
      v40 = v92[0];
      if ( v92[0] )
      {
LABEL_72:
        if ( atomic_fetch_add(v40, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v92[0], 2, 8);
      }
    }
    else
    {
LABEL_42:
      v28 = *v5;
      v29 = strlen(__s);
      QString::fromUtf8(v75, v29, __s);
      v90 = *(_OWORD *)v75;
      v91 = *(_QWORD *)&v75[16];
      sub_10002A628(&v28[6412], &v90);
      if ( (_QWORD)v90 && atomic_fetch_add((atomic_uint *volatile)v90, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v90, 2, 8);
      if ( v14 == 1 )
      {
        v30 = strlen(__s);
        QString::fromUtf8(v75, v30, __s);
        v31 = *(atomic_uint **)v75;
        v88 = *(_OWORD *)v75;
        v89 = *(_QWORD *)&v75[16];
        v32 = lumixtether::DeviceAdapter::adp_LMX_func_api_OpenSession((__int64)this, (__int64)&v88);
        if ( v31 && atomic_fetch_add(v31, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v88, 2, 8);
        if ( !v32 )
        {
          v45 = strlen(__s);
          QString::fromUtf8(v75, v45, __s);
          v46 = *(atomic_uint **)v75;
          v86 = *(_OWORD *)v75;
          v87 = *(_QWORD *)&v75[16];
          lumixtether::DeviceAdapter::adp_LMX_func_api_CloseSession((__int64)this, (__int64)&v86);
          if ( v46 && atomic_fetch_add(v46, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v86, 2, 8);
          v47 = strlen(__s);
          QString::fromUtf8(v75, v47, __s);
          v48 = *(atomic_uint **)v75;
          v84 = *(_OWORD *)v75;
          v85 = *(_QWORD *)&v75[16];
          lumixtether::DeviceAdapter::adp_LMX_func_api_CloseDevice((__int64)this, (atomic_uint **)&v84);
          if ( v48 && atomic_fetch_add(v48, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v84, 2, 8);
          v49 = *v5;
          v50 = strlen(__s);
          QString::fromUtf8(v75, v50, __s);
          v82 = *(_OWORD *)v75;
          v83 = *(_QWORD *)&v75[16];
          sub_10002E070(&v49[6412], &v82);
          if ( (_QWORD)v82 && atomic_fetch_add((atomic_uint *volatile)v82, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v82, 2, 8);
        }
        if ( v32 )
        {
          v33 = *(_QWORD *)&(*v5)[6410].__m_.__opaque[24];
          if ( !v33 || *(__int64 *)(v33 + 24) <= 11 )
          {
            *(_DWORD *)v75 = 0;
            WORD6(v80) = 0;
            BYTE14(v80) = 0;
            *(_QWORD *)&v81[24] = 0;
            *(_OWORD *)&v75[8] = 0u;
            v76 = 0u;
            v77 = 0u;
            memset(v78, 0, sizeof(v78));
            memset(v79, 0, sizeof(v79));
            LOWORD(v80) = 0;
            DWORD1(v80) = 0;
            *(_DWORD *)((char *)&v80 + 7) = 0;
            *(_QWORD *)v81 = 0;
            v81[8] = 0;
            *(_WORD *)&v81[20] = 0;
            *(_QWORD *)&v81[12] = 0;
            v74[0] = v92[0];
            v74[1] = v92[1];
            v74[2] = v92[2];
            if ( v92[0] )
              atomic_fetch_add(v92[0], 1u);
            v34 = strlen(__s);
            QString::fromUtf8(&v93, v34, __s);
            v72 = v93;
            v73 = v94;
            lumixtether::DeviceAdapter::getCameraInfo(this, v12, v74, &v72, 0, v75);
            if ( (_QWORD)v72 && atomic_fetch_add((atomic_uint *volatile)v72, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v72, 2, 8);
            if ( v74[0] && atomic_fetch_add(v74[0], 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v74[0], 2, 8);
            std::recursive_mutex::lock(*v5 + 6411);
            v35 = *v5;
            v36 = strlen(__s);
            QString::fromUtf8(&v93, v36, __s);
            v70 = v93;
            v71 = v94;
            v37 = sub_10002AE78(&v35[6410].__m_.__opaque[24], &v70);
            *(_DWORD *)v37 = *(_DWORD *)v75;
            QString::operator=(v37 + 8, &v75[8]);
            QString::operator=(v37 + 32, (char *)&v76 + 8);
            QString::operator=(v37 + 56, v78);
            QString::operator=(v37 + 80, (char *)&v78[1] + 8);
            QString::operator=(v37 + 104, v79);
            QString::operator=(v37 + 128, (char *)&v79[1] + 8);
            v39 = *(_OWORD *)v81;
            v38 = *(_OWORD *)&v81[16];
            *(_OWORD *)(v37 + 152) = v80;
            *(_OWORD *)(v37 + 168) = v39;
            *(_OWORD *)(v37 + 184) = v38;
            if ( (_QWORD)v70 && atomic_fetch_add((atomic_uint *volatile)v70, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v70, 2, 8);
            std::recursive_mutex::unlock(*v5 + 6411);
            v68 = *((atomic_uint **)&v76 + 1);
            v69 = v77;
            if ( *((_QWORD *)&v76 + 1) )
              atomic_fetch_add(*((atomic_uint *volatile *)&v76 + 1), 1u);
            lumixtether::DeviceAdapter::setFileTargetById(this, &v68);
            if ( v68 && atomic_fetch_add(v68, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v68, 2, 8);
            sub_1000A7354(v75);
            LOBYTE(v65) = 1;
          }
          HIDWORD(v65) = 1;
        }
      }
      v40 = v92[0];
      if ( v92[0] )
        goto LABEL_72;
    }
    ++v10;
  }
  while ( v10 != v67 );
  if ( (v65 & 1) == 0 )
    return HIDWORD(v65);
  v51 = 0;
  if ( v67 <= 1 )
    v52 = 1;
  else
    v52 = v67;
  while ( 2 )
  {
    v53 = (__int64)&(*v5)[2501].__m_.__opaque[48];
    v54 = *(_DWORD *)(v53 + 2060 * v51 + 520);
    QString::fromUcs4(v75, *(_QWORD *)(v53 + 8 * v51 + 8), -1);
    std::recursive_mutex::lock(*v5 + 6411);
    v55 = (__int64)&(*v5)[6410].__m_.__opaque[24];
    if ( *(_QWORD *)v55 )
    {
      sub_1000A9464(&(*v5)[6410].__m_.__opaque[24]);
    }
    else
    {
      v56 = (atomic_uint *)operator new(0x20u);
      *v56 = 0;
      *((_QWORD *)v56 + 3) = 0;
      *((_QWORD *)v56 + 2) = 0;
      *((_QWORD *)v56 + 1) = v56 + 4;
      *(_QWORD *)v55 = v56;
      atomic_fetch_add(v56, 1u);
    }
    v57 = *(_QWORD **)(*(_QWORD *)v55 + 8LL);
    while ( 1 )
    {
      v58 = &(*v5)[6410].__m_.__opaque[24];
      if ( *(_QWORD *)v58 )
      {
        sub_1000A9464(&(*v5)[6410].__m_.__opaque[24]);
      }
      else
      {
        v59 = (atomic_uint *)operator new(0x20u);
        *v59 = 0;
        *((_QWORD *)v59 + 3) = 0;
        *((_QWORD *)v59 + 2) = 0;
        *((_QWORD *)v59 + 1) = v59 + 4;
        *(_QWORD *)v58 = v59;
        atomic_fetch_add(v59, 1u);
      }
      if ( v57 == (_QWORD *)(*(_QWORD *)v58 + 16LL) )
        break;
      v60 = v57[10];
      if ( v60 == *(_QWORD *)&v75[16]
        && !(unsigned int)QtPrivate::compareStrings(v60, v57[9], v57[10], *(_QWORD *)&v75[8], 1) )
      {
        *((_DWORD *)v57 + 14) = v54;
        v61 = (_QWORD *)v57[1];
        if ( v61 )
        {
          do
          {
LABEL_109:
            v57 = v61;
            v61 = (_QWORD *)*v61;
          }
          while ( v61 );
          continue;
        }
      }
      else
      {
        v61 = (_QWORD *)v57[1];
        if ( v61 )
          goto LABEL_109;
      }
      v62 = (__int64)(v57 + 2);
      v8 = *(_QWORD *)v57[2] == (_QWORD)v57;
      v57 = (_QWORD *)v57[2];
      if ( !v8 )
      {
        do
        {
          v63 = *(_QWORD *)v62;
          v64 = *(_QWORD **)(*(_QWORD *)v62 + 16LL);
          v62 = *(_QWORD *)v62 + 16LL;
          v57 = v64;
        }
        while ( *v64 != v63 );
      }
    }
    std::recursive_mutex::unlock(*v5 + 6411);
    if ( *(_QWORD *)v75 && atomic_fetch_add(*(atomic_uint *volatile *)v75, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(*(_QWORD *)v75, 2, 8);
    if ( ++v51 != v52 )
      continue;
    break;
  }
  lumixtether::DeviceAdapter::camera_list_update_camera_list((lumixtether::DeviceAdapter *)this, 0);
  lumixtether::DeviceAdapter::cameraListChanged((lumixtether::DeviceAdapter *)this);
  return HIDWORD(v65);
}
