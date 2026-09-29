// __ZN11lumixtether13DeviceAdapter26adp_Lmx_func_api_Get_ErrorERm @ 0x1000346d4 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_Lmx_func_api_Get_Error(atomic_ullong *this, unsigned __int64 *a2)
{
  __int64 v3; // x8
  atomic_ullong *v4; // x19
  __int64 v5; // x8

  v3 = 0;
  v4 = this + 141;
  atomic_compare_exchange_strong_explicit(
    this + 141,
    (unsigned __int64 *)&v3,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v3 )
    QBasicMutex::lockInternal((QBasicMutex *)(this + 141));
  *a2 = (unsigned int)Lmx_func_api_Get_Error();
  v5 = 1;
  atomic_compare_exchange_strong_explicit(v4, (unsigned __int64 *)&v5, 0, memory_order_release, memory_order_relaxed);
  if ( v5 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v4);
  return 1;
}
