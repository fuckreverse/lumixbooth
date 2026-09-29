// __ZN11lumixtether21DeviceAdapterCallback11popArgumentEPjS1_P7QString @ 0x1000da72c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapterCallback::popArgument(
        atomic_ullong *this,
        unsigned int *a2,
        unsigned int *a3,
        QString *a4)
{
  __int64 v4; // x20
  __int64 v9; // x8
  atomic_ullong *v10; // x19
  __int64 v11; // x8
  bool v12; // zf
  int *v13; // x8
  __int64 v14; // x9
  int *v15; // x8
  __int64 v16; // x9
  int *v17; // x8
  atomic_uint *volatile *v18; // x8
  __int64 v19; // x9
  __int64 v20; // x8

  v4 = 0;
  if ( a2 && a3 )
  {
    v9 = 0;
    v10 = this + 12;
    atomic_compare_exchange_strong_explicit(
      this + 12,
      (unsigned __int64 *)&v9,
      1u,
      memory_order_acquire,
      memory_order_acquire);
    if ( v9 )
      QBasicMutex::lockInternal((QBasicMutex *)(this + 12));
    v11 = *(this + 4);
    v12 = v11 > 0 && v11 == *(this + 7);
    v4 = v12;
    if ( v12 )
    {
      *a2 = *(_DWORD *)*(this + 3);
      *a3 = *(_DWORD *)*(this + 6);
      QString::operator=(a4, *(this + 9));
      v13 = (int *)*(this + 2);
      if ( !v13 || *v13 >= 2 )
        sub_1000BDC70(this + 2, 0, 0, 0);
      v14 = *(this + 4) - 1;
      *(this + 3) += 4LL;
      *(this + 4) = v14;
      v15 = (int *)*(this + 5);
      if ( !v15 || *v15 >= 2 )
        sub_1000BDC70(this + 5, 0, 0, 0);
      v16 = *(this + 7) - 1;
      *(this + 6) += 4LL;
      *(this + 7) = v16;
      v17 = (int *)*(this + 8);
      if ( !v17 || *v17 >= 2 )
        sub_1000283EC(this + 8, 0, 0, 0);
      v18 = (atomic_uint *volatile *)*(this + 9);
      if ( *v18 && atomic_fetch_add(*v18, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(*v18, 2, 8);
      v19 = *(this + 10) - 1;
      *(this + 9) += 24LL;
      *(this + 10) = v19;
    }
    v20 = 1;
    atomic_compare_exchange_strong_explicit(
      v10,
      (unsigned __int64 *)&v20,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v20 != 1 )
      QBasicMutex::unlockInternal((QBasicMutex *)v10);
  }
  return v4;
}
