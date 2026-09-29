// __ZN11lumixtether21DeviceAdapterCallback23IsInterruptionRequestedEv @ 0x1000da048 (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapterCallback::IsInterruptionRequested(atomic_ullong *this)
{
  __int64 v2; // x8
  atomic_ullong *v3; // x19
  int v4; // w20
  __int64 v5; // x8

  v2 = 0;
  v3 = this + 12;
  atomic_compare_exchange_strong_explicit(
    this + 12,
    (unsigned __int64 *)&v2,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v2 )
    QBasicMutex::lockInternal((QBasicMutex *)(this + 12));
  v4 = *((unsigned __int8 *)this + 88);
  v5 = 1;
  atomic_compare_exchange_strong_explicit(v3, (unsigned __int64 *)&v5, 0, memory_order_release, memory_order_relaxed);
  if ( v5 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v3);
  return v4 != 0;
}
