// __ZN9ObjectAdd6doWorkEv @ 0x1000be2d0
ApplicationData *__fastcall ObjectAdd::doWork(ObjectAdd *this)
{
  ApplicationData *result; // x0
  lumixtether::DeviceAdapter *DeviceAdapter; // x0
  __int64 v4; // x7
  __int64 v5; // x0
  __int64 v6; // x9
  int v7; // [xsp+9Ch] [xbp-24h] BYREF
  unsigned int v8; // [xsp+A0h] [xbp-20h] BYREF
  unsigned int v9; // [xsp+A4h] [xbp-1Ch] BYREF
  unsigned __int64 v10; // [xsp+A8h] [xbp-18h] BYREF

  result = (ApplicationData *)ObjectAdd::popData(this, &v8, &v9, &v10);
  if ( (_DWORD)result && (v9 & 0xFFFFFFFE) == 4 )
  {
    DeviceAdapter = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(result);
    result = (ApplicationData *)lumixtether::DeviceAdapter::fileTarget(DeviceAdapter);
    if ( (unsigned int)((_DWORD)result - 1) <= 1 )
    {
      v5 = *((_QWORD *)this + 11);
      v6 = *(_QWORD *)(v5 + 16);
      *(_DWORD *)(v6 + 4) = v8;
      *(_QWORD *)(v6 + 8) = v10;
      v7 = 0;
      return (ApplicationData *)QMetaObject::invokeMethod(
                                  v5,
                                  "setObjectAddStateValue",
                                  130,
                                  0,
                                  0,
                                  &v7,
                                  "int",
                                  v4,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0);
    }
  }
  return result;
}
