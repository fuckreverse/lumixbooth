// __ZN11lumixtether13DeviceAdapter40adp_LMX_func_api_Rec_Ctrl_4k_burst_startEv @ 0x10005db58 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Rec_Ctrl_4k_burst_start(
        lumixtether::DeviceAdapter *this)
{
  atomic_uint *v2; // x19
  atomic_uint *v3; // x22
  atomic_uint *v4; // x23
  __int64 v5; // x8
  __int64 v6; // x8
  __int64 v7; // x9
  _QWORD *v8; // x23
  _QWORD *v9; // x9
  __int64 v10; // x9
  _QWORD *v11; // x9
  __int64 v12; // x26
  __int64 v13; // x27
  atomic_uint *v14; // x22
  atomic_uint *v15; // x21
  _QWORD *v16; // x19
  atomic_uint *v17; // x8
  atomic_uint *v18; // x9
  atomic_uint *v19; // x8
  atomic_uint *v20; // x9
  _QWORD *v21; // x8
  __int64 v22; // x8
  __int64 v23; // x9
  _QWORD *v24; // t1
  __int64 v25; // x8
  __int64 v26; // x9
  atomic_uint **v27; // x23
  atomic_uint **v28; // x9
  __int64 v29; // x9
  atomic_uint **v30; // x9
  atomic_uint *v31; // x22
  atomic_uint *v32; // x8
  atomic_uint *v33; // x9
  atomic_uint *v34; // x8
  atomic_uint *v35; // x9
  atomic_uint *v36; // x8
  __int64 v37; // x8
  atomic_uint *v38; // x9
  atomic_uint **v39; // t1
  atomic_uint *v40; // x19
  __int64 v41; // x20
  int v43; // [xsp+4h] [xbp-91Ch]
  atomic_uint *v44; // [xsp+8h] [xbp-918h]
  atomic_uint *v45[3]; // [xsp+10h] [xbp-910h] BYREF
  atomic_uint *v46[3]; // [xsp+28h] [xbp-8F8h] BYREF
  atomic_uint *v47[3]; // [xsp+40h] [xbp-8E0h] BYREF
  atomic_uint *v48[3]; // [xsp+58h] [xbp-8C8h] BYREF
  atomic_uint *v49[3]; // [xsp+70h] [xbp-8B0h] BYREF
  atomic_uint *v50; // [xsp+88h] [xbp-898h] BYREF
  __int64 v51; // [xsp+90h] [xbp-890h]
  __int64 v52; // [xsp+98h] [xbp-888h]
  atomic_uint *v53; // [xsp+A0h] [xbp-880h] BYREF
  atomic_uint *v54; // [xsp+A8h] [xbp-878h]
  atomic_uint *v55; // [xsp+B0h] [xbp-870h]
  int v56; // [xsp+B8h] [xbp-868h] BYREF
  int v57; // [xsp+BCh] [xbp-864h] BYREF

  bzero(&v57, 0x808u);
  v56 = 50331697;
  v2 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307848LL);
  v3 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307856LL);
  v4 = *(atomic_uint **)(*((_QWORD *)this + 140) + 307864LL);
  if ( v2 )
  {
    atomic_fetch_add(v2, 1u);
    v53 = v2;
    v54 = v3;
    v55 = v4;
    atomic_fetch_add(v2, 1u);
  }
  else
  {
    v53 = nullptr;
    v54 = v3;
    v55 = v4;
  }
  v44 = v2;
  lumixtether::DeviceAdapter::dev_mutex_lock(this, &v53);
  if ( v53 && atomic_fetch_add(v53, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v53, 2, 8);
  QString::toLocal8Bit_helper(&v50, v3, v4);
  if ( !v50 || *v50 >= 2 )
    QByteArray::reallocData(&v50, v52, 1);
  v43 = LMX_func_api_Rec_Ctrl_4k(&v56, v51, 0);
  if ( v50 && atomic_fetch_add(v50, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v50, 1, 8);
  v49[0] = v2;
  v49[1] = v3;
  v49[2] = v4;
  if ( v2 )
    atomic_fetch_add(v2, 1u);
  lumixtether::DeviceAdapter::dev_mutex_unlock(this, v49);
  if ( v49[0] && atomic_fetch_add(v49[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v49[0], 2, 8);
  v5 = *((_QWORD *)this + 140);
  if ( *(_DWORD *)(v5 + 410376) == 1 )
  {
    std::recursive_mutex::lock((std::recursive_mutex *)(v5 + 410304));
    v6 = *((_QWORD *)this + 140);
    v7 = *(_QWORD *)(v6 + 410272);
    if ( v7 )
      v8 = *(_QWORD **)(v7 + 8);
    else
      v8 = nullptr;
    if ( v7 )
      v9 = (_QWORD *)(v7 + 16);
    else
      v9 = nullptr;
    if ( v9 != v8 )
    {
      do
      {
        v12 = v6 + 307832;
        v13 = *(unsigned int *)(v6 + 307832);
        if ( (int)v13 >= 1 )
        {
          v14 = (atomic_uint *)v8[6];
          v15 = *(atomic_uint **)(v6 + 307864);
          v16 = (_QWORD *)(v6 + 307920);
          while ( v14 == v15 && !(unsigned int)QtPrivate::compareStrings(v14, v8[5], v14, *(_QWORD *)(v12 + 24), 1)
               || *v16 != v8[13]
               || (unsigned int)QtPrivate::compareStrings(*v16, *(v16 - 1), *v16, v8[12], 1)
               || !*((_BYTE *)v8 + 208) )
          {
            v16 += 25;
            if ( !--v13 )
              goto LABEL_56;
          }
          v17 = (atomic_uint *)v8[4];
          v18 = (atomic_uint *)v8[5];
          v48[0] = v17;
          v48[1] = v18;
          v48[2] = v14;
          if ( v17 )
            atomic_fetch_add(v17, 1u);
          lumixtether::DeviceAdapter::dev_mutex_lock(this, v48);
          if ( v48[0] && atomic_fetch_add(v48[0], 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v48[0], 2, 8);
          QString::toLocal8Bit_helper(&v50, v8[5], v8[6]);
          if ( !v50 || *v50 >= 2 )
            QByteArray::reallocData(&v50, v52, 1);
          LMX_func_api_Rec_Ctrl_4k(&v56, v51, 0);
          if ( v50 && atomic_fetch_add(v50, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v50, 1, 8);
          v19 = (atomic_uint *)v8[4];
          v20 = (atomic_uint *)v8[5];
          v47[0] = v19;
          v47[1] = v20;
          v47[2] = *((atomic_uint **)v8 + 6);
          if ( v19 )
            atomic_fetch_add(v19, 1u);
          lumixtether::DeviceAdapter::dev_mutex_unlock(this, v47);
          if ( v47[0] && atomic_fetch_add(v47[0], 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v47[0], 2, 8);
        }
LABEL_56:
        v21 = (_QWORD *)v8[1];
        if ( v21 )
        {
          do
          {
            v8 = v21;
            v21 = (_QWORD *)*v21;
          }
          while ( v21 );
        }
        else
        {
          v22 = (__int64)(v8 + 2);
          if ( *(_QWORD **)v8[2] == v8 )
          {
            v8 = (_QWORD *)v8[2];
          }
          else
          {
            do
            {
              v23 = *(_QWORD *)v22;
              v24 = *(_QWORD **)(*(_QWORD *)v22 + 16LL);
              v22 = *(_QWORD *)v22 + 16LL;
              v8 = v24;
            }
            while ( *v24 != v23 );
          }
        }
        v6 = *((_QWORD *)this + 140);
        v10 = *(_QWORD *)(v6 + 410272);
        if ( v10 )
          v11 = (_QWORD *)(v10 + 16);
        else
          v11 = nullptr;
      }
      while ( v8 != v11 );
    }
    std::recursive_mutex::unlock((std::recursive_mutex *)(v6 + 410304));
    v5 = *((_QWORD *)this + 140);
  }
  std::recursive_mutex::lock((std::recursive_mutex *)(v5 + 410304));
  v25 = *((_QWORD *)this + 140);
  v26 = *(_QWORD *)(v25 + 410272);
  if ( v26 )
    v27 = *(atomic_uint ***)(v26 + 8);
  else
    v27 = nullptr;
  if ( v26 )
    v28 = (atomic_uint **)(v26 + 16);
  else
    v28 = nullptr;
  if ( v28 != v27 )
  {
    do
    {
      v31 = v27[6];
      if ( (v31 != *(atomic_uint **)(v25 + 307864)
         || (unsigned int)QtPrivate::compareStrings(v27[6], v27[5], v27[6], *(_QWORD *)(v25 + 307856), 1))
        && *((_BYTE *)v27 + 208)
        && *((_BYTE *)v27 + 242) )
      {
        v32 = v27[4];
        v33 = v27[5];
        v46[0] = v32;
        v46[1] = v33;
        v46[2] = v31;
        if ( v32 )
          atomic_fetch_add(v32, 1u);
        lumixtether::DeviceAdapter::dev_mutex_lock(this, v46);
        if ( v46[0] && atomic_fetch_add(v46[0], 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v46[0], 2, 8);
        QString::toLocal8Bit_helper(&v50, v27[5], v27[6]);
        if ( !v50 || *v50 >= 2 )
          QByteArray::reallocData(&v50, v52, 1);
        LMX_func_api_Rec_Ctrl_4k(&v56, v51, 0);
        if ( v50 && atomic_fetch_add(v50, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v50, 1, 8);
        v34 = v27[4];
        v35 = v27[5];
        v45[0] = v34;
        v45[1] = v35;
        v45[2] = v27[6];
        if ( v34 )
          atomic_fetch_add(v34, 1u);
        lumixtether::DeviceAdapter::dev_mutex_unlock(this, v45);
        if ( v45[0] && atomic_fetch_add(v45[0], 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v45[0], 2, 8);
      }
      v36 = v27[1];
      if ( v36 )
      {
        do
        {
          v27 = (atomic_uint **)v36;
          v36 = *(atomic_uint **)v36;
        }
        while ( v36 );
      }
      else
      {
        v37 = (__int64)(v27 + 2);
        if ( *(atomic_uint ***)v27[2] == v27 )
        {
          v27 = (atomic_uint **)v27[2];
        }
        else
        {
          do
          {
            v38 = *(atomic_uint **)v37;
            v39 = *(atomic_uint ***)(*(_QWORD *)v37 + 16LL);
            v37 = *(_QWORD *)v37 + 16LL;
            v27 = v39;
          }
          while ( *v39 != v38 );
        }
      }
      v25 = *((_QWORD *)this + 140);
      v29 = *(_QWORD *)(v25 + 410272);
      if ( v29 )
        v30 = (atomic_uint **)(v29 + 16);
      else
        v30 = nullptr;
    }
    while ( v27 != v30 );
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(v25 + 410304));
  if ( v43 == 1 )
  {
    v41 = 1;
    v40 = v44;
    if ( !v44 )
      return v41;
    goto LABEL_108;
  }
  v40 = v44;
  if ( v43 == 2 )
  {
    lumixtether::DeviceAdapter::adp_LMX_func_api_Rec_Ctrl_4k_burst_stop(this);
    lumixtether::DeviceAdapter::memoryCardNothingNotify(this);
  }
  v41 = 0;
  if ( v44 )
  {
LABEL_108:
    if ( atomic_fetch_add(v40, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v40, 2, 8);
  }
  return v41;
}
