// __ZN9ObjectAdd7popDataERjS0_Rm @ 0x1000be384
__int64 __fastcall ObjectAdd::popData(atomic_ullong *this, unsigned int *a2, unsigned int *a3, unsigned __int64 *a4)
{
  __int64 v8; // x8
  atomic_ullong *v9; // x19
  __int64 v10; // x8
  unsigned int *v11; // x9
  int *v12; // x10
  int *v13; // x8
  __int64 v14; // x9
  int *v15; // x8
  __int64 v16; // x9
  __int64 v17; // x20
  __int64 v18; // x8

  v8 = 0;
  v9 = this + 13;
  atomic_compare_exchange_strong_explicit(
    this + 13,
    (unsigned __int64 *)&v8,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v8 )
    QBasicMutex::lockInternal((QBasicMutex *)(this + 13));
  v10 = *(this + 4);
  if ( v10 < 1 || *(this + 7) < 1 || *(this + 10) < 1 )
  {
    v17 = 0;
  }
  else
  {
    v12 = (int *)*(this + 2);
    v11 = (unsigned int *)*(this + 3);
    *a2 = *v11;
    *a3 = *(_DWORD *)*(this + 6);
    *a4 = *(_QWORD *)*(this + 9);
    if ( !v12 || *v12 >= 2 )
    {
      sub_1000BDC70(this + 2, 0, 0, 0);
      v11 = (unsigned int *)*(this + 3);
      v10 = *(this + 4);
    }
    *(this + 3) = (atomic_ullong)(v11 + 1);
    *(this + 4) = v10 - 1;
    v13 = (int *)*(this + 5);
    if ( !v13 || *v13 >= 2 )
      sub_1000BDC70(this + 5, 0, 0, 0);
    v14 = *(this + 7) - 1;
    *(this + 6) += 4LL;
    *(this + 7) = v14;
    v15 = (int *)*(this + 8);
    if ( !v15 || *v15 >= 2 )
      sub_1000C92A8(this + 8, 0, 0, 0);
    v16 = *(this + 10) - 1;
    *(this + 9) += 8LL;
    *(this + 10) = v16;
    v17 = 1;
  }
  v18 = 1;
  atomic_compare_exchange_strong_explicit(v9, (unsigned __int64 *)&v18, 0, memory_order_release, memory_order_relaxed);
  if ( v18 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v9);
  return v17;
}
