// __ZN11lumixtether21DeviceAdapterCallback16registerCallbackEjjPc @ 0x1000daef4 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapterCallback::registerCallback(
        lumixtether::DeviceAdapterCallback *this,
        unsigned int a2,
        char *a3,
        char *a4)
{
  int v6; // w22
  ApplicationData *DeviceAdapter; // x0
  __int64 v8; // x20
  lumixtether::DeviceAdapter *v9; // x0
  ApplicationData *selected_camera_uuid; // x0
  void *v11; // x0
  int v12; // w8
  lumixtether::DeviceAdapter *v13; // x0
  ApplicationData *isMultiviewMode; // x0
  lumixtether::DeviceAdapter *v15; // x0
  ApplicationData *isFwupProcessing; // x0
  lumixtether::DeviceAdapter *v17; // x0
  void *v18; // x0
  lumixtether::DeviceAdapter *v19; // x0
  size_t v20; // x0
  atomic_uint *v21; // x0
  size_t v22; // x0
  size_t v23; // x0
  int v24; // w22
  size_t v25; // x0
  ApplicationData *v26; // x0
  __int64 v27; // x20
  void *v28; // x0
  lumixtether::DeviceAdapter *v29; // x0
  __int128 v31; // [xsp+8h] [xbp-108h] BYREF
  __int64 v32; // [xsp+18h] [xbp-F8h]
  atomic_uint *v33[3]; // [xsp+20h] [xbp-F0h] BYREF
  atomic_uint *v34[3]; // [xsp+38h] [xbp-D8h] BYREF
  atomic_uint *v35; // [xsp+50h] [xbp-C0h] BYREF
  __int128 v36; // [xsp+68h] [xbp-A8h] BYREF
  __int64 v37; // [xsp+78h] [xbp-98h]
  __int128 v38; // [xsp+80h] [xbp-90h] BYREF
  __int64 v39; // [xsp+90h] [xbp-80h]
  __int128 v40; // [xsp+98h] [xbp-78h] BYREF
  __int64 v41; // [xsp+A8h] [xbp-68h]
  atomic_uint *v42; // [xsp+B0h] [xbp-60h] BYREF
  void *v43; // [xsp+B8h] [xbp-58h]
  __int64 v44; // [xsp+C0h] [xbp-50h]
  __int128 v45; // [xsp+C8h] [xbp-48h] BYREF
  __int64 v46; // [xsp+D8h] [xbp-38h]

  v6 = (int)this;
  DeviceAdapter = (ApplicationData *)ApplicationData::getDeviceAdapter(this);
  v8 = *((_QWORD *)DeviceAdapter + 143);
  v9 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(DeviceAdapter);
  selected_camera_uuid = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_selected_camera_uuid(
                                              (__int64 *)&v42,
                                              v9);
  if ( *a3 )
  {
    v11 = v43 ? v43 : &QString::_empty;
    selected_camera_uuid = (ApplicationData *)QString::compare_helper(v11, v44, a3, -1, 1);
    if ( (_DWORD)selected_camera_uuid )
    {
      if ( v6 > 234881055 )
      {
        if ( v6 <= 310378768 )
        {
          if ( v6 == 234881056 || v6 == 268435523 )
            goto LABEL_19;
          v12 = 301989904;
        }
        else if ( v6 > 535953408 )
        {
          if ( v6 == 535953409 )
            goto LABEL_19;
          v12 = 1090519061;
        }
        else
        {
          if ( v6 == 310378769 )
            goto LABEL_19;
          v12 = 364904464;
        }
      }
      else
      {
        if ( (unsigned int)(v6 - 1) < 6 )
          goto LABEL_19;
        v12 = 134217808;
      }
      if ( v6 != v12 )
        goto LABEL_78;
    }
  }
LABEL_19:
  v13 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(selected_camera_uuid);
  isMultiviewMode = (ApplicationData *)lumixtether::DeviceAdapter::isMultiviewMode(v13);
  if ( (_DWORD)isMultiviewMode && (v6 == 16777232 || v6 == 33554896) )
    goto LABEL_78;
  v15 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(isMultiviewMode);
  isFwupProcessing = (ApplicationData *)lumixtether::DeviceAdapter::isFwupProcessing(v15);
  if ( (_DWORD)isFwupProcessing )
  {
    v17 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(isFwupProcessing);
    isFwupProcessing = (ApplicationData *)lumixtether::DeviceAdapter::getFwupProcessingUUID((__int64 *)&v45, v17);
    if ( !*a3
      || (*((_QWORD *)&v45 + 1) ? (v18 = *((void **)&v45 + 1)) : (v18 = &QString::_empty),
          (isFwupProcessing = (ApplicationData *)QString::compare_helper(v18, v46, a3, -1, 1), (_DWORD)isFwupProcessing)
       || (unsigned int)(v6 - 1) < 6) )
    {
LABEL_29:
      if ( (_QWORD)v45 && atomic_fetch_add((atomic_uint *volatile)v45, 0xFFFFFFFF) == 1 )
        isFwupProcessing = (ApplicationData *)QArrayData::deallocate(v45, 2, 8);
      goto LABEL_32;
    }
    if ( v6 == 535953409 )
    {
      v29 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(isFwupProcessing);
      lumixtether::DeviceAdapter::setDisconnectInFwup(v29, 1);
    }
    else if ( v6 == 1090519061 )
    {
      goto LABEL_29;
    }
    if ( (_QWORD)v45 && atomic_fetch_add((atomic_uint *volatile)v45, 0xFFFFFFFF) == 1 )
    {
      v21 = (atomic_uint *)v45;
      goto LABEL_77;
    }
    goto LABEL_78;
  }
LABEL_32:
  if ( !v8 )
    goto LABEL_78;
  if ( v6 <= 16777231 )
  {
    if ( (unsigned int)(v6 - 1) < 6 )
    {
LABEL_35:
      v19 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(isFwupProcessing);
      lumixtether::DeviceAdapter::registerEventFWUPStatusProc(v19, v6, a2);
      goto LABEL_78;
    }
LABEL_46:
    v22 = strlen(a3);
    QString::fromUtf8(&v45, v22, a3);
    v31 = v45;
    v32 = v46;
    lumixtether::DeviceAdapterCallback::pushArgumentLast((_QWORD *)v8, v6, a2, (__int64)&v31);
    if ( (_QWORD)v31 && atomic_fetch_add((atomic_uint *volatile)v31, 0xFFFFFFFF) == 1 )
    {
      v21 = (atomic_uint *)v31;
      goto LABEL_77;
    }
    goto LABEL_78;
  }
  if ( v6 > 268435519 )
  {
    switch ( v6 )
    {
      case 268435520:
        v24 = *(_DWORD *)(v8 + 32);
        v25 = strlen(a3);
        QString::fromUtf8(&v45, v25, a3);
        v36 = v45;
        v37 = v46;
        v26 = (ApplicationData *)lumixtether::DeviceAdapterCallback::pushArgumentLast(
                                   (_QWORD *)v8,
                                   268435520,
                                   a2,
                                   (__int64)&v36);
        if ( (_QWORD)v36 && atomic_fetch_add((atomic_uint *volatile)v36, 0xFFFFFFFF) == 1 )
          v26 = (ApplicationData *)QArrayData::deallocate(v36, 2, 8);
        if ( (a2 & 0xF000000) != 0x1000000 && *(_DWORD *)(v8 + 32) > v24 )
        {
          v27 = ApplicationData::getDeviceAdapter(v26);
          sub_1000BE134((int)&v35, a3);
          lumixtether::DeviceAdapter::registerAddEventReceivedNotify(v27, 268435520);
          if ( v35 )
          {
            if ( atomic_fetch_add(v35, 0xFFFFFFFF) == 1 )
            {
              v21 = v35;
              goto LABEL_77;
            }
          }
        }
        goto LABEL_78;
      case 301989904:
        if ( v43 )
          v28 = v43;
        else
          v28 = &QString::_empty;
        if ( (unsigned int)QString::compare_helper(v28, v44, a3, -1, 1) )
        {
          sub_1000BE134((int)v34, a3);
          lumixtether::DeviceAdapterCallback::pushArgumentLast((_QWORD *)v8, -64759, a2, (__int64)v34);
          if ( v34[0] && atomic_fetch_add(v34[0], 0xFFFFFFFF) == 1 )
          {
            v21 = v34[0];
            goto LABEL_77;
          }
        }
        else
        {
          sub_1000BE134((int)v33, a3);
          lumixtether::DeviceAdapterCallback::pushArgumentLast((_QWORD *)v8, 301989904, a2, (__int64)v33);
          if ( v33[0] && atomic_fetch_add(v33[0], 0xFFFFFFFF) == 1 )
          {
            v21 = v33[0];
            goto LABEL_77;
          }
        }
        goto LABEL_78;
      case 1090519061:
        goto LABEL_35;
    }
    goto LABEL_46;
  }
  if ( v6 == 16777232 )
  {
    v23 = strlen(a3);
    QString::fromUtf8(&v45, v23, a3);
    v40 = v45;
    v41 = v46;
    lumixtether::DeviceAdapterCallback::pushArgumentCheck2(v8, 16777232, a2, (__int64)&v40);
    if ( (_QWORD)v40 && atomic_fetch_add((atomic_uint *volatile)v40, 0xFFFFFFFF) == 1 )
    {
      v21 = (atomic_uint *)v40;
      goto LABEL_77;
    }
    goto LABEL_78;
  }
  if ( v6 != 33554544 && v6 != 33554720 )
    goto LABEL_46;
  v20 = strlen(a3);
  QString::fromUtf8(&v45, v20, a3);
  v38 = v45;
  v39 = v46;
  lumixtether::DeviceAdapterCallback::pushArgumentCheck((_QWORD *)v8, v6, a2, (__int64)&v38);
  if ( (_QWORD)v38 && atomic_fetch_add((atomic_uint *volatile)v38, 0xFFFFFFFF) == 1 )
  {
    v21 = (atomic_uint *)v38;
LABEL_77:
    QArrayData::deallocate(v21, 2, 8);
  }
LABEL_78:
  if ( v42 && atomic_fetch_add(v42, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v42, 2, 8);
  return 0;
}
