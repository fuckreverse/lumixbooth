// __ZN11lumixtether13DeviceAdapter18getImgQualityParamE7QStringNS_9Utilities20LiveViewImageQualityEP38_tag_LMX_STRUCT_LIVEVIEW_STR_TRANS_IMG @ 0x10004e910 (imagebase-relative)
bool __fastcall lumixtether::DeviceAdapter::getImgQualityParam(
        __int64 a1,
        atomic_uint **a2,
        unsigned int a3,
        __int64 a4)
{
  _BOOL8 v4; // x23
  atomic_uint *v9; // x8
  atomic_uint *v10; // x9
  int Recom_Img; // w23
  atomic_uint *v12; // x8
  atomic_uint *v13; // x9
  bool v14; // cc
  __int16 v15; // w8
  atomic_uint *v17[3]; // [xsp+0h] [xbp-2080h] BYREF
  atomic_uint *v18[3]; // [xsp+18h] [xbp-2068h] BYREF
  atomic_uint *v19[3]; // [xsp+30h] [xbp-2050h] BYREF
  unsigned __int16 v20[4100]; // [xsp+48h] [xbp-2038h] BYREF

  v4 = 0;
  if ( a3 <= 2 && a4 )
  {
    bzero(v20, 0x2004u);
    v9 = *a2;
    v10 = a2[1];
    v19[0] = v9;
    v19[1] = v10;
    v19[2] = a2[2];
    if ( v9 )
      atomic_fetch_add(v9, 1u);
    lumixtether::DeviceAdapter::dev_mutex_lock(a1, v19);
    if ( v19[0] && atomic_fetch_add(v19[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v19[0], 2, 8);
    QString::toLocal8Bit_helper(v18, a2[1], a2[2]);
    if ( !v18[0] || *v18[0] >= 2 )
      QByteArray::reallocData(v18, v18[2], 1);
    Recom_Img = LMX_func_api_LiveView_Str_Get_Recom_Img(v20, v18[1], 0);
    if ( v18[0] && atomic_fetch_add(v18[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v18[0], 1, 8);
    v12 = *a2;
    v13 = a2[1];
    v17[0] = v12;
    v17[1] = v13;
    v17[2] = a2[2];
    if ( v12 )
      atomic_fetch_add(v12, 1u);
    lumixtether::DeviceAdapter::dev_mutex_unlock(a1, v17);
    if ( v17[0] && atomic_fetch_add(v17[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v17[0], 2, 8);
    v14 = Recom_Img == 1 && v20[0] > a3;
    v4 = v14;
    if ( v4 )
    {
      *(_QWORD *)a4 = *(_QWORD *)&v20[4 * a3 + 2];
      if ( *(_BYTE *)(sub_10002AE78(*(_QWORD *)(a1 + 1120) + 410272LL, a2) + 160) )
      {
        if ( a3 == 1 )
        {
          v15 = 64;
          goto LABEL_31;
        }
        if ( a3 == 2 )
        {
          v15 = 128;
LABEL_31:
          *(_WORD *)(a4 + 4) = v15;
        }
      }
    }
  }
  return v4;
}
