// __ZN11lumixtether13DeviceAdapter34adp_LMX_func_api_Get_LiveView_dataEv @ 0x100034418 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Get_LiveView_data(lumixtether::DeviceAdapter *this)
{
  __int64 v1; // x9
  __int64 v2; // x8
  unsigned int v3; // w8
  bool v4; // cc
  int v5; // w8
  __int64 v7; // x21
  __int64 v10; // x8
  atomic_ullong *v11; // x20
  __int64 v12; // x21
  __int64 v13; // x22
  __int64 v14; // x23
  __int64 v15; // x24
  _BOOL8 *v16; // x8
  __int64 v17; // x9
  _BOOL8 v18; // x10
  __int64 v19; // x8
  atomic_uint *v20[2]; // [xsp+10h] [xbp-60h] BYREF
  __int64 v21; // [xsp+20h] [xbp-50h]
  unsigned int v22; // [xsp+2Ch] [xbp-44h] BYREF
  unsigned int v23; // [xsp+30h] [xbp-40h] BYREF
  unsigned int v24; // [xsp+34h] [xbp-3Ch] BYREF
  unsigned int v25; // [xsp+38h] [xbp-38h] BYREF
  unsigned int v26; // [xsp+3Ch] [xbp-34h] BYREF

  v26 = **((_QWORD **)this + 146);
  v1 = **((_QWORD **)this + 148);
  v24 = **((_QWORD **)this + 150);
  v25 = v1;
  v23 = 0x100000;
  v2 = *((_QWORD *)this + 140);
  if ( !*(_BYTE *)(v2 + 410384) )
    return 0;
  v3 = *(_DWORD *)(v2 + 307740);
  v4 = v3 > 4;
  v5 = (1 << v3) & 0x13;
  if ( !v4 && v5 != 0 )
    return 0;
  v10 = 0;
  v11 = (atomic_ullong *)((char *)this + 1136);
  atomic_compare_exchange_strong_explicit(
    (atomic_ullong *volatile)this + 142,
    (unsigned __int64 *)&v10,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v10 )
    QBasicMutex::lockInternal((lumixtether::DeviceAdapter *)((char *)this + 1136));
  v12 = *((_QWORD *)this + 145);
  v13 = *((_QWORD *)this + 147);
  v14 = *((_QWORD *)this + 149);
  if ( **((_QWORD **)this + 155) )
  {
    v15 = *((_QWORD *)this + 152);
    QString::toLocal8Bit_helper(
      v20,
      *(_QWORD *)(*((_QWORD *)this + 140) + 307856LL),
      *(_QWORD *)(*((_QWORD *)this + 140) + 307864LL));
    if ( !v20[0] || *v20[0] >= 2 )
      QByteArray::reallocData(v20, v21, 1);
  }
  else
  {
    v15 = *((_QWORD *)this + 151);
    QString::toLocal8Bit_helper(
      v20,
      *(_QWORD *)(*((_QWORD *)this + 140) + 307856LL),
      *(_QWORD *)(*((_QWORD *)this + 140) + 307864LL));
    if ( !v20[0] || *v20[0] >= 2 )
      QByteArray::reallocData(v20, v21, 1);
  }
  **((_QWORD **)this + 156) = (unsigned int)LMX_func_api_Get_LiveView_data(
                                              v12,
                                              &v26,
                                              v13,
                                              &v25,
                                              v14,
                                              &v24,
                                              v15,
                                              &v23,
                                              v20[1],
                                              &v22);
  if ( v20[0] && atomic_fetch_add(v20[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v20[0], 1, 8);
  **((_QWORD **)this + 146) = v26;
  **((_QWORD **)this + 148) = v25;
  **((_QWORD **)this + 150) = v24;
  v16 = *((_BOOL8 **)this + 155);
  if ( *v16 )
    v17 = 1232;
  else
    v17 = 1224;
  v18 = !*v16;
  **(_QWORD **)((char *)this + v17) = v23;
  *v16 = v18;
  if ( **((_QWORD **)this + 156) == 1 )
  {
    v7 = 1;
  }
  else
  {
    v7 = 0;
    **((_QWORD **)this + 157) = v22;
  }
  v19 = 1;
  atomic_compare_exchange_strong_explicit(v11, (unsigned __int64 *)&v19, 0, memory_order_release, memory_order_relaxed);
  if ( v19 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)v11);
  return v7;
}
