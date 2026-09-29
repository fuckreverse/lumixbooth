// __ZN11lumixtether13DeviceAdapter42adp_LMX_func_api_ptpip_Get_Connection_TypeEv @ 0x10009f008 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_Get_Connection_Type(atomic_ullong *this)
{
  __int64 v2; // x8
  QBasicMutex *v3; // x0
  __int64 v4; // x8
  unsigned int v6; // [xsp+Ch] [xbp-14h] BYREF

  v6 = 0;
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
  LMX_func_api_ptpip_Get_Connection_Type(&v6, nullptr);
  if ( *(_DWORD *)(*(this + 140) + 410380) == 1 )
  {
    v4 = 1;
    atomic_compare_exchange_strong_explicit(
      this + 141,
      (unsigned __int64 *)&v4,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v4 != 1 )
      QBasicMutex::unlockInternal((QBasicMutex *)(this + 141));
  }
  return v6;
}
