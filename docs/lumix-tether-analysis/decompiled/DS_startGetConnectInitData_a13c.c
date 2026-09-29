// __ZN11lumixtether12DeviceSearch23startGetConnectInitDataEv @ 0x10000a13c (imagebase-relative)
void __fastcall lumixtether::DeviceSearch::startGetConnectInitData(lumixtether::DeviceSearch *this)
{
  std::mutex *v2; // x20
  lumixtether::DeviceSearch *v3; // [xsp+0h] [xbp-30h] BYREF
  _QWORD v4[2]; // [xsp+8h] [xbp-28h] BYREF
  std::thread v5; // [xsp+18h] [xbp-18h] BYREF

  v2 = (std::mutex *)((char *)this + 176);
  std::mutex::lock((std::mutex *)((char *)this + 176));
  *((_BYTE *)this + 168) = 1;
  std::condition_variable::notify_all((std::condition_variable *)this + 5);
  std::mutex::unlock(v2);
  if ( *((_QWORD *)this + 20) )
    std::thread::join((std::thread *)this + 20);
  *((_BYTE *)this + 168) = 0;
  v4[0] = lumixtether::DeviceSearch::ConnectThreadFunc;
  v4[1] = 0;
  v3 = this;
  sub_10000ABD0(&v5, v4, &v3);
  if ( *((_QWORD *)this + 20) )
    std::terminate();
  *((std::thread *)this + 20) = v5;
  v5.__t_ = nullptr;
  std::thread::~thread(&v5);
}
