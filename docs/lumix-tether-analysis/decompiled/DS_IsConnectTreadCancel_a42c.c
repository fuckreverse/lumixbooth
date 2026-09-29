// __ZN11lumixtether12DeviceSearch20IsConnectTreadCancelEi @ 0x10000a42c (imagebase-relative)
bool __fastcall lumixtether::DeviceSearch::IsConnectTreadCancel(lumixtether::DeviceSearch *this, int a2)
{
  std::chrono::steady_clock::time_point v4; // x21
  __int64 v5; // x8
  std::chrono::time_point<std::chrono::system_clock, std::chrono::duration<long long, std::ratio<1, 1000000000>>> v6; // x2
  std::chrono::steady_clock::time_point v7; // x25
  _BOOL8 v8; // x19
  std::unique_lock<std::mutex> v10; // [xsp+0h] [xbp-50h] BYREF
  std::chrono::system_clock::time_point v11; // 0:x0.8

  v10.__m_ = (std::unique_lock<std::mutex>::mutex_type *)((char *)this + 176);
  v10.__owns_ = 1;
  std::mutex::lock((std::mutex *)((char *)this + 176));
  v4.__d_.__rep_ = std::chrono::steady_clock::now().__d_.__rep_ + 1000000LL * a2;
  while ( !*((_BYTE *)this + 168) )
  {
    if ( std::chrono::steady_clock::now().__d_.__rep_ >= v4.__d_.__rep_ )
    {
LABEL_18:
      v8 = *((_BYTE *)this + 168) != 0;
      if ( !v10.__owns_ )
        return v8;
      goto LABEL_19;
    }
    v7.__d_.__rep_ = v4.__d_.__rep_ - std::chrono::steady_clock::now().__d_.__rep_;
    if ( v7.__d_.__rep_ >= 1 )
    {
      std::chrono::steady_clock::now();
      v11.__d_.__rep_ = std::chrono::system_clock::now().__d_.__rep_;
      if ( !v11.__d_.__rep_ )
      {
        v5 = 0;
        goto LABEL_16;
      }
      if ( v11.__d_.__rep_ < 1 )
      {
        if ( (unsigned __int64)v11.__d_.__rep_ >= 0xFFDF3B645A1CAC09LL )
          goto LABEL_15;
        v5 = 0x8000000000000000LL;
      }
      else
      {
        if ( (unsigned __int64)v11.__d_.__rep_ > 0x20C49BA5E353F7LL )
        {
          v5 = 0x7FFFFFFFFFFFFFFFLL;
          goto LABEL_16;
        }
LABEL_15:
        v5 = 1000 * v11.__d_.__rep_;
LABEL_16:
        v6.__d_.__rep_ = 0x7FFFFFFFFFFFFFFFLL;
        if ( v5 > 0x7FFFFFFFFFFFFFFFLL - v7.__d_.__rep_ )
        {
LABEL_4:
          std::condition_variable::__do_timed_wait((std::condition_variable *)this + 5, &v10, v6);
          std::chrono::steady_clock::now();
          goto LABEL_5;
        }
      }
      v6.__d_.__rep_ = v5 + v7.__d_.__rep_;
      goto LABEL_4;
    }
LABEL_5:
    if ( std::chrono::steady_clock::now().__d_.__rep_ >= v4.__d_.__rep_ )
      goto LABEL_18;
  }
  v8 = 1;
  if ( v10.__owns_ )
LABEL_19:
    std::mutex::unlock(v10.__m_);
  return v8;
}
