// __ZN11lumixtether13DeviceAdapter21adp_LMX_func_api_InitEv @ 0x100028964
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Init(atomic_ullong *this)
{
  __int64 v1; // x8
  atomic_ullong *v2; // x19
  __int64 v3; // x8

  v1 = 0;
  v2 = this + 141;
  atomic_compare_exchange_strong_explicit(
    this + 141,
    (unsigned __int64 *)&v1,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v1 )
    QBasicMutex::lockInternal((QBasicMutex *)(this + 141));
  LMX_func_api_Init();
  v3 = 1;
  atomic_compare_exchange_strong_explicit(v2, (unsigned __int64 *)&v3, 0, memory_order_release, memory_order_relaxed);
  if ( v3 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v2);
  return 1;
}
