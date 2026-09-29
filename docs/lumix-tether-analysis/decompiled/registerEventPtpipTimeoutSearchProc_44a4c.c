// __ZN11lumixtether13DeviceAdapter35registerEventPtpipTimeoutSearchProcEjPvS1_ @ 0x100044a4c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::registerEventPtpipTimeoutSearchProc(
        __int64 this,
        int a2,
        void *a3,
        void *a4)
{
  if ( a2 == 2 )
  {
    *(_BYTE *)(*(_QWORD *)(this + 1120) + 410385LL) = 0;
    return lumixtether::DeviceSearch::SetPTPIPSearchEvent((lumixtether::DeviceSearch *)(this + 1288), 2u);
  }
  return this;
}
