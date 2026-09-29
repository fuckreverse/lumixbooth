// __ZN11lumixtether13DeviceAdapter17AddSortSearchListEP26SearchCameraListItemObject @ 0x1000296bc
__int64 __fastcall lumixtether::DeviceAdapter::AddSortSearchList(
        lumixtether::DeviceAdapter *this,
        SearchCameraListItemObject *a2)
{
  __int64 v3; // x8
  __int64 v5; // x8
  __int64 v6; // x19
  __int64 v7; // x23
  __int64 v8; // x21
  __int64 v9; // x22
  _QWORD *v10; // x24
  atomic_uint *v11; // x8
  int **v12; // x21
  SearchCameraListItemObject **i; // x24
  int **v14; // x21
  __int64 v15; // x8
  __int64 v16; // x27
  __int64 v17; // x19
  __int64 v18; // x21
  __int64 v19; // x22
  _QWORD *v20; // x28
  atomic_uint *v21; // x8
  int **v23; // x0
  int *v24; // x1
  __int64 v25[3]; // [xsp+8h] [xbp-88h] BYREF
  __int64 v26[3]; // [xsp+20h] [xbp-70h] BYREF
  SearchCameraListItemObject *v27; // [xsp+38h] [xbp-58h] BYREF

  v3 = *((_QWORD *)this + 140);
  if ( !*(_QWORD *)(v3 + 410296) )
  {
    v23 = (int **)(v3 + 410280);
    v27 = a2;
    v24 = nullptr;
    return sub_1000AD214(v23, v24, &v27);
  }
  SearchCameraListItemObject::devSerialNo(v26, a2);
  v5 = *((_QWORD *)this + 140);
  v6 = *(unsigned int *)(v5 + 307832);
  if ( (int)v6 >= 1 )
  {
    v7 = 0;
    v9 = v26[1];
    v8 = v26[2];
    v10 = (_QWORD *)(v5 + 307920);
    while ( v8 != *v10 || (unsigned int)QtPrivate::compareStrings(v8, v9, v8, *(v10 - 1), 1) )
    {
      ++v7;
      v10 += 25;
      if ( v6 == v7 )
        goto LABEL_9;
    }
    v11 = (atomic_uint *)v26[0];
    if ( !v26[0] )
      goto LABEL_12;
    goto LABEL_10;
  }
LABEL_9:
  LODWORD(v7) = -1;
  v11 = (atomic_uint *)v26[0];
  if ( v26[0] )
  {
LABEL_10:
    if ( atomic_fetch_add(v11, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v26[0], 2, 8);
  }
LABEL_12:
  v12 = (int **)(*((_QWORD *)this + 140) + 410280LL);
  if ( (_DWORD)v7 != -1 )
  {
    if ( !*v12 || **v12 >= 2 )
      sub_1000A9C00(v12, 0, 0, 0);
    for ( i = (SearchCameraListItemObject **)v12[1]; ; ++i )
    {
      v14 = (int **)(*((_QWORD *)this + 140) + 410280LL);
      if ( !*v14 || **v14 >= 2 )
        sub_1000A9C00(*((_QWORD *)this + 140) + 410280LL, 0, 0, 0);
      if ( i == (SearchCameraListItemObject **)&v14[1][2 * (_QWORD)v14[2]] )
        return sub_1000AD474(
                 *((_QWORD *)this + 140) + 410280LL,
                 ((__int64)i - *(_QWORD *)(*((_QWORD *)this + 140) + 410288LL)) >> 3,
                 1,
                 a2);
      SearchCameraListItemObject::devSerialNo(v25, *i);
      v15 = *((_QWORD *)this + 140);
      v16 = *(unsigned int *)(v15 + 307832);
      if ( (int)v16 < 1 )
        break;
      v17 = 0;
      v19 = v25[1];
      v18 = v25[2];
      v20 = (_QWORD *)(v15 + 307920);
      while ( v18 != *v20 || (unsigned int)QtPrivate::compareStrings(v18, v19, v18, *(v20 - 1), 1) )
      {
        ++v17;
        v20 += 25;
        if ( v16 == v17 )
          goto LABEL_28;
      }
      v21 = (atomic_uint *)v25[0];
      if ( v25[0] )
        goto LABEL_29;
LABEL_31:
      if ( (_DWORD)v17 == -1 || (int)v7 < (int)v17 )
        return sub_1000AD474(
                 *((_QWORD *)this + 140) + 410280LL,
                 ((__int64)i - *(_QWORD *)(*((_QWORD *)this + 140) + 410288LL)) >> 3,
                 1,
                 a2);
    }
LABEL_28:
    LODWORD(v17) = -1;
    v21 = (atomic_uint *)v25[0];
    if ( !v25[0] )
      goto LABEL_31;
LABEL_29:
    if ( atomic_fetch_add(v21, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v25[0], 2, 8);
    goto LABEL_31;
  }
  v27 = a2;
  v24 = v12[2];
  v23 = v12;
  return sub_1000AD214(v23, v24, &v27);
}
