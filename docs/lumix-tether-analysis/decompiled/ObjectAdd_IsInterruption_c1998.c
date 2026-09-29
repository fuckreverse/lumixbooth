// __ZN9ObjectAdd23IsInterruptionRequestedEv @ 0x1000c1998
bool __fastcall ObjectAdd::IsInterruptionRequested(atomic_ullong *this)
{
  __int64 v2; // x8
  atomic_ullong *v3; // x19
  int v4; // w20
  __int64 v5; // x8

  v2 = 0;
  v3 = this + 13;
  atomic_compare_exchange_strong_explicit(
    this + 13,
    (unsigned __int64 *)&v2,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v2 )
    QBasicMutex::lockInternal((QBasicMutex *)(this + 13));
  v4 = *((unsigned __int8 *)this + 96);
  v5 = 1;
  atomic_compare_exchange_strong_explicit(v3, (unsigned __int64 *)&v5, 0, memory_order_release, memory_order_relaxed);
  if ( v5 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v3);
  return v4 != 0;
}
