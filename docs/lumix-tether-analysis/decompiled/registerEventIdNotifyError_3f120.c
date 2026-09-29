// __ZN11lumixtether13DeviceAdapter26registerEventIdNotifyErrorEjj7QString @ 0x10003f120 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::registerEventIdNotifyError(
        __int64 result,
        int a2,
        __int64 a3,
        atomic_uint **a4)
{
  atomic_uint *v4; // x8
  atomic_uint *v5; // x9
  atomic_uint *v6[3]; // [xsp+8h] [xbp-28h] BYREF

  if ( a2 == 364904464 )
  {
    v4 = *a4;
    v5 = a4[1];
    v6[0] = v4;
    v6[1] = v5;
    v6[2] = a4[2];
    if ( v4 )
      atomic_fetch_add(v4, 1u);
    result = lumixtether::DeviceAdapter::adp_LMX_func_api_GetSetupInfoError(result, v6);
    if ( v6[0] )
    {
      if ( atomic_fetch_add(v6[0], 0xFFFFFFFF) == 1 )
        return QArrayData::deallocate(v6[0], 2, 8);
    }
  }
  return result;
}
