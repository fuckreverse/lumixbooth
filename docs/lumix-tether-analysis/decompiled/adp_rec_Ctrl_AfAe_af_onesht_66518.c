// __ZN11lumixtether13DeviceAdapter43adp_LMX_def_lib_tag_rec_Ctrl_AfAe_af_oneshtEv @ 0x100066518 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_def_lib_tag_rec_Ctrl_AfAe_af_onesht(
        lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  int v5; // w23
  __int64 v6; // x20
  atomic_uint *v8[3]; // [xsp+8h] [xbp-888h] BYREF
  atomic_uint *v9[3]; // [xsp+20h] [xbp-870h] BYREF
  atomic_uint *v10; // [xsp+38h] [xbp-858h] BYREF
  atomic_uint *v11; // [xsp+40h] [xbp-850h]
  atomic_uint *v12; // [xsp+48h] [xbp-848h]
  int v13; // [xsp+50h] [xbp-840h] BYREF
  int v14; // [xsp+54h] [xbp-83Ch] BYREF

  bzero(&v14, 0x808u);
  v13 = 50331684;
  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v10 = v2;
    v11 = v3;
    v12 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v10 = nullptr;
    v11 = v3;
    v12 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v10);
  if ( v10 && atomic_fetch_add(v10, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v10, 2, 8);
  QString::toLocal8Bit_helper(v9, v3, v4);
  if ( !v9[0] || *v9[0] >= 2 )
    QByteArray::reallocData(v9, v9[2], 1);
  v5 = LMX_func_api_Rec_Ctrl_AF_AE(&v13, v9[1], 0);
  if ( v9[0] && atomic_fetch_add(v9[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v9[0], 1, 8);
  v8[0] = v2;
  v8[1] = v3;
  v8[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v8);
  if ( v8[0] && atomic_fetch_add(v8[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v8[0], 2, 8);
  if ( v5 == 1 )
  {
    v6 = 1;
    if ( !v2 )
      return v6;
  }
  else
  {
    lumixtether::DeviceAdapter::settingErrorNotify(this);
    v6 = 0;
    if ( !v2 )
      return v6;
  }
  if ( atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v2, 2, 8);
  return v6;
}
