// __ZN11lumixtether13DeviceAdapter42adp_LMX_func_api_ptpip_Set_Connection_TypeEi @ 0x10002d470 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_Set_Connection_Type(
        lumixtether::DeviceAdapter *this,
        unsigned int a2)
{
  unsigned int *v4; // x8
  unsigned int v5; // w9
  __int64 v6; // x8
  int v7; // w21
  __int64 v8; // x8
  unsigned int v9; // w0

  v4 = (unsigned int *)(*((_QWORD *)this + 140) + 410380LL);
  v5 = a2;
  if ( *v4 != a2 )
  {
    *v4 = a2;
    lumixtether::DeviceAdapter::connectionTypeChanged(this, a2);
    v5 = *(_DWORD *)(*((_QWORD *)this + 140) + 410380LL);
  }
  if ( v5 == 1 )
  {
    v6 = 0;
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)this + 141,
      (unsigned __int64 *)&v6,
      1u,
      memory_order_acquire,
      memory_order_acquire);
    if ( v6 )
      QBasicMutex::lockInternal((lumixtether::DeviceAdapter *)((char *)this + 1128));
  }
  v7 = LMX_func_api_ptpip_Set_Connection_Type(a2, nullptr);
  if ( *(_DWORD *)(*((_QWORD *)this + 140) + 410380LL) == 1 )
  {
    v8 = 1;
    atomic_compare_exchange_strong_explicit(
      (atomic_ullong *volatile)this + 141,
      (unsigned __int64 *)&v8,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v8 != 1 )
      QBasicMutex::unlockInternal((lumixtether::DeviceAdapter *)((char *)this + 1128));
  }
  if ( v7 == 1 )
  {
    if ( a2 == 1 )
      v9 = 12000;
    else
      v9 = 5000;
    LMX_func_api_ptpip_Set_SendCommand_TimeOutVal_Config(v9, nullptr);
    return 1;
  }
  else
  {
    lumixtether::DeviceAdapter::settingErrorNotify(this);
    return 0;
  }
}
