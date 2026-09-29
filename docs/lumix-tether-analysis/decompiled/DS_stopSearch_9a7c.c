// __ZN11lumixtether12DeviceSearch10stopSearchEv @ 0x100009a7c (imagebase-relative)
void __fastcall lumixtether::DeviceSearch::stopSearch(lumixtether::DeviceSearch *this)
{
  std::mutex *v2; // x20
  std::thread *v3; // x0
  atomic_ullong *DeviceAdapter; // x0
  ApplicationData *Connection_Type; // x0
  lumixtether::DeviceAdapter *v6; // x0
  std::chrono::nanoseconds __ns; // [xsp+8h] [xbp-18h] BYREF

  v2 = (std::mutex *)((char *)this + 32);
  std::mutex::lock((std::mutex *)((char *)this + 32));
  *((_BYTE *)this + 24) = 1;
  std::condition_variable::notify_all((std::condition_variable *)this + 2);
  std::mutex::unlock(v2);
  v3 = (std::thread *)((char *)this + 16);
  if ( *((_QWORD *)this + 2) )
    std::thread::join(v3);
  DeviceAdapter = (atomic_ullong *)ApplicationData::getDeviceAdapter((ApplicationData *)v3);
  Connection_Type = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_Get_Connection_Type(DeviceAdapter);
  if ( (_DWORD)Connection_Type == 1 )
  {
    if ( *((_BYTE *)this + 144) )
    {
      v6 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(Connection_Type);
      lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_StopGetDeviceInfo(v6);
      while ( *((_BYTE *)this + 144) )
      {
        __ns.__rep_ = 50000000;
        std::this_thread::sleep_for(&__ns);
      }
    }
  }
}
