// __ZN11lumixtether13DeviceAdapter39adp_LMX_func_api_Mnt_Ctrl_LiveView_StopEv @ 0x100066074 (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Mnt_Ctrl_LiveView_Stop(lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  int v5; // w23
  atomic_uint *v7[3]; // [xsp+8h] [xbp-888h] BYREF
  atomic_uint *v8[3]; // [xsp+20h] [xbp-870h] BYREF
  atomic_uint *v9; // [xsp+38h] [xbp-858h] BYREF
  atomic_uint *v10; // [xsp+40h] [xbp-850h]
  atomic_uint *v11; // [xsp+48h] [xbp-848h]
  int v12; // [xsp+50h] [xbp-840h] BYREF
  int v13; // [xsp+54h] [xbp-83Ch] BYREF

  bzero(&v13, 0x808u);
  v12 = -2147155727;
  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v9 = v2;
    v10 = v3;
    v11 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v9 = nullptr;
    v10 = v3;
    v11 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v9);
  if ( v9 && atomic_fetch_add(v9, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v9, 2, 8);
  QString::toLocal8Bit_helper(v8, v3, v4);
  if ( !v8[0] || *v8[0] >= 2 )
    QByteArray::reallocData(v8, v8[2], 1);
  v5 = LMX_func_api_Mnt_Ctrl_LiveView(&v12, v8[1], 0);
  if ( v8[0] && atomic_fetch_add(v8[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v8[0], 1, 8);
  v7[0] = v2;
  v7[1] = v3;
  v7[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v7);
  if ( v7[0] && atomic_fetch_add(v7[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v7[0], 2, 8);
  if ( v2 && atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v2, 2, 8);
  return v5 == 1;
}
