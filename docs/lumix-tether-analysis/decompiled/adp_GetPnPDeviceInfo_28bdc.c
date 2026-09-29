// __ZN11lumixtether13DeviceAdapter33adp_LMX_func_api_GetPnPDeviceInfoEb @ 0x100028bdc (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetPnPDeviceInfo(atomic_ullong *this, int a2)
{
  __int64 v3; // x8
  QBasicMutex *v4; // x20
  bool v5; // w8
  int PnPDeviceInfo; // w21
  __int64 v7; // x9
  __int64 v8; // x22
  __int64 v9; // x23
  __int64 v10; // x24
  SearchCameraListItemObject *v11; // x21
  __int64 v12; // x8
  __int64 v13; // x2
  __int128 v15; // [xsp+8h] [xbp-88h] BYREF
  __int64 v16; // [xsp+18h] [xbp-78h]
  __int128 v17; // [xsp+20h] [xbp-70h] BYREF
  __int64 v18; // [xsp+30h] [xbp-60h]
  __int128 v19; // [xsp+38h] [xbp-58h] BYREF
  __int64 v20; // [xsp+48h] [xbp-48h]

  v3 = 0;
  v4 = (QBasicMutex *)(this + 141);
  atomic_compare_exchange_strong_explicit(
    this + 141,
    (unsigned __int64 *)&v3,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  v5 = v3 == 0;
  if ( a2 )
  {
    if ( !v5 )
      return 1;
  }
  else if ( !v5 )
  {
    QBasicMutex::lockInternal((QBasicMutex *)(this + 141));
  }
  lumixtether::DeviceAdapter::ClearSearchList((lumixtether::DeviceAdapter *)this);
  PnPDeviceInfo = LMX_func_api_GetPnPDeviceInfo(*(this + 140) + 160120, 0);
  v7 = 1;
  atomic_compare_exchange_strong_explicit(
    this + 141,
    (unsigned __int64 *)&v7,
    0,
    memory_order_release,
    memory_order_relaxed);
  if ( v7 != 1 )
    QBasicMutex::unlockInternal(v4);
  if ( PnPDeviceInfo != 1 )
    return 0;
  v8 = *(unsigned int *)(*(this + 140) + 160120);
  if ( (_DWORD)v8 )
  {
    v9 = 160128;
    v10 = 160640;
    do
    {
      QString::fromUtf8(&v19, 0, &unk_10014269A);
      v17 = v19;
      v18 = v20;
      lumixtether::DeviceAdapter::GetUSBDevFriendlyName(
        this,
        *(this + 140) + v10,
        *(_QWORD *)(*(this + 140) + v9),
        &v17);
      v11 = (SearchCameraListItemObject *)operator new(0x1678u);
      SearchCameraListItemObject::SearchCameraListItemObject(v11, nullptr);
      v12 = *(this + 140);
      v13 = *(_QWORD *)(v12 + v9);
      v15 = v17;
      v16 = v18;
      if ( (_QWORD)v17 )
        atomic_fetch_add((atomic_uint *volatile)v17, 1u);
      SearchCameraListItemObject::SetConnectUsbDevInfo(v11, v12 + v10, v13, &v15);
      if ( (_QWORD)v15 && atomic_fetch_add((atomic_uint *volatile)v15, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v15, 2, 8);
      SearchCameraListItemObject::setEnable(v11, 1);
      SearchCameraListItemObject::setAuthorize(v11, 1);
      lumixtether::DeviceAdapter::AddSortSearchList((lumixtether::DeviceAdapter *)this, v11);
      if ( (_QWORD)v17 )
      {
        if ( atomic_fetch_add((atomic_uint *volatile)v17, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v17, 2, 8);
      }
      v10 += 2060;
      v9 += 8;
      --v8;
    }
    while ( v8 );
  }
  lumixtether::DeviceAdapter::searchListChanged((lumixtether::DeviceAdapter *)this);
  return 1;
}
