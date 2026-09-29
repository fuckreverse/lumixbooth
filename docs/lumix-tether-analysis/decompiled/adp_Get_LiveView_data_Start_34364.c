// __ZN11lumixtether13DeviceAdapter40adp_LMX_func_api_Get_LiveView_data_StartEv @ 0x100034364 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Get_LiveView_data_Start(
        lumixtether::DeviceAdapter *this)
{
  __int64 v1; // x19
  __int128 v3; // [xsp+0h] [xbp-40h] BYREF
  __int64 v4; // [xsp+10h] [xbp-30h]
  __int128 v5; // [xsp+18h] [xbp-28h] BYREF
  __int64 v6; // [xsp+28h] [xbp-18h]

  v1 = *(_QWORD *)(ApplicationData::getDeviceAdapter(this) + 1144);
  if ( !v1 )
    return 0;
  QString::fromUtf8(&v5, 0, &unk_10014269A);
  v3 = v5;
  v4 = v6;
  lumixtether::DeviceAdapterCallback::pushArgumentCheck(v1, 4294902529LL, 0, &v3);
  if ( (_QWORD)v3 )
  {
    if ( atomic_fetch_add((atomic_uint *volatile)v3, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v3, 2, 8);
  }
  return 1;
}
