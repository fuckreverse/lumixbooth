// __ZN15LiveViewManager8StopLiveEv @ 0x1000d57ec (imagebase-relative)
void __fastcall LiveViewManager::StopLive(LiveViewManager *this)
{
  std::string *v2; // x21
  std::string *v3; // x22
  signed __int64 v4; // x0
  unsigned __int64 v5; // x25
  void **v6; // x21
  void **v7; // x8
  void *v8; // x0
  void **v9; // x22
  void *__p; // [xsp+8h] [xbp-58h] BYREF
  void **v11; // [xsp+10h] [xbp-50h]
  char *v12; // [xsp+18h] [xbp-48h] BYREF

  atomic_store(1u, (unsigned __int8 *)this + 560);
  if ( *((_QWORD *)this + 66) )
    std::thread::join((std::thread *)this + 66);
  if ( *((_QWORD *)this + 67) )
    std::thread::join((std::thread *)this + 67);
  if ( *((_QWORD *)this + 68) )
    std::thread::join((std::thread *)this + 68);
  if ( *((_QWORD *)this + 69) )
    std::thread::join((std::thread *)this + 69);
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 144));
  __p = nullptr;
  v11 = nullptr;
  v12 = nullptr;
  v3 = *((std::string **)this + 40);
  v2 = *((std::string **)this + 41);
  v4 = (char *)v2 - (char *)v3;
  if ( v2 != v3 )
  {
    v5 = 0x8E38E38E38E38E39LL * (v4 >> 3);
    if ( v5 >= 0x38E38E38E38E38FLL )
      sub_1000AA1F4(&__p);
    __p = operator new(v4);
    v12 = (char *)__p + 72 * v5;
    v11 = (void **)sub_1000AA208((int)&v12, v3, (int)v2, (std::string *)__p);
  }
  LiveViewManager::MultiCmd_Stop(this, &__p);
  v6 = (void **)__p;
  if ( __p )
  {
    v7 = v11;
    if ( v11 == __p )
    {
      v8 = __p;
    }
    else
    {
      do
      {
        v9 = v7 - 9;
        if ( *((char *)v7 - 49) < 0 )
          operator delete(*(v7 - 9));
        v7 = v9;
      }
      while ( v9 != v6 );
      v8 = __p;
    }
    v11 = v6;
    operator delete(v8);
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 144));
  *((_BYTE *)this + 592) = 0;
}
