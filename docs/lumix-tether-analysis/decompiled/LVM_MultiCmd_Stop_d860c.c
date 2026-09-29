// __ZN15LiveViewManager13MultiCmd_StopENSt3__16vectorI23_MULTIVIEW_DEVICE_PARAMNS0_9allocatorIS2_EEEE @ 0x1000d860c
void __fastcall LiveViewManager::MultiCmd_Stop(__int64 a1, _QWORD *a2)
{
  __int64 v4; // x0
  __int64 v5; // x22
  __int64 v6; // x23
  unsigned __int64 v7; // x24
  unsigned __int64 v8; // x24
  __int64 v9; // x3
  __int64 v10; // x0
  std::thread *v11; // x23
  unsigned __int64 v12; // x8
  std::thread *v13; // x21
  __int64 v14; // x25
  unsigned __int64 v15; // x9
  __int64 v16; // x8
  unsigned __int64 v17; // x26
  char *v18; // x0
  std::thread *v19; // x9
  char *v20; // x8
  std::thread *v21; // x10
  _opaque_pthread_t *t; // t1
  std::thread *v23; // x0
  __int64 v24; // x0
  __int64 v25; // x21
  __int64 v26; // x22
  unsigned __int64 v27; // x23
  std::thread **v28; // [xsp+0h] [xbp-80h]
  int v29; // [xsp+Ch] [xbp-74h] BYREF
  __int64 v30; // [xsp+10h] [xbp-70h] BYREF
  _QWORD v31[2]; // [xsp+18h] [xbp-68h] BYREF
  std::thread v32; // [xsp+28h] [xbp-58h] BYREF

  if ( *(_QWORD *)(a1 + 864) != *(_QWORD *)(a1 + 856) )
  {
    std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 792));
    v4 = *(_QWORD *)(a1 + 864);
    v5 = *(_QWORD *)(a1 + 856);
    if ( v4 != v5 )
    {
      v6 = 0;
      v7 = 0;
      do
      {
        if ( *(_QWORD *)(v5 + v6) )
        {
          std::thread::join((std::thread *)(v5 + v6));
          v4 = *(_QWORD *)(a1 + 864);
          v5 = *(_QWORD *)(a1 + 856);
        }
        ++v7;
        v6 += 8;
      }
      while ( v7 < (v4 - v5) >> 3 );
      while ( v4 != v5 )
        std::thread::~thread((std::thread *)(v4 - 8));
      v4 = v5;
    }
    *(_QWORD *)(a1 + 864) = v4;
    std::recursive_mutex::unlock((std::recursive_mutex *)(a1 + 792));
  }
  if ( a2[1] != *a2 )
  {
    v8 = 0;
    v28 = (std::thread **)(a1 + 856);
    do
    {
      std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 792));
      v31[0] = LiveViewManager::MultiCmdThreadFunc;
      v31[1] = 0;
      v30 = a1;
      v9 = *a2 + 72 * v8;
      v29 = 2;
      v10 = sub_1000D9B30(&v32, v31, &v30, v9, &v29);
      v11 = *(std::thread **)(a1 + 864);
      v12 = *(_QWORD *)(a1 + 872);
      if ( (unsigned __int64)v11 < v12 )
      {
        v11->__t_ = v32.__t_;
        v32.__t_ = nullptr;
        *(_QWORD *)(a1 + 864) = v11 + 1;
      }
      else
      {
        v13 = *v28;
        v14 = v11 - *v28;
        v15 = v14 + 1;
        if ( (unsigned __int64)(v14 + 1) >> 61 )
          sub_1000D9DD4(v28);
        v16 = v12 - (_QWORD)v13;
        if ( v16 >> 2 > v15 )
          v15 = v16 >> 2;
        if ( (unsigned __int64)v16 >= 0x7FFFFFFFFFFFFFF8LL )
          v17 = 0x1FFFFFFFFFFFFFFFLL;
        else
          v17 = v15;
        if ( v17 )
        {
          if ( v17 >> 61 )
            sub_10000CE54(v10);
          v18 = (char *)operator new(8 * v17);
        }
        else
        {
          v18 = nullptr;
        }
        v19 = (std::thread *)&v18[8 * v14];
        v20 = &v18[8 * v17];
        v19->__t_ = v32.__t_;
        v21 = v19 + 1;
        v32.__t_ = nullptr;
        if ( v11 != v13 )
        {
          do
          {
            t = v11[-1].__t_;
            --v11;
            v19[-1].__t_ = t;
            --v19;
            v11->__t_ = nullptr;
          }
          while ( v11 != v13 );
          v11 = *(std::thread **)(a1 + 856);
          v23 = *(std::thread **)(a1 + 864);
          *(_QWORD *)(a1 + 856) = v19;
          *(_QWORD *)(a1 + 864) = v21;
          *(_QWORD *)(a1 + 872) = v20;
          while ( v23 != v11 )
            std::thread::~thread(v23 - 1);
          if ( !v11 )
            goto LABEL_14;
LABEL_33:
          operator delete(v11);
          goto LABEL_14;
        }
        *(_QWORD *)(a1 + 856) = v19;
        *(_QWORD *)(a1 + 864) = v21;
        *(_QWORD *)(a1 + 872) = v20;
        if ( v11 )
          goto LABEL_33;
      }
LABEL_14:
      std::thread::~thread(&v32);
      std::recursive_mutex::unlock((std::recursive_mutex *)(a1 + 792));
      ++v8;
    }
    while ( v8 < 0x8E38E38E38E38E39LL * ((__int64)(a2[1] - *a2) >> 3) );
  }
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 792));
  v24 = *(_QWORD *)(a1 + 864);
  v25 = *(_QWORD *)(a1 + 856);
  if ( v24 != v25 )
  {
    v26 = 0;
    v27 = 0;
    do
    {
      if ( *(_QWORD *)(v25 + v26) )
      {
        std::thread::join((std::thread *)(v25 + v26));
        v24 = *(_QWORD *)(a1 + 864);
        v25 = *(_QWORD *)(a1 + 856);
      }
      ++v27;
      v26 += 8;
    }
    while ( v27 < (v24 - v25) >> 3 );
    while ( v24 != v25 )
      std::thread::~thread((std::thread *)(v24 - 8));
    v24 = v25;
  }
  *(_QWORD *)(a1 + 864) = v24;
  std::recursive_mutex::unlock((std::recursive_mutex *)(a1 + 792));
}
