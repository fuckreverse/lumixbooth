// __ZN11lumixtether13DeviceAdapter28adp_LMX_func_api_OpenSessionE7QString @ 0x10002d570 (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_OpenSession(__int64 a1, __int64 a2)
{
  __int64 v4; // x1
  void *v5; // x9
  void *v6; // x0
  atomic_uint *v7; // x8
  atomic_uint *v8; // x9
  int v9; // w21
  atomic_uint *v10; // x8
  atomic_uint *v11; // x9
  __int64 v12; // x20
  __int64 v13; // x21
  atomic_uint *v14; // x0
  atomic_uint **v15; // x25
  atomic_uint **v16; // x21
  atomic_uint *v17; // x0
  char *v18; // x21
  atomic_uint *v19; // x8
  atomic_uint *v20; // x9
  int v21; // w21
  atomic_uint *v22; // x8
  atomic_uint *v23; // x9
  atomic_uint *v24; // x8
  __int64 v25; // x8
  atomic_uint *v26; // x9
  atomic_uint **v27; // t1
  atomic_uint *v29[3]; // [xsp+0h] [xbp-C0h] BYREF
  atomic_uint *v30[3]; // [xsp+18h] [xbp-A8h] BYREF
  atomic_uint *v31[3]; // [xsp+30h] [xbp-90h] BYREF
  atomic_uint *v32[3]; // [xsp+48h] [xbp-78h] BYREF
  atomic_uint *v33; // [xsp+60h] [xbp-60h] BYREF
  char *v34; // [xsp+68h] [xbp-58h]
  __int64 v35; // [xsp+70h] [xbp-50h]
  unsigned int v36; // [xsp+7Ch] [xbp-44h] BYREF

  v36 = 0;
  v5 = *(void **)(a2 + 8);
  v4 = *(_QWORD *)(a2 + 16);
  if ( v5 )
    v6 = v5;
  else
    v6 = &QString::_empty;
  if ( (unsigned int)QString::compare_helper(v6, v4, "All", -1, 1) )
  {
    v7 = *(atomic_uint **)a2;
    v8 = *(atomic_uint **)(a2 + 8);
    v30[0] = v7;
    v30[1] = v8;
    v30[2] = *(atomic_uint **)(a2 + 16);
    if ( v7 )
      atomic_fetch_add(v7, 1u);
    lumixtether::DeviceAdapter::dev_mutex_lock(a1, v30);
    if ( v30[0] && atomic_fetch_add(v30[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v30[0], 2, 8);
    QString::toLocal8Bit_helper(&v33, *(_QWORD *)(a2 + 8), *(_QWORD *)(a2 + 16));
    if ( !v33 || *v33 >= 2 )
      QByteArray::reallocData(&v33, v35, 1);
    v9 = LMX_func_api_OpenSession(0, &v36, v34, nullptr);
    if ( v33 && atomic_fetch_add(v33, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v33, 1, 8);
    v10 = *(atomic_uint **)a2;
    v11 = *(atomic_uint **)(a2 + 8);
    v29[0] = v10;
    v29[1] = v11;
    v29[2] = *(atomic_uint **)(a2 + 16);
    if ( v10 )
      atomic_fetch_add(v10, 1u);
    lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v29);
    if ( v29[0] && atomic_fetch_add(v29[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v29[0], 2, 8);
    return v9 == 1;
  }
  else
  {
    std::recursive_mutex::lock((std::recursive_mutex *)(*(_QWORD *)(a1 + 1120) + 410304LL));
    v13 = *(_QWORD *)(a1 + 1120) + 410272LL;
    if ( *(_QWORD *)v13 )
    {
      sub_1000A9464(*(_QWORD *)(a1 + 1120) + 410272LL);
    }
    else
    {
      v14 = (atomic_uint *)operator new(0x20u);
      *v14 = 0;
      *((_QWORD *)v14 + 3) = 0;
      *((_QWORD *)v14 + 2) = 0;
      *((_QWORD *)v14 + 1) = v14 + 4;
      *(_QWORD *)v13 = v14;
      atomic_fetch_add(v14, 1u);
    }
    v12 = 0;
    v15 = *(atomic_uint ***)(*(_QWORD *)v13 + 8LL);
    while ( 1 )
    {
      v16 = (atomic_uint **)(*(_QWORD *)(a1 + 1120) + 410272LL);
      if ( *v16 )
      {
        sub_1000A9464(*(_QWORD *)(a1 + 1120) + 410272LL);
      }
      else
      {
        v17 = (atomic_uint *)operator new(0x20u);
        *v17 = 0;
        *((_QWORD *)v17 + 3) = 0;
        *((_QWORD *)v17 + 2) = 0;
        *((_QWORD *)v17 + 1) = v17 + 4;
        *v16 = v17;
        atomic_fetch_add(v17, 1u);
      }
      if ( v15 == (atomic_uint **)(*v16 + 4) )
        break;
      QString::toLocal8Bit_helper(&v33, v15[5], v15[6]);
      if ( !v33 || *v33 >= 2 )
        QByteArray::reallocData(&v33, v35, 1);
      v18 = v34;
      v19 = v15[4];
      v20 = v15[5];
      v32[0] = v19;
      v32[1] = v20;
      v32[2] = v15[6];
      if ( v19 )
        atomic_fetch_add(v19, 1u);
      lumixtether::DeviceAdapter::dev_mutex_lock(a1, v32);
      if ( v32[0] && atomic_fetch_add(v32[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v32[0], 2, 8);
      v21 = LMX_func_api_OpenSession(0, &v36, v18, nullptr);
      v22 = v15[4];
      v23 = v15[5];
      v31[0] = v22;
      v31[1] = v23;
      v31[2] = v15[6];
      if ( v22 )
        atomic_fetch_add(v22, 1u);
      lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v31);
      if ( v31[0] && atomic_fetch_add(v31[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v31[0], 2, 8);
      v24 = v15[1];
      if ( v24 )
      {
        do
        {
          v15 = (atomic_uint **)v24;
          v24 = *(atomic_uint **)v24;
        }
        while ( v24 );
      }
      else
      {
        v25 = (__int64)(v15 + 2);
        if ( *(atomic_uint ***)v15[2] == v15 )
        {
          v15 = (atomic_uint **)v15[2];
        }
        else
        {
          do
          {
            v26 = *(atomic_uint **)v25;
            v27 = *(atomic_uint ***)(*(_QWORD *)v25 + 16LL);
            v25 = *(_QWORD *)v25 + 16LL;
            v15 = v27;
          }
          while ( *v27 != v26 );
        }
      }
      if ( v21 == 1 )
        v12 = 1;
      else
        v12 = (unsigned int)v12;
      if ( v33 && atomic_fetch_add(v33, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v33, 1, 8);
    }
    std::recursive_mutex::unlock((std::recursive_mutex *)(*(_QWORD *)(a1 + 1120) + 410304LL));
  }
  return v12;
}
