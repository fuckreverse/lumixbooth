// __ZN11lumixtether13DeviceAdapter32adp_LMX_func_api_GetCameraStatusEv @ 0x10009d22c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetCameraStatus(lumixtether::DeviceAdapter *this)
{
  __int64 v2; // x10
  atomic_uint *v3; // x9
  atomic_uint *v4; // x8
  atomic_uint *v5; // x10
  int CameraStatus; // w20
  __int64 v7; // x23
  __int64 v8; // x24
  __int64 v9; // x24
  __int64 v10; // x25
  __int64 v11; // t1
  atomic_uint *v12; // x21
  atomic_uint *v13; // x22
  __int64 v14; // x26
  int v15; // w0
  int v16; // w20
  unsigned __int16 v17; // w21
  _BOOL4 v18; // w20
  __int64 v19; // x19
  atomic_uint *v20; // x8
  int v21; // w1
  _DWORD *v22; // x8
  atomic_uint *v24[3]; // [xsp+8h] [xbp-A8h] BYREF
  atomic_uint *v25[3]; // [xsp+20h] [xbp-90h] BYREF
  atomic_uint *v26; // [xsp+38h] [xbp-78h] BYREF
  atomic_uint *v27; // [xsp+40h] [xbp-70h]
  atomic_uint *v28; // [xsp+48h] [xbp-68h]
  atomic_uint *v29; // [xsp+50h] [xbp-60h] BYREF
  atomic_uint *v30; // [xsp+58h] [xbp-58h]
  atomic_uint *v31; // [xsp+60h] [xbp-50h]
  unsigned __int16 v32; // [xsp+6Eh] [xbp-42h] BYREF

  v2 = *((_QWORD *)this + 140) + 307848LL;
  v3 = *(atomic_uint **)v2;
  v29 = v3;
  v4 = *(atomic_uint **)(v2 + 8);
  v30 = v4;
  v5 = *(atomic_uint **)(v2 + 16);
  v31 = v5;
  if ( v3 )
  {
    atomic_fetch_add(v3, 1u);
    v26 = v29;
    v27 = v30;
    v28 = v31;
    atomic_fetch_add(v29, 1u);
  }
  else
  {
    v26 = nullptr;
    v27 = v4;
    v28 = v5;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v26);
  if ( v26 && atomic_fetch_add(v26, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v26, 2, 8);
  QString::toLocal8Bit_helper(v25, v30, v31);
  if ( !v25[0] || *v25[0] >= 2 )
    QByteArray::reallocData(v25, v25[2], 1);
  CameraStatus = LMX_func_api_GetCameraStatus(&v32, (char *)v25[1], nullptr);
  if ( v25[0] && atomic_fetch_add(v25[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v25[0], 1, 8);
  v24[0] = v29;
  v24[1] = v30;
  v24[2] = v31;
  if ( v29 )
    atomic_fetch_add(v29, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v24);
  if ( v24[0] && atomic_fetch_add(v24[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v24[0], 2, 8);
  if ( CameraStatus != 1 )
  {
    v19 = 0;
    v20 = v29;
    if ( !v29 )
      return v19;
    goto LABEL_36;
  }
  std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
  v7 = *((_QWORD *)this + 140);
  v8 = *(_QWORD *)(v7 + 410272);
  if ( !v8 )
    goto LABEL_30;
  v11 = *(_QWORD *)(v8 + 16);
  v9 = v8 + 16;
  v10 = v11;
  if ( !v11 )
    goto LABEL_30;
  v12 = v30;
  v13 = v31;
  v14 = v9;
  do
  {
    v15 = QtPrivate::compareStrings(*(_QWORD *)(v10 + 48), *(_QWORD *)(v10 + 40), v13, v12, 1);
    if ( v15 >= 0 )
      v14 = v10;
    v10 = *(_QWORD *)(v10 + 8LL * ((unsigned int)v15 >> 31));
  }
  while ( v10 );
  if ( v14 == v9
    || (QtPrivate::compareStrings(v13, v12, *(_QWORD *)(v14 + 48), *(_QWORD *)(v14 + 40), 1) & 0x80000000) != 0 )
  {
LABEL_30:
    v18 = 0;
  }
  else
  {
    v16 = *(unsigned __int16 *)(sub_10002AE78(v7 + 410272, &v29) + 188);
    v17 = v32;
    v18 = v16 != v32;
    *(_WORD *)(sub_10002AE78(*((_QWORD *)this + 140) + 410272LL, &v29) + 188) = v17;
    v7 = *((_QWORD *)this + 140);
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(v7 + 410304));
  v21 = v32;
  v22 = (_DWORD *)(*((_QWORD *)this + 140) + 160100LL);
  if ( *v22 != v32 )
  {
    *v22 = v32;
    lumixtether::DeviceAdapter::cameraStatusChanged(this, v21);
    lumixtether::DeviceAdapter::motionPictureFormatChanged(this, *(unsigned int *)(*((_QWORD *)this + 140) + 1452LL));
  }
  if ( v18 )
    lumixtether::DeviceAdapter::updateLiveviewSelectCamera(this);
  v19 = 1;
  v20 = v29;
  if ( v29 )
  {
LABEL_36:
    if ( atomic_fetch_add(v20, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v29, 2, 8);
  }
  return v19;
}
