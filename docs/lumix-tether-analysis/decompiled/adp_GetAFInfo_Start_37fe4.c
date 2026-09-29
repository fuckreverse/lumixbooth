// __ZN11lumixtether13DeviceAdapter33adp_LMX_func_api_WB_GetCapabilityEv @ 0x100037fe4 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_WB_GetCapability(lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  __int64 v5; // x23
  int Capability; // w23
  __int64 v7; // x21
  __int64 v8; // x8
  __int64 v9; // x9
  int v10; // w0
  __int64 v11; // x8
  int v12; // w10
  int v13; // w0
  __int64 v14; // x8
  __int64 v15; // x11
  __int64 v16; // x8
  _DWORD *v17; // x9
  __int64 i; // x11
  __int64 v19; // x15
  int v20; // w10
  __int64 v21; // x1
  __int64 v22; // x20
  int v23; // w0
  __int64 v24; // x8
  int v25; // w0
  __int64 v26; // x8
  int v27; // w0
  __int64 v28; // x8
  atomic_uint *v30[3]; // [xsp+8h] [xbp-78h] BYREF
  atomic_uint *v31[3]; // [xsp+20h] [xbp-60h] BYREF
  atomic_uint *v32; // [xsp+38h] [xbp-48h] BYREF
  atomic_uint *v33; // [xsp+40h] [xbp-40h]
  atomic_uint *v34; // [xsp+48h] [xbp-38h]

  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v32 = v2;
    v33 = v3;
    v34 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v32 = nullptr;
    v33 = v3;
    v34 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v32);
  if ( v32 && atomic_fetch_add(v32, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v32, 2, 8);
  v5 = *((_QWORD *)this + 140);
  QString::toLocal8Bit_helper(v31, v3, v4);
  if ( !v31[0] || *v31[0] >= 2 )
    QByteArray::reallocData(v31, v31[2], 1);
  Capability = LMX_func_api_WB_GetCapability(v5 + 37946, v31[1], 0);
  if ( v31[0] && atomic_fetch_add(v31[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v31[0], 1, 8);
  v30[0] = v2;
  v30[1] = v3;
  v30[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v30);
  if ( v30[0] && atomic_fetch_add(v30[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v30[0], 2, 8);
  if ( !Capability )
  {
    v22 = 0;
    if ( !v2 )
      return v22;
    goto LABEL_59;
  }
  v7 = 0;
  v8 = *((_QWORD *)this + 140);
  v9 = 0x101010101010101LL * *(unsigned __int8 *)(v8 + 410520);
  *(_DWORD *)(v8 + 16952) = v9;
  v8 += 16937;
  *(_QWORD *)v8 = v9;
  *(_QWORD *)(v8 + 8) = v9;
  do
  {
    v10 = sub_1000497F8(*(unsigned __int16 *)(*((_QWORD *)this + 140) + v7 + 37948));
    if ( v10 != -1 )
      *(_BYTE *)(*((_QWORD *)this + 140) + v10 + 16937LL) = 1;
    v7 += 2;
  }
  while ( v7 != 1024 );
  v11 = *((_QWORD *)this + 140);
  v12 = *(unsigned __int16 *)(v11 + 37946);
  if ( *(_DWORD *)(v11 + 18892) != v12 )
  {
    *(_DWORD *)(v11 + 18892) = v12;
    lumixtether::DeviceAdapter::whiteBalanceFlgNumChanged(this);
    v11 = *((_QWORD *)this + 140);
  }
  v13 = sub_1000497F8(*(unsigned __int16 *)(v11 + 43086));
  if ( (unsigned int)(v13 + 1) <= 0x13 )
  {
    v14 = *((_QWORD *)this + 140);
    if ( *(_DWORD *)(v14 + 1524) != v13 )
    {
      *(_DWORD *)(v14 + 1524) = v13;
      lumixtether::DeviceAdapter::whiteBalanceChanged(this);
    }
  }
  v15 = 0;
  v16 = *((_QWORD *)this + 140);
  v17 = (_DWORD *)(v16 + 18896);
  do
    *(_BYTE *)(v16 + 16956 + v15++) = *(_BYTE *)(v16 + 410520);
  while ( v15 != 80 );
  for ( i = 0; i != 512; ++i )
  {
    v19 = 0;
    while ( lumixtether::Utilities::arrWBKVal[v19] != *(unsigned __int16 *)(v16 + 2 * i + 38976) )
    {
      if ( ++v19 == 80 )
        goto LABEL_31;
    }
    if ( (_DWORD)v19 != -1 )
      *(_BYTE *)(v16 + 16956 + v19) = 1;
LABEL_31:
    ;
  }
  v20 = *(unsigned __int16 *)(v16 + 38974);
  if ( *v17 != v20 )
  {
    *v17 = v20;
    lumixtether::DeviceAdapter::whiteBalanceKSetFlgNumChanged(this);
    v16 = *((_QWORD *)this + 140);
  }
  v21 = 0;
  while ( lumixtether::Utilities::arrWBKVal[v21] != *(unsigned __int16 *)(v16 + 43088) )
  {
    if ( ++v21 == 80 )
    {
      LODWORD(v21) = -1;
      goto LABEL_47;
    }
  }
  if ( (unsigned int)(v21 + 1) > 0x50 )
    goto LABEL_49;
LABEL_47:
  if ( *(_DWORD *)(v16 + 1528) != (_DWORD)v21 )
  {
    *(_DWORD *)(v16 + 1528) = v21;
    lumixtether::DeviceAdapter::whiteBalanceKSetChanged(this);
    v16 = *((_QWORD *)this + 140);
  }
LABEL_49:
  v23 = sub_100049918(*(unsigned __int16 *)(v16 + 43090));
  if ( (unsigned int)(v23 + 1) <= 0x15 )
  {
    v24 = *((_QWORD *)this + 140);
    if ( *(_DWORD *)(v24 + 1532) != v23 )
    {
      *(_DWORD *)(v24 + 1532) = v23;
      lumixtether::DeviceAdapter::wbAdjustABChanged(this);
    }
  }
  v25 = sub_100049918(*(unsigned __int16 *)(*((_QWORD *)this + 140) + 43092LL));
  if ( (unsigned int)(v25 + 1) <= 0x15 )
  {
    v26 = *((_QWORD *)this + 140);
    if ( *(_DWORD *)(v26 + 1540) != v25 )
    {
      *(_DWORD *)(v26 + 1540) = v25;
      lumixtether::DeviceAdapter::wbAdjustGMChanged(this);
    }
  }
  v27 = sub_100049918(*(unsigned __int16 *)(*((_QWORD *)this + 140) + 43094LL));
  if ( (unsigned int)(v27 + 1) <= 0x15 )
  {
    v28 = *((_QWORD *)this + 140);
    if ( *(_DWORD *)(v28 + 1536) != v27 )
    {
      *(_DWORD *)(v28 + 1536) = v27;
      lumixtether::DeviceAdapter::wbAdjustABSepChanged(this);
    }
  }
  v22 = 1;
  if ( v2 )
  {
LABEL_59:
    if ( atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v2, 2, 8);
  }
  return v22;
}
