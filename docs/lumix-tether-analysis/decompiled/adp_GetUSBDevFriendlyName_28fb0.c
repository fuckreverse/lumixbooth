// __ZN11lumixtether13DeviceAdapter21GetUSBDevFriendlyNameEP16_tag_LMX_DEVINFOPwP7QString @ 0x100028fb0 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::GetUSBDevFriendlyName(
        __int64 a1,
        unsigned int *a2,
        __int64 a3,
        __int64 a4)
{
  __int64 result; // x0
  size_t v9; // x0
  atomic_uint *v10; // x19
  size_t v11; // x0
  atomic_uint *v12; // x19
  size_t v13; // x0
  atomic_uint *v14; // x8
  __int64 v15; // x9
  __int64 v16; // x9
  atomic_uint *v17; // x0
  __int64 v18; // x22
  atomic_uint *v19; // x19
  atomic_uint *v20; // x24
  atomic_uint *v21; // x25
  __int64 v22; // x8
  int v23; // w22
  __int64 v24; // x8
  size_t v25; // x0
  atomic_uint *v26; // x23
  char v27; // w22
  size_t v28; // x0
  atomic_uint *v29; // x22
  size_t v30; // x0
  atomic_uint *v31; // x22
  size_t v32; // x0
  atomic_uint *v33; // x8
  __int64 v34; // x9
  __int64 v35; // x9
  size_t v36; // x0
  atomic_uint *v37; // x21
  size_t v38; // x0
  atomic_uint *v39; // x21
  _QWORD v40[3]; // [xsp+0h] [xbp-206B0h] BYREF
  _QWORD v41[3]; // [xsp+18h] [xbp-20698h] BYREF
  __int128 v42; // [xsp+30h] [xbp-20680h] BYREF
  __int64 v43; // [xsp+40h] [xbp-20670h]
  __int128 v44; // [xsp+48h] [xbp-20668h] BYREF
  __int64 v45; // [xsp+58h] [xbp-20658h]
  _QWORD v46[3]; // [xsp+60h] [xbp-20650h] BYREF
  atomic_uint *v47[3]; // [xsp+78h] [xbp-20638h] BYREF
  atomic_uint *v48; // [xsp+90h] [xbp-20620h] BYREF
  atomic_uint *v49; // [xsp+98h] [xbp-20618h]
  atomic_uint *v50; // [xsp+A0h] [xbp-20610h]
  _QWORD v51[3]; // [xsp+A8h] [xbp-20608h] BYREF
  _QWORD v52[3]; // [xsp+C0h] [xbp-205F0h] BYREF
  __int128 v53; // [xsp+D8h] [xbp-205D8h] BYREF
  __int64 v54; // [xsp+E8h] [xbp-205C8h]
  char v55[16]; // [xsp+F0h] [xbp-205C0h] BYREF
  __int128 v56; // [xsp+100h] [xbp-205B0h]
  char v57; // [xsp+110h] [xbp-205A0h]
  char v58[16]; // [xsp+120h] [xbp-20590h] BYREF
  __int128 v59; // [xsp+130h] [xbp-20580h]
  char v60; // [xsp+140h] [xbp-20570h]
  _BYTE v61[2060]; // [xsp+328h] [xbp-20388h] BYREF
  _BYTE __s[37]; // [xsp+20630h] [xbp-80h] BYREF

  result = 0;
  if ( a2 && a3 && a4 )
  {
    memset(__s, 0, sizeof(__s));
    if ( (unsigned int)LMX_func_api_IsConnectedUSBDevice(a3, __s) )
    {
      v60 = 0;
      *(_OWORD *)v58 = 0u;
      v59 = 0u;
      v9 = strlen(__s);
      QString::fromUtf8(v55, v9, __s);
      v10 = *(atomic_uint **)v55;
      v52[0] = *(_QWORD *)v55;
      v52[1] = *(_QWORD *)&v55[8];
      v52[2] = v56;
      lumixtether::DeviceAdapter::dev_mutex_lock(a1, v52);
      if ( v10 && atomic_fetch_add(v10, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v52[0], 2, 8);
      LMX_func_api_Body_SettingInfo_Get_Individual_Id((unsigned __int8 *)v58, __s, nullptr);
      v11 = strlen(__s);
      QString::fromUtf8(v55, v11, __s);
      v12 = *(atomic_uint **)v55;
      v51[0] = *(_QWORD *)v55;
      v51[1] = *(_QWORD *)&v55[8];
      v51[2] = v56;
      lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v51);
      if ( v12 && atomic_fetch_add(v12, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v51[0], 2, 8);
      v13 = strlen(v58);
      QString::fromUtf8(v55, v13, v58);
      v14 = *(atomic_uint **)a4;
      v15 = *(_QWORD *)(a4 + 8);
      *(_OWORD *)a4 = *(_OWORD *)v55;
      *(_QWORD *)v55 = v14;
      *(_QWORD *)&v55[8] = v15;
      v16 = *(_QWORD *)(a4 + 16);
      *(_QWORD *)(a4 + 16) = v56;
      *(_QWORD *)&v56 = v16;
      if ( !v14 || atomic_fetch_add(v14, 0xFFFFFFFF) != 1 )
        return 1;
      v17 = *(atomic_uint **)v55;
LABEL_52:
      QArrayData::deallocate(v17, 2, 8);
      return 1;
    }
    v18 = *a2;
    bzero(v58, 0x20508u);
    *(_DWORD *)v58 = 1;
    *(_QWORD *)&v58[8] = a3;
    memcpy(v61, a2, sizeof(v61));
    v19 = *(atomic_uint **)(*(_QWORD *)(a1 + 1120) + 307848LL);
    v20 = *(atomic_uint **)(*(_QWORD *)(a1 + 1120) + 307856LL);
    v21 = *(atomic_uint **)(*(_QWORD *)(a1 + 1120) + 307864LL);
    if ( v19 )
    {
      atomic_fetch_add(v19, 1u);
      v48 = v19;
      v49 = v20;
      v50 = v21;
      atomic_fetch_add(v19, 1u);
    }
    else
    {
      v48 = nullptr;
      v49 = v20;
      v50 = v21;
    }
    lumixtether::DeviceAdapter::dev_mutex_lock(a1, &v48);
    if ( v48 && atomic_fetch_add(v48, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v48, 2, 8);
    v22 = 0;
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)(a1 + 1128),
      (unsigned __int64 *)&v22,
      1u,
      memory_order_acquire,
      memory_order_acquire);
    if ( v22 )
      QBasicMutex::lockInternal((QBasicMutex *)(a1 + 1128));
    v23 = LMX_func_api_SelectPnPDevice(v18, v58, __s, 0, 0, 0, 0);
    v24 = 1;
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)(a1 + 1128),
      (unsigned __int64 *)&v24,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v24 != 1 )
      QBasicMutex::unlockInternal((QBasicMutex *)(a1 + 1128));
    v47[0] = v19;
    v47[1] = v20;
    v47[2] = v21;
    if ( v19 )
      atomic_fetch_add(v19, 1u);
    lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v47);
    if ( v47[0] && atomic_fetch_add(v47[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v47[0], 2, 8);
    if ( v23 )
    {
      v25 = strlen(__s);
      QString::fromUtf8(v55, v25, __s);
      v26 = *(atomic_uint **)v55;
      v46[0] = *(_QWORD *)v55;
      v46[1] = *(_QWORD *)&v55[8];
      v46[2] = v56;
      v27 = lumixtether::DeviceAdapter::adp_LMX_func_api_OpenSession(a1, v46);
      if ( v26 && atomic_fetch_add(v26, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v46[0], 2, 8);
      if ( v27 == 1 )
      {
        v57 = 0;
        *(_OWORD *)v55 = 0u;
        v56 = 0u;
        v28 = strlen(__s);
        QString::fromUtf8(&v53, v28, __s);
        v29 = (atomic_uint *)v53;
        v44 = v53;
        v45 = v54;
        lumixtether::DeviceAdapter::dev_mutex_lock(a1, &v44);
        if ( v29 && atomic_fetch_add(v29, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v44, 2, 8);
        LMX_func_api_Body_SettingInfo_Get_Individual_Id((unsigned __int8 *)v55, __s, nullptr);
        v30 = strlen(__s);
        QString::fromUtf8(&v53, v30, __s);
        v31 = (atomic_uint *)v53;
        v42 = v53;
        v43 = v54;
        lumixtether::DeviceAdapter::dev_mutex_unlock(a1, &v42);
        if ( v31 && atomic_fetch_add(v31, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v42, 2, 8);
        v32 = strlen(v55);
        QString::fromUtf8(&v53, v32, v55);
        v33 = *(atomic_uint **)a4;
        v34 = *(_QWORD *)(a4 + 8);
        *(_OWORD *)a4 = v53;
        *(_QWORD *)&v53 = v33;
        *((_QWORD *)&v53 + 1) = v34;
        v35 = *(_QWORD *)(a4 + 16);
        *(_QWORD *)(a4 + 16) = v54;
        v54 = v35;
        if ( v33 && atomic_fetch_add(v33, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v53, 2, 8);
      }
      v36 = strlen(__s);
      QString::fromUtf8(v55, v36, __s);
      v37 = *(atomic_uint **)v55;
      v41[0] = *(_QWORD *)v55;
      v41[1] = *(_QWORD *)&v55[8];
      v41[2] = v56;
      lumixtether::DeviceAdapter::adp_LMX_func_api_CloseSession(a1, v41);
      if ( v37 && atomic_fetch_add(v37, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v41[0], 2, 8);
      v38 = strlen(__s);
      QString::fromUtf8(v55, v38, __s);
      v39 = *(atomic_uint **)v55;
      v40[0] = *(_QWORD *)v55;
      v40[1] = *(_QWORD *)&v55[8];
      v40[2] = v56;
      lumixtether::DeviceAdapter::adp_LMX_func_api_CloseDevice(a1, v40);
      if ( v39 && atomic_fetch_add(v39, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v40[0], 2, 8);
      if ( !v19 || atomic_fetch_add(v19, 0xFFFFFFFF) != 1 )
        return 1;
      v17 = v19;
      goto LABEL_52;
    }
    if ( v19 && atomic_fetch_add(v19, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v19, 2, 8);
    return 0;
  }
  return result;
}
