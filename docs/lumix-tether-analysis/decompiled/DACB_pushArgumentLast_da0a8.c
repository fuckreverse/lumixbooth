// __ZN11lumixtether21DeviceAdapterCallback16pushArgumentLastEjj7QString @ 0x1000da0a8 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapterCallback::pushArgumentLast(_QWORD *a1, int a2, int a3, __int64 a4)
{
  __int64 v8; // x8
  atomic_ullong *v9; // x19
  int **v10; // x25
  __int64 v11; // x1
  _QWORD *v12; // x27
  int **v13; // x23
  __int64 v14; // x28
  __int64 v15; // x22
  int **v16; // x26
  __int64 result; // x0
  int *v18; // x8
  __int64 v19; // x8
  __int64 v20; // x0
  int *v21; // x8
  int *v22; // x8
  __int64 v23; // x8
  int v24; // [xsp+8h] [xbp-58h]
  int v25; // [xsp+Ch] [xbp-54h] BYREF

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
  v10 = (int **)(a1 + 2);
  v11 = a1[4];
  if ( !v11 )
  {
    v25 = a2;
    sub_1000BDA18(a1 + 2, 0, &v25);
    v25 = a3;
    sub_1000BDA18(a1 + 5, a1[7], &v25);
    v13 = (int **)(a1 + 8);
    v12 = a1 + 10;
LABEL_30:
    result = sub_1000ACF44(v13, *v12, a4);
    goto LABEL_31;
  }
  v12 = a1 + 10;
  v13 = (int **)(a1 + 8);
  if ( (__int64)a1[10] < 1 )
  {
LABEL_29:
    v25 = a2;
    sub_1000BDA18(a1 + 2, v11, &v25);
    v25 = a3;
    sub_1000BDA18(a1 + 5, a1[7], &v25);
    goto LABEL_30;
  }
  v24 = a3;
  v14 = 0;
  v15 = 0;
  v16 = (int **)(a1 + 5);
  while ( 1 )
  {
    v18 = *v13;
    if ( (!*v13 || *v18 >= 2) && (sub_1000283EC(a1 + 8, 0, 0, 0), (v18 = *v13) == nullptr) || *v18 >= 2 )
      sub_1000283EC(a1 + 8, 0, 0, 0);
    v19 = a1[9] + v14;
    v20 = *(_QWORD *)(v19 + 16);
    if ( v20 == *(_QWORD *)(a4 + 16) )
    {
      result = QtPrivate::compareStrings(v20, *(_QWORD *)(v19 + 8), *(_QWORD *)(v19 + 16), *(_QWORD *)(a4 + 8), 1);
      if ( !(_DWORD)result )
      {
        v21 = *v10;
        if ( (!*v10 || *v21 >= 2) && (result = sub_1000BDC70(a1 + 2, 0, 0, 0), (v21 = *v10) == nullptr) || *v21 >= 2 )
          result = sub_1000BDC70(a1 + 2, 0, 0, 0);
        if ( *(_DWORD *)(a1[3] + 4 * v15) == a2 )
        {
          v22 = *v16;
          if ( (!*v16 || *v22 >= 2) && (result = sub_1000BDC70(a1 + 5, 0, 0, 0), (v22 = *v16) == nullptr) || *v22 >= 2 )
            result = sub_1000BDC70(a1 + 5, 0, 0, 0);
          if ( *(_DWORD *)(a1[6] + 4 * v15) == v24 )
            break;
        }
      }
    }
    ++v15;
    v14 += 24;
    if ( *v12 <= v15 )
    {
      v11 = a1[4];
      a3 = v24;
      goto LABEL_29;
    }
  }
LABEL_31:
  v23 = 1;
  atomic_compare_exchange_strong_explicit(v9, (unsigned __int64 *)&v23, 0, memory_order_release, memory_order_relaxed);
  if ( v23 != 1 )
    return QBasicMutex::unlockInternal((QBasicMutex *)v9);
  return result;
}
