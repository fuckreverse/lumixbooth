// __ZN11lumixtether13DeviceAdapter40adp_LMX_func_api_AF_Config_GetCapabilityEv @ 0x100039388 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_AF_Config_GetCapability(
        lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  __int64 v5; // x23
  int Capability; // w23
  __int64 v7; // x8
  int v8; // w9
  __int64 v9; // x8
  _DWORD *v10; // x9
  int v11; // w10
  __int16 *v12; // x11
  __int64 v13; // x16
  unsigned __int64 v14; // x17
  unsigned __int64 v15; // x9
  int v16; // w1
  __int64 v17; // x20
  __int64 v18; // x10
  __int64 v19; // x12
  __int64 v20; // x8
  unsigned int v21; // w17
  unsigned __int64 v22; // x10
  __int64 v23; // x15
  __int64 v24; // x10
  __int64 v25; // x11
  __int64 v26; // x12
  __int64 v27; // x13
  __int64 v28; // x14
  __int64 v29; // x21
  __int64 v30; // x16
  int v31; // w9
  __int64 v32; // x17
  char *v33; // x8
  _BYTE *v34; // x15
  unsigned __int64 v35; // x5
  __int64 v36; // x22
  int v37; // w10
  int v38; // w10
  int v39; // w10
  int v40; // w10
  int v41; // w11
  char v42; // w9
  char v43; // w10
  __int64 v44; // x9
  char *v45; // x8
  char v46; // w9
  char v47; // w10
  __int64 v48; // x8
  int *v49; // x9
  int v50; // w11
  int v51; // w1
  int *v52; // x9
  int v53; // w1
  int *v54; // x9
  int v55; // w1
  char *v56; // x9
  char v57; // w8
  char v58; // w10
  __int64 v59; // x8
  int *v60; // x9
  int v61; // w11
  int v62; // w1
  int v63; // w10
  _DWORD *v64; // x9
  int v65; // w10
  int v66; // w8
  __int64 v67; // x8
  __int64 v68; // x8
  __int64 v69; // x1
  atomic_uint *v71[3]; // [xsp+8h] [xbp-78h] BYREF
  atomic_uint *v72[3]; // [xsp+20h] [xbp-60h] BYREF
  atomic_uint *v73; // [xsp+38h] [xbp-48h] BYREF
  atomic_uint *v74; // [xsp+40h] [xbp-40h]
  atomic_uint *v75; // [xsp+48h] [xbp-38h]

  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v73 = v2;
    v74 = v3;
    v75 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v73 = nullptr;
    v74 = v3;
    v75 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v73);
  if ( v73 && atomic_fetch_add(v73, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v73, 2, 8);
  v5 = *((_QWORD *)this + 140);
  QString::toLocal8Bit_helper(v72, v3, v4);
  if ( !v72[0] || *v72[0] >= 2 )
    QByteArray::reallocData(v72, v72[2], 1);
  Capability = LMX_func_api_AF_Config_GetCapability(v5 + 56502, v72[1], 0);
  if ( v72[0] && atomic_fetch_add(v72[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v72[0], 1, 8);
  v71[0] = v2;
  v71[1] = v3;
  v71[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v71);
  if ( v71[0] && atomic_fetch_add(v71[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v71[0], 2, 8);
  if ( Capability )
  {
    v7 = *((_QWORD *)this + 140);
    v8 = 16843009 * *(unsigned __int8 *)(v7 + 410520);
    *(_BYTE *)(v7 + 9000) = *(_BYTE *)(v7 + 410520);
    *(_DWORD *)(v7 + 8996) = v8;
    v9 = *((_QWORD *)this + 140);
    v10 = (_DWORD *)(v9 + 18796);
    v11 = *(unsigned __int16 *)(v9 + 56502);
    if ( *(_WORD *)(v9 + 56502) )
    {
      v12 = (__int16 *)(v9 + 56504);
      v13 = *(unsigned __int16 *)(v9 + 56502);
      do
      {
        v14 = *v12;
        if ( v14 <= 6 && ((0x79u >> v14) & 1) != 0 )
          *(_BYTE *)(v9 + qword_100147D48[v14] + 8996) = 1;
        ++v12;
        --v13;
      }
      while ( v13 );
    }
    if ( *v10 != v11 )
    {
      *v10 = v11;
      lumixtether::DeviceAdapter::focusModeFlgNumChanged(this);
      v9 = *((_QWORD *)this + 140);
    }
    v15 = *(__int16 *)(v9 + 65754);
    if ( v15 > 6 )
      v16 = -1;
    else
      v16 = dword_100147D80[v15];
    if ( *(_DWORD *)(v9 + 108) != v16 )
    {
      *(_DWORD *)(v9 + 108) = v16;
      lumixtether::DeviceAdapter::focusModeChanged(this);
      v9 = *((_QWORD *)this + 140);
    }
    v18 = 0;
    v19 = 0x101010101010101LL * *(unsigned __int8 *)(v9 + 410520);
    *(_QWORD *)(v9 + 9001) = v19;
    *(_QWORD *)(v9 + 9009) = v19;
    *(_DWORD *)(v9 + 9016) = v19;
    v20 = *((_QWORD *)this + 140);
    do
    {
      v21 = *(unsigned __int16 *)(v20 + 57532 + v18);
      if ( v21 <= 0x15 && ((0x3FC06Fu >> v21) & 1) != 0 )
        *(_BYTE *)(v20 + qword_100147FB0[(__int16)v21] + 9001) = 1;
      v18 += 2;
    }
    while ( v18 != 1024 );
    v22 = *(__int16 *)(v20 + 65756);
    if ( v22 > 0x15 )
    {
      v24 = 0xFFFFFFFFLL;
      v25 = 0xFFFFFFFFLL;
      v26 = 0xFFFFFFFFLL;
      v27 = 0xFFFFFFFFLL;
      v28 = 0xFFFFFFFFLL;
      v29 = 0xFFFFFFFFLL;
    }
    else
    {
      v23 = 4 * v22;
      v24 = dword_100147D9C[v22];
      v25 = *(unsigned int *)((char *)&unk_100147DF4 + v23);
      v26 = *(unsigned int *)((char *)&unk_100147E4C + v23);
      v27 = *(unsigned int *)((char *)&unk_100147EA4 + v23);
      v28 = *(unsigned int *)((char *)&unk_100147EFC + v23);
      v29 = *(unsigned int *)((char *)&unk_100147F54 + v23);
    }
    v30 = 0;
    v31 = 16843009 * *(unsigned __int8 *)(v20 + 410520);
    *(_WORD *)(v20 + 9024) = v31;
    *(_DWORD *)(v20 + 9020) = v31;
    v32 = *((_QWORD *)this + 140);
    v33 = (char *)(v32 + 410440);
    v34 = (_BYTE *)(v32 + 9004);
    do
    {
      v35 = *(__int16 *)(v32 + 59588 + v30);
      if ( v35 <= 6 && ((0x77u >> v35) & 1) != 0 )
        *(_BYTE *)(v32 + qword_100148060[v35] + 9020) = 1;
      v30 += 2;
    }
    while ( v30 != 1024 );
    v36 = 0;
    switch ( *(_WORD *)(v32 + 65760) )
    {
      case 0:
        break;
      case 1:
        v37 = (unsigned __int8)*v34;
        *v34 = 0;
        v36 = 1;
        if ( v37 )
          *(_BYTE *)(v32 + 9005) = 1;
        v29 = v28;
        break;
      case 2:
        v38 = (unsigned __int8)*v34;
        *v34 = 0;
        if ( v38 )
          *(_BYTE *)(v32 + 9006) = 1;
        v36 = 2;
        v29 = v27;
        break;
      case 4:
        v39 = (unsigned __int8)*v34;
        *v34 = 0;
        if ( v39 )
          *(_BYTE *)(v32 + 9007) = 1;
        v36 = 3;
        v29 = v26;
        break;
      case 5:
        v40 = (unsigned __int8)*v34;
        *v34 = 0;
        if ( v40 )
          *(_BYTE *)(v32 + 9008) = 1;
        v36 = 4;
        v29 = v25;
        break;
      case 6:
        v41 = (unsigned __int8)*v34;
        *v34 = 0;
        if ( v41 )
          *(_BYTE *)(v32 + 9009) = 1;
        v36 = 5;
        v29 = v24;
        break;
      default:
        *v34 = 0;
        v36 = 0xFFFFFFFFLL;
        break;
    }
    v42 = *(_BYTE *)(v32 + 61640);
    if ( (v42 & 1) != 0 )
    {
      if ( *v33 )
        goto LABEL_70;
      v43 = 1;
    }
    else
    {
      if ( !*v33 )
        goto LABEL_70;
      v43 = 0;
    }
    *v33 = v43;
    lumixtether::DeviceAdapter::autoRecognizeAnimalEnableChanged(this, v42 & 1);
LABEL_70:
    v44 = *((_QWORD *)this + 140);
    v45 = (char *)(v44 + 410448);
    v46 = *(_BYTE *)(v44 + 62668);
    if ( (v46 & 1) != 0 )
    {
      if ( *v45 )
        goto LABEL_76;
      v47 = 1;
    }
    else
    {
      if ( !*v45 )
        goto LABEL_76;
      v47 = 0;
    }
    *v45 = v47;
    lumixtether::DeviceAdapter::autoRecognizeGeneralEnableChanged(this, v46 & 1);
LABEL_76:
    v48 = *((_QWORD *)this + 140);
    v49 = (int *)(v48 + 410444);
    if ( *(_WORD *)(v48 + 65762) == 1 )
      v50 = 1;
    else
      v50 = -1;
    if ( *(_WORD *)(v48 + 65762) )
      v51 = v50;
    else
      v51 = 0;
    if ( *v49 != v51 )
    {
      *v49 = v51;
      lumixtether::DeviceAdapter::autoRecognizeAnimalChanged(this);
      v48 = *((_QWORD *)this + 140);
    }
    v52 = (int *)(v48 + 410452);
    if ( *(unsigned __int16 *)(v48 + 65764) >= 0xBu )
      v53 = -1;
    else
      v53 = *(unsigned __int16 *)(v48 + 65764);
    if ( *v52 != v53 )
    {
      *v52 = v53;
      lumixtether::DeviceAdapter::autoRecognizeGeneralChanged(this);
      v48 = *((_QWORD *)this + 140);
    }
    v54 = (int *)(v48 + 410460);
    if ( *(unsigned __int16 *)(v48 + 65768) >= 0xFu )
      v55 = -1;
    else
      v55 = *(unsigned __int16 *)(v48 + 65768);
    if ( *v54 != v55 )
    {
      *v54 = v55;
      lumixtether::DeviceAdapter::autoRecognizePartsChanged(this);
      v48 = *((_QWORD *)this + 140);
    }
    v56 = (char *)(v48 + 410472);
    v57 = *(_BYTE *)(v48 + 63696);
    if ( (v57 & 1) != 0 )
    {
      if ( *v56 )
        goto LABEL_100;
      v58 = 1;
    }
    else
    {
      if ( !*v56 )
        goto LABEL_100;
      v58 = 0;
    }
    *v56 = v58;
    lumixtether::DeviceAdapter::automaticRecoEnableChanged(this, v57 & 1);
LABEL_100:
    v59 = *((_QWORD *)this + 140);
    v60 = (int *)(v59 + 410476);
    if ( *(_WORD *)(v59 + 65766) == 1 )
      v61 = 1;
    else
      v61 = -1;
    if ( *(_WORD *)(v59 + 65766) )
      v62 = v61;
    else
      v62 = 0;
    if ( *v60 != v62 )
    {
      *v60 = v62;
      lumixtether::DeviceAdapter::automaticRecoChanged(this);
      v59 = *((_QWORD *)this + 140);
    }
    v63 = *(unsigned __int16 *)(v59 + 57530);
    if ( *(_DWORD *)(v59 + 18800) != v63 )
    {
      *(_DWORD *)(v59 + 18800) = v63;
      lumixtether::DeviceAdapter::autoFocusFlgNumChanged(this);
      v59 = *((_QWORD *)this + 140);
    }
    v64 = (_DWORD *)(v59 + 18804);
    v65 = *(_DWORD *)(v59 + 18804);
    v66 = *(unsigned __int16 *)(v59 + 59586);
    if ( v65 != v66 )
    {
      *v64 = v66;
      lumixtether::DeviceAdapter::customMultiFlgNumChanged(this);
    }
    v67 = *((_QWORD *)this + 140);
    if ( *(_DWORD *)(v67 + 112) != (_DWORD)v29 )
    {
      *(_DWORD *)(v67 + 112) = v29;
      lumixtether::DeviceAdapter::autoFocusModeChanged(this, v29);
    }
    v68 = *((_QWORD *)this + 140);
    if ( *(_DWORD *)(v68 + 116) != (_DWORD)v36 )
    {
      *(_DWORD *)(v68 + 116) = v36;
      lumixtether::DeviceAdapter::customMultiChanged(this, v36);
      v68 = *((_QWORD *)this + 140);
    }
    if ( (*(_BYTE *)(v68 + 65752) & 1) != 0 )
    {
      v69 = *(unsigned __int16 *)(v68 + 65770);
      if ( *(_DWORD *)(v68 + 136) == (_DWORD)v69 )
        goto LABEL_122;
      *(_DWORD *)(v68 + 136) = v69;
    }
    else
    {
      if ( !*(_DWORD *)(v68 + 136) )
        goto LABEL_122;
      v69 = 0;
      *(_DWORD *)(v68 + 136) = 0;
    }
    lumixtether::DeviceAdapter::afFrameColorChanged(this, v69);
LABEL_122:
    v17 = 1;
    if ( !v2 )
      return v17;
    goto LABEL_123;
  }
  v17 = 0;
  if ( !v2 )
    return v17;
LABEL_123:
  if ( atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v2, 2, 8);
  return v17;
}
