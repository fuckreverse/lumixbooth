// __ZN11lumixtether13DeviceAdapter33adp_LMX_func_api_GetStatusOfCardsEPNS0_13StatusOfCardsE7QString @ 0x10009aaac (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetStatusOfCards(__int64 a1, _DWORD *a2, __int64 a3)
{
  void *v6; // x0
  atomic_uint *v7; // x8
  atomic_uint *v8; // x9
  int StatusOfCards; // w22
  atomic_uint *v10; // x8
  atomic_uint *v11; // x9
  int16x8_t v12; // q2
  int8x8_t v13; // d3
  int8x8_t v14; // d1
  __int64 v15; // x1
  atomic_uint *v17[3]; // [xsp+10h] [xbp-90h] BYREF
  atomic_uint *v18[3]; // [xsp+28h] [xbp-78h] BYREF
  atomic_uint *v19[3]; // [xsp+40h] [xbp-60h] BYREF
  __int16 v20; // [xsp+58h] [xbp-48h] BYREF
  int16x8_t v21; // [xsp+5Ah] [xbp-46h]
  int16x8_t v22; // [xsp+6Ah] [xbp-36h]

  if ( *(_QWORD *)(a3 + 8) )
    v6 = *(void **)(a3 + 8);
  else
    v6 = &QString::_empty;
  if ( !(unsigned int)QString::compare_helper(v6, *(_QWORD *)(a3 + 16), &unk_10014269A, -1, 1) )
    QString::operator=(a3, *(_QWORD *)(a1 + 1120) + 307848LL);
  v7 = *(atomic_uint **)a3;
  v8 = *(atomic_uint **)(a3 + 8);
  v19[0] = v7;
  v19[1] = v8;
  v19[2] = *(atomic_uint **)(a3 + 16);
  if ( v7 )
    atomic_fetch_add(v7, 1u);
  lumixtether::DeviceAdapter::dev_mutex_lock(a1, v19);
  if ( v19[0] && atomic_fetch_add(v19[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v19[0], 2, 8);
  QString::toLocal8Bit_helper(v18, *(_QWORD *)(a3 + 8), *(_QWORD *)(a3 + 16));
  if ( !v18[0] || *v18[0] >= 2 )
    QByteArray::reallocData(v18, v18[2], 1);
  StatusOfCards = LMX_func_api_GetStatusOfCards(&v20, v18[1], 0);
  if ( v18[0] && atomic_fetch_add(v18[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v18[0], 1, 8);
  v10 = *(atomic_uint **)a3;
  v11 = *(atomic_uint **)(a3 + 8);
  v17[0] = v10;
  v17[1] = v11;
  v17[2] = *(atomic_uint **)(a3 + 16);
  if ( v10 )
    atomic_fetch_add(v10, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v17);
  if ( v17[0] )
  {
    if ( atomic_fetch_add(v17[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v17[0], 2, 8);
  }
  if ( StatusOfCards != 1 )
    return 0;
  if ( v20 )
  {
    v12.i64[0] = 0x1000100010001LL;
    v12.i64[1] = 0x1000100010001LL;
    v13 = vmovn_s16(vceqq_s16(v21, v12));
    v14 = vmovn_s16(vceqq_s16(v22, v12));
    if ( !(v13.i8[0] & 1
         | (2 * (v13.i8[1] & 1)) & 0xC3
         | (4 * (v13.i8[2] & 1)) & 0xC7
         | (8 * (v13.i8[3] & 1)) & 0xCF
         | (16 * (v13.i8[4] & 1)) & 0xDF
         | (unsigned __int16)(32 * (v13.i8[5] & 1))
         | ((v13.i8[6] & 1) << 6)
         | ((v13.i8[7] & 1) << 7)
         | ((v14.i8[0] & 1) << 8)
         | ((v14.i8[1] & 1) << 9)
         | ((v14.i8[2] & 1) << 10)
         | ((v14.i8[3] & 1) << 11)
         | ((v14.i8[4] & 1) << 12)
         | ((v14.i8[5] & 1) << 13)
         | ((v14.i8[6] & 1) << 14)
         | (unsigned __int16)(v14.u8[7] << 15)) )
    {
      if ( v21.u16[0] > 3u )
      {
        v15 = 0xFFFFFFFFLL;
        if ( a2 )
          goto LABEL_32;
      }
      else
      {
        v15 = dword_1001460C0[v21.i16[0]];
        if ( a2 )
          goto LABEL_32;
      }
LABEL_34:
      lumixtether::DeviceAdapter::setStatusOfCardsValue(a1, v15);
      return 1;
    }
    v15 = 0;
    if ( !a2 )
      goto LABEL_34;
  }
  else
  {
    v15 = 1;
    if ( !a2 )
      goto LABEL_34;
  }
LABEL_32:
  *a2 = v15;
  return 1;
}
