// __ZN11lumixtether12DeviceSearch16SearchThreadFuncEv @ 0x100009c60 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceSearch::SearchThreadFunc(lumixtether::DeviceSearch *this)
{
  int v2; // w8
  ApplicationData *v3; // x0
  atomic_ullong *DeviceAdapter; // x0
  unsigned int Connection_Type; // w0
  int v6; // w8
  unsigned int v7; // w21
  std::chrono::duration<long long, std::ratio<1, 1000000000>>::rep v8; // x24
  __int64 v9; // x8
  std::chrono::time_point<std::chrono::system_clock, std::chrono::duration<long long, std::ratio<1, 1000000000>>> v10; // x2
  std::chrono::steady_clock::time_point v11; // x25
  bool v12; // w24
  lumixtether::DeviceAdapter *v13; // x0
  ApplicationData *v14; // x0
  atomic_uint *m; // x24
  atomic_uint *v16; // x25
  atomic_uint *v17; // x28
  __int64 v18; // x0
  ApplicationData *v19; // x0
  atomic_ullong *v20; // x0
  std::chrono::steady_clock::time_point v21; // x0
  lumixtether::DeviceAdapter *v22; // x0
  __int64 v23; // x25
  int v24; // w25
  std::chrono::duration<long long, std::ratio<1, 1000000000>>::rep v25; // x28
  __int64 v26; // x8
  std::chrono::time_point<std::chrono::system_clock, std::chrono::duration<long long, std::ratio<1, 1000000000>>> v27; // x2
  std::chrono::steady_clock::time_point v28; // x25
  bool v29; // w25
  lumixtether::DeviceAdapter *v30; // x0
  __int64 v31; // x25
  atomic_ullong *v32; // x0
  atomic_uint *v34[3]; // [xsp+0h] [xbp-80h] BYREF
  std::unique_lock<std::mutex> __lk; // [xsp+18h] [xbp-68h] BYREF
  atomic_uint *v36; // [xsp+28h] [xbp-58h]
  std::chrono::steady_clock::time_point v37; // 0:x0.8
  std::chrono::system_clock::time_point v38; // 0:x0.8
  std::chrono::system_clock::time_point v39; // 0:x0.8

  if ( *((_BYTE *)this + 152) )
    v2 = 2;
  else
    v2 = 1;
  *((_DWORD *)this + 37) = v2;
  v3 = (ApplicationData *)lumixtether::DeviceSearch::devSearchStatusChanged(this);
  DeviceAdapter = (atomic_ullong *)ApplicationData::getDeviceAdapter(v3);
  Connection_Type = lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_Get_Connection_Type(DeviceAdapter);
  v6 = *((_DWORD *)this + 39);
  if ( v6 == 2 )
  {
    v7 = 1;
  }
  else if ( v6 == 1 )
  {
    v7 = 0;
  }
  else
  {
    v7 = Connection_Type;
  }
  while ( 2 )
  {
    __lk.__m_ = (std::unique_lock<std::mutex>::mutex_type *)((char *)this + 32);
    __lk.__owns_ = 1;
    std::mutex::lock((std::mutex *)((char *)this + 32));
    v37.__d_.__rep_ = std::chrono::steady_clock::now().__d_.__rep_;
    v8 = v37.__d_.__rep_ + 100000000;
    while ( !*((_BYTE *)this + 24) )
    {
      v37.__d_.__rep_ = std::chrono::steady_clock::now().__d_.__rep_;
      if ( v37.__d_.__rep_ >= v8 )
      {
LABEL_27:
        v12 = *((_BYTE *)this + 24) != 0;
        if ( !__lk.__owns_ )
          goto LABEL_29;
        goto LABEL_28;
      }
      v11.__d_.__rep_ = v8 - std::chrono::steady_clock::now().__d_.__rep_;
      if ( v11.__d_.__rep_ >= 1 )
      {
        std::chrono::steady_clock::now();
        v38.__d_.__rep_ = std::chrono::system_clock::now().__d_.__rep_;
        if ( !v38.__d_.__rep_ )
        {
          v9 = 0;
          goto LABEL_25;
        }
        if ( v38.__d_.__rep_ < 1 )
        {
          if ( (unsigned __int64)v38.__d_.__rep_ >= 0xFFDF3B645A1CAC09LL )
            goto LABEL_24;
          v9 = 0x8000000000000000LL;
        }
        else
        {
          if ( (unsigned __int64)v38.__d_.__rep_ > 0x20C49BA5E353F7LL )
          {
            v9 = 0x7FFFFFFFFFFFFFFFLL;
            goto LABEL_25;
          }
LABEL_24:
          v9 = 1000 * v38.__d_.__rep_;
LABEL_25:
          v10.__d_.__rep_ = 0x7FFFFFFFFFFFFFFFLL;
          if ( v9 > 0x7FFFFFFFFFFFFFFFLL - v11.__d_.__rep_ )
          {
LABEL_13:
            std::condition_variable::__do_timed_wait((std::condition_variable *)this + 2, &__lk, v10);
            std::chrono::steady_clock::now();
            goto LABEL_14;
          }
        }
        v10.__d_.__rep_ = v9 + v11.__d_.__rep_;
        goto LABEL_13;
      }
LABEL_14:
      v37.__d_.__rep_ = std::chrono::steady_clock::now().__d_.__rep_;
      if ( v37.__d_.__rep_ >= v8 )
        goto LABEL_27;
    }
    v12 = 1;
    if ( __lk.__owns_ )
LABEL_28:
      std::mutex::unlock(__lk.__m_);
LABEL_29:
    if ( !v12 )
    {
      *((_WORD *)this + 72) = v7 != 0;
      v13 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)v37.__d_.__rep_);
      lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_Set_Connection_Type(v13, v7);
      v14 = (ApplicationData *)QString::fromUtf8(&__lk, 0, &unk_10014269A);
      m = (atomic_uint *)__lk.__m_;
      v16 = *(atomic_uint **)&__lk.__owns_;
      v17 = v36;
      v18 = ApplicationData::getDeviceAdapter(v14);
      v34[0] = m;
      v34[1] = v16;
      v34[2] = v17;
      if ( m )
        atomic_fetch_add(m, 1u);
      v19 = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_SetSearchCondition(v18, 0, v34);
      if ( v34[0] && atomic_fetch_add(v34[0], 0xFFFFFFFF) == 1 )
        v19 = (ApplicationData *)QArrayData::deallocate(v34[0], 2, 8);
      v20 = (atomic_ullong *)ApplicationData::getDeviceAdapter(v19);
      v21.__d_.__rep_ = lumixtether::DeviceAdapter::adp_LMX_func_api_GetPnPDeviceInfo(v20, 0);
      if ( v7 != 1 )
      {
        if ( LODWORD(v21.__d_.__rep_) != 1 )
          goto LABEL_75;
        v22 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)v21.__d_.__rep_);
        v21.__d_.__rep_ = (std::chrono::duration<long long, std::ratio<1, 1000000000>>::rep)lumixtether::DeviceAdapter::searchList(
                                                                                              (__int64 *)&__lk,
                                                                                              v22);
        v23 = (__int64)v36;
        if ( __lk.__m_ && atomic_fetch_add((atomic_uint *volatile)__lk.__m_, 0xFFFFFFFF) == 1 )
          v21.__d_.__rep_ = QArrayData::deallocate(__lk.__m_, 8, 8);
        if ( v23 > 0 )
        {
          v24 = 3;
          if ( !m )
            goto LABEL_9;
        }
        else
        {
LABEL_75:
          if ( !*((_DWORD *)this + 39) )
          {
            v32 = (atomic_ullong *)ApplicationData::getDeviceAdapter((ApplicationData *)v21.__d_.__rep_);
            v7 = lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_Get_Connection_Type(v32) == 0;
          }
          if ( *((_BYTE *)this + 153) )
            v24 = 3;
          else
            v24 = 0;
          if ( !m )
            goto LABEL_9;
        }
LABEL_81:
        if ( atomic_fetch_add(m, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(m, 2, 8);
        goto LABEL_9;
      }
LABEL_44:
      if ( !*((_BYTE *)this + 144) || *((_BYTE *)this + 145) )
      {
        v30 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)v21.__d_.__rep_);
        v21.__d_.__rep_ = (std::chrono::duration<long long, std::ratio<1, 1000000000>>::rep)lumixtether::DeviceAdapter::searchList(
                                                                                              (__int64 *)&__lk,
                                                                                              v30);
        v31 = (__int64)v36;
        if ( __lk.__m_ && atomic_fetch_add((atomic_uint *volatile)__lk.__m_, 0xFFFFFFFF) == 1 )
          v21.__d_.__rep_ = QArrayData::deallocate(__lk.__m_, 8, 8);
        if ( v31 <= 0 )
          goto LABEL_75;
LABEL_73:
        v7 = 1;
        v24 = 3;
        if ( m )
          goto LABEL_81;
LABEL_9:
        if ( v24 )
          break;
        continue;
      }
      __lk.__m_ = (std::unique_lock<std::mutex>::mutex_type *)((char *)this + 32);
      __lk.__owns_ = 1;
      std::mutex::lock((std::mutex *)((char *)this + 32));
      v21.__d_.__rep_ = std::chrono::steady_clock::now().__d_.__rep_;
      v25 = v21.__d_.__rep_ + 100000000;
      while ( 2 )
      {
        if ( *((_BYTE *)this + 24) )
        {
          v29 = 1;
          if ( !__lk.__owns_ )
            goto LABEL_43;
LABEL_66:
          std::mutex::unlock(__lk.__m_);
LABEL_43:
          if ( v29 )
            goto LABEL_73;
          goto LABEL_44;
        }
        v21.__d_.__rep_ = std::chrono::steady_clock::now().__d_.__rep_;
        if ( v21.__d_.__rep_ >= v25 )
        {
LABEL_63:
          v29 = *((_BYTE *)this + 24) != 0;
          if ( !__lk.__owns_ )
            goto LABEL_43;
          goto LABEL_66;
        }
        v28.__d_.__rep_ = v25 - std::chrono::steady_clock::now().__d_.__rep_;
        if ( v28.__d_.__rep_ >= 1 )
        {
          std::chrono::steady_clock::now();
          v39.__d_.__rep_ = std::chrono::system_clock::now().__d_.__rep_;
          if ( !v39.__d_.__rep_ )
          {
            v26 = 0;
            goto LABEL_61;
          }
          if ( v39.__d_.__rep_ < 1 )
          {
            if ( (unsigned __int64)v39.__d_.__rep_ >= 0xFFDF3B645A1CAC09LL )
              goto LABEL_60;
            v26 = 0x8000000000000000LL;
          }
          else
          {
            if ( (unsigned __int64)v39.__d_.__rep_ > 0x20C49BA5E353F7LL )
            {
              v26 = 0x7FFFFFFFFFFFFFFFLL;
              goto LABEL_61;
            }
LABEL_60:
            v26 = 1000 * v39.__d_.__rep_;
LABEL_61:
            v27.__d_.__rep_ = 0x7FFFFFFFFFFFFFFFLL;
            if ( v26 > 0x7FFFFFFFFFFFFFFFLL - v28.__d_.__rep_ )
            {
LABEL_49:
              std::condition_variable::__do_timed_wait((std::condition_variable *)this + 2, &__lk, v27);
              std::chrono::steady_clock::now();
              goto LABEL_50;
            }
          }
          v27.__d_.__rep_ = v26 + v28.__d_.__rep_;
          goto LABEL_49;
        }
LABEL_50:
        v21.__d_.__rep_ = std::chrono::steady_clock::now().__d_.__rep_;
        if ( v21.__d_.__rep_ >= v25 )
          goto LABEL_63;
        continue;
      }
    }
    break;
  }
  *((_DWORD *)this + 37) = 0;
  return lumixtether::DeviceSearch::devSearchStatusChanged(this);
}
