// __ZN11lumixtether13DeviceAdapter29adp_LMX_func_api_GetImageInfoEv @ 0x10003bee4 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_GetImageInfo(lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  int ImageInfo; // w23
  __n128 v6; // q0
  __int64 v7; // x21
  int v8; // w10
  __int64 v9; // x8
  _DWORD *v10; // x9
  unsigned __int64 *v11; // x8
  double v12; // x9
  unsigned __int64 *v13; // x8
  double *v14; // x8
  unsigned __int64 v15; // x10
  __int64 v16; // x8
  int *v17; // x9
  int v18; // w1
  int v19; // w1
  atomic_uint *v21[3]; // [xsp+8h] [xbp-B8h] BYREF
  atomic_uint *v22[3]; // [xsp+20h] [xbp-A0h] BYREF
  atomic_uint *v23; // [xsp+38h] [xbp-88h] BYREF
  atomic_uint *v24; // [xsp+40h] [xbp-80h]
  atomic_uint *v25; // [xsp+48h] [xbp-78h]
  _BYTE v26[8]; // [xsp+50h] [xbp-70h] BYREF
  int v27; // [xsp+58h] [xbp-68h]
  __int16 v28; // [xsp+62h] [xbp-5Eh]
  unsigned __int16 v29; // [xsp+6Ch] [xbp-54h]

  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v23 = v2;
    v24 = v3;
    v25 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v23 = nullptr;
    v24 = v3;
    v25 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v23);
  if ( v23 && atomic_fetch_add(v23, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v23, 2, 8);
  QString::toLocal8Bit_helper(v22, v3, v4);
  if ( !v22[0] || *v22[0] >= 2 )
    QByteArray::reallocData(v22, v22[2], 1);
  ImageInfo = LMX_func_api_GetImageInfo(v26, 33554592, v22[1], 0);
  if ( v22[0] && atomic_fetch_add(v22[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v22[0], 1, 8);
  v21[0] = v2;
  v21[1] = v3;
  v21[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v21);
  if ( v21[0] && atomic_fetch_add(v21[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v21[0], 2, 8);
  v7 = 0;
  if ( ImageInfo )
  {
    v8 = v29;
    v9 = *((_QWORD *)this + 140);
    *(_WORD *)(v9 + 52374) = v29;
    v10 = (_DWORD *)(v9 + 160032);
    switch ( v8 )
    {
      case 0:
        if ( *v10 )
        {
          *v10 = 0;
          lumixtether::DeviceAdapter::aspectRatioChanged(this, 0);
          v9 = *((_QWORD *)this + 140);
        }
        if ( *(double *)(v9 + 300368) == 1.33333333 )
          goto LABEL_28;
        goto LABEL_27;
      case 1:
        if ( *v10 != 1 )
        {
          *v10 = 1;
          lumixtether::DeviceAdapter::aspectRatioChanged(this, 1);
          v9 = *((_QWORD *)this + 140);
        }
        if ( *(double *)(v9 + 300368) != 1.33333333 )
        {
LABEL_27:
          *(_QWORD *)(v9 + 300368) = 0x3FF55555547044B7LL;
          lumixtether::DeviceAdapter::afFrame_asp_xChanged(this, 1.33333333);
          v9 = *((_QWORD *)this + 140);
        }
LABEL_28:
        v11 = (unsigned __int64 *)(v9 + 300376);
        v6.n128_u64[0] = *v11;
        v12 = 36.8;
        goto LABEL_44;
      case 2:
        if ( *v10 != 2 )
        {
          *v10 = 2;
          lumixtether::DeviceAdapter::aspectRatioChanged(this, 2);
          v9 = *((_QWORD *)this + 140);
        }
        if ( *(double *)(v9 + 300368) != 1.5 )
        {
          *(_QWORD *)(v9 + 300368) = 0x3FF8000000000000LL;
          lumixtether::DeviceAdapter::afFrame_asp_xChanged(this, 1.5);
          v9 = *((_QWORD *)this + 140);
        }
        v11 = (unsigned __int64 *)(v9 + 300376);
        v6.n128_u64[0] = *v11;
        v12 = 33.6;
        goto LABEL_44;
      case 3:
        if ( *v10 != 3 )
        {
          *v10 = 3;
          lumixtether::DeviceAdapter::aspectRatioChanged(this, 3);
          v9 = *((_QWORD *)this + 140);
        }
        if ( *(double *)(v9 + 300368) != 1.7777777 )
        {
          *(_QWORD *)(v9 + 300368) = 0x3FFC71C70790EDF9LL;
          lumixtether::DeviceAdapter::afFrame_asp_xChanged(this, 1.7777777);
          v9 = *((_QWORD *)this + 140);
        }
        v11 = (unsigned __int64 *)(v9 + 300376);
        v6.n128_u64[0] = *v11;
        v12 = 29.2;
        goto LABEL_44;
      case 4:
        if ( *v10 != 4 )
        {
          *v10 = 4;
          lumixtether::DeviceAdapter::aspectRatioChanged(this, 4);
          v9 = *((_QWORD *)this + 140);
        }
        if ( *(double *)(v9 + 300368) != 1.0 )
        {
          *(_QWORD *)(v9 + 300368) = 0x3FF0000000000000LL;
          lumixtether::DeviceAdapter::afFrame_asp_xChanged(this, 1.0);
          v9 = *((_QWORD *)this + 140);
        }
        v11 = (unsigned __int64 *)(v9 + 300376);
        v6.n128_u64[0] = *v11;
        v12 = 45.0;
LABEL_44:
        if ( v6.n128_f64[0] != v12 )
        {
          *(double *)v11 = v12;
          lumixtether::DeviceAdapter::lvGDraw_diagonal_rotationChanged(this, v12);
        }
        goto LABEL_55;
      case 10:
        if ( *v10 != 10 )
        {
          *v10 = 10;
          lumixtether::DeviceAdapter::aspectRatioChanged(this, 10);
          v9 = *((_QWORD *)this + 140);
        }
        v13 = (unsigned __int64 *)(v9 + 300368);
        v6.n128_u64[0] = *v13;
        if ( *(double *)v13 == 2.7083333 )
          goto LABEL_55;
        *v13 = 0x4005AAAAA6315791LL;
        v6.n128_u64[0] = 0x4005AAAAA6315791LL;
        break;
      case 11:
        if ( *v10 != 11 )
        {
          *v10 = 11;
          lumixtether::DeviceAdapter::aspectRatioChanged(this, 11);
          v9 = *((_QWORD *)this + 140);
        }
        v14 = (double *)(v9 + 300368);
        v6.n128_u64[0] = 2.0;
        if ( *v14 == 2.0 )
          goto LABEL_55;
        *v14 = 2.0;
        break;
      default:
        goto LABEL_63;
    }
    lumixtether::DeviceAdapter::afFrame_asp_xChanged(this, v6.n128_f64[0]);
LABEL_55:
    v15 = v28;
    v16 = *((_QWORD *)this + 140);
    v17 = (int *)(v16 + 160036);
    *(_WORD *)(v16 + 52372) = v28;
    if ( v15 > 0x10 )
      v18 = -1;
    else
      v18 = dword_100148390[v15];
    if ( *v17 != v18 )
    {
      *v17 = v18;
      lumixtether::DeviceAdapter::imgInfoQualityChanged(this, v6);
      lumixtether::DeviceAdapter::updateCopyPcMask(this);
      v16 = *((_QWORD *)this + 140);
    }
    v19 = (unsigned __int16)v27;
    *(_WORD *)(v16 + 52370) = v27;
    if ( *(_DWORD *)(v16 + 1448) != v19 )
    {
      *(_DWORD *)(v16 + 1448) = v19;
      lumixtether::DeviceAdapter::pictureSizeChanged(this, v19);
    }
    v7 = 1;
  }
LABEL_63:
  if ( v2 && atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v2, 2, 8);
  return v7;
}
