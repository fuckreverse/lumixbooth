// __ZN15LiveViewManager9ForceStopEv @ 0x1000d5780
__int64 __fastcall LiveViewManager::ForceStop(LiveViewManager *this)
{
  atomic_store(1u, (unsigned __int8 *)this + 520);
  if ( *((_QWORD *)this + 64) )
  {
    std::thread::join((std::thread *)this + 64);
    *((_QWORD *)this + 62) = *((_QWORD *)this + 61);
  }
  LiveViewManager::StopLive(this);
  *((_DWORD *)this + 149) = 0;
  return LiveViewManager::videoImageStatusChanged(this);
}
