// __ZN11lumixtether13DeviceAdapter17selectPtpipDeviceEP34_tag_LMX_PTPIP_CONNECT_DEVICE_INFOPj @ 0x100042ef8
__int64 __fastcall lumixtether::DeviceAdapter::selectPtpipDevice(
        lumixtether::DeviceAdapter *a1,
        __int64 a2,
        _DWORD *a3)
{
  lumixtether::DeviceAdapter *v5; // x27
  _DWORD *v6; // x8
  __int64 v7; // x9
  _DWORD *v8; // x22
  __int64 v9; // x22
  size_t v10; // x0
  size_t v11; // x0
  atomic_uint *v12; // x26
  __int64 v13; // x24
  __int64 v14; // x24
  __int64 v15; // x25
  __int64 v16; // x8
  _QWORD *v17; // x28
  _QWORD *v18; // x19
  lumixtether::DeviceAdapter *v19; // x20
  __int64 v20; // x26
  __int64 v21; // x27
  _QWORD *v22; // x8
  __int64 v23; // x8
  __int64 v24; // x9
  _QWORD *v25; // t1
  int v26; // w0
  __int64 v27; // x20
  size_t v28; // x0
  size_t v29; // x0
  atomic_uint *v30; // x19
  char v31; // w23
  __int64 v32; // x8
  size_t v33; // x0
  size_t v34; // x0
  __int64 v35; // x19
  size_t v36; // x0
  __int64 v37; // x21
  __int128 v38; // q0
  __int128 v39; // q1
  __int64 v40; // x8
  __int64 v41; // x22
  lumixtether::DeviceAdapter *v42; // x24
  __int64 v43; // x19
  __int64 v44; // x26
  atomic_uint **v45; // x27
  __int64 v46; // x28
  __int64 v47; // x8
  atomic_uint *v48; // x21
  _QWORD *v49; // x20
  atomic_uint *v50; // x8
  __int64 v51; // x8
  atomic_uint *v52; // x9
  atomic_uint **v53; // t1
  atomic_uint *v54; // x8
  atomic_uint *v55; // x9
  __int64 v56; // x8
  void *v57; // x0
  __int64 v58; // x21
  size_t v59; // x0
  atomic_uint *v60; // x19
  size_t v61; // x0
  atomic_uint *v62; // x19
  __int64 v63; // x19
  size_t v64; // x0
  __int64 v65; // x20
  atomic_uint *v66; // x8
  atomic_uint *v67; // x0
  atomic_uint **v68; // x19
  atomic_uint **v69; // x21
  atomic_uint *v70; // x0
  atomic_uint *v71; // x8
  atomic_uint *v72; // x9
  atomic_uint *v74; // [xsp+0h] [xbp-300h]
  atomic_uint *v75[3]; // [xsp+8h] [xbp-2F8h] BYREF
  atomic_uint *v76[3]; // [xsp+20h] [xbp-2E0h] BYREF
  atomic_uint *v77; // [xsp+38h] [xbp-2C8h] BYREF
  __int128 v78; // [xsp+40h] [xbp-2C0h]
  __int128 v79; // [xsp+50h] [xbp-2B0h] BYREF
  __int64 v80; // [xsp+60h] [xbp-2A0h]
  __int128 v81; // [xsp+68h] [xbp-298h] BYREF
  __int64 v82; // [xsp+78h] [xbp-288h]
  __int128 v83; // [xsp+80h] [xbp-280h] BYREF
  __int64 v84; // [xsp+90h] [xbp-270h]
  _BYTE v85[24]; // [xsp+98h] [xbp-268h] BYREF
  __int128 v86; // [xsp+B0h] [xbp-250h] BYREF
  __int128 v87; // [xsp+C0h] [xbp-240h]
  _OWORD v88[3]; // [xsp+D0h] [xbp-230h] BYREF
  _OWORD v89[3]; // [xsp+100h] [xbp-200h] BYREF
  __int128 v90; // [xsp+130h] [xbp-1D0h]
  _BYTE v91[32]; // [xsp+140h] [xbp-1C0h]
  __int128 v92; // [xsp+160h] [xbp-1A0h] BYREF
  __int64 v93; // [xsp+170h] [xbp-190h]
  __int128 v94; // [xsp+178h] [xbp-188h] BYREF
  __int64 v95; // [xsp+188h] [xbp-178h]
  __int128 v96; // [xsp+190h] [xbp-170h] BYREF
  __int64 v97; // [xsp+1A0h] [xbp-160h]
  __int128 v98; // [xsp+1A8h] [xbp-158h] BYREF
  __int64 v99; // [xsp+1B8h] [xbp-148h]
  __int128 v100; // [xsp+1C0h] [xbp-140h] BYREF
  __int64 v101; // [xsp+1D0h] [xbp-130h]
  int v102; // [xsp+1DCh] [xbp-124h] BYREF
  _QWORD v103[3]; // [xsp+1E0h] [xbp-120h] BYREF
  __int128 v104; // [xsp+1F8h] [xbp-108h] BYREF
  __int64 v105; // [xsp+208h] [xbp-F8h]
  __int128 v106; // [xsp+210h] [xbp-F0h] BYREF
  __int64 v107; // [xsp+220h] [xbp-E0h]
  __int128 v108; // [xsp+228h] [xbp-D8h] BYREF
  __int64 v109; // [xsp+238h] [xbp-C8h]
  atomic_uint *v110; // [xsp+240h] [xbp-C0h] BYREF
  __int128 v111; // [xsp+258h] [xbp-A8h] BYREF
  __int64 v112; // [xsp+268h] [xbp-98h]
  _BYTE __s[37]; // [xsp+270h] [xbp-90h] BYREF

  v5 = a1;
  v6 = (_DWORD *)(*((_QWORD *)a1 + 140) + 160120LL);
  v7 = (unsigned int)*v6;
  v8 = &v6[515 * v7];
  *v6 = v7 + 1;
  memcpy(v8 + 130, (const void *)a2, 0x80Cu);
  v9 = (unsigned int)v8[130];
  QString::fromUcs4(
    &v110,
    *((_QWORD *)v5 + 140) + 160120LL + 2060LL * (unsigned int)(*(_DWORD *)(*((_QWORD *)v5 + 140) + 160120LL) - 1) + 1552,
    -1);
  v10 = strlen((const char *)(a2 + 3108));
  QString::fromUtf8(v85, v10, a2 + 3108);
  v108 = *(_OWORD *)v85;
  v109 = *(_QWORD *)&v85[16];
  v11 = strlen((const char *)(a2 + 3368));
  QString::fromUtf8(v85, v11, a2 + 3368);
  v12 = *(atomic_uint **)v85;
  v106 = *(_OWORD *)v85;
  v107 = *(_QWORD *)&v85[16];
  if ( *(_QWORD *)v85 )
    atomic_fetch_add(*(atomic_uint *volatile *)v85, 1u);
  v74 = v12;
  v13 = sub_100043D1C(&v106, 8);
  if ( (_QWORD)v106 && atomic_fetch_add((atomic_uint *volatile)v106, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v106, 2, 8);
  *(_QWORD *)sub_100043DB0(*((_QWORD *)v5 + 140) + 410424LL, &v108) = v13;
  QString::fromUtf8(v85, 0, &unk_10014269A);
  v14 = *(_QWORD *)&v85[8];
  v104 = *(_OWORD *)v85;
  v15 = *(_QWORD *)&v85[16];
  v105 = *(_QWORD *)&v85[16];
  v16 = *(_QWORD *)(*((_QWORD *)v5 + 140) + 410416LL);
  if ( v16 )
    v17 = *(_QWORD **)(v16 + 8);
  else
    v17 = nullptr;
  if ( v16 )
    v18 = (_QWORD *)(v16 + 16);
  else
    v18 = nullptr;
  if ( v18 != v17 )
  {
    v19 = v5;
    v21 = *((_QWORD *)&v108 + 1);
    v20 = v109;
    while ( v20 != v17[6] || (unsigned int)QtPrivate::compareStrings(v20, v21, v20, v17[5], 1) )
    {
      v22 = (_QWORD *)v17[1];
      if ( v22 )
      {
        do
        {
          v17 = v22;
          v22 = (_QWORD *)*v22;
        }
        while ( v22 );
      }
      else
      {
        v23 = (__int64)(v17 + 2);
        if ( *(_QWORD **)v17[2] == v17 )
        {
          v17 = (_QWORD *)v17[2];
        }
        else
        {
          do
          {
            v24 = *(_QWORD *)v23;
            v25 = *(_QWORD **)(*(_QWORD *)v23 + 16LL);
            v23 = *(_QWORD *)v23 + 16LL;
            v17 = v25;
          }
          while ( *v25 != v24 );
        }
      }
      if ( v17 == v18 )
        goto LABEL_25;
    }
    QString::operator=(&v104, v17 + 7);
    v14 = *((_QWORD *)&v104 + 1);
    v15 = v105;
LABEL_25:
    v12 = v74;
    v5 = v19;
  }
  QString::toLocal8Bit_helper(v103, v14, v15);
  if ( !v103[0] || *(int *)v103[0] >= 2 )
    QByteArray::reallocData(v103, v103[2], 1);
  memset(__s, 0, sizeof(__s));
  v102 = 0;
  v26 = LMX_func_api_SelectPnPDevice(v9, *((_QWORD *)v5 + 140) + 160120LL, __s, 0, v103[1], 1, &v102);
  if ( a3 )
    *a3 = v102;
  if ( !v26 )
  {
LABEL_100:
    v65 = 0;
    v66 = (atomic_uint *)v103[0];
    if ( !v103[0] )
      goto LABEL_116;
    goto LABEL_114;
  }
  v27 = *((_QWORD *)v5 + 140);
  v28 = strlen(__s);
  QString::fromUtf8(v85, v28, __s);
  v100 = *(_OWORD *)v85;
  v101 = *(_QWORD *)&v85[16];
  sub_10002A628(v27 + 410368, &v100);
  if ( (_QWORD)v100 && atomic_fetch_add((atomic_uint *volatile)v100, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v100, 2, 8);
  v29 = strlen(__s);
  QString::fromUtf8(v85, v29, __s);
  v30 = *(atomic_uint **)v85;
  v98 = *(_OWORD *)v85;
  v99 = *(_QWORD *)&v85[16];
  v31 = lumixtether::DeviceAdapter::adp_LMX_func_api_OpenSession(v5, &v98);
  if ( v30 && atomic_fetch_add(v30, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v98, 2, 8);
  if ( !v31 )
  {
    v59 = strlen(__s);
    QString::fromUtf8(v85, v59, __s);
    v60 = *(atomic_uint **)v85;
    v96 = *(_OWORD *)v85;
    v97 = *(_QWORD *)&v85[16];
    lumixtether::DeviceAdapter::adp_LMX_func_api_CloseSession((__int64)v5, (__int64)&v96);
    if ( v60 && atomic_fetch_add(v60, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v96, 2, 8);
    v61 = strlen(__s);
    QString::fromUtf8(v85, v61, __s);
    v62 = *(atomic_uint **)v85;
    v94 = *(_OWORD *)v85;
    v95 = *(_QWORD *)&v85[16];
    lumixtether::DeviceAdapter::adp_LMX_func_api_CloseDevice((__int64)v5, (atomic_uint **)&v94);
    if ( v62 && atomic_fetch_add(v62, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v94, 2, 8);
    v63 = *((_QWORD *)v5 + 140);
    v64 = strlen(__s);
    QString::fromUtf8(v85, v64, __s);
    v92 = *(_OWORD *)v85;
    v93 = *(_QWORD *)&v85[16];
    sub_10002E070(v63 + 410368, &v92);
    if ( (_QWORD)v92 && atomic_fetch_add((atomic_uint *volatile)v92, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v92, 2, 8);
    goto LABEL_100;
  }
  v32 = *(_QWORD *)(*((_QWORD *)v5 + 140) + 410272LL);
  if ( !v32 || !*(_QWORD *)(v32 + 24) )
    lumixtether::DeviceAdapter::adp_LMX_func_api_Ctrl_LiveView_Stop(v5);
  *(_DWORD *)v85 = 0;
  WORD6(v90) = 0;
  BYTE14(v90) = 0;
  *(_QWORD *)&v91[24] = 0;
  *(_OWORD *)&v85[8] = 0u;
  v86 = 0u;
  v87 = 0u;
  memset(v88, 0, sizeof(v88));
  memset(v89, 0, sizeof(v89));
  LOWORD(v90) = 0;
  DWORD1(v90) = 0;
  *(_DWORD *)((char *)&v90 + 7) = 0;
  *(_QWORD *)v91 = 0;
  v91[8] = 0;
  *(_WORD *)&v91[20] = 0;
  *(_QWORD *)&v91[12] = 0;
  v33 = strlen(__s);
  QString::fromUtf8(&v111, v33, __s);
  v83 = v111;
  v84 = v112;
  v34 = strlen(__s);
  QString::fromUtf8(&v111, v34, __s);
  v81 = v111;
  v82 = v112;
  lumixtether::DeviceAdapter::getCameraInfo(v5, v9, &v83, &v81, *(unsigned __int8 *)(a2 + 3404), v85);
  if ( (_QWORD)v81 && atomic_fetch_add((atomic_uint *volatile)v81, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v81, 2, 8);
  if ( (_QWORD)v83 && atomic_fetch_add((atomic_uint *volatile)v83, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v83, 2, 8);
  std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)v5 + 140) + 410304LL));
  v35 = *((_QWORD *)v5 + 140);
  v36 = strlen(__s);
  QString::fromUtf8(&v111, v36, __s);
  v79 = v111;
  v80 = v112;
  v37 = sub_10002AE78(v35 + 410272, &v79);
  *(_DWORD *)v37 = *(_DWORD *)v85;
  QString::operator=(v37 + 8, &v85[8]);
  QString::operator=(v37 + 32, (char *)&v86 + 8);
  QString::operator=(v37 + 56, v88);
  QString::operator=(v37 + 80, (char *)&v88[1] + 8);
  QString::operator=(v37 + 104, v89);
  QString::operator=(v37 + 128, (char *)&v89[1] + 8);
  v39 = *(_OWORD *)v91;
  v38 = *(_OWORD *)&v91[16];
  *(_OWORD *)(v37 + 152) = v90;
  *(_OWORD *)(v37 + 168) = v39;
  *(_OWORD *)(v37 + 184) = v38;
  if ( (_QWORD)v79 && atomic_fetch_add((atomic_uint *volatile)v79, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v79, 2, 8);
  std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)v5 + 140) + 410304LL));
  v77 = *((atomic_uint **)&v86 + 1);
  v78 = v87;
  if ( *((_QWORD *)&v86 + 1) )
    atomic_fetch_add(*((atomic_uint *volatile *)&v86 + 1), 1u);
  lumixtether::DeviceAdapter::setFileTargetById(v5, &v77);
  if ( v77 && atomic_fetch_add(v77, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v77, 2, 8);
  v40 = *((_QWORD *)v5 + 140);
  if ( *(int *)(v40 + 307832) >= 1 )
  {
    v41 = 0;
    while ( 1 )
    {
      std::recursive_mutex::lock((std::recursive_mutex *)(v40 + 410304));
      v42 = v5;
      v43 = *((_QWORD *)v5 + 140);
      v44 = *(_QWORD *)(v43 + 410272);
      v45 = v44 ? *(atomic_uint ***)(v44 + 8) : nullptr;
      v46 = v44 ? v44 + 16 : 0LL;
      if ( (atomic_uint **)v46 != v45 )
      {
        v47 = v43 + 200 * v41;
        v48 = *(atomic_uint **)(v47 + 307920);
        v49 = (_QWORD *)(v47 + 307912);
        while ( v48 != v45[13] || (unsigned int)QtPrivate::compareStrings(v48, *v49, v48, v45[12], 1) )
        {
          v50 = v45[1];
          if ( v50 )
          {
            do
            {
              v45 = (atomic_uint **)v50;
              v50 = *(atomic_uint **)v50;
            }
            while ( v50 );
          }
          else
          {
            v51 = (__int64)(v45 + 2);
            if ( *(atomic_uint ***)v45[2] == v45 )
            {
              v45 = (atomic_uint **)v45[2];
            }
            else
            {
              do
              {
                v52 = *(atomic_uint **)v51;
                v53 = *(atomic_uint ***)(*(_QWORD *)v51 + 16LL);
                v51 = *(_QWORD *)v51 + 16LL;
                v45 = v53;
              }
              while ( *v53 != v52 );
            }
          }
          if ( v45 == (atomic_uint **)v46 )
            goto LABEL_58;
        }
        if ( v44 && *(_QWORD *)(v44 + 24) == 1 )
          break;
      }
LABEL_58:
      std::recursive_mutex::unlock((std::recursive_mutex *)(v43 + 410304));
      ++v41;
      v5 = v42;
      v40 = *((_QWORD *)v42 + 140);
      if ( v41 >= *(int *)(v40 + 307832) )
        goto LABEL_85;
    }
    v54 = v45[4];
    v55 = v45[5];
    v76[0] = v54;
    v76[1] = v55;
    v76[2] = v45[6];
    if ( v54 )
      atomic_fetch_add(v54, 1u);
    v5 = v42;
    lumixtether::DeviceAdapter::setCameraInfoOfSelectedCamera(v42, v76);
    if ( v76[0] && atomic_fetch_add(v76[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v76[0], 2, 8);
    std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)v42 + 140) + 410304LL));
    v40 = *((_QWORD *)v42 + 140);
  }
LABEL_85:
  v56 = v40 + 307816;
  if ( *(_QWORD *)v56 )
    v57 = *(void **)v56;
  else
    v57 = &QString::_empty;
  v12 = v74;
  if ( !(unsigned int)QString::compare_helper(v57, *(_QWORD *)(v56 + 8), &unk_10014269A, -1, 1) )
  {
    std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)v5 + 140) + 410304LL));
    v58 = *((_QWORD *)v5 + 140) + 410272LL;
    if ( *(_QWORD *)v58 )
    {
      sub_1000A9464(*((_QWORD *)v5 + 140) + 410272LL);
    }
    else
    {
      v67 = (atomic_uint *)operator new(0x20u);
      *v67 = 0;
      *((_QWORD *)v67 + 3) = 0;
      *((_QWORD *)v67 + 2) = 0;
      *((_QWORD *)v67 + 1) = v67 + 4;
      *(_QWORD *)v58 = v67;
      atomic_fetch_add(v67, 1u);
    }
    v68 = *(atomic_uint ***)(*(_QWORD *)v58 + 8LL);
    v69 = (atomic_uint **)(*((_QWORD *)v5 + 140) + 410272LL);
    if ( *v69 )
    {
      sub_1000A9464(*((_QWORD *)v5 + 140) + 410272LL);
    }
    else
    {
      v70 = (atomic_uint *)operator new(0x20u);
      *v70 = 0;
      *((_QWORD *)v70 + 3) = 0;
      *((_QWORD *)v70 + 2) = 0;
      *((_QWORD *)v70 + 1) = v70 + 4;
      *v69 = v70;
      atomic_fetch_add(v70, 1u);
    }
    if ( v68 != (atomic_uint **)(*v69 + 4) )
    {
      v71 = v68[4];
      v72 = v68[5];
      v75[0] = v71;
      v75[1] = v72;
      v75[2] = v68[6];
      if ( v71 )
        atomic_fetch_add(v71, 1u);
      lumixtether::DeviceAdapter::setCameraInfoOfSelectedCamera(v5, v75);
      if ( v75[0] && atomic_fetch_add(v75[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v75[0], 2, 8);
    }
    std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)v5 + 140) + 410304LL));
  }
  lumixtether::DeviceAdapter::camera_list_update_camera_list(v5, 0);
  lumixtether::DeviceAdapter::cameraListChanged(v5);
  sub_1000A7354(v85);
  v65 = 1;
  v66 = (atomic_uint *)v103[0];
  if ( v103[0] )
  {
LABEL_114:
    if ( atomic_fetch_add(v66, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v103[0], 1, 8);
  }
LABEL_116:
  if ( (_QWORD)v104 && atomic_fetch_add((atomic_uint *volatile)v104, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v104, 2, 8);
  if ( v12 && atomic_fetch_add(v12, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v12, 2, 8);
  if ( (_QWORD)v108 && atomic_fetch_add((atomic_uint *volatile)v108, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v108, 2, 8);
  if ( v110 && atomic_fetch_add(v110, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v110, 2, 8);
  return v65;
}
