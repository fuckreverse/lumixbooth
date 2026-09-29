// __ZN15LiveViewManager21SetSelectedCameraUUIDE23_MULTIVIEW_DEVICE_PARAM @ 0x1000d5cbc (imagebase-relative)
void __fastcall LiveViewManager::SetSelectedCameraUUID(__int64 a1, __int64 a2)
{
  std::recursive_mutex *v4; // x21
  __int64 v5; // x24
  __int64 v6; // x8
  __int64 v7; // x25
  unsigned __int64 v8; // x26
  int v9; // w27
  size_t v10; // x22
  __int64 v11; // x28
  unsigned __int8 *v12; // x21
  bool v13; // w23
  __int64 v14; // x9
  __int64 v15; // x8
  __int64 v16; // x10
  const void *v17; // x0
  unsigned __int8 *v18; // x1
  __int64 v19; // x8
  unsigned __int8 *v20; // x9
  unsigned __int8 *v21; // x10
  int v22; // w11
  int v23; // t1
  int v24; // t1
  __int128 v25; // q0
  __int128 v26; // q1
  std::recursive_mutex *v27; // [xsp+8h] [xbp-58h]

  v4 = (std::recursive_mutex *)(a1 + 144);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 144));
  v5 = *(_QWORD *)(a1 + 272);
  v6 = *(_QWORD *)(a1 + 280) - v5;
  v27 = v4;
  if ( !v6 )
  {
    v13 = 0;
    goto LABEL_31;
  }
  v7 = 0;
  v8 = v6 / 72;
  v9 = *(char *)(a2 + 23);
  if ( v9 >= 0 )
    v10 = *(unsigned __int8 *)(a2 + 23);
  else
    v10 = *(_QWORD *)(a2 + 8);
  if ( v8 <= 1 )
    v11 = 1;
  else
    v11 = v6 / 72;
  v12 = (unsigned __int8 *)(v5 + 1);
  v13 = 1;
  while ( 1 )
  {
    v14 = v5 + 72 * v7;
    v15 = *(unsigned __int8 *)(v14 + 23);
    if ( (v15 & 0x80u) == 0LL )
      v16 = *(unsigned __int8 *)(v14 + 23);
    else
      v16 = *(_QWORD *)(v14 + 8);
    if ( v16 != v10 )
      goto LABEL_9;
    v17 = (v15 & 0x80u) == 0LL ? (const void *)(v5 + 72 * v7) : *(const void **)v14;
    v18 = v9 >= 0 ? (unsigned __int8 *)a2 : *(unsigned __int8 **)a2;
    if ( (v15 & 0x80) == 0 )
      break;
    if ( !v10 || !memcmp(v17, v18, v10) )
      goto LABEL_31;
LABEL_9:
    v13 = ++v7 < v8;
    v12 += 72;
    if ( v7 == v11 )
      goto LABEL_31;
  }
  if ( !v10 )
    goto LABEL_31;
  if ( *v18 != (unsigned __int8)*(_QWORD *)v14 )
    goto LABEL_9;
  v19 = v15 - 1;
  v20 = v18 + 1;
  v21 = v12;
  while ( v19 )
  {
    v23 = *v21++;
    v22 = v23;
    v24 = *v20++;
    --v19;
    if ( v22 != v24 )
      goto LABEL_9;
  }
LABEL_31:
  std::recursive_mutex::unlock(v27);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 16));
  std::string::operator=((std::string *)(a1 + 344), (const std::string *)a2);
  v25 = *(_OWORD *)(a2 + 52);
  v26 = *(_OWORD *)(a2 + 40);
  *(_OWORD *)(a1 + 368) = *(_OWORD *)(a2 + 24);
  *(_OWORD *)(a1 + 384) = v26;
  *(_OWORD *)(a1 + 396) = v25;
  if ( !v13
    && (*(double *)(a1 + 760) != 0.0
     || *(double *)(a1 + 768) != 0.0
     || *(double *)(a1 + 776) != 0.0
     || *(double *)(a1 + 784) != 0.0) )
  {
    *(_OWORD *)(a1 + 760) = 0u;
    *(_OWORD *)(a1 + 776) = 0u;
    LiveViewManager::selctedPaintSizeChanged((LiveViewManager *)a1, *(_DWORD *)(a1 + 524) != 0, 0.0, 0.0, 0.0, 0.0);
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(a1 + 16));
}
