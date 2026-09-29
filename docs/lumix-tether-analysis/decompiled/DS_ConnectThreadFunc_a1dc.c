// __ZN11lumixtether12DeviceSearch17ConnectThreadFuncEv @ 0x10000a1dc (imagebase-relative)
__int64 __fastcall lumixtether::DeviceSearch::ConnectThreadFunc(lumixtether::DeviceSearch *this)
{
  lumixtether::DeviceAdapter *DeviceAdapter; // x0
  __int64 *v3; // x0
  __int64 v4; // x0
  ApplicationData *SDKValue; // x0
  lumixtether::DeviceAdapter *v6; // x0
  ApplicationData *v7; // x0
  __int64 v8; // x0
  __int64 result; // x0
  __int64 v10; // x0
  ApplicationData *v11; // x0
  __int64 v12; // x0
  __int128 *v13; // x8
  lumixtether::DeviceAdapter *v14; // x0
  __int128 v15; // kr00_16
  __int64 v16; // x9
  __int64 v17; // x0
  ApplicationData *v18; // x0
  __int64 v19; // x0
  __int128 v20; // [xsp+0h] [xbp-70h] BYREF
  __int64 v21; // [xsp+10h] [xbp-60h]
  __int128 v22; // [xsp+18h] [xbp-58h] BYREF
  __int64 v23; // [xsp+28h] [xbp-48h]
  __int128 v24; // [xsp+30h] [xbp-40h] BYREF
  __int64 v25; // [xsp+40h] [xbp-30h]
  __int128 v26; // [xsp+48h] [xbp-28h] BYREF
  __int64 v27; // [xsp+58h] [xbp-18h]

  DeviceAdapter = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(this);
  v3 = lumixtether::DeviceAdapter::camIndividualId((__int64 *)&v26, DeviceAdapter);
  if ( !v27 )
  {
    v14 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)v3);
    v3 = lumixtether::DeviceAdapter::camModelName((__int64 *)&v24, v14);
    v15 = v26;
    v26 = v24;
    v24 = v15;
    v16 = v27;
    v27 = v25;
    v25 = v16;
    if ( (_QWORD)v15 )
    {
      if ( atomic_fetch_add((atomic_uint *volatile)v15, 0xFFFFFFFF) == 1 )
        v3 = (__int64 *)QArrayData::deallocate(v24, 2, 8);
    }
  }
  v4 = ApplicationData::getDeviceAdapter((ApplicationData *)v3);
  lumixtether::DeviceAdapter::setCamConnectStatus(v4, 1);
  if ( (lumixtether::DeviceSearch::GetSDKCapability(this) & 1) != 0 )
  {
    SDKValue = (ApplicationData *)lumixtether::DeviceSearch::GetSDKValue(this);
    if ( ((unsigned __int8)SDKValue & 1) != 0 )
    {
      v6 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(SDKValue);
      v7 = (ApplicationData *)lumixtether::DeviceAdapter::set_file_target_for_camera_list(v6);
      v8 = ApplicationData::getDeviceAdapter(v7);
      result = lumixtether::DeviceAdapter::setCamConnectStatus(v8, 2);
      goto LABEL_21;
    }
    result = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    if ( (result & 1) == 0 )
    {
      v17 = ApplicationData::getDeviceAdapter((ApplicationData *)result);
      v18 = (ApplicationData *)lumixtether::DeviceAdapter::setCamConnectStatus(v17, 3);
      v19 = ApplicationData::getDeviceAdapter(v18);
      v20 = v26;
      v21 = v27;
      if ( (_QWORD)v26 )
        atomic_fetch_add((atomic_uint *volatile)v26, 1u);
      result = lumixtether::DeviceAdapter::notifyConnectErrMsg(v19, &v20);
      if ( (_QWORD)v20 )
      {
        if ( atomic_fetch_add((atomic_uint *volatile)v20, 0xFFFFFFFF) == 1 )
        {
          v13 = &v20;
          goto LABEL_20;
        }
      }
    }
  }
  else
  {
    result = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    if ( (result & 1) == 0 )
    {
      v10 = ApplicationData::getDeviceAdapter((ApplicationData *)result);
      v11 = (ApplicationData *)lumixtether::DeviceAdapter::setCamConnectStatus(v10, 3);
      v12 = ApplicationData::getDeviceAdapter(v11);
      v22 = v26;
      v23 = v27;
      if ( (_QWORD)v26 )
        atomic_fetch_add((atomic_uint *volatile)v26, 1u);
      result = lumixtether::DeviceAdapter::notifyConnectErrMsg(v12, &v22);
      if ( (_QWORD)v22 )
      {
        if ( atomic_fetch_add((atomic_uint *volatile)v22, 0xFFFFFFFF) == 1 )
        {
          v13 = &v22;
LABEL_20:
          result = QArrayData::deallocate(*(_QWORD *)v13, 2, 8);
        }
      }
    }
  }
LABEL_21:
  if ( (_QWORD)v26 )
  {
    if ( atomic_fetch_add((atomic_uint *volatile)v26, 0xFFFFFFFF) == 1 )
      return QArrayData::deallocate(v26, 2, 8);
  }
  return result;
}
