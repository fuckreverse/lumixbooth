// __ZN11lumixtether13DeviceAdapter27adp_LMX_func_api_Get_ObjectEjPhj7QString @ 0x100071ff8 (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object(
        __int64 a1,
        unsigned int a2,
        unsigned __int8 *a3,
        unsigned int a4,
        __int64 a5)
{
  void *v10; // x0
  atomic_uint *v11; // x8
  atomic_uint *v12; // x9
  int Object; // w21
  atomic_uint *v14; // x8
  atomic_uint *v15; // x9
  atomic_uint *v17[3]; // [xsp+8h] [xbp-78h] BYREF
  atomic_uint *v18[3]; // [xsp+20h] [xbp-60h] BYREF
  atomic_uint *v19[3]; // [xsp+38h] [xbp-48h] BYREF

  if ( *(_QWORD *)(a5 + 8) )
    v10 = *(void **)(a5 + 8);
  else
    v10 = &QString::_empty;
  if ( !(unsigned int)QString::compare_helper(v10, *(_QWORD *)(a5 + 16), &unk_10014269A, -1, 1) )
    QString::operator=(a5, *(_QWORD *)(a1 + 1120) + 307848LL);
  v11 = *(atomic_uint **)a5;
  v12 = *(atomic_uint **)(a5 + 8);
  v19[0] = v11;
  v19[1] = v12;
  v19[2] = *(atomic_uint **)(a5 + 16);
  if ( v11 )
    atomic_fetch_add(v11, 1u);
  lumixtether::DeviceAdapter::dev_mutex_lock(a1, v19);
  if ( v19[0] && atomic_fetch_add(v19[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v19[0], 2, 8);
  QString::toLocal8Bit_helper(v18, *(_QWORD *)(a5 + 8), *(_QWORD *)(a5 + 16));
  if ( !v18[0] || *v18[0] >= 2 )
    QByteArray::reallocData(v18, v18[2], 1);
  Object = LMX_func_api_Get_Object(a2, a3, a4, (char *)v18[1], nullptr);
  if ( v18[0] && atomic_fetch_add(v18[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v18[0], 1, 8);
  v14 = *(atomic_uint **)a5;
  v15 = *(atomic_uint **)(a5 + 8);
  v17[0] = v14;
  v17[1] = v15;
  v17[2] = *(atomic_uint **)(a5 + 16);
  if ( v14 )
    atomic_fetch_add(v14, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v17);
  if ( v17[0] && atomic_fetch_add(v17[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v17[0], 2, 8);
  return Object != 0;
}
