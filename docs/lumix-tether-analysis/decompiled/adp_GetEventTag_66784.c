// __ZN11lumixtether13DeviceAdapter28adp_LMX_func_api_GetEventTagEPjj @ 0x100066784 (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetEventTag(
        lumixtether::DeviceAdapter *this,
        unsigned int *a2,
        unsigned int a3)
{
  atomic_uint *v6; // x19
  atomic_uint *v7; // x21
  atomic_uint *v8; // x22
  int EventTag; // w23
  atomic_uint *v11[3]; // [xsp+8h] [xbp-78h] BYREF
  atomic_uint *v12[3]; // [xsp+20h] [xbp-60h] BYREF
  atomic_uint *v13; // [xsp+38h] [xbp-48h] BYREF
  atomic_uint *v14; // [xsp+40h] [xbp-40h]
  atomic_uint *v15; // [xsp+48h] [xbp-38h]

  v6 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v7 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v8 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v6 )
  {
    atomic_fetch_add(v6, 1u);
    v13 = v6;
    v14 = v7;
    v15 = v8;
    atomic_fetch_add(v6, 1u);
  }
  else
  {
    v13 = nullptr;
    v14 = v7;
    v15 = v8;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v13);
  if ( v13 && atomic_fetch_add(v13, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v13, 2, 8);
  QString::toLocal8Bit_helper(v12, v7, v8);
  if ( !v12[0] || *v12[0] >= 2 )
    QByteArray::reallocData(v12, v12[2], 1);
  EventTag = LMX_func_api_GetEventTag(a2, a3, (char *)v12[1], nullptr);
  if ( v12[0] && atomic_fetch_add(v12[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v12[0], 1, 8);
  v11[0] = v6;
  v11[1] = v7;
  v11[2] = v8;
  if ( v6 )
    atomic_fetch_add(v6, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v11);
  if ( v11[0] && atomic_fetch_add(v11[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v11[0], 2, 8);
  if ( v6 && atomic_fetch_add(v6, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v6, 2, 8);
  return EventTag == 1;
}
