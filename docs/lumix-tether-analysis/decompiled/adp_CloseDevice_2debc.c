// __ZN11lumixtether13DeviceAdapter28adp_LMX_func_api_CloseDeviceE7QString @ 0x10002debc
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_CloseDevice(__int64 a1, atomic_uint **a2)
{
  atomic_uint *v4; // x8
  atomic_uint *v5; // x9
  int v6; // w21
  atomic_uint *v7; // x8
  atomic_uint *v8; // x9
  atomic_uint *v10[3]; // [xsp+8h] [xbp-68h] BYREF
  atomic_uint *v11[3]; // [xsp+20h] [xbp-50h] BYREF
  atomic_uint *v12[3]; // [xsp+38h] [xbp-38h] BYREF

  v4 = *a2;
  v5 = a2[1];
  v12[0] = v4;
  v12[1] = v5;
  v12[2] = a2[2];
  if ( v4 )
    atomic_fetch_add(v4, 1u);
  lumixtether::DeviceAdapter::dev_mutex_lock(a1, v12);
  if ( v12[0] && atomic_fetch_add(v12[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v12[0], 2, 8);
  QString::toLocal8Bit_helper(v11, a2[1], a2[2]);
  if ( !v11[0] || *v11[0] >= 2 )
    QByteArray::reallocData(v11, v11[2], 1);
  v6 = LMX_func_api_CloseDevice((char *)v11[1], nullptr);
  if ( v11[0] && atomic_fetch_add(v11[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v11[0], 1, 8);
  v7 = *a2;
  v8 = a2[1];
  v10[0] = v7;
  v10[1] = v8;
  v10[2] = a2[2];
  if ( v7 )
    atomic_fetch_add(v7, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v10);
  if ( v10[0] && atomic_fetch_add(v10[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v10[0], 2, 8);
  return v6 == 1;
}
