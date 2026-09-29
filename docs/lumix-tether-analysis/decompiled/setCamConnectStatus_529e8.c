// __ZN11lumixtether13DeviceAdapter19setCamConnectStatusENS_9Utilities19CameraConnectStatusE @ 0x1000529e8 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::setCamConnectStatus(__int64 result, int a2)
{
  _DWORD *v2; // x8

  v2 = (_DWORD *)(*(_QWORD *)(result + 1120) + 307740LL);
  if ( *v2 != a2 )
  {
    *v2 = a2;
    return lumixtether::DeviceAdapter::camConnectStatusChanged();
  }
  return result;
}
