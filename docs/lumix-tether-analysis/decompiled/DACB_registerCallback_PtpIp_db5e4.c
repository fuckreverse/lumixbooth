// __ZN11lumixtether21DeviceAdapterCallback22registerCallback_PtpIpEjPvS1_S1_ @ 0x1000db5e4 (imagebase-relative)
__int64 *__fastcall lumixtether::DeviceAdapterCallback::registerCallback_PtpIp(
        lumixtether::DeviceAdapterCallback *this,
        void *a2,
        _BYTE *a3,
        void *a4,
        void *a5)
{
  int v7; // w21
  lumixtether::DeviceAdapter *DeviceAdapter; // x0
  __int64 *result; // x0
  lumixtether::DeviceAdapter *v10; // x0
  void *v11; // x0
  lumixtether::DeviceAdapter *v12; // x0
  __int64 v13; // x0
  lumixtether::DeviceAdapter *v14; // x0
  __int64 v15; // x0
  _QWORD *v16; // x20
  size_t v17; // x0
  lumixtether::DeviceAdapter *v18; // x0
  lumixtether::DeviceAdapter *v19; // x0
  __int64 v20; // x0
  __int128 v21; // [xsp+0h] [xbp-50h] BYREF
  __int64 v22; // [xsp+10h] [xbp-40h]
  __int128 v23; // [xsp+18h] [xbp-38h] BYREF
  __int64 v24; // [xsp+28h] [xbp-28h]

  v7 = (int)this;
  DeviceAdapter = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(this);
  result = (__int64 *)lumixtether::DeviceAdapter::isFwupProcessing(DeviceAdapter);
  if ( !(_DWORD)result )
  {
LABEL_11:
    result = (__int64 *)ApplicationData::getDeviceAdapter((ApplicationData *)result);
    switch ( v7 )
    {
      case 1:
        v12 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)result);
        result = (__int64 *)lumixtether::DeviceAdapter::registerEventPtpipFoundDeviceProc(v12, 1u, a2, a3);
        break;
      case 2:
        v15 = ApplicationData::getDeviceAdapter((ApplicationData *)result);
        result = (__int64 *)lumixtether::DeviceAdapter::registerEventPtpipTimeoutSearchProc(v15, 2, a2, a3);
        break;
      case 3:
        v13 = ApplicationData::getDeviceAdapter((ApplicationData *)result);
        result = (__int64 *)lumixtether::DeviceAdapter::registerEventPtpipStopSearchProc(v13, 3, a2, a3);
        break;
      case 4:
        v16 = (_QWORD *)result[143];
        if ( a3 )
          v17 = strlen(a3);
        else
          v17 = 0;
        QString::fromUtf8(&v23, v17, a3);
        v21 = v23;
        v22 = v24;
        result = (__int64 *)lumixtether::DeviceAdapterCallback::pushArgumentLast(v16, -65227, 0, (__int64)&v21);
        if ( (_QWORD)v21 && atomic_fetch_add((atomic_uint *volatile)v21, 0xFFFFFFFF) == 1 )
        {
          v20 = v21;
          return (__int64 *)QArrayData::deallocate(v20, 2, 8);
        }
        break;
      case 5:
        v14 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)result);
        result = (__int64 *)lumixtether::DeviceAdapter::registerEventPtpipAuthenticatePwProc(v14, 5u, a2, a3);
        break;
      case 6:
        v18 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)result);
        result = (__int64 *)lumixtether::DeviceAdapter::registerEventPtpipFoundConnectedDeviceProc(v18, 6u, a2, a3);
        break;
      default:
        return result;
    }
    return result;
  }
  v10 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)result);
  result = lumixtether::DeviceAdapter::getFwupProcessingUUID((__int64 *)&v23, v10);
  if ( !a3
    || !*a3
    || (*((_QWORD *)&v23 + 1) ? (v11 = *((void **)&v23 + 1)) : (v11 = &QString::_empty),
        result = (__int64 *)QString::compare_helper(v11, v24, a3, -1, 1),
        (_DWORD)result) )
  {
    if ( (_QWORD)v23 && atomic_fetch_add((atomic_uint *volatile)v23, 0xFFFFFFFF) == 1 )
      result = (__int64 *)QArrayData::deallocate(v23, 2, 8);
    goto LABEL_11;
  }
  if ( v7 == 4 )
  {
    v19 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)result);
    result = (__int64 *)lumixtether::DeviceAdapter::setDisconnectInFwup(v19, 1);
  }
  if ( (_QWORD)v23 && atomic_fetch_add((atomic_uint *volatile)v23, 0xFFFFFFFF) == 1 )
  {
    v20 = v23;
    return (__int64 *)QArrayData::deallocate(v20, 2, 8);
  }
  return result;
}
