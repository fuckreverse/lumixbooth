// __ZN11lumixtether13DeviceAdapter32registerEventPtpipStopSearchProcEjPvS1_ @ 0x100044a28 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::registerEventPtpipStopSearchProc(
        __int64 this,
        int a2,
        void *a3,
        void *a4)
{
  if ( a2 == 3 )
  {
    *(_BYTE *)(*(_QWORD *)(this + 1120) + 410385LL) = 0;
    return lumixtether::DeviceSearch::SetPTPIPSearchEvent((lumixtether::DeviceSearch *)(this + 1288), 3u);
  }
  return this;
}
