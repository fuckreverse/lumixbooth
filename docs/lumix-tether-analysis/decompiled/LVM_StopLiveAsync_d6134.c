// __ZN15LiveViewManager13StopLiveAsyncEv @ 0x1000d6134 (imagebase-relative)
void __fastcall LiveViewManager::StopLiveAsync(LiveViewManager *this)
{
  std::recursive_mutex *v2; // x20
  char *v3; // x21
  char *i; // x22
  unsigned __int64 v5; // x8
  char *v6; // x9
  _BYTE *v7; // x21
  size_t v8; // x22
  __int64 v9; // x24
  unsigned __int64 v10; // x9
  __int64 v11; // x8
  unsigned __int64 v12; // x25
  char *v13; // x23
  char *v14; // x24
  unsigned __int8 v15; // w8
  LiveViewManager *v16; // [xsp+0h] [xbp-60h] BYREF
  _QWORD v17[2]; // [xsp+8h] [xbp-58h] BYREF
  std::thread v18; // [xsp+18h] [xbp-48h] BYREF

  v2 = (std::recursive_mutex *)((char *)this + 424);
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 424));
  *((_DWORD *)this + 149) = 0;
  LiveViewManager::videoImageStatusChanged(this);
  v3 = *((char **)this + 61);
  for ( i = *((char **)this + 62); v3 != i; *((_QWORD *)this + 62) = i )
  {
    while ( (*(_DWORD *)v3 & 0xFFFFFFFE) != 2 )
    {
      v3 += 4;
      if ( v3 == i )
        goto LABEL_6;
    }
    memmove(v3, v3 + 4, i - (v3 + 4));
    i -= 4;
  }
LABEL_6:
  sub_1000D9030((_DWORD)this + 320, *((std::string **)this + 34));
  v6 = *((char **)this + 62);
  v5 = *((_QWORD *)this + 63);
  if ( (unsigned __int64)v6 >= v5 )
  {
    v7 = *((_BYTE **)this + 61);
    v8 = v6 - v7;
    v9 = (v6 - v7) >> 2;
    v10 = v9 + 1;
    if ( (unsigned __int64)(v9 + 1) >> 62 )
      sub_1000D9264();
    v11 = v5 - (_QWORD)v7;
    if ( v11 >> 1 > v10 )
      v10 = v11 >> 1;
    if ( (unsigned __int64)v11 >= 0x7FFFFFFFFFFFFFFCLL )
      v12 = 0x3FFFFFFFFFFFFFFFLL;
    else
      v12 = v10;
    if ( v12 )
    {
      if ( v12 >> 62 )
        sub_10000CE54();
      v13 = (char *)operator new(4 * v12);
    }
    else
    {
      v13 = nullptr;
    }
    v14 = &v13[4 * v9];
    *(_DWORD *)v14 = 2;
    memmove(v13, v7, v8);
    *((_QWORD *)this + 61) = v13;
    *((_QWORD *)this + 62) = v14 + 4;
    *((_QWORD *)this + 63) = &v13[4 * v12];
    if ( v7 )
      operator delete(v7);
  }
  else
  {
    *(_DWORD *)v6 = 2;
    *((_QWORD *)this + 62) = v6 + 4;
  }
  std::recursive_mutex::unlock(v2);
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 16));
  v15 = atomic_load((unsigned __int8 *)this + 520);
  if ( (v15 & 1) != 0 )
  {
    if ( *((_QWORD *)this + 64) )
      std::thread::join((std::thread *)this + 64);
    atomic_store(0, (unsigned __int8 *)this + 520);
    v17[0] = LiveViewManager::CmdQueueThreadFunc;
    v17[1] = 0;
    v16 = this;
    sub_1000D9278(&v18, v17, &v16);
    if ( *((_QWORD *)this + 64) )
      std::terminate();
    *((std::thread *)this + 64) = v18;
    v18.__t_ = nullptr;
    std::thread::~thread(&v18);
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 16));
}
