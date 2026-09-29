// __ZN11lumixtether13DeviceAdapter29adp_LMX_func_api_Get_Rec_InfoEv @ 0x10003fcbc (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Rec_Info(lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x21
  atomic_uint *v4; // x22
  int Rec_Info; // w23
  int16x8_t v6; // q2
  int8x8_t v7; // d3
  int8x8_t v8; // d1
  __int64 v9; // x1
  __int64 v10; // x20
  __int64 v11; // x26
  __int64 v12; // x22
  __int64 v13; // x22
  __int64 v14; // x28
  __int64 v15; // t1
  __int64 v16; // x23
  __int64 v17; // x24
  __int64 v18; // x27
  int v19; // w0
  int v20; // w21
  __int16 v21; // w22
  _BOOL4 v22; // w21
  int v23; // w1
  _DWORD *v24; // x8
  int v25; // w1
  __int64 v26; // x8
  int *v27; // x9
  unsigned __int64 v28; // x1
  unsigned __int64 v29; // x1
  unsigned __int64 v30; // x1
  unsigned __int64 v31; // x1
  int v32; // w1
  int v33; // w1
  int v34; // w1
  int v35; // w1
  _DWORD *v36; // x8
  int v37; // w1
  int *v38; // x8
  int v39; // w1
  int *v40; // x8
  atomic_uint *v42[3]; // [xsp+18h] [xbp-278h] BYREF
  atomic_uint *v43[3]; // [xsp+30h] [xbp-260h] BYREF
  atomic_uint *v44; // [xsp+48h] [xbp-248h] BYREF
  atomic_uint *v45; // [xsp+50h] [xbp-240h]
  atomic_uint *v46; // [xsp+58h] [xbp-238h]
  _OWORD v47[2]; // [xsp+60h] [xbp-230h] BYREF
  int v48[4]; // [xsp+80h] [xbp-210h]
  _QWORD v49[6]; // [xsp+90h] [xbp-200h] BYREF
  __int128 v50; // [xsp+C0h] [xbp-1D0h]
  __int128 v51; // [xsp+D0h] [xbp-1C0h]
  __int128 v52; // [xsp+E0h] [xbp-1B0h]
  __int128 v53; // [xsp+F0h] [xbp-1A0h]
  __int128 v54; // [xsp+100h] [xbp-190h]
  __int128 v55; // [xsp+110h] [xbp-180h]
  __int128 v56; // [xsp+120h] [xbp-170h]
  __int128 v57; // [xsp+130h] [xbp-160h]
  _OWORD v58[10]; // [xsp+140h] [xbp-150h] BYREF
  __int128 v59; // [xsp+1E0h] [xbp-B0h]
  __int128 v60; // [xsp+1F0h] [xbp-A0h]
  __int128 v61; // [xsp+200h] [xbp-90h]
  __int128 v62; // [xsp+210h] [xbp-80h]
  int v63; // [xsp+220h] [xbp-70h]

  v63 = 0;
  v61 = 0u;
  v62 = 0u;
  v59 = 0u;
  v60 = 0u;
  memset(v58, 0, sizeof(v58));
  v56 = 0u;
  v57 = 0u;
  v54 = 0u;
  v55 = 0u;
  v52 = 0u;
  v53 = 0u;
  v50 = 0u;
  v51 = 0u;
  *(_OWORD *)v48 = 0u;
  memset(v49, 0, sizeof(v49));
  memset(v47, 0, sizeof(v47));
  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v44 = v2;
    v45 = v3;
    v46 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v44 = nullptr;
    v45 = v3;
    v46 = v4;
  }
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v44);
  if ( v44 && atomic_fetch_add(v44, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v44, 2, 8);
  QString::toLocal8Bit_helper(v43, v3, v4);
  if ( !v43[0] || *v43[0] >= 2 )
    QByteArray::reallocData(v43, v43[2], 1);
  Rec_Info = LMX_func_api_Get_Rec_Info(v47, v43[1], 0);
  if ( v43[0] && atomic_fetch_add(v43[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v43[0], 1, 8);
  v42[0] = v2;
  v42[1] = v3;
  v42[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v42);
  if ( v42[0] && atomic_fetch_add(v42[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v42[0], 2, 8);
  if ( Rec_Info != 1 )
  {
    v10 = 0;
    if ( !v2 )
      return v10;
    goto LABEL_73;
  }
  if ( HIWORD(v49[0]) )
  {
    v6.i64[0] = 0x1000100010001LL;
    v6.i64[1] = 0x1000100010001LL;
    v7 = vmovn_s16(vceqq_s16(*(int16x8_t *)&v49[1], v6));
    v8 = vmovn_s16(vceqq_s16(*(int16x8_t *)&v49[3], v6));
    if ( v7.i8[0] & 1
       | (2 * (v7.i8[1] & 1)) & 0xC3
       | (4 * (v7.i8[2] & 1)) & 0xC7
       | (8 * (v7.i8[3] & 1)) & 0xCF
       | (16 * (v7.i8[4] & 1)) & 0xDF
       | (unsigned __int16)(32 * (v7.i8[5] & 1))
       | ((v7.i8[6] & 1) << 6)
       | ((v7.i8[7] & 1) << 7)
       | ((v8.i8[0] & 1) << 8)
       | ((v8.i8[1] & 1) << 9)
       | ((v8.i8[2] & 1) << 10)
       | ((v8.i8[3] & 1) << 11)
       | ((v8.i8[4] & 1) << 12)
       | ((v8.i8[5] & 1) << 13)
       | ((v8.i8[6] & 1) << 14)
       | (unsigned __int16)(v8.u8[7] << 15) )
    {
      v9 = 0;
    }
    else if ( LOWORD(v49[1]) > 3u )
    {
      v9 = 0xFFFFFFFFLL;
    }
    else
    {
      v9 = dword_1001460C0[SLOWORD(v49[1])];
    }
  }
  else
  {
    v9 = 1;
  }
  lumixtether::DeviceAdapter::setStatusOfCardsValue(this, v9);
  std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
  v11 = *((_QWORD *)this + 140);
  v12 = *(_QWORD *)(v11 + 410272);
  if ( !v12 )
    goto LABEL_37;
  v15 = *(_QWORD *)(v12 + 16);
  v13 = v12 + 16;
  v14 = v15;
  if ( !v15 )
    goto LABEL_37;
  v16 = *(_QWORD *)(v11 + 307856);
  v17 = *(_QWORD *)(v11 + 307864);
  v18 = v13;
  do
  {
    v19 = QtPrivate::compareStrings(*(_QWORD *)(v14 + 48), *(_QWORD *)(v14 + 40), v17, v16, 1);
    if ( v19 >= 0 )
      v18 = v14;
    v14 = *(_QWORD *)(v14 + 8LL * ((unsigned int)v19 >> 31));
  }
  while ( v14 );
  if ( v18 == v13
    || (QtPrivate::compareStrings(v17, v16, *(_QWORD *)(v18 + 48), *(_QWORD *)(v18 + 40), 1) & 0x80000000) != 0 )
  {
LABEL_37:
    v22 = 0;
  }
  else
  {
    v20 = *(unsigned __int16 *)(sub_10002AE78(v11 + 410272, v11 + 307848) + 188);
    v21 = v48[0];
    v22 = v20 != LOWORD(v48[0]);
    *(_WORD *)(sub_10002AE78(*((_QWORD *)this + 140) + 410272LL, *((_QWORD *)this + 140) + 307848LL) + 188) = v21;
    v11 = *((_QWORD *)this + 140);
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(v11 + 410304));
  v23 = LOWORD(v48[0]);
  v24 = (_DWORD *)(*((_QWORD *)this + 140) + 160100LL);
  if ( *v24 != LOWORD(v48[0]) )
  {
    *v24 = LOWORD(v48[0]);
    lumixtether::DeviceAdapter::cameraStatusChanged(this, v23);
    lumixtether::DeviceAdapter::motionPictureFormatChanged(this, *(unsigned int *)(*((_QWORD *)this + 140) + 1452LL));
  }
  v25 = *(int *)((char *)&v48[2] + 2);
  v26 = *((_QWORD *)this + 140);
  v27 = (int *)(v26 + 160096);
  if ( *(int *)((char *)&v48[2] + 2) )
    ++*(_DWORD *)(v26 + 19316);
  if ( *v27 != v25 )
  {
    *v27 = v25;
    lumixtether::DeviceAdapter::elapsedInMovieRecChanged(this, v25);
    v26 = *((_QWORD *)this + 140);
  }
  v28 = *(unsigned int *)((char *)&v50 + 2);
  if ( *(_QWORD *)(v26 + 160064) != *(unsigned int *)((char *)&v50 + 2) )
  {
    *(_QWORD *)(v26 + 160064) = *(unsigned int *)((char *)&v50 + 2);
    lumixtether::DeviceAdapter::imageFreeSpaceChanged(this, v28);
    v26 = *((_QWORD *)this + 140);
  }
  v29 = *(unsigned int *)((char *)&v50 + 6);
  if ( *(_QWORD *)(v26 + 160080) != *(unsigned int *)((char *)&v50 + 6) )
  {
    *(_QWORD *)(v26 + 160080) = *(unsigned int *)((char *)&v50 + 6);
    lumixtether::DeviceAdapter::image4KFreeSpaceChanged(this, v29);
    v26 = *((_QWORD *)this + 140);
  }
  v30 = *(unsigned int *)((char *)v58 + 10);
  if ( *(_QWORD *)(v26 + 160072) != *(unsigned int *)((char *)v58 + 10) )
  {
    *(_QWORD *)(v26 + 160072) = *(unsigned int *)((char *)v58 + 10);
    lumixtether::DeviceAdapter::secondFreeSpaceChanged(this, v30);
    v26 = *((_QWORD *)this + 140);
  }
  v31 = *(unsigned int *)((char *)v58 + 14);
  if ( *(_QWORD *)(v26 + 160088) != *(unsigned int *)((char *)v58 + 14) )
  {
    *(_QWORD *)(v26 + 160088) = *(unsigned int *)((char *)v58 + 14);
    lumixtether::DeviceAdapter::second4KFreeSpaceChanged(this, v31);
    v26 = *((_QWORD *)this + 140);
  }
  v32 = WORD1(v59);
  if ( *(_DWORD *)(v26 + 160104) != WORD1(v59) )
  {
    *(_DWORD *)(v26 + 160104) = WORD1(v59);
    lumixtether::DeviceAdapter::afStateChanged(this, v32);
    v26 = *((_QWORD *)this + 140);
  }
  v33 = WORD3(v59);
  if ( *(_DWORD *)(v26 + 160108) != WORD3(v59) )
  {
    *(_DWORD *)(v26 + 160108) = WORD3(v59);
    lumixtether::DeviceAdapter::afaeStateChanged(this, v33);
    v26 = *((_QWORD *)this + 140);
  }
  v34 = (unsigned __int16)v60;
  if ( *(_DWORD *)(v26 + 160112) != (unsigned __int16)v60 )
  {
    *(_DWORD *)(v26 + 160112) = (unsigned __int16)v60;
    lumixtether::DeviceAdapter::afcStartPosStateChanged(this, v34);
    v26 = *((_QWORD *)this + 140);
  }
  v35 = WORD5(v60);
  v36 = (_DWORD *)(v26 + 160116);
  if ( *v36 != WORD5(v60) )
  {
    *v36 = WORD5(v60);
    lumixtether::DeviceAdapter::nrRemainingTimeChanged(this, v35);
  }
  if ( HIWORD(v61) >= 4u )
    v37 = -1;
  else
    v37 = HIWORD(v61);
  v38 = (int *)(*((_QWORD *)this + 140) + 410464LL);
  if ( *v38 != v37 )
  {
    *v38 = v37;
    lumixtether::DeviceAdapter::hdmiSdiStatusChanged(this);
  }
  if ( HIWORD(v63) >= 3u )
    v39 = -1;
  else
    v39 = HIWORD(v63);
  v40 = (int *)(*((_QWORD *)this + 140) + 410468LL);
  if ( *v40 != v39 )
  {
    *v40 = v39;
    lumixtether::DeviceAdapter::shotModeStatusChanged(this);
  }
  if ( v22 )
    lumixtether::DeviceAdapter::updateLiveviewSelectCamera(this);
  v10 = 1;
  if ( v2 )
  {
LABEL_73:
    if ( atomic_fetch_add(v2, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v2, 2, 8);
  }
  return v10;
}
