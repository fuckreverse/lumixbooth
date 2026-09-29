// __ZN9ObjectAdd8pushDataEjjm @ 0x1000c1ab0
__int64 __fastcall ObjectAdd::pushData(atomic_ullong *this, int a2, int a3, __int64 a4)
{
  __int64 v8; // x8
  atomic_ullong *v9; // x19
  __int64 result; // x0
  __int64 v11; // x8
  __int64 v12; // [xsp+8h] [xbp-38h] BYREF

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
  LODWORD(v12) = a2;
  sub_1000BDA18(this + 2, *(this + 4), &v12);
  LODWORD(v12) = a3;
  sub_1000BDA18(this + 5, *(this + 7), &v12);
  v12 = a4;
  result = sub_1000C9050(this + 8, *(this + 10), &v12);
  v11 = 1;
  atomic_compare_exchange_strong_explicit(v9, (unsigned __int64 *)&v11, 0, memory_order_release, memory_order_relaxed);
  if ( v11 != 1 )
    return QBasicMutex::unlockInternal((QBasicMutex *)v9);
  return result;
}
