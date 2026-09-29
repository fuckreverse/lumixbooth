// __ZN11lumixtether13DeviceAdapter37adp_LMX_func_api_Get_Partial_ObjectExEjPhmj7QString @ 0x100071ddc (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Partial_ObjectEx(
        __int64 a1,
        unsigned int a2,
        unsigned __int8 *a3,
        unsigned __int64 a4,
        unsigned int a5,
        __int64 a6)
{
  void *v12; // x0
  atomic_uint *v13; // x8
  atomic_uint *v14; // x9
  int Partial_Object; // w21
  atomic_uint *v16; // x8
  atomic_uint *v17; // x9
  atomic_uint *v19[3]; // [xsp+8h] [xbp-78h] BYREF
  atomic_uint *v20[3]; // [xsp+20h] [xbp-60h] BYREF
  atomic_uint *v21[3]; // [xsp+38h] [xbp-48h] BYREF

  if ( *(_QWORD *)(a6 + 8) )
    v12 = *(void **)(a6 + 8);
  else
    v12 = &QString::_empty;
  if ( !(unsigned int)QString::compare_helper(v12, *(_QWORD *)(a6 + 16), &unk_10014269A, -1, 1) )
    QString::operator=(a6, *(_QWORD *)(a1 + 1120) + 307848LL);
  v13 = *(atomic_uint **)a6;
  v14 = *(atomic_uint **)(a6 + 8);
  v21[0] = v13;
  v21[1] = v14;
  v21[2] = *(atomic_uint **)(a6 + 16);
  if ( v13 )
    atomic_fetch_add(v13, 1u);
  lumixtether::DeviceAdapter::dev_mutex_lock(a1, v21);
  if ( v21[0] && atomic_fetch_add(v21[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v21[0], 2, 8);
  QString::toLocal8Bit_helper(v20, *(_QWORD *)(a6 + 8), *(_QWORD *)(a6 + 16));
  if ( !v20[0] || *v20[0] >= 2 )
    QByteArray::reallocData(v20, v20[2], 1);
  Partial_Object = LMX_func_api_Get_Partial_ObjectEx(a2, a3, a4, a5, (char *)v20[1], nullptr);
  if ( v20[0] && atomic_fetch_add(v20[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v20[0], 1, 8);
  v16 = *(atomic_uint **)a6;
  v17 = *(atomic_uint **)(a6 + 8);
  v19[0] = v16;
  v19[1] = v17;
  v19[2] = *(atomic_uint **)(a6 + 16);
  if ( v16 )
    atomic_fetch_add(v16, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v19);
  if ( v19[0] && atomic_fetch_add(v19[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v19[0], 2, 8);
  return Partial_Object != 0;
}
