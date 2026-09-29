// __ZN15LiveViewManager14StartCmdThreadEv @ 0x1000d5c30
void __fastcall LiveViewManager::StartCmdThread(LiveViewManager *this)
{
  unsigned __int8 v1; // w8
  std::thread *v3; // x20
  LiveViewManager *v4; // [xsp+0h] [xbp-30h] BYREF
  _QWORD v5[2]; // [xsp+8h] [xbp-28h] BYREF
  std::thread v6; // [xsp+18h] [xbp-18h] BYREF

  v1 = atomic_load((unsigned __int8 *)this + 520);
  if ( (v1 & 1) != 0 )
  {
    v3 = (std::thread *)((char *)this + 512);
    if ( *((_QWORD *)this + 64) )
      std::thread::join((std::thread *)this + 64);
    atomic_store(0, (unsigned __int8 *)this + 520);
    v5[0] = LiveViewManager::CmdQueueThreadFunc;
    v5[1] = 0;
    v4 = this;
    sub_1000D9278(&v6, v5, &v4);
    if ( *((_QWORD *)this + 64) )
      std::terminate();
    v3->__t_ = v6.__t_;
    v6.__t_ = nullptr;
    std::thread::~thread(&v6);
  }
}
