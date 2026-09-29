// __ZN11lumixtether13DeviceAdapter30adp_LMX_func_api_GetDeviceInfoE7QStringPNS0_10DeviceInfoE @ 0x100030a24 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetDeviceInfo(__int64 a1, atomic_uint **a2, __int64 a3)
{
  atomic_uint *v6; // x8
  atomic_uint *v7; // x9
  int DeviceInfo; // w22
  atomic_uint *v9; // x8
  atomic_uint *v10; // x9
  size_t v11; // x0
  atomic_uint *v12; // x8
  __int64 v13; // x9
  __int64 v14; // x9
  size_t v15; // x0
  atomic_uint *v16; // x8
  __int64 v17; // x9
  __int64 v18; // x9
  size_t v19; // x0
  atomic_uint *v20; // x8
  __int64 v21; // x9
  __int64 v22; // x9
  size_t v23; // x0
  atomic_uint *v24; // x8
  __int64 v25; // x9
  __int64 v26; // x9
  atomic_uint *v28[3]; // [xsp+8h] [xbp-488h] BYREF
  atomic_uint *v29[3]; // [xsp+20h] [xbp-470h] BYREF
  __int128 v30; // [xsp+38h] [xbp-458h] BYREF
  __int64 v31; // [xsp+48h] [xbp-448h]
  char v32; // [xsp+50h] [xbp-440h] BYREF
  char v33[258]; // [xsp+51h] [xbp-43Fh] BYREF
  char v34[258]; // [xsp+153h] [xbp-33Dh] BYREF
  char v35[258]; // [xsp+255h] [xbp-23Bh] BYREF
  char v36[257]; // [xsp+357h] [xbp-139h] BYREF

  if ( !a3 )
    return 0;
  bzero(&v32, 0x408u);
  v6 = *a2;
  v7 = a2[1];
  v29[0] = v6;
  v29[1] = v7;
  v29[2] = a2[2];
  if ( v6 )
    atomic_fetch_add(v6, 1u);
  lumixtether::DeviceAdapter::dev_mutex_lock(a1, v29);
  if ( v29[0] && atomic_fetch_add(v29[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v29[0], 2, 8);
  QString::toLocal8Bit_helper(&v30, a2[1], a2[2]);
  if ( !(_QWORD)v30 || *(int *)v30 >= 2 )
    QByteArray::reallocData(&v30, v31, 1);
  DeviceInfo = LMX_func_api_GetDeviceInfo(&v32, *((_QWORD *)&v30 + 1), 0);
  if ( (_QWORD)v30 && atomic_fetch_add((atomic_uint *volatile)v30, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v30, 1, 8);
  v9 = *a2;
  v10 = a2[1];
  v28[0] = v9;
  v28[1] = v10;
  v28[2] = a2[2];
  if ( v9 )
    atomic_fetch_add(v9, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v28);
  if ( v28[0] && atomic_fetch_add(v28[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v28[0], 2, 8);
  if ( DeviceInfo != 1 )
    return 0;
  v11 = strlen(v33);
  QString::fromUtf8(&v30, v11, v33);
  v12 = *(atomic_uint **)a3;
  v13 = *(_QWORD *)(a3 + 8);
  *(_OWORD *)a3 = v30;
  *(_QWORD *)&v30 = v12;
  *((_QWORD *)&v30 + 1) = v13;
  v14 = *(_QWORD *)(a3 + 16);
  *(_QWORD *)(a3 + 16) = v31;
  v31 = v14;
  if ( v12 && atomic_fetch_add(v12, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v30, 2, 8);
  v15 = strlen(v34);
  QString::fromUtf8(&v30, v15, v34);
  v16 = *(atomic_uint **)(a3 + 24);
  v17 = *(_QWORD *)(a3 + 32);
  *(_OWORD *)(a3 + 24) = v30;
  *(_QWORD *)&v30 = v16;
  *((_QWORD *)&v30 + 1) = v17;
  v18 = *(_QWORD *)(a3 + 40);
  *(_QWORD *)(a3 + 40) = v31;
  v31 = v18;
  if ( v16 && atomic_fetch_add(v16, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v30, 2, 8);
  v19 = strlen(v35);
  QString::fromUtf8(&v30, v19, v35);
  v20 = *(atomic_uint **)(a3 + 48);
  v21 = *(_QWORD *)(a3 + 56);
  *(_OWORD *)(a3 + 48) = v30;
  *(_QWORD *)&v30 = v20;
  *((_QWORD *)&v30 + 1) = v21;
  v22 = *(_QWORD *)(a3 + 64);
  *(_QWORD *)(a3 + 64) = v31;
  v31 = v22;
  if ( v20 && atomic_fetch_add(v20, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v30, 2, 8);
  v23 = strlen(v36);
  QString::fromUtf8(&v30, v23, v36);
  v24 = *(atomic_uint **)(a3 + 72);
  v25 = *(_QWORD *)(a3 + 80);
  *(_OWORD *)(a3 + 72) = v30;
  *(_QWORD *)&v30 = v24;
  *((_QWORD *)&v30 + 1) = v25;
  v26 = *(_QWORD *)(a3 + 88);
  *(_QWORD *)(a3 + 88) = v31;
  v31 = v26;
  if ( v24 )
  {
    if ( atomic_fetch_add(v24, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v30, 2, 8);
  }
  return 1;
}
