// __ZN11lumixtether13DeviceAdapter36adp_LMX_func_api_Ctrl_LiveView_StartEv @ 0x10002e768 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Ctrl_LiveView_Start(lumixtether::DeviceAdapter *this)
{
  __int64 v2; // x8
  __int64 v3; // x9
  unsigned int *v4; // x8
  int v5; // w0
  int v6; // w10
  __int64 v7; // x9
  __int64 v8; // x13
  __int64 v9; // x11
  __int64 v10; // x15
  int v11; // w16
  __int64 v12; // x23
  __int64 v13; // x20
  atomic_uint *v14; // x0
  atomic_uint *v15; // x21
  __int64 v16; // x20
  atomic_uint **v17; // x20
  atomic_uint *v18; // x0
  __int64 v19; // x0
  atomic_uint *v20; // x8
  __int64 v21; // x8
  bool v22; // zf
  __int64 v23; // x9
  atomic_uint *v24; // t1
  atomic_uint *v25; // x8
  atomic_uint *v26; // x20
  atomic_uint *v27; // x9
  int v28; // w10
  int v29; // w21
  std::string *v30; // x21
  __int128 v31; // q0
  __int128 v32; // q1
  __int64 v33; // x21
  atomic_uint *v34; // x9
  atomic_uint *v35; // x10
  int CameraStatus_UUID; // w20
  int camera_power_mode_DisplayList; // w21
  __int64 v38; // x9
  atomic_uint *v39; // x8
  __int64 v40; // x9
  atomic_uint *v41; // x20
  atomic_uint *v42; // x8
  atomic_uint **v43; // x9
  int v44; // w21
  std::string *v45; // x21
  __int128 v46; // q0
  __int128 v47; // q1
  int v48; // w20
  std::string *v49; // x22
  signed __int64 v50; // x0
  unsigned __int64 v51; // x24
  void **v52; // x21
  void **v53; // x8
  void *v54; // x0
  void **v55; // x22
  __int64 v56; // x8
  __int64 v57; // x9
  atomic_uint *v58; // x8
  int v59; // w21
  std::string *v60; // x19
  std::string *v61; // x8
  std::string *v62; // x0
  std::string *v63; // x20
  int v65; // [xsp+Ch] [xbp-1A4h]
  int v66; // [xsp+10h] [xbp-1A0h]
  int v67; // [xsp+14h] [xbp-19Ch]
  __int64 v68; // [xsp+18h] [xbp-198h]
  std::string v69; // [xsp+20h] [xbp-190h] BYREF
  __int128 v70; // [xsp+38h] [xbp-178h]
  _OWORD v71[2]; // [xsp+48h] [xbp-168h]
  atomic_uint *v72[3]; // [xsp+68h] [xbp-148h] BYREF
  void *__p; // [xsp+80h] [xbp-130h] BYREF
  void **v74; // [xsp+88h] [xbp-128h]
  char *v75; // [xsp+90h] [xbp-120h] BYREF
  atomic_uint *v76[3]; // [xsp+98h] [xbp-118h] BYREF
  atomic_uint *v77[3]; // [xsp+B0h] [xbp-100h] BYREF
  atomic_uint *v78[3]; // [xsp+C8h] [xbp-E8h] BYREF
  atomic_uint *v79[3]; // [xsp+E0h] [xbp-D0h] BYREF
  std::string __str; // [xsp+F8h] [xbp-B8h] BYREF
  __int128 v81; // [xsp+110h] [xbp-A0h]
  _BYTE v82[28]; // [xsp+120h] [xbp-90h]
  std::string *v83; // [xsp+140h] [xbp-70h] BYREF
  std::string *v84; // [xsp+148h] [xbp-68h]
  std::string *v85; // [xsp+150h] [xbp-60h]

  v83 = nullptr;
  v84 = nullptr;
  v85 = nullptr;
  v2 = *((_QWORD *)this + 140);
  v3 = v2 + 410500;
  v4 = (unsigned int *)(v2 + 307832);
  if ( *(_BYTE *)v3 )
  {
    v68 = *v4;
    v5 = LiveViewManager::Get1PageMaxDevNum((char *)this + 224, *(unsigned int *)(v3 + 4));
    v6 = 0;
    v7 = *((_QWORD *)this + 140);
    v8 = *(_QWORD *)(v7 + 410272);
    v9 = *(int *)(v7 + 410508);
    v10 = v9 * v5;
    v11 = v9 - 1;
    if ( v8 )
      goto LABEL_5;
    while ( v10 > 0 )
    {
      while ( 1 )
      {
        *(_DWORD *)(v7 + 410508) = v11;
        v6 -= v5;
        v10 -= v5;
        --v11;
        if ( !v8 )
          break;
LABEL_5:
        if ( *(_QWORD *)(v8 + 24) >= v10 )
          goto LABEL_6;
      }
    }
LABEL_6:
    if ( (int)v68 >= 1 )
    {
      v12 = 0;
      v66 = v6 + v9 * v5;
      v67 = 0;
      v65 = v5 + v5 * v9 + v6;
      do
      {
        std::recursive_mutex::lock((std::recursive_mutex *)(v7 + 410304));
        v13 = *((_QWORD *)this + 140) + 410272LL;
        if ( *(_QWORD *)v13 )
        {
          sub_1000A9464(*((_QWORD *)this + 140) + 410272LL);
        }
        else
        {
          v14 = (atomic_uint *)operator new(0x20u);
          *v14 = 0;
          *((_QWORD *)v14 + 3) = 0;
          *((_QWORD *)v14 + 2) = 0;
          *((_QWORD *)v14 + 1) = v14 + 4;
          *(_QWORD *)v13 = v14;
          atomic_fetch_add(v14, 1u);
        }
        v15 = *(atomic_uint **)(*(_QWORD *)v13 + 8LL);
        v16 = *((_QWORD *)this + 140);
        while ( 1 )
        {
          v17 = (atomic_uint **)(v16 + 410272);
          if ( *v17 )
          {
            sub_1000A9464(v17);
          }
          else
          {
            v18 = (atomic_uint *)operator new(0x20u);
            *v18 = 0;
            *((_QWORD *)v18 + 3) = 0;
            *((_QWORD *)v18 + 2) = 0;
            *((_QWORD *)v18 + 1) = v18 + 4;
            *v17 = v18;
            atomic_fetch_add(v18, 1u);
          }
          if ( v15 == *v17 + 4 )
            break;
          v16 = *((_QWORD *)this + 140);
          v19 = *((_QWORD *)v15 + 13);
          if ( v19 == *(_QWORD *)(v16 + 200 * v12 + 307920)
            && !(unsigned int)QtPrivate::compareStrings(
                                v19,
                                *((_QWORD *)v15 + 12),
                                *((_QWORD *)v15 + 13),
                                *(_QWORD *)(v16 + 200 * v12 + 307912),
                                1)
            && *((_BYTE *)v15 + 243) )
          {
            v26 = *((atomic_uint **)v15 + 4);
            v25 = *((atomic_uint **)v15 + 5);
            v27 = *((atomic_uint **)v15 + 6);
            if ( v26 )
              atomic_fetch_add(v26, 1u);
            v28 = v67;
            if ( v67 >= v66 && v67 < v65 )
            {
              memset(&__str, 0, sizeof(__str));
              v79[0] = v26;
              v79[1] = v25;
              v79[2] = v27;
              if ( v26 )
                atomic_fetch_add(v26, 1u);
              v29 = lumixtether::DeviceAdapter::CreateMultiviewParam(this, v79, &__str);
              if ( v79[0] && atomic_fetch_add(v79[0], 0xFFFFFFFF) == 1 )
                QArrayData::deallocate(v79[0], 2, 8);
              if ( v29 )
              {
                v30 = v84;
                if ( v84 == v85 )
                {
                  sub_1000ACCF0(&v83, &__str);
                }
                else
                {
                  std::string::basic_string(v84, &__str);
                  v31 = v81;
                  v32 = *(_OWORD *)v82;
                  *(_OWORD *)((char *)v30[2].__r_.__value_.__r.__words + 4) = *(_OWORD *)&v82[12];
                  *(_OWORD *)&v30[1].__r_.__value_.__r.__words[2] = v32;
                  *(_OWORD *)&v30[1].__r_.__value_.__l.__data_ = v31;
                  v84 = v30 + 3;
                }
              }
              if ( SHIBYTE(__str.__r_.__value_.__r.__words[2]) < 0 )
                operator delete(__str.__r_.__value_.__l.__data_);
              v28 = v67;
            }
            v67 = v28 + 1;
            if ( v26 && atomic_fetch_add(v26, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v26, 2, 8);
            break;
          }
          v20 = *((atomic_uint **)v15 + 1);
          if ( v20 )
          {
            do
            {
              v15 = v20;
              v20 = *(atomic_uint **)v20;
            }
            while ( v20 );
          }
          else
          {
            v21 = (__int64)(v15 + 4);
            v22 = **((_QWORD **)v15 + 2) == (_QWORD)v15;
            v15 = *((atomic_uint **)v15 + 2);
            if ( !v22 )
            {
              do
              {
                v23 = *(_QWORD *)v21;
                v24 = *(atomic_uint **)(*(_QWORD *)v21 + 16LL);
                v21 = *(_QWORD *)v21 + 16LL;
                v15 = v24;
              }
              while ( *(_QWORD *)v24 != v23 );
            }
          }
        }
        std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
        ++v12;
        v7 = *((_QWORD *)this + 140);
      }
      while ( v12 != v68 );
    }
    v33 = *(unsigned int *)(v7 + 410504);
    goto LABEL_86;
  }
  v34 = *((atomic_uint **)v4 + 2);
  v35 = *((atomic_uint **)v4 + 3);
  v78[0] = v34;
  v78[1] = v35;
  v78[2] = *((atomic_uint **)v4 + 4);
  if ( v34 )
    atomic_fetch_add(v34, 1u);
  CameraStatus_UUID = lumixtether::DeviceAdapter::adp_LMX_func_api_GetCameraStatus_UUID(this, v78);
  if ( v78[0] && atomic_fetch_add(v78[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v78[0], 2, 8);
  camera_power_mode_DisplayList = 0;
  if ( CameraStatus_UUID != 7 && CameraStatus_UUID != 10 )
  {
    v38 = *((_QWORD *)this + 140) + 307848LL;
    v39 = *(atomic_uint **)v38;
    v77[0] = v39;
    v77[1] = *(atomic_uint **)(v38 + 8);
    v77[2] = *(atomic_uint **)(v38 + 16);
    if ( v39 )
      atomic_fetch_add(v39, 1u);
    camera_power_mode_DisplayList = lumixtether::DeviceAdapter::camera_list_get_camera_power_mode_DisplayList(this, v77);
  }
  if ( CameraStatus_UUID != 7 && CameraStatus_UUID != 10 && v77[0] && atomic_fetch_add(v77[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v77[0], 2, 8);
  if ( !camera_power_mode_DisplayList )
  {
LABEL_85:
    v33 = 6;
LABEL_86:
    __p = nullptr;
    v74 = nullptr;
    v75 = nullptr;
    v49 = v83;
    v48 = (int)v84;
    v50 = (char *)v84 - (char *)v83;
    if ( v84 != v83 )
    {
      v51 = 0x8E38E38E38E38E39LL * (v50 >> 3);
      if ( v51 >= 0x38E38E38E38E38FLL )
        sub_1000AA1F4(&__p);
      __p = operator new(v50);
      v75 = (char *)__p + 72 * v51;
      v74 = (void **)sub_1000AA208((int)&v75, v49, v48, (std::string *)__p);
    }
    LiveViewManager::SetCameraUUID((char *)this + 224, &__p, v33);
    v52 = (void **)__p;
    if ( __p )
    {
      v53 = v74;
      if ( v74 == __p )
      {
        v54 = __p;
      }
      else
      {
        do
        {
          v55 = v53 - 9;
          if ( *((char *)v53 - 49) < 0 )
            operator delete(*(v53 - 9));
          v53 = v55;
        }
        while ( v55 != v52 );
        v54 = __p;
      }
      v74 = v52;
      operator delete(v54);
    }
    v56 = *((_QWORD *)this + 140);
    v57 = v56 + 307848;
    *(_BYTE *)(v56 + 410512) = 0;
    memset(&__str, 0, sizeof(__str));
    v58 = *(atomic_uint **)(v56 + 307848);
    v72[0] = v58;
    v72[1] = *(atomic_uint **)(v57 + 8);
    v72[2] = *(atomic_uint **)(v57 + 16);
    if ( v58 )
      atomic_fetch_add(v58, 1u);
    v59 = lumixtether::DeviceAdapter::CreateMultiviewParam(this, v72, &__str);
    if ( v72[0] && atomic_fetch_add(v72[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v72[0], 2, 8);
    if ( v59 )
    {
      std::string::basic_string(&v69, &__str);
      v70 = v81;
      v71[0] = *(_OWORD *)v82;
      *(_OWORD *)((char *)v71 + 12) = *(_OWORD *)&v82[12];
      LiveViewManager::SetSelectedCameraUUID((char *)this + 224, &v69);
      if ( SHIBYTE(v69.__r_.__value_.__r.__words[2]) < 0 )
        operator delete(v69.__r_.__value_.__l.__data_);
    }
    LiveViewManager::SetVideoAdapter(
      (lumixtether::DeviceAdapter *)((char *)this + 224),
      (lumixtether::DeviceAdapter *)((char *)this + 16));
    LiveViewManager::StartLiveAsync((lumixtether::DeviceAdapter *)((char *)this + 224));
    *(_BYTE *)(*((_QWORD *)this + 140) + 410384LL) = 1;
    if ( SHIBYTE(__str.__r_.__value_.__r.__words[2]) < 0 )
      operator delete(__str.__r_.__value_.__l.__data_);
    goto LABEL_107;
  }
  v40 = *((_QWORD *)this + 140);
  v41 = *(atomic_uint **)(v40 + 307848);
  if ( v41 )
  {
    atomic_fetch_add(v41, 1u);
    v40 = *((_QWORD *)this + 140);
    v42 = *(atomic_uint **)(v40 + 307848);
  }
  else
  {
    v42 = nullptr;
  }
  v43 = (atomic_uint **)(v40 + 307856);
  memset(&__str, 0, sizeof(__str));
  v76[0] = v42;
  v76[1] = *v43;
  v76[2] = v43[1];
  if ( v42 )
    atomic_fetch_add(v42, 1u);
  v44 = lumixtether::DeviceAdapter::CreateMultiviewParam(this, v76, &__str);
  if ( v76[0] && atomic_fetch_add(v76[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v76[0], 2, 8);
  if ( !v44 )
  {
LABEL_80:
    if ( SHIBYTE(__str.__r_.__value_.__r.__words[2]) < 0 )
      operator delete(__str.__r_.__value_.__l.__data_);
    if ( v41 && atomic_fetch_add(v41, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v41, 2, 8);
    goto LABEL_85;
  }
  if ( !v82[16] )
  {
    v45 = v84;
    if ( v84 == v85 )
    {
      sub_1000ACCF0(&v83, &__str);
    }
    else
    {
      std::string::basic_string(v84, &__str);
      v46 = v81;
      v47 = *(_OWORD *)v82;
      *(_OWORD *)((char *)v45[2].__r_.__value_.__r.__words + 4) = *(_OWORD *)&v82[12];
      *(_OWORD *)&v45[1].__r_.__value_.__r.__words[2] = v47;
      *(_OWORD *)&v45[1].__r_.__value_.__l.__data_ = v46;
      v84 = v45 + 3;
    }
    goto LABEL_80;
  }
  lumixtether::DeviceAdapter::setLiveviewPause(this);
  *(_BYTE *)(*((_QWORD *)this + 140) + 410384LL) = 1;
  if ( SHIBYTE(__str.__r_.__value_.__r.__words[2]) < 0 )
    operator delete(__str.__r_.__value_.__l.__data_);
  if ( v41 && atomic_fetch_add(v41, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v41, 2, 8);
LABEL_107:
  v60 = v83;
  if ( v83 )
  {
    v61 = v84;
    if ( v84 == v83 )
    {
      v62 = v83;
    }
    else
    {
      do
      {
        v63 = v61 - 3;
        if ( SHIBYTE(v61[-3].__r_.__value_.__r.__words[2]) < 0 )
          operator delete(v61[-3].__r_.__value_.__l.__data_);
        v61 = v63;
      }
      while ( v63 != v60 );
      v62 = v83;
    }
    v84 = v60;
    operator delete(v62);
  }
  return 1;
}
