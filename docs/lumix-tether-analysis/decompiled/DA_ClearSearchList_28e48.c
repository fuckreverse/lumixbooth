// __ZN11lumixtether13DeviceAdapter15ClearSearchListEv @ 0x100028e48
lumixtether::DeviceAdapter *__fastcall lumixtether::DeviceAdapter::ClearSearchList(lumixtether::DeviceAdapter *this)
{
  __int64 v1; // x8
  lumixtether::DeviceAdapter *v2; // x19
  __int64 v3; // x22
  __int64 v4; // x9
  __int64 v5; // x20
  int *v6; // x8
  __int64 v7; // x0
  __int64 v8; // x20
  __int64 v9; // x8
  __int64 v10; // x3
  __int64 v11; // x8
  atomic_uint *v12; // x0
  __int64 v13; // [xsp+8h] [xbp-38h] BYREF

  v1 = *((_QWORD *)this + 140);
  if ( *(__int64 *)(v1 + 410296) >= 1 )
  {
    v2 = this;
    v3 = 0;
    do
    {
      v5 = v1 + 410280;
      v6 = *(int **)(v1 + 410280);
      if ( (!v6 || *v6 >= 2) && (sub_1000A9C00(v5, 0, 0, 0), (v6 = *(int **)v5) == nullptr) || *v6 >= 2 )
        sub_1000A9C00(v5, 0, 0, 0);
      v7 = *(_QWORD *)(*(_QWORD *)(v5 + 8) + 8 * v3);
      if ( v7 )
        (*(void (__fastcall **)(__int64))(*(_QWORD *)v7 + 32LL))(v7);
      ++v3;
      v1 = *((_QWORD *)v2 + 140);
      v4 = *(_QWORD *)(v1 + 410296);
    }
    while ( v4 > v3 );
    if ( !v4 )
      return (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::searchListChanged(v2);
    v8 = v1 + 410280;
    v9 = *(_QWORD *)(v1 + 410280);
    if ( v9 )
    {
      if ( *(int *)v9 < 2 )
      {
        *(_QWORD *)(v8 + 16) = 0;
        return (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::searchListChanged(v2);
      }
      v10 = *(_QWORD *)(v9 + 8);
    }
    else
    {
      v10 = 0;
    }
    v11 = QArrayData::allocate(&v13, 8, 8, v10, 1);
    v12 = *(atomic_uint **)v8;
    *(_QWORD *)v8 = v13;
    *(_QWORD *)(v8 + 8) = v11;
    *(_QWORD *)(v8 + 16) = 0;
    if ( v12 )
    {
      if ( atomic_fetch_add(v12, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v12, 8, 8);
    }
    return (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::searchListChanged(v2);
  }
  return this;
}
