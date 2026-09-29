// __ZN11lumixtether21DeviceAdapterCallback17pushArgumentCheckEjj7QString @ 0x1000da32c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapterCallback::pushArgumentCheck(_QWORD *a1, int a2, int a3, __int64 a4)
{
  __int64 v8; // x8
  atomic_ullong *v9; // x19
  __int64 result; // x0
  __int64 v11; // x1
  __int64 v12; // x9
  char v13; // w8
  __int64 v14; // x10
  __int64 v15; // x8
  int v16; // [xsp+Ch] [xbp-34h] BYREF

  v8 = 0;
  v9 = a1 + 12;
  atomic_compare_exchange_strong_explicit(
    a1 + 12,
    (unsigned __int64 *)&v8,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v8 )
    QBasicMutex::lockInternal((QBasicMutex *)(a1 + 12));
  result = (__int64)(a1 + 2);
  v11 = a1[4];
  if ( v11 <= 0 )
    goto LABEL_9;
  v12 = 0;
  v13 = 0;
  v14 = a1[7];
  if ( v14 <= 0 )
    v14 = 0;
  do
  {
    if ( v14 == v12 )
      break;
    v13 |= *(_DWORD *)(a1[3] + 4 * v12++) == a2;
  }
  while ( v11 != v12 );
  if ( (v13 & 1) == 0 )
  {
LABEL_9:
    v16 = a2;
    sub_1000BDA18(result, v11, &v16);
    v16 = a3;
    sub_1000BDA18(a1 + 5, a1[7], &v16);
    result = sub_1000ACF44(a1 + 8, a1[10], a4);
  }
  v15 = 1;
  atomic_compare_exchange_strong_explicit(v9, (unsigned __int64 *)&v15, 0, memory_order_release, memory_order_relaxed);
  if ( v15 != 1 )
    return QBasicMutex::unlockInternal((QBasicMutex *)v9);
  return result;
}
