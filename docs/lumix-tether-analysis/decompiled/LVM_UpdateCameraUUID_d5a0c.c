// __ZN15LiveViewManager16UpdateCameraUUIDENSt3__16vectorI23_MULTIVIEW_DEVICE_PARAMNS0_9allocatorIS2_EEEE16_VIEW_SPLIT_MODE @ 0x1000d5a0c (imagebase-relative)
void __fastcall LiveViewManager::UpdateCameraUUID(__int64 a1, std::string **a2, int a3)
{
  std::recursive_mutex *v6; // x20
  int v7; // w8
  char *v8; // x21
  char *v9; // x22
  unsigned __int64 v10; // x8
  _BYTE *v11; // x21
  signed __int64 v12; // x22
  unsigned __int64 v13; // x9
  __int64 v14; // x8
  unsigned __int64 v15; // x25
  char *v16; // x23
  char *v17; // x24
  unsigned __int8 v18; // w8
  __int64 v19; // [xsp+0h] [xbp-60h] BYREF
  _QWORD v20[2]; // [xsp+8h] [xbp-58h] BYREF
  std::thread v21; // [xsp+18h] [xbp-48h] BYREF

  v6 = (std::recursive_mutex *)(a1 + 144);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 144));
  sub_1000D9030(a1 + 296, *(std::string **)(a1 + 272));
  if ( (std::string **)(a1 + 272) != a2 )
    sub_1000D9030(a1 + 272, *a2);
  if ( a3 == 6 )
    v7 = 0;
  else
    v7 = a3;
  *(_BYTE *)(a1 + 880) = a3 != 6;
  *(_DWORD *)(a1 + 884) = v7;
  *(_DWORD *)(a1 + 888) = 0;
  std::recursive_mutex::unlock(v6);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 424));
  v8 = *(char **)(a1 + 488);
  v9 = *(char **)(a1 + 496);
  if ( v8 == v9 )
  {
    v9 = *(char **)(a1 + 488);
  }
  else
  {
    do
    {
      while ( *(_DWORD *)v8 != 3 )
      {
        v8 += 4;
        if ( v8 == v9 )
          goto LABEL_11;
      }
      memmove(v8, v8 + 4, v9 - (v8 + 4));
      v9 -= 4;
      *(_QWORD *)(a1 + 496) = v9;
    }
    while ( v8 != v9 );
  }
LABEL_11:
  v10 = *(_QWORD *)(a1 + 504);
  if ( (unsigned __int64)v9 >= v10 )
  {
    v11 = *(_BYTE **)(a1 + 488);
    v12 = v9 - v11;
    v13 = (v12 >> 2) + 1;
    if ( v13 >> 62 )
      sub_1000D9264();
    v14 = v10 - (_QWORD)v11;
    if ( v14 >> 1 > v13 )
      v13 = v14 >> 1;
    if ( (unsigned __int64)v14 >= 0x7FFFFFFFFFFFFFFCLL )
      v15 = 0x3FFFFFFFFFFFFFFFLL;
    else
      v15 = v13;
    if ( v15 )
    {
      if ( v15 >> 62 )
        sub_10000CE54();
      v16 = (char *)operator new(4 * v15);
    }
    else
    {
      v16 = nullptr;
    }
    v17 = &v16[4 * (v12 >> 2)];
    *(_DWORD *)v17 = 3;
    memmove(v16, v11, v12);
    *(_QWORD *)(a1 + 488) = v16;
    *(_QWORD *)(a1 + 496) = v17 + 4;
    *(_QWORD *)(a1 + 504) = &v16[4 * v15];
    if ( v11 )
      operator delete(v11);
  }
  else
  {
    *(_DWORD *)v9 = 3;
    *(_QWORD *)(a1 + 496) = v9 + 4;
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(a1 + 424));
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 16));
  v18 = atomic_load((unsigned __int8 *)(a1 + 520));
  if ( (v18 & 1) != 0 )
  {
    if ( *(_QWORD *)(a1 + 512) )
      std::thread::join((std::thread *)(a1 + 512));
    atomic_store(0, (unsigned __int8 *)(a1 + 520));
    v20[0] = LiveViewManager::CmdQueueThreadFunc;
    v20[1] = 0;
    v19 = a1;
    sub_1000D9278(&v21, v20, &v19);
    if ( *(_QWORD *)(a1 + 512) )
      std::terminate();
    *(std::thread *)(a1 + 512) = v21;
    v21.__t_ = nullptr;
    std::thread::~thread(&v21);
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(a1 + 16));
}
