// __ZN15LiveViewManager11SetViewPageEb16_VIEW_SPLIT_MODEi @ 0x1000d8f98 (imagebase-relative)
void __fastcall LiveViewManager::SetViewPage(LiveViewManager *this, char a2, int a3, int a4)
{
  atomic_store(1u, (unsigned __int8 *)this + 560);
  if ( *((_QWORD *)this + 66) )
    std::thread::join((std::thread *)this + 66);
  if ( *((_QWORD *)this + 67) )
    std::thread::join((std::thread *)this + 67);
  if ( *((_QWORD *)this + 68) )
    std::thread::join((std::thread *)this + 68);
  if ( *((_QWORD *)this + 69) )
    std::thread::join((std::thread *)this + 69);
  *((_BYTE *)this + 880) = a2;
  *((_DWORD *)this + 221) = a3;
  *((_DWORD *)this + 222) = a4;
  LiveViewManager::StartLive(this, 1);
}
