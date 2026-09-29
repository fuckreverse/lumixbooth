// __ZN15LiveViewManager14StartLiveAsyncEv @ 0x1000d5f48
void __fastcall LiveViewManager::StartLiveAsync(LiveViewManager *this)
{
  std::recursive_mutex *v2; // x20
  int v3; // w1
  char *v4; // x21
  char *v5; // x22
  unsigned __int64 v6; // x8
  _BYTE *v7; // x21
  signed __int64 v8; // x22
  unsigned __int64 v9; // x9
  __int64 v10; // x8
  unsigned __int64 v11; // x25
  char *v12; // x23
  char *v13; // x24
  unsigned __int8 v14; // w8
  LiveViewManager *v15; // [xsp+0h] [xbp-60h] BYREF
  _QWORD v16[2]; // [xsp+8h] [xbp-58h] BYREF
  std::thread v17; // [xsp+18h] [xbp-48h] BYREF

  v2 = (std::recursive_mutex *)((char *)this + 424);
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 424));
  if ( *((_QWORD *)this + 35) == *((_QWORD *)this + 34) )
    v3 = 2;
  else
    v3 = 1;
  *((_DWORD *)this + 149) = v3;
  LiveViewManager::videoImageStatusChanged(this);
  v4 = *((char **)this + 61);
  v5 = *((char **)this + 62);
  if ( v4 == v5 )
  {
    v5 = *((char **)this + 61);
  }
  else
  {
    do
    {
      while ( (*(_DWORD *)v4 | 2) != 3 )
      {
        v4 += 4;
        if ( v4 == v5 )
          goto LABEL_9;
      }
      memmove(v4, v4 + 4, v5 - (v4 + 4));
      v5 -= 4;
      *((_QWORD *)this + 62) = v5;
    }
    while ( v4 != v5 );
  }
LABEL_9:
  v6 = *((_QWORD *)this + 63);
  if ( (unsigned __int64)v5 >= v6 )
  {
    v7 = *((_BYTE **)this + 61);
    v8 = v5 - v7;
    v9 = (v8 >> 2) + 1;
    if ( v9 >> 62 )
      sub_1000D9264();
    v10 = v6 - (_QWORD)v7;
    if ( v10 >> 1 > v9 )
      v9 = v10 >> 1;
    if ( (unsigned __int64)v10 >= 0x7FFFFFFFFFFFFFFCLL )
      v11 = 0x3FFFFFFFFFFFFFFFLL;
    else
      v11 = v9;
    if ( v11 )
    {
      if ( v11 >> 62 )
        sub_10000CE54();
      v12 = (char *)operator new(4 * v11);
    }
    else
    {
      v12 = nullptr;
    }
    v13 = &v12[4 * (v8 >> 2)];
    *(_DWORD *)v13 = 1;
    memmove(v12, v7, v8);
    *((_QWORD *)this + 61) = v12;
    *((_QWORD *)this + 62) = v13 + 4;
    *((_QWORD *)this + 63) = &v12[4 * v11];
    if ( v7 )
      operator delete(v7);
  }
  else
  {
    *(_DWORD *)v5 = 1;
    *((_QWORD *)this + 62) = v5 + 4;
  }
  std::recursive_mutex::unlock(v2);
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 16));
  v14 = atomic_load((unsigned __int8 *)this + 520);
  if ( (v14 & 1) != 0 )
  {
    if ( *((_QWORD *)this + 64) )
      std::thread::join((std::thread *)this + 64);
    atomic_store(0, (unsigned __int8 *)this + 520);
    v16[0] = LiveViewManager::CmdQueueThreadFunc;
    v16[1] = 0;
    v15 = this;
    sub_1000D9278(&v17, v16, &v15);
    if ( *((_QWORD *)this + 64) )
      std::terminate();
    *((std::thread *)this + 64) = v17;
    v17.__t_ = nullptr;
    std::thread::~thread(&v17);
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 16));
}
