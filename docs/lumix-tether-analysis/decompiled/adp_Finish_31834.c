// __ZN11lumixtether13DeviceAdapter23adp_LMX_func_api_FinishEv @ 0x100031834
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Finish(atomic_ullong *this)
{
  __int64 v2; // x8
  QBasicMutex *v3; // x0
  int v4; // w20
  __int64 v5; // x8

  if ( *(_DWORD *)(*(this + 140) + 410380) == 1 )
  {
    v2 = 0;
    v3 = (QBasicMutex *)(this + 141);
    atomic_compare_exchange_strong_explicit(
      this + 141,
      (unsigned __int64 *)&v2,
      1u,
      memory_order_acquire,
      memory_order_acquire);
    if ( v2 )
      QBasicMutex::lockInternal(v3);
  }
  v4 = LMX_func_api_Finish(nullptr);
  if ( *(_DWORD *)(*(this + 140) + 410380) == 1 )
  {
    v5 = 1;
    atomic_compare_exchange_strong_explicit(
      this + 141,
      (unsigned __int64 *)&v5,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v5 != 1 )
      QBasicMutex::unlockInternal((QBasicMutex *)(this + 141));
  }
  return v4 == 1;
}
