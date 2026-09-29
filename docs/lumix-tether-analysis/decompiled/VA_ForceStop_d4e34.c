// __ZN12VideoAdapter9ForceStopEv @ 0x1000d4e34 (imagebase-relative)
void __fastcall VideoAdapter::ForceStop(VideoAdapter *this)
{
  QTimer::stop((VideoAdapter *)((char *)this + 24));
  if ( *((_QWORD *)this + 2) )
  {
    std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 48));
    *((_QWORD *)this + 2) = 0;
    std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 48));
  }
}
