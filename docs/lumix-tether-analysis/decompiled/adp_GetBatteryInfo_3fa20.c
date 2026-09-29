// __ZN11lumixtether13DeviceAdapter31adp_LMX_func_api_GetBatteryInfoEv @ 0x10003fa20 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetBatteryInfo(lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  __int64 v5; // x23
  int BatteryInfo; // w23
  __int64 v7; // x9
  unsigned __int16 *v8; // x8
  _WORD *v9; // x9
  unsigned int v10; // w8
  __int64 v11; // x20
  atomic_uint *v13[3]; // [xsp+8h] [xbp-78h] BYREF
  atomic_uint *v14[3]; // [xsp+20h] [xbp-60h] BYREF
  atomic_uint *v15; // [xsp+38h] [xbp-48h] BYREF
  atomic_uint *v16; // [xsp+40h] [xbp-40h]
  atomic_uint *v17; // [xsp+48h] [xbp-38h]

  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v15 = v2;
    v16 = v3;
    v17 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v15 = nullptr;
    v16 = v3;
    v17 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v15);
  if ( v15 && atomic_fetch_add(v15, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v15, 2, 8);
  v5 = *((_QWORD *)this + 140);
  QString::toLocal8Bit_helper(v14, v3, v4);
  if ( !v14[0] || *v14[0] >= 2 )
    QByteArray::reallocData(v14, v14[2], 1);
  BatteryInfo = LMX_func_api_GetBatteryInfo(v5 + 292480, v14[1], 0);
  if ( v14[0] && atomic_fetch_add(v14[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v14[0], 1, 8);
  v13[0] = v2;
  v13[1] = v3;
  v13[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v13);
  if ( v13[0] && atomic_fetch_add(v13[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v13[0], 2, 8);
  if ( BatteryInfo != 1 )
  {
    v11 = 0;
    if ( !v2 )
      return v11;
    goto LABEL_27;
  }
  v7 = *((_QWORD *)this + 140);
  v8 = (unsigned __int16 *)(v7 + 292490);
  v9 = (_WORD *)(v7 + 160056);
  if ( (unsigned int)*v8 - 1 > 1 )
    v10 = v8[1];
  else
    v10 = v8[2];
  if ( (unsigned __int16)*v9 != v10 )
  {
    *v9 = v10;
    lumixtether::DeviceAdapter::batteryLevelChanged(this, v10);
  }
  v11 = 1;
  if ( v2 )
  {
LABEL_27:
    if ( atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v2, 2, 8);
  }
  return v11;
}
