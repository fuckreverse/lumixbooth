// __ZN11lumixtether13DeviceAdapter32adp_LMX_func_api_SelectPnPDeviceEv @ 0x10002996c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_SelectPnPDevice(lumixtether::DeviceAdapter *this)
{
  __int64 v2; // x20
  __int64 v3; // x26
  __int64 v4; // x8
  __int64 v5; // x9
  __int64 v6; // x28
  __int64 v7; // x23
  int v8; // w24
  __int64 v9; // x9
  __int64 v10; // x8
  __int64 v11; // x20
  size_t v12; // x0
  size_t v13; // x0
  __int64 v14; // x20
  size_t v15; // x0
  __int64 v16; // x20
  __int128 v17; // q0
  __int128 v18; // q1
  __int64 v19; // x8
  __int64 v20; // x24
  __int64 v21; // x23
  int *v22; // x8
  __int64 ConnectUsbDevID; // x0
  __int64 v24; // x23
  int *v25; // x8
  atomic_uint *v26; // x8
  __int64 v27; // x23
  int *v28; // x8
  __int64 v29; // x8
  __int64 v30; // x22
  __int64 v31; // x26
  __int64 v32; // x8
  atomic_uint **v33; // x27
  __int64 v34; // x28
  __int64 v35; // x8
  atomic_uint *v36; // x21
  _QWORD *v37; // x25
  atomic_uint *v38; // x8
  __int64 v39; // x8
  atomic_uint *v40; // x9
  atomic_uint **v41; // t1
  atomic_uint *v42; // x8
  atomic_uint *v43; // x9
  atomic_uint **v44; // x8
  __int64 v45; // x21
  atomic_uint *v46; // x0
  atomic_uint **v47; // x24
  atomic_uint **v48; // x21
  atomic_uint *v49; // x0
  atomic_uint *v50; // x8
  __int64 v51; // x8
  bool v52; // zf
  atomic_uint *v53; // x9
  atomic_uint **v54; // t1
  atomic_uint *v55; // x8
  atomic_uint *v56; // x9
  __int64 v58; // [xsp+48h] [xbp-258h]
  QBasicMutex *v59; // [xsp+50h] [xbp-250h]
  atomic_uint *v60[3]; // [xsp+58h] [xbp-248h] BYREF
  atomic_uint *v61[3]; // [xsp+70h] [xbp-230h] BYREF
  __int128 v62; // [xsp+88h] [xbp-218h] BYREF
  atomic_uint *v63; // [xsp+98h] [xbp-208h]
  atomic_uint *v64; // [xsp+A0h] [xbp-200h] BYREF
  __int128 v65; // [xsp+A8h] [xbp-1F8h]
  __int128 v66; // [xsp+B8h] [xbp-1E8h] BYREF
  atomic_uint *v67; // [xsp+C8h] [xbp-1D8h]
  __int128 v68; // [xsp+D0h] [xbp-1D0h] BYREF
  atomic_uint *v69; // [xsp+E0h] [xbp-1C0h]
  atomic_uint *v70[3]; // [xsp+E8h] [xbp-1B8h] BYREF
  atomic_uint *v71; // [xsp+100h] [xbp-1A0h] BYREF
  atomic_uint *v72; // [xsp+108h] [xbp-198h]
  atomic_uint *v73; // [xsp+110h] [xbp-190h]
  _BYTE v74[24]; // [xsp+118h] [xbp-188h] BYREF
  __int128 v75; // [xsp+130h] [xbp-170h] BYREF
  __int128 v76; // [xsp+140h] [xbp-160h]
  _OWORD v77[3]; // [xsp+150h] [xbp-150h] BYREF
  _OWORD v78[3]; // [xsp+180h] [xbp-120h] BYREF
  __int128 v79; // [xsp+1B0h] [xbp-F0h]
  _BYTE v80[32]; // [xsp+1C0h] [xbp-E0h]
  __int128 v81; // [xsp+1E0h] [xbp-C0h] BYREF
  __int64 v82; // [xsp+1F0h] [xbp-B0h]
  __int128 v83; // [xsp+1F8h] [xbp-A8h] BYREF
  atomic_uint *v84; // [xsp+208h] [xbp-98h]
  _BYTE __s[37]; // [xsp+210h] [xbp-90h] BYREF

  v58 = *(unsigned int *)(*((_QWORD *)this + 140) + 160120LL);
  if ( !(_DWORD)v58 )
    return 0;
  v2 = 0;
  v3 = 0;
  v59 = (lumixtether::DeviceAdapter *)((char *)this + 1128);
  do
  {
    v4 = 0;
    v5 = *((_QWORD *)this + 140) + 160120LL;
    v6 = *(unsigned int *)(v5 + 2060 * v3 + 520);
    v7 = *(_QWORD *)(v5 + 8 * v3 + 8);
    memset(__s, 0, sizeof(__s));
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)v59,
      (unsigned __int64 *)&v4,
      1u,
      memory_order_acquire,
      memory_order_acquire);
    if ( v4 )
      QBasicMutex::lockInternal(v59);
    v8 = LMX_func_api_SelectPnPDevice(v6, *((_QWORD *)this + 140) + 160120LL, __s, 0, 0, 0, 0);
    v9 = 1;
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)this + 141,
      (unsigned __int64 *)&v9,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v9 != 1 )
      QBasicMutex::unlockInternal(v59);
    v10 = *((_QWORD *)this + 140);
    if ( v8 == 1 )
    {
      v11 = v10 + 410368;
      v12 = strlen(__s);
      QString::fromUtf8(v74, v12, __s);
      v81 = *(_OWORD *)v74;
      v82 = *(_QWORD *)&v74[16];
      sub_10002A628(v11, &v81);
      if ( (_QWORD)v81 && atomic_fetch_add((atomic_uint *volatile)v81, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v81, 2, 8);
      *(_DWORD *)v74 = 0;
      WORD6(v79) = 0;
      BYTE14(v79) = 0;
      *(_QWORD *)&v80[24] = 0;
      *(_OWORD *)&v74[8] = 0u;
      v75 = 0u;
      v76 = 0u;
      memset(v77, 0, sizeof(v77));
      memset(v78, 0, sizeof(v78));
      LOWORD(v79) = 0;
      DWORD1(v79) = 0;
      *(_DWORD *)((char *)&v79 + 7) = 0;
      *(_QWORD *)v80 = 0;
      v80[8] = 0;
      *(_WORD *)&v80[20] = 0;
      *(_QWORD *)&v80[12] = 0;
      QString::fromUcs4(&v71, v7, -1);
      v70[0] = v71;
      v70[1] = v72;
      v70[2] = v73;
      if ( v71 )
        atomic_fetch_add(v71, 1u);
      v13 = strlen(__s);
      QString::fromUtf8(&v83, v13, __s);
      v68 = v83;
      v69 = v84;
      lumixtether::DeviceAdapter::getCameraInfo(this, v6, v70, &v68, 0, v74);
      if ( (_QWORD)v68 && atomic_fetch_add((atomic_uint *volatile)v68, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v68, 2, 8);
      if ( v70[0] && atomic_fetch_add(v70[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v70[0], 2, 8);
      std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
      v14 = *((_QWORD *)this + 140);
      v15 = strlen(__s);
      QString::fromUtf8(&v83, v15, __s);
      v66 = v83;
      v67 = v84;
      v16 = sub_10002AE78(v14 + 410272, &v66);
      *(_DWORD *)v16 = *(_DWORD *)v74;
      QString::operator=(v16 + 8, &v74[8]);
      QString::operator=(v16 + 32, (char *)&v75 + 8);
      QString::operator=(v16 + 56, v77);
      QString::operator=(v16 + 80, (char *)&v77[1] + 8);
      QString::operator=(v16 + 104, v78);
      QString::operator=(v16 + 128, (char *)&v78[1] + 8);
      v18 = *(_OWORD *)v80;
      v17 = *(_OWORD *)&v80[16];
      *(_OWORD *)(v16 + 152) = v79;
      *(_OWORD *)(v16 + 168) = v18;
      *(_OWORD *)(v16 + 184) = v17;
      if ( (_QWORD)v66 && atomic_fetch_add((atomic_uint *volatile)v66, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v66, 2, 8);
      std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
      v64 = *((atomic_uint **)&v75 + 1);
      v65 = v76;
      if ( *((_QWORD *)&v75 + 1) )
        atomic_fetch_add(*((atomic_uint *volatile *)&v75 + 1), 1u);
      lumixtether::DeviceAdapter::setFileTargetById(this, &v64);
      if ( v64 && atomic_fetch_add(v64, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v64, 2, 8);
      if ( v71 && atomic_fetch_add(v71, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v71, 2, 8);
      sub_1000A7354(v74);
      v2 = 1;
    }
    else if ( !*(_DWORD *)(v10 + 410380) )
    {
      QString::fromUcs4(&v83, v7, -1);
      v19 = *((_QWORD *)this + 140);
      if ( *(__int64 *)(v19 + 410296) >= 1 )
      {
        v20 = 0;
        do
        {
          v21 = v19 + 410280;
          v22 = *(int **)(v19 + 410280);
          if ( (!v22 || *v22 >= 2) && (sub_1000A9C00(v21, 0, 0, 0), (v22 = *(int **)v21) == nullptr) || *v22 >= 2 )
            sub_1000A9C00(v21, 0, 0, 0);
          ConnectUsbDevID = SearchCameraListItemObject::GetConnectUsbDevID(*(SearchCameraListItemObject **)(*(_QWORD *)(v21 + 8) + 8 * v20));
          QString::fromUcs4(&v71, ConnectUsbDevID, -1);
          if ( v84 == v73 && !(unsigned int)QtPrivate::compareStrings(v84, *((_QWORD *)&v83 + 1), v84, v72, 1) )
          {
            QString::fromUtf8(v74, 0, &unk_10014269A);
            v66 = *(_OWORD *)v74;
            v67 = *(atomic_uint **)&v74[16];
            v24 = *((_QWORD *)this + 140) + 410280LL;
            v25 = *(int **)v24;
            if ( (!*(_QWORD *)v24 || *v25 >= 2)
              && (sub_1000A9C00(*((_QWORD *)this + 140) + 410280LL, 0, 0, 0), (v25 = *(int **)v24) == nullptr)
              || *v25 >= 2 )
            {
              sub_1000A9C00(v24, 0, 0, 0);
            }
            SearchCameraListItemObject::devFrlyName(
              (__int64 *)v74,
              *(SearchCameraListItemObject **)(*(_QWORD *)(v24 + 8) + 8 * v20));
            QString::operator=(&v66, v74);
            if ( *(_QWORD *)v74 && atomic_fetch_add(*(atomic_uint *volatile *)v74, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(*(_QWORD *)v74, 2, 8);
            v26 = v67;
            if ( !v67 )
            {
              v27 = *((_QWORD *)this + 140) + 410280LL;
              v28 = *(int **)v27;
              if ( (!*(_QWORD *)v27 || *v28 >= 2)
                && (sub_1000A9C00(*((_QWORD *)this + 140) + 410280LL, 0, 0, 0), (v28 = *(int **)v27) == nullptr)
                || *v28 >= 2 )
              {
                sub_1000A9C00(v27, 0, 0, 0);
              }
              SearchCameraListItemObject::devModelName(
                (__int64 *)v74,
                *(SearchCameraListItemObject **)(*(_QWORD *)(v27 + 8) + 8 * v20));
              QString::operator=(&v66, v74);
              if ( *(_QWORD *)v74 && atomic_fetch_add(*(atomic_uint *volatile *)v74, 0xFFFFFFFF) == 1 )
                QArrayData::deallocate(*(_QWORD *)v74, 2, 8);
              v26 = v67;
            }
            v62 = v66;
            v63 = v26;
            if ( (_QWORD)v66 )
              atomic_fetch_add((atomic_uint *volatile)v66, 1u);
            lumixtether::DeviceAdapter::notifyConnectErrorMessage(this, 0, &v62, 0);
            if ( (_QWORD)v62 && atomic_fetch_add((atomic_uint *volatile)v62, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v62, 2, 8);
            if ( (_QWORD)v66 && atomic_fetch_add((atomic_uint *volatile)v66, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v66, 2, 8);
          }
          if ( v71 && atomic_fetch_add(v71, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v71, 2, 8);
          ++v20;
          v19 = *((_QWORD *)this + 140);
        }
        while ( *(_QWORD *)(v19 + 410296) > v20 );
      }
      if ( (_QWORD)v83 && atomic_fetch_add((atomic_uint *volatile)v83, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v83, 2, 8);
    }
    ++v3;
  }
  while ( v3 != v58 );
  if ( (_DWORD)v2 == 1 )
  {
    lumixtether::DeviceAdapter::camera_list_update_camera_list(this, 0);
    v29 = *((_QWORD *)this + 140);
    if ( *(int *)(v29 + 307832) < 1 )
    {
LABEL_103:
      std::recursive_mutex::lock((std::recursive_mutex *)(v29 + 410304));
      v45 = *((_QWORD *)this + 140) + 410272LL;
      if ( *(_QWORD *)v45 )
      {
        sub_1000A9464(*((_QWORD *)this + 140) + 410272LL);
      }
      else
      {
        v46 = (atomic_uint *)operator new(0x20u);
        *v46 = 0;
        *((_QWORD *)v46 + 3) = 0;
        *((_QWORD *)v46 + 2) = 0;
        *((_QWORD *)v46 + 1) = v46 + 4;
        *(_QWORD *)v45 = v46;
        atomic_fetch_add(v46, 1u);
      }
      v47 = *(atomic_uint ***)(*(_QWORD *)v45 + 8LL);
      while ( 1 )
      {
        v48 = (atomic_uint **)(*((_QWORD *)this + 140) + 410272LL);
        if ( *v48 )
        {
          sub_1000A9464(*((_QWORD *)this + 140) + 410272LL);
        }
        else
        {
          v49 = (atomic_uint *)operator new(0x20u);
          *v49 = 0;
          *((_QWORD *)v49 + 3) = 0;
          *((_QWORD *)v49 + 2) = 0;
          *((_QWORD *)v49 + 1) = v49 + 4;
          *v48 = v49;
          atomic_fetch_add(v49, 1u);
        }
        if ( v47 == (atomic_uint **)(*v48 + 4) )
          break;
        if ( !*((_DWORD *)v47 + 14) )
        {
          v55 = v47[4];
          v56 = v47[5];
          v60[0] = v55;
          v60[1] = v56;
          v60[2] = v47[6];
          if ( v55 )
            atomic_fetch_add(v55, 1u);
          lumixtether::DeviceAdapter::setCameraInfoOfSelectedCamera(this, v60);
          if ( v60[0] && atomic_fetch_add(v60[0], 0xFFFFFFFF) == 1 )
          {
            v44 = v60;
            goto LABEL_123;
          }
          break;
        }
        v50 = v47[1];
        if ( v50 )
        {
          do
          {
            v47 = (atomic_uint **)v50;
            v50 = *(atomic_uint **)v50;
          }
          while ( v50 );
        }
        else
        {
          v51 = (__int64)(v47 + 2);
          v52 = *(_QWORD *)v47[2] == (_QWORD)v47;
          v47 = (atomic_uint **)v47[2];
          if ( !v52 )
          {
            do
            {
              v53 = *(atomic_uint **)v51;
              v54 = *(atomic_uint ***)(*(_QWORD *)v51 + 16LL);
              v51 = *(_QWORD *)v51 + 16LL;
              v47 = v54;
            }
            while ( *v54 != v53 );
          }
        }
      }
    }
    else
    {
      v30 = 0;
      while ( 1 )
      {
        std::recursive_mutex::lock((std::recursive_mutex *)(v29 + 410304));
        v31 = *((_QWORD *)this + 140);
        v32 = *(_QWORD *)(v31 + 410272);
        v33 = v32 ? *(atomic_uint ***)(v32 + 8) : nullptr;
        v34 = v32 ? v32 + 16 : 0LL;
        if ( (atomic_uint **)v34 != v33 )
          break;
LABEL_78:
        std::recursive_mutex::unlock((std::recursive_mutex *)(v31 + 410304));
        ++v30;
        v29 = *((_QWORD *)this + 140);
        if ( v30 >= *(int *)(v29 + 307832) )
          goto LABEL_103;
      }
      v35 = v31 + 200 * v30;
      v36 = *(atomic_uint **)(v35 + 307920);
      v37 = (_QWORD *)(v35 + 307912);
      while ( v36 != v33[13] || (unsigned int)QtPrivate::compareStrings(v36, *v37, v36, v33[12], 1) )
      {
        v38 = v33[1];
        if ( v38 )
        {
          do
          {
            v33 = (atomic_uint **)v38;
            v38 = *(atomic_uint **)v38;
          }
          while ( v38 );
        }
        else
        {
          v39 = (__int64)(v33 + 2);
          if ( *(atomic_uint ***)v33[2] == v33 )
          {
            v33 = (atomic_uint **)v33[2];
          }
          else
          {
            do
            {
              v40 = *(atomic_uint **)v39;
              v41 = *(atomic_uint ***)(*(_QWORD *)v39 + 16LL);
              v39 = *(_QWORD *)v39 + 16LL;
              v33 = v41;
            }
            while ( *v41 != v40 );
          }
        }
        if ( v33 == (atomic_uint **)v34 )
          goto LABEL_78;
      }
      v42 = v33[4];
      v43 = v33[5];
      v61[0] = v42;
      v61[1] = v43;
      v61[2] = v33[6];
      if ( v42 )
        atomic_fetch_add(v42, 1u);
      lumixtether::DeviceAdapter::setCameraInfoOfSelectedCamera(this, v61);
      if ( v61[0] && atomic_fetch_add(v61[0], 0xFFFFFFFF) == 1 )
      {
        v44 = v61;
LABEL_123:
        QArrayData::deallocate(*v44, 2, 8);
      }
    }
    std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
  }
  return v2;
}
