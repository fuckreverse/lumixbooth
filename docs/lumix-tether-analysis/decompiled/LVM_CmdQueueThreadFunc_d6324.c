// __ZN15LiveViewManager18CmdQueueThreadFuncEv @ 0x1000d6324
void __fastcall LiveViewManager::CmdQueueThreadFunc(LiveViewManager *this)
{
  std::recursive_mutex *v2; // x20
  char *v3; // x0
  char *v4; // x23
  int v5; // w22
  std::chrono::nanoseconds __ns; // [xsp+8h] [xbp-38h] BYREF

  v2 = (std::recursive_mutex *)((char *)this + 424);
  while ( 1 )
  {
    std::recursive_mutex::lock(v2);
    v3 = *((char **)this + 61);
    v4 = *((char **)this + 62);
    if ( v4 == v3 )
    {
      std::recursive_mutex::unlock(v2);
      v5 = 0;
    }
    else
    {
      v5 = *(_DWORD *)v3;
      memmove(v3, v3 + 4, v4 - (v3 + 4));
      *((_QWORD *)this + 62) = v4 - 4;
      std::recursive_mutex::unlock(v2);
      switch ( v5 )
      {
        case 3:
          LiveViewManager::UpdateCamera(this);
          break;
        case 2:
          LiveViewManager::StopLive(this);
          break;
        case 1:
          LiveViewManager::StartLive(this, 0);
          break;
      }
    }
    if ( *((_QWORD *)this + 62) == *((_QWORD *)this + 61) )
      break;
    if ( (unsigned int)(v5 - 1) <= 1 )
    {
      __ns.__rep_ = 200000000;
      std::this_thread::sleep_for(&__ns);
    }
  }
  atomic_store(1u, (unsigned __int8 *)this + 520);
}
