// __ZN15LiveViewManager15SetVideoAdapterEP12VideoAdapter @ 0x1000d5f0c (imagebase-relative)
void __fastcall LiveViewManager::SetVideoAdapter(LiveViewManager *this, VideoAdapter *a2)
{
  std::recursive_mutex *v4; // x21

  v4 = (std::recursive_mutex *)((char *)this + 16);
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 16));
  *((_QWORD *)this + 52) = a2;
  std::recursive_mutex::unlock(v4);
}
