// __ZN9ObjectAdd24ClearInterruptionRequestEv @ 0x1000beaf8
__int64 __fastcall ObjectAdd::ClearInterruptionRequest(__int64 this)
{
  __int64 v1; // x20
  __int64 v2; // x8
  atomic_ullong *v3; // x19
  __int64 v4; // x8

  v1 = this;
  v2 = 0;
  v3 = (atomic_ullong *)(this + 104);
  atomic_compare_exchange_strong_explicit(
    (atomic_ullong *volatile)(this + 104),
    (unsigned __int64 *)&v2,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v2 )
    this = QBasicMutex::lockInternal((QBasicMutex *)(this + 104));
  *(_BYTE *)(v1 + 96) = 0;
  v4 = 1;
  atomic_compare_exchange_strong_explicit(v3, (unsigned __int64 *)&v4, 0, memory_order_release, memory_order_relaxed);
  if ( v4 != 1 )
    return QBasicMutex::unlockInternal((QBasicMutex *)v3);
  return this;
}
