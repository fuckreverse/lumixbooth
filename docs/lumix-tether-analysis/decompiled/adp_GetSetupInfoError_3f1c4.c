// __ZN11lumixtether13DeviceAdapter34adp_LMX_func_api_GetSetupInfoErrorE7QString @ 0x10003f1c4 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetSetupInfoError(__int64 a1, atomic_uint **a2)
{
  atomic_uint *v4; // x8
  atomic_uint *v5; // x9
  int SetupInfoError; // w21
  atomic_uint *v7; // x8
  atomic_uint *v8; // x9
  _OWORD *v9; // x8
  __int128 v10; // q1
  __int128 v11; // q1
  __int128 v12; // q1
  __int128 v13; // q1
  __int64 v14; // x22
  __int64 v15; // x8
  _QWORD *v16; // x23
  _QWORD *v18; // x24
  atomic_uint *v19; // x21
  _QWORD *v20; // x8
  __int64 v21; // x8
  __int64 v22; // x9
  _QWORD *v23; // t1
  atomic_uint *v24; // x8
  atomic_uint *v25; // x10
  atomic_uint *v26; // x9
  atomic_uint *v27[3]; // [xsp+0h] [xbp-140h] BYREF
  atomic_uint *v28[3]; // [xsp+18h] [xbp-128h] BYREF
  atomic_uint *v29; // [xsp+30h] [xbp-110h] BYREF
  atomic_uint *v30; // [xsp+38h] [xbp-108h]
  atomic_uint *v31; // [xsp+40h] [xbp-100h]
  atomic_uint *v32[3]; // [xsp+48h] [xbp-F8h] BYREF
  _OWORD v33[4]; // [xsp+60h] [xbp-E0h] BYREF
  __int128 v34; // [xsp+A0h] [xbp-A0h]
  __int128 v35; // [xsp+B0h] [xbp-90h]
  __int128 v36; // [xsp+C0h] [xbp-80h]
  __int128 v37; // [xsp+D0h] [xbp-70h]
  _OWORD v38[2]; // [xsp+E0h] [xbp-60h]

  v4 = *a2;
  v5 = a2[1];
  v32[0] = v4;
  v32[1] = v5;
  v32[2] = a2[2];
  if ( v4 )
    atomic_fetch_add(v4, 1u);
  lumixtether::DeviceAdapter::dev_mutex_lock(a1, v32);
  if ( v32[0] && atomic_fetch_add(v32[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v32[0], 2, 8);
  QString::toLocal8Bit_helper(&v29, a2[1], a2[2]);
  if ( !v29 || *v29 >= 2 )
    QByteArray::reallocData(&v29, v31, 1);
  SetupInfoError = LMX_func_api_GetSetupInfoError(v33, v30, 0);
  if ( v29 && atomic_fetch_add(v29, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v29, 1, 8);
  v7 = *a2;
  v8 = a2[1];
  v28[0] = v7;
  v28[1] = v8;
  v28[2] = a2[2];
  if ( v7 )
    atomic_fetch_add(v7, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v28);
  if ( v28[0] && atomic_fetch_add(v28[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v28[0], 2, 8);
  if ( SetupInfoError != 1 )
    return 0;
  if ( DWORD2(v34) )
  {
    v9 = (_OWORD *)(*(_QWORD *)(a1 + 1120) + 159842LL);
    v10 = v37;
    v9[6] = v36;
    v9[7] = v10;
    v9[8] = v38[0];
    *(_OWORD *)((char *)v9 + 138) = *(_OWORD *)((char *)v38 + 10);
    v11 = v33[3];
    v9[2] = v33[2];
    v9[3] = v11;
    v12 = v35;
    v9[4] = v34;
    v9[5] = v12;
    v13 = v33[1];
    *v9 = v33[0];
    v9[1] = v13;
    std::recursive_mutex::lock((std::recursive_mutex *)(*(_QWORD *)(a1 + 1120) + 410304LL));
    v14 = *(_QWORD *)(a1 + 1120);
    v15 = *(_QWORD *)(v14 + 410272);
    if ( v15 )
      v16 = *(_QWORD **)(v15 + 8);
    else
      v16 = nullptr;
    if ( v15 )
      v18 = (_QWORD *)(v15 + 16);
    else
      v18 = nullptr;
    if ( v18 != v16 )
    {
      v19 = a2[2];
      while ( (atomic_uint *)v16[6] != v19 || (unsigned int)QtPrivate::compareStrings(v19, v16[5], v19, a2[1], 1) )
      {
        v20 = (_QWORD *)v16[1];
        if ( v20 )
        {
          do
          {
            v16 = v20;
            v20 = (_QWORD *)*v20;
          }
          while ( v20 );
        }
        else
        {
          v21 = (__int64)(v16 + 2);
          if ( *(_QWORD **)v16[2] == v16 )
          {
            v16 = (_QWORD *)v16[2];
          }
          else
          {
            do
            {
              v22 = *(_QWORD *)v21;
              v23 = *(_QWORD **)(*(_QWORD *)v21 + 16LL);
              v21 = *(_QWORD *)v21 + 16LL;
              v16 = v23;
            }
            while ( *v23 != v22 );
          }
        }
        if ( v16 == v18 )
          goto LABEL_52;
      }
      v25 = (atomic_uint *)v16[14];
      v24 = (atomic_uint *)v16[15];
      v29 = v25;
      v30 = v24;
      v26 = (atomic_uint *)v16[16];
      v31 = v26;
      if ( v25 )
      {
        atomic_fetch_add(v25, 1u);
        v24 = v30;
        v26 = v31;
      }
      if ( !v24 || !v26 )
      {
        QString::operator=(&v29, v16 + 17);
        v24 = v30;
        v26 = v31;
      }
      v27[0] = v29;
      v27[1] = v24;
      v27[2] = v26;
      if ( v29 )
        atomic_fetch_add(v29, 1u);
      lumixtether::DeviceAdapter::cameraErrorNotify(a1, v27);
      if ( v27[0] && atomic_fetch_add(v27[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v27[0], 2, 8);
      if ( v29 && atomic_fetch_add(v29, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v29, 2, 8);
      v14 = *(_QWORD *)(a1 + 1120);
    }
LABEL_52:
    std::recursive_mutex::unlock((std::recursive_mutex *)(v14 + 410304));
  }
  return 1;
}
