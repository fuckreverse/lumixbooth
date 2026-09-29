// __ZN11lumixtether13DeviceAdapter30adp_LMX_func_api_DbgLog_ConfigEv @ 0x100028b5c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_DbgLog_Config(atomic_ullong *this)
{
  __int64 v1; // x8
  atomic_ullong *v2; // x19
  lumixtether::ApplicationSettings *ApplicationSettings; // x0
  ApplicationData *v4; // x0
  lumixtether::ApplicationSettings *v5; // x0
  int v6; // w0
  __int64 v7; // x8

  v1 = 0;
  v2 = this + 141;
  atomic_compare_exchange_strong_explicit(
    this + 141,
    (unsigned __int64 *)&v1,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v1 )
    this = (atomic_ullong *)QBasicMutex::lockInternal((QBasicMutex *)(this + 141));
  ApplicationSettings = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings((ApplicationData *)this);
  v4 = (ApplicationData *)lumixtether::ApplicationSettings::debugEnable(ApplicationSettings);
  if ( (_DWORD)v4 )
  {
    v5 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v4);
    v6 = lumixtether::ApplicationSettings::sdkDbgType(v5);
    if ( v6 == 2 )
      LODWORD(v4) = 2;
    else
      LODWORD(v4) = v6 == 1;
  }
  LMX_func_api_DbgLog_Config((unsigned int)v4, nullptr);
  v7 = 1;
  atomic_compare_exchange_strong_explicit(v2, (unsigned __int64 *)&v7, 0, memory_order_release, memory_order_relaxed);
  if ( v7 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v2);
  return 1;
}
