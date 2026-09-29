// __ZN11lumixtether12DeviceSearch11startSearchEbbNS0_16DeviceSearchModeE @ 0x100009bac (imagebase-relative)
bool __fastcall lumixtether::DeviceSearch::startSearch(__int64 a1, char a2, char a3, int a4)
{
  int v4; // w23
  __int64 v10; // [xsp+0h] [xbp-50h] BYREF
  _QWORD v11[2]; // [xsp+8h] [xbp-48h] BYREF
  std::thread v12; // [xsp+18h] [xbp-38h] BYREF

  v4 = *(unsigned __int8 *)(a1 + 144);
  if ( !*(_BYTE *)(a1 + 144) )
  {
    lumixtether::DeviceSearch::stopSearch((lumixtether::DeviceSearch *)a1);
    *(_BYTE *)(a1 + 24) = 0;
    *(_BYTE *)(a1 + 152) = a2;
    *(_BYTE *)(a1 + 153) = a3;
    lumixtether::DeviceSearch::backgroundSearchChanged((lumixtether::DeviceSearch *)a1);
    lumixtether::DeviceSearch::addSearchModeChanged((lumixtether::DeviceSearch *)a1);
    *(_DWORD *)(a1 + 156) = a4;
    v11[0] = lumixtether::DeviceSearch::SearchThreadFunc;
    v11[1] = 0;
    v10 = a1;
    sub_10000ABD0(&v12, v11, &v10);
    if ( *(_QWORD *)(a1 + 16) )
      std::terminate();
    *(std::thread *)(a1 + 16) = v12;
    v12.__t_ = nullptr;
    std::thread::~thread(&v12);
  }
  return v4 == 0;
}
