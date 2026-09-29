// __ZN11lumixtether13DeviceAdapter40adp_LMX_func_api_Get_Object_AssociatDescEjPj7QString @ 0x1000717b8 (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_AssociatDesc(
        __int64 a1,
        unsigned int a2,
        unsigned int *a3,
        __int64 a4)
{
  void *v8; // x0
  atomic_uint *v9; // x8
  atomic_uint *v10; // x9
  int Object_AssociatDesc; // w21
  atomic_uint *v12; // x8
  atomic_uint *v13; // x9
  atomic_uint *v15[3]; // [xsp+8h] [xbp-68h] BYREF
  atomic_uint *v16[3]; // [xsp+20h] [xbp-50h] BYREF
  atomic_uint *v17[3]; // [xsp+38h] [xbp-38h] BYREF

  if ( *(_QWORD *)(a4 + 8) )
    v8 = *(void **)(a4 + 8);
  else
    v8 = &QString::_empty;
  if ( !(unsigned int)QString::compare_helper(v8, *(_QWORD *)(a4 + 16), &unk_10014269A, -1, 1) )
    QString::operator=(a4, *(_QWORD *)(a1 + 1120) + 307848LL);
  v9 = *(atomic_uint **)a4;
  v10 = *(atomic_uint **)(a4 + 8);
  v17[0] = v9;
  v17[1] = v10;
  v17[2] = *(atomic_uint **)(a4 + 16);
  if ( v9 )
    atomic_fetch_add(v9, 1u);
  lumixtether::DeviceAdapter::dev_mutex_lock(a1, v17);
  if ( v17[0] && atomic_fetch_add(v17[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v17[0], 2, 8);
  QString::toLocal8Bit_helper(v16, *(_QWORD *)(a4 + 8), *(_QWORD *)(a4 + 16));
  if ( !v16[0] || *v16[0] >= 2 )
    QByteArray::reallocData(v16, v16[2], 1);
  Object_AssociatDesc = LMX_func_api_Get_Object_AssociatDesc(a2, a3, (char *)v16[1], nullptr);
  if ( v16[0] && atomic_fetch_add(v16[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v16[0], 1, 8);
  v12 = *(atomic_uint **)a4;
  v13 = *(atomic_uint **)(a4 + 8);
  v15[0] = v12;
  v15[1] = v13;
  v15[2] = *(atomic_uint **)(a4 + 16);
  if ( v12 )
    atomic_fetch_add(v12, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v15);
  if ( v15[0] && atomic_fetch_add(v15[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v15[0], 2, 8);
  return Object_AssociatDesc != 0;
}
