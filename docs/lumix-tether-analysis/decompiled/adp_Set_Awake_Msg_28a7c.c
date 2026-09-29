// __ZN11lumixtether13DeviceAdapter30adp_LMX_func_api_Set_Awake_MsgE7QString @ 0x100028a7c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Set_Awake_Msg(__int64 a1, QString *a2)
{
  __int64 v3; // x8
  atomic_ullong *v4; // x19
  __int64 v5; // x8
  atomic_uint *v7[3]; // [xsp+8h] [xbp-28h] BYREF

  v3 = 0;
  v4 = (atomic_ullong *)(a1 + 1128);
  atomic_compare_exchange_strong_explicit(
    (atomic_ullong *volatile)(a1 + 1128),
    (unsigned __int64 *)&v3,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v3 )
    QBasicMutex::lockInternal((QBasicMutex *)(a1 + 1128));
  QString::toLatin1_helper(a2, a2);
  if ( !v7[0] || *v7[0] >= 2 )
    QByteArray::reallocData(v7, v7[2], 1);
  LMX_func_api_Set_Awake_Msg((char *)v7[1], nullptr);
  v5 = 1;
  atomic_compare_exchange_strong_explicit(v4, (unsigned __int64 *)&v5, 0, memory_order_release, memory_order_relaxed);
  if ( v5 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v4);
  if ( v7[0] && atomic_fetch_add(v7[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v7[0], 1, 8);
  return 1;
}
