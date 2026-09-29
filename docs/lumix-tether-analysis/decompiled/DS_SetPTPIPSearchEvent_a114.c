// __ZN11lumixtether12DeviceSearch19SetPTPIPSearchEventEj @ 0x10000a114 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceSearch::SetPTPIPSearchEvent(__int64 this, int a2)
{
  if ( (unsigned int)(a2 - 2) >= 2 )
  {
    if ( a2 == 1 )
      *(_BYTE *)(this + 145) = 1;
  }
  else
  {
    *(_BYTE *)(this + 144) = 0;
  }
  return this;
}
