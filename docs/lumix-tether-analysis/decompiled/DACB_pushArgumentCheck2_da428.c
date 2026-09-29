// __ZN11lumixtether21DeviceAdapterCallback18pushArgumentCheck2Ejj7QString @ 0x1000da428 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapterCallback::pushArgumentCheck2(__int64 result, int a2, int a3, __int64 a4)
{
  _QWORD *v7; // x21
  __int64 v8; // x8
  atomic_ullong *v9; // x19
  int **v10; // x24
  __int64 v11; // x1
  __int64 v12; // x9
  __int64 v13; // x10
  int v14; // w8
  int v15; // w26
  int v16; // w13
  __int64 v17; // x27
  __int64 v18; // x9
  __int64 v19; // x0
  __int64 v20; // x8
  _QWORD *v21; // x26
  _QWORD *v22; // x28
  __int64 v23; // x8
  __int64 v24; // x9
  int *v25; // x8
  __int64 v26; // x8
  __int64 v27; // x9
  char *v28; // x0
  _BYTE *v29; // x1
  _BYTE *v30; // x9
  __int64 v31; // x9
  int *v32; // x8
  atomic_uint *volatile *v33; // x27
  atomic_uint *volatile *v34; // x1
  __int64 v35; // x8
  atomic_uint *volatile *v36; // x9
  atomic_uint *volatile *v37; // x9
  int v38; // [xsp+Ch] [xbp-54h] BYREF

  v7 = (_QWORD *)result;
  v8 = 0;
  v9 = (atomic_ullong *)(result + 96);
  atomic_compare_exchange_strong_explicit(
    (atomic_ullong *volatile)(result + 96),
    (unsigned __int64 *)&v8,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v8 )
    result = QBasicMutex::lockInternal((QBasicMutex *)(result + 96));
  v10 = (int **)(v7 + 2);
  v11 = v7[4];
  if ( v11 <= 0 )
    goto LABEL_22;
  v12 = 0;
  v13 = (__int64)v7[7] <= 0 ? 0LL : v7[7];
  v14 = -1;
  v15 = -1;
  do
  {
    if ( v13 == v12 )
      break;
    v16 = *(_DWORD *)(v7[3] + 4 * v12);
    if ( v16 == 301989904 )
    {
      v14 = v12;
    }
    else if ( v16 == 16777232 )
    {
      v15 = v12;
    }
    ++v12;
  }
  while ( v11 != v12 );
  if ( v15 == -1 )
  {
LABEL_22:
    v38 = a2;
    sub_1000BDA18(v7 + 2, v11, &v38);
    v38 = a3;
    sub_1000BDA18(v7 + 5, v7[7], &v38);
    v21 = v7 + 8;
    v22 = v7 + 10;
  }
  else
  {
    if ( v15 >= v14 )
      goto LABEL_24;
    v17 = v15;
    if ( !*v10 || **v10 >= 2 )
    {
      sub_1000BDC70(v7 + 2, 0, 0, 0);
      v11 = v7[4];
    }
    v18 = v7[3];
    v19 = v18 + 4LL * v15;
    v20 = v19 + 4;
    if ( v15 || v11 == 1 )
    {
      v24 = v18 + 4 * v11;
      if ( v20 != v24 )
      {
        memmove((void *)v19, (const void *)(v19 + 4), v24 - v20);
        v11 = v7[4];
      }
    }
    else
    {
      v7[3] = v20;
    }
    v25 = (int *)v7[5];
    v7[4] = v11 - 1;
    if ( !v25 || *v25 >= 2 )
      sub_1000BDC70(v7 + 5, 0, 0, 0);
    v27 = v7[6];
    v26 = v7[7];
    v28 = (char *)(v27 + 4LL * v15);
    v29 = v28 + 4;
    if ( v15 || v26 == 1 )
    {
      v30 = (_BYTE *)(v27 + 4 * v26);
      if ( v29 != v30 )
      {
        memmove(v28, v29, v30 - v29);
        v26 = v7[7];
      }
    }
    else
    {
      v7[6] = v29;
    }
    v31 = v26 - 1;
    v21 = v7 + 8;
    v32 = (int *)v7[8];
    v7[7] = v31;
    if ( !v32 || *v32 >= 2 )
      sub_1000283EC(v7 + 8, 0, 0, 0);
    v33 = (atomic_uint *volatile *)(v7[9] + 24 * v17);
    if ( *v33 && atomic_fetch_add(*v33, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(*v33, 2, 8);
    v34 = v33 + 3;
    v22 = v7 + 10;
    v35 = v7[10];
    v36 = (atomic_uint *volatile *)v7[9];
    if ( v36 != v33 || v35 == 1 )
    {
      v37 = &v36[3 * v35];
      if ( v34 != v37 )
      {
        memmove((void *)v33, (const void *)v34, (char *)v37 - (char *)v34);
        v35 = *v22;
      }
    }
    else
    {
      v7[9] = v34;
    }
    v7[10] = v35 - 1;
    v38 = a2;
    sub_1000BDA18(v7 + 2, v7[4], &v38);
    v38 = a3;
    sub_1000BDA18(v7 + 5, v7[7], &v38);
  }
  result = sub_1000ACF44(v21, *v22, a4);
LABEL_24:
  v23 = 1;
  atomic_compare_exchange_strong_explicit(v9, (unsigned __int64 *)&v23, 0, memory_order_release, memory_order_relaxed);
  if ( v23 != 1 )
    return QBasicMutex::unlockInternal((QBasicMutex *)v9);
  return result;
}
