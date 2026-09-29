// __ZN11lumixtether13DeviceAdapter18connectPtpipDeviceEP34_tag_LMX_PTPIP_CONNECT_DEVICE_INFOPj @ 0x100043f78
__int64 __fastcall lumixtether::DeviceAdapter::connectPtpipDevice(
        lumixtether::DeviceAdapter *a1,
        const char *a2,
        _DWORD *a3)
{
  const char *v4; // x21
  _DWORD *v6; // x8
  __int64 v7; // x9
  _DWORD *v8; // x22
  __int64 v9; // x22
  size_t v10; // x0
  size_t v11; // x0
  atomic_uint *v12; // x27
  __int64 v13; // x24
  __int64 v14; // x24
  __int64 v15; // x25
  __int64 v16; // x8
  _QWORD *v17; // x19
  _QWORD *v18; // x28
  _DWORD *v19; // x21
  __int64 v20; // x23
  atomic_uint *v21; // x22
  __int64 v22; // x26
  __int64 v23; // x27
  _QWORD *v24; // x8
  __int64 v25; // x8
  __int64 v26; // x9
  _QWORD *v27; // t1
  int v28; // w0
  __int64 v29; // x23
  size_t v30; // x0
  size_t v31; // x0
  atomic_uint *v32; // x19
  char v33; // w23
  size_t v34; // x0
  size_t v35; // x0
  __int64 v36; // x19
  size_t v37; // x0
  __int64 v38; // x21
  __int128 v39; // q0
  __int128 v40; // q1
  __int64 v41; // x20
  atomic_uint *v42; // x8
  size_t v43; // x0
  atomic_uint *v44; // x19
  size_t v45; // x0
  atomic_uint *v46; // x19
  __int64 v47; // x19
  size_t v48; // x0
  const char *v50; // [xsp+0h] [xbp-2D0h]
  atomic_uint *v51; // [xsp+8h] [xbp-2C8h] BYREF
  __int128 v52; // [xsp+10h] [xbp-2C0h]
  __int128 v53; // [xsp+20h] [xbp-2B0h] BYREF
  __int64 v54; // [xsp+30h] [xbp-2A0h]
  __int128 v55; // [xsp+38h] [xbp-298h] BYREF
  __int64 v56; // [xsp+48h] [xbp-288h]
  __int128 v57; // [xsp+50h] [xbp-280h] BYREF
  __int64 v58; // [xsp+60h] [xbp-270h]
  _BYTE v59[24]; // [xsp+68h] [xbp-268h] BYREF
  __int128 v60; // [xsp+80h] [xbp-250h] BYREF
  __int128 v61; // [xsp+90h] [xbp-240h]
  _OWORD v62[3]; // [xsp+A0h] [xbp-230h] BYREF
  _OWORD v63[3]; // [xsp+D0h] [xbp-200h] BYREF
  __int128 v64; // [xsp+100h] [xbp-1D0h]
  _BYTE v65[32]; // [xsp+110h] [xbp-1C0h]
  __int128 v66; // [xsp+130h] [xbp-1A0h] BYREF
  __int64 v67; // [xsp+140h] [xbp-190h]
  __int128 v68; // [xsp+148h] [xbp-188h] BYREF
  __int64 v69; // [xsp+158h] [xbp-178h]
  __int128 v70; // [xsp+160h] [xbp-170h] BYREF
  __int64 v71; // [xsp+170h] [xbp-160h]
  __int128 v72; // [xsp+178h] [xbp-158h] BYREF
  __int64 v73; // [xsp+188h] [xbp-148h]
  __int128 v74; // [xsp+190h] [xbp-140h] BYREF
  __int64 v75; // [xsp+1A0h] [xbp-130h]
  int v76; // [xsp+1ACh] [xbp-124h] BYREF
  _QWORD v77[3]; // [xsp+1B0h] [xbp-120h] BYREF
  __int128 v78; // [xsp+1C8h] [xbp-108h] BYREF
  __int64 v79; // [xsp+1D8h] [xbp-F8h]
  __int128 v80; // [xsp+1E0h] [xbp-F0h] BYREF
  __int64 v81; // [xsp+1F0h] [xbp-E0h]
  __int128 v82; // [xsp+1F8h] [xbp-D8h] BYREF
  __int64 v83; // [xsp+208h] [xbp-C8h]
  atomic_uint *v84; // [xsp+210h] [xbp-C0h] BYREF
  __int128 v85; // [xsp+228h] [xbp-A8h] BYREF
  __int64 v86; // [xsp+238h] [xbp-98h]
  _BYTE __s[37]; // [xsp+240h] [xbp-90h] BYREF

  v4 = a2;
  v6 = (_DWORD *)(*((_QWORD *)a1 + 140) + 160120LL);
  v7 = (unsigned int)*v6;
  v8 = &v6[515 * v7];
  *v6 = v7 + 1;
  memcpy(v8 + 130, a2, 0x80Cu);
  v9 = (unsigned int)v8[130];
  QString::fromUcs4(
    &v84,
    *((_QWORD *)a1 + 140) + 160120LL + 2060LL * (unsigned int)(*(_DWORD *)(*((_QWORD *)a1 + 140) + 160120LL) - 1) + 1552,
    -1);
  v10 = strlen(v4 + 3108);
  QString::fromUtf8(v59, v10, v4 + 3108);
  v82 = *(_OWORD *)v59;
  v83 = *(_QWORD *)&v59[16];
  v11 = strlen(v4 + 3368);
  QString::fromUtf8(v59, v11, v4 + 3368);
  v12 = *(atomic_uint **)v59;
  v80 = *(_OWORD *)v59;
  v81 = *(_QWORD *)&v59[16];
  if ( *(_QWORD *)v59 )
    atomic_fetch_add(*(atomic_uint *volatile *)v59, 1u);
  v13 = sub_100043D1C(&v80, 8);
  if ( (_QWORD)v80 && atomic_fetch_add((atomic_uint *volatile)v80, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v80, 2, 8);
  *(_QWORD *)sub_100043DB0(*((_QWORD *)a1 + 140) + 410424LL, &v82) = v13;
  QString::fromUtf8(v59, 0, &unk_10014269A);
  v14 = *(_QWORD *)&v59[8];
  v78 = *(_OWORD *)v59;
  v15 = *(_QWORD *)&v59[16];
  v79 = *(_QWORD *)&v59[16];
  v16 = *(_QWORD *)(*((_QWORD *)a1 + 140) + 410416LL);
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
    v50 = v4;
    v19 = a3;
    v20 = v9;
    v21 = v12;
    v23 = *((_QWORD *)&v82 + 1);
    v22 = v83;
    while ( v22 != v17[6] || (unsigned int)QtPrivate::compareStrings(v22, v23, v22, v17[5], 1) )
    {
      v24 = (_QWORD *)v17[1];
      if ( v24 )
      {
        do
        {
          v17 = v24;
          v24 = (_QWORD *)*v24;
        }
        while ( v24 );
      }
      else
      {
        v25 = (__int64)(v17 + 2);
        if ( *(_QWORD **)v17[2] == v17 )
        {
          v17 = (_QWORD *)v17[2];
        }
        else
        {
          do
          {
            v26 = *(_QWORD *)v25;
            v27 = *(_QWORD **)(*(_QWORD *)v25 + 16LL);
            v25 = *(_QWORD *)v25 + 16LL;
            v17 = v27;
          }
          while ( *v27 != v26 );
        }
      }
      if ( v17 == v18 )
        goto LABEL_25;
    }
    QString::operator=(&v78, v17 + 7);
    v14 = *((_QWORD *)&v78 + 1);
    v15 = v79;
LABEL_25:
    v12 = v21;
    v9 = v20;
    a3 = v19;
    v4 = v50;
  }
  QString::toLocal8Bit_helper(v77, v14, v15);
  if ( !v77[0] || *(int *)v77[0] >= 2 )
    QByteArray::reallocData(v77, v77[2], 1);
  memset(__s, 0, sizeof(__s));
  v76 = 0;
  v28 = LMX_func_api_SelectPnPDevice(v9, *((_QWORD *)a1 + 140) + 160120LL, __s, 0, v77[1], 1, &v76);
  if ( a3 )
    *a3 = v76;
  if ( !v28 )
  {
LABEL_64:
    v41 = 0;
    v42 = (atomic_uint *)v77[0];
    if ( !v77[0] )
      goto LABEL_67;
    goto LABEL_65;
  }
  v29 = *((_QWORD *)a1 + 140);
  v30 = strlen(__s);
  QString::fromUtf8(v59, v30, __s);
  v74 = *(_OWORD *)v59;
  v75 = *(_QWORD *)&v59[16];
  sub_10002A628(v29 + 410368, &v74);
  if ( (_QWORD)v74 && atomic_fetch_add((atomic_uint *volatile)v74, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v74, 2, 8);
  v31 = strlen(__s);
  QString::fromUtf8(v59, v31, __s);
  v32 = *(atomic_uint **)v59;
  v72 = *(_OWORD *)v59;
  v73 = *(_QWORD *)&v59[16];
  v33 = lumixtether::DeviceAdapter::adp_LMX_func_api_OpenSession(a1, &v72);
  if ( v32 && atomic_fetch_add(v32, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v72, 2, 8);
  if ( !v33 )
  {
    v43 = strlen(__s);
    QString::fromUtf8(v59, v43, __s);
    v44 = *(atomic_uint **)v59;
    v70 = *(_OWORD *)v59;
    v71 = *(_QWORD *)&v59[16];
    lumixtether::DeviceAdapter::adp_LMX_func_api_CloseSession((__int64)a1, (__int64)&v70);
    if ( v44 && atomic_fetch_add(v44, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v70, 2, 8);
    v45 = strlen(__s);
    QString::fromUtf8(v59, v45, __s);
    v46 = *(atomic_uint **)v59;
    v68 = *(_OWORD *)v59;
    v69 = *(_QWORD *)&v59[16];
    lumixtether::DeviceAdapter::adp_LMX_func_api_CloseDevice((__int64)a1, (atomic_uint **)&v68);
    if ( v46 && atomic_fetch_add(v46, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v68, 2, 8);
    v47 = *((_QWORD *)a1 + 140);
    v48 = strlen(__s);
    QString::fromUtf8(v59, v48, __s);
    v66 = *(_OWORD *)v59;
    v67 = *(_QWORD *)&v59[16];
    sub_10002E070(v47 + 410368, &v66);
    if ( (_QWORD)v66 && atomic_fetch_add((atomic_uint *volatile)v66, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v66, 2, 8);
    goto LABEL_64;
  }
  *(_DWORD *)v59 = 0;
  WORD6(v64) = 0;
  BYTE14(v64) = 0;
  *(_QWORD *)&v65[24] = 0;
  *(_OWORD *)&v59[8] = 0u;
  v60 = 0u;
  v61 = 0u;
  memset(v62, 0, sizeof(v62));
  memset(v63, 0, sizeof(v63));
  LOWORD(v64) = 0;
  DWORD1(v64) = 0;
  *(_DWORD *)((char *)&v64 + 7) = 0;
  *(_QWORD *)v65 = 0;
  v65[8] = 0;
  *(_WORD *)&v65[20] = 0;
  *(_QWORD *)&v65[12] = 0;
  v34 = strlen(__s);
  QString::fromUtf8(&v85, v34, __s);
  v57 = v85;
  v58 = v86;
  v35 = strlen(__s);
  QString::fromUtf8(&v85, v35, __s);
  v55 = v85;
  v56 = v86;
  lumixtether::DeviceAdapter::getCameraInfo(a1, v9, &v57, &v55, *((unsigned __int8 *)v4 + 3404), v59);
  if ( (_QWORD)v55 && atomic_fetch_add((atomic_uint *volatile)v55, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v55, 2, 8);
  if ( (_QWORD)v57 && atomic_fetch_add((atomic_uint *volatile)v57, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v57, 2, 8);
  std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)a1 + 140) + 410304LL));
  v36 = *((_QWORD *)a1 + 140);
  v37 = strlen(__s);
  QString::fromUtf8(&v85, v37, __s);
  v53 = v85;
  v54 = v86;
  v38 = sub_10002AE78(v36 + 410272, &v53);
  *(_DWORD *)v38 = *(_DWORD *)v59;
  QString::operator=(v38 + 8, &v59[8]);
  QString::operator=(v38 + 32, (char *)&v60 + 8);
  QString::operator=(v38 + 56, v62);
  QString::operator=(v38 + 80, (char *)&v62[1] + 8);
  QString::operator=(v38 + 104, v63);
  QString::operator=(v38 + 128, (char *)&v63[1] + 8);
  v40 = *(_OWORD *)v65;
  v39 = *(_OWORD *)&v65[16];
  *(_OWORD *)(v38 + 152) = v64;
  *(_OWORD *)(v38 + 168) = v40;
  *(_OWORD *)(v38 + 184) = v39;
  if ( (_QWORD)v53 && atomic_fetch_add((atomic_uint *volatile)v53, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v53, 2, 8);
  std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)a1 + 140) + 410304LL));
  v51 = *((atomic_uint **)&v60 + 1);
  v52 = v61;
  if ( *((_QWORD *)&v60 + 1) )
    atomic_fetch_add(*((atomic_uint *volatile *)&v60 + 1), 1u);
  lumixtether::DeviceAdapter::setFileTargetById(a1, &v51);
  if ( v51 && atomic_fetch_add(v51, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v51, 2, 8);
  lumixtether::DeviceAdapter::camera_list_update_camera_list(a1, 0);
  lumixtether::DeviceAdapter::cameraListChanged(a1);
  sub_1000A7354(v59);
  v41 = 1;
  v42 = (atomic_uint *)v77[0];
  if ( v77[0] )
  {
LABEL_65:
    if ( atomic_fetch_add(v42, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v77[0], 1, 8);
  }
LABEL_67:
  if ( (_QWORD)v78 && atomic_fetch_add((atomic_uint *volatile)v78, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v78, 2, 8);
  if ( v12 && atomic_fetch_add(v12, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v12, 2, 8);
  if ( (_QWORD)v82 && atomic_fetch_add((atomic_uint *volatile)v82, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v82, 2, 8);
  if ( v84 && atomic_fetch_add(v84, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v84, 2, 8);
  return v41;
}
