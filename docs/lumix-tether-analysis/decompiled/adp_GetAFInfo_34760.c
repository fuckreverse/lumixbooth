// __ZN11lumixtether13DeviceAdapter26adp_LMX_func_api_GetAFInfoEv @ 0x100034760 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetAFInfo(lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  int AFInfo; // w23
  __int64 v6; // x8
  int v7; // w21
  __int64 v8; // x20
  atomic_uint *v10[3]; // [xsp+0h] [xbp-13E0h] BYREF
  atomic_uint *v11[3]; // [xsp+18h] [xbp-13C8h] BYREF
  atomic_uint *v12; // [xsp+30h] [xbp-13B0h] BYREF
  atomic_uint *v13; // [xsp+38h] [xbp-13A8h]
  atomic_uint *v14; // [xsp+40h] [xbp-13A0h]
  _QWORD __src[621]; // [xsp+48h] [xbp-1398h] BYREF

  bzero(__src, 0x1368u);
  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v12 = v2;
    v13 = v3;
    v14 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v12 = nullptr;
    v13 = v3;
    v14 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v12);
  if ( v12 && atomic_fetch_add(v12, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v12, 2, 8);
  QString::toLocal8Bit_helper(v11, v3, v4);
  if ( !v11[0] || *v11[0] >= 2 )
    QByteArray::reallocData(v11, v11[2], 1);
  AFInfo = LMX_func_api_GetAFInfo(__src, 16777232, v11[1], 0);
  if ( v11[0] && atomic_fetch_add(v11[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v11[0], 1, 8);
  v10[0] = v2;
  v10[1] = v3;
  v10[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v10);
  if ( v10[0] && atomic_fetch_add(v10[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v10[0], 2, 8);
  v6 = *((_QWORD *)this + 140);
  if ( *(unsigned __int16 *)(v6 + 149454) == HIWORD(__src[616])
    && *(_QWORD *)(v6 + 149456) == __src[617]
    && *(_QWORD *)(v6 + 149464) == __src[618]
    && *(_QWORD *)(v6 + 149472) == __src[619]
    && *(_QWORD *)(v6 + 149480) == __src[620] )
  {
    v7 = 0;
    if ( AFInfo != 1 )
      goto LABEL_24;
  }
  else
  {
    v7 = 1;
    if ( AFInfo != 1 )
    {
LABEL_24:
      v8 = 0;
      if ( !v2 )
        return v8;
      goto LABEL_30;
    }
  }
  memcpy((void *)(v6 + 144520), __src, 0x1368u);
  lumixtether::DeviceAdapter::af_frame_info_Changed(this);
  if ( v7 )
    lumixtether::DeviceAdapter::af_pdaf_frame_numChanged(this);
  lumixtether::DeviceAdapter::af_detect_frame_info_Changed(this);
  v8 = 1;
  if ( v2 )
  {
LABEL_30:
    if ( atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v2, 2, 8);
  }
  return v8;
}
