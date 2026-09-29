// __ZN15LiveViewManager18MultiCmdThreadFuncE23_MULTIVIEW_DEVICE_PARAM14_LVM_QUEUE_CMD @ 0x1000d8ba0
void __fastcall LiveViewManager::MultiCmdThreadFunc(__int64 a1, __int64 a2, int a3)
{
  __int64 v4; // x8
  atomic_ullong *v5; // x0
  char *v6; // x0
  __int64 v7; // x8
  atomic_ullong *v8; // x0
  char *v9; // x0
  atomic_ullong *v10; // x0
  __int64 v11; // x8
  std::chrono::nanoseconds __ns; // [xsp+8h] [xbp-18h] BYREF

  if ( a3 == 2 )
  {
    v7 = 0;
    v8 = *(atomic_ullong **)(a2 + 32);
    atomic_compare_exchange_strong_explicit(v8, (unsigned __int64 *)&v7, 1u, memory_order_acquire, memory_order_acquire);
    if ( v7 )
      QBasicMutex::lockInternal((QBasicMutex *)v8);
    if ( *(char *)(a2 + 23) < 0 )
      v9 = *(char **)a2;
    else
      v9 = (char *)a2;
    LMX_func_api_Ctrl_LiveView_Stop(v9, nullptr);
  }
  else
  {
    if ( a3 != 1 )
      return;
    v4 = 0;
    v5 = *(atomic_ullong **)(a2 + 32);
    atomic_compare_exchange_strong_explicit(v5, (unsigned __int64 *)&v4, 1u, memory_order_acquire, memory_order_acquire);
    if ( v4 )
      QBasicMutex::lockInternal((QBasicMutex *)v5);
    if ( *(char *)(a2 + 23) < 0 )
      v6 = *(char **)a2;
    else
      v6 = (char *)a2;
    LMX_func_api_Ctrl_LiveView_Start(v6, nullptr);
  }
  v10 = *(atomic_ullong **)(a2 + 32);
  v11 = 1;
  atomic_compare_exchange_strong_explicit(v10, (unsigned __int64 *)&v11, 0, memory_order_release, memory_order_relaxed);
  if ( v11 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v10);
  __ns.__rep_ = 200000000;
  std::this_thread::sleep_for(&__ns);
}
