// __ZN11lumixtether13DeviceAdapter30adp_LMX_func_api_Select_DeviceEi @ 0x10002e2f4 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Select_Device(lumixtether::DeviceAdapter *this, int a2)
{
  __int64 v4; // x9
  __int64 v5; // x8
  __int64 v6; // x21
  atomic_uint *v7; // x0
  atomic_uint **v8; // x24
  atomic_uint **v9; // x21
  atomic_uint *v10; // x0
  atomic_uint *v11; // x8
  __int64 v12; // x8
  bool v13; // zf
  atomic_uint *v14; // x9
  atomic_uint **v15; // t1
  atomic_uint *v16; // x8
  atomic_uint *v17; // x9
  __int64 v18; // x8
  __int64 v19; // x8
  lumixtether::DeviceAdapter *v20; // x0
  lumixtether::DeviceAdapter *Recom_Img_Start; // x0
  atomic_uint *v23[3]; // [xsp+0h] [xbp-50h] BYREF
  std::chrono::nanoseconds __ns; // [xsp+18h] [xbp-38h] BYREF

  v4 = *((_QWORD *)this + 140);
  if ( *(_BYTE *)(v4 + 410384) )
  {
    if ( *(_QWORD *)(v4 + 307864) )
    {
      if ( !*(_BYTE *)(v4 + 410500) )
      {
        lumixtether::DeviceAdapter::adp_LMX_func_api_Ctrl_LiveView_Stop(this);
        v5 = *((_QWORD *)this + 140) + 410380LL;
        *(_BYTE *)(v5 + 4) = 1;
        if ( !*(_DWORD *)v5 )
        {
          if ( (unsigned int)LiveViewManager::IsLiveViewWorking((lumixtether::DeviceAdapter *)((char *)this + 224)) )
          {
            do
            {
              __ns.__rep_ = 1000000;
              std::this_thread::sleep_for(&__ns);
            }
            while ( (LiveViewManager::IsLiveViewWorking((lumixtether::DeviceAdapter *)((char *)this + 224)) & 1) != 0 );
          }
        }
      }
    }
  }
  std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
  v6 = *((_QWORD *)this + 140) + 410272LL;
  if ( *(_QWORD *)v6 )
  {
    sub_1000A9464(*((_QWORD *)this + 140) + 410272LL);
  }
  else
  {
    v7 = (atomic_uint *)operator new(0x20u);
    *v7 = 0;
    *((_QWORD *)v7 + 3) = 0;
    *((_QWORD *)v7 + 2) = 0;
    *((_QWORD *)v7 + 1) = v7 + 4;
    *(_QWORD *)v6 = v7;
    atomic_fetch_add(v7, 1u);
  }
  v8 = *(atomic_uint ***)(*(_QWORD *)v6 + 8LL);
  while ( 1 )
  {
    v9 = (atomic_uint **)(*((_QWORD *)this + 140) + 410272LL);
    if ( *v9 )
    {
      sub_1000A9464(*((_QWORD *)this + 140) + 410272LL);
    }
    else
    {
      v10 = (atomic_uint *)operator new(0x20u);
      *v10 = 0;
      *((_QWORD *)v10 + 3) = 0;
      *((_QWORD *)v10 + 2) = 0;
      *((_QWORD *)v10 + 1) = v10 + 4;
      *v9 = v10;
      atomic_fetch_add(v10, 1u);
    }
    if ( v8 == (atomic_uint **)(*v9 + 4) )
      break;
    if ( *((_DWORD *)v8 + 14) == a2 )
    {
      v16 = v8[4];
      v17 = v8[5];
      v23[0] = v16;
      v23[1] = v17;
      v23[2] = v8[6];
      if ( v16 )
        atomic_fetch_add(v16, 1u);
      lumixtether::DeviceAdapter::setCameraInfoOfSelectedCamera(this, v23);
      if ( v23[0] && atomic_fetch_add(v23[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v23[0], 2, 8);
      break;
    }
    v11 = v8[1];
    if ( v11 )
    {
      do
      {
        v8 = (atomic_uint **)v11;
        v11 = *(atomic_uint **)v11;
      }
      while ( v11 );
    }
    else
    {
      v12 = (__int64)(v8 + 2);
      v13 = *(_QWORD *)v8[2] == (_QWORD)v8;
      v8 = (atomic_uint **)v8[2];
      if ( !v13 )
      {
        do
        {
          v14 = *(atomic_uint **)v12;
          v15 = *(atomic_uint ***)(*(_QWORD *)v12 + 16LL);
          v12 = *(_QWORD *)v12 + 16LL;
          v8 = v15;
        }
        while ( *v15 != v14 );
      }
    }
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
  if ( *((_BYTE *)this + 1576) != 1 )
  {
    *((_BYTE *)this + 1576) = 1;
    lumixtether::DeviceAdapter::isCamerasConnectedChanged(this);
  }
  lumixtether::DeviceAdapter::switchCameraNotify(this, a2);
  v18 = *((_QWORD *)this + 140);
  if ( !*(_BYTE *)(v18 + 410384) )
  {
    if ( !(unsigned int)VideoAdapter::getVideoOutVisibleStatus((lumixtether::DeviceAdapter *)((char *)this + 16)) )
      return 1;
    v18 = *((_QWORD *)this + 140);
  }
  if ( !*(_BYTE *)(v18 + 410500) )
  {
    v19 = v18 + 19000;
    if ( *(_BYTE *)(v19 + 8) && *(_DWORD *)v19 != 1 )
    {
      lumixtether::DeviceAdapter::setLiveviewPause(this);
    }
    else
    {
      v20 = (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::adp_LMX_func_api_Ctrl_LiveView_Start(this);
      Recom_Img_Start = (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::adp_LMX_func_api_LiveView_Str_Get_Recom_Img_Start(v20);
      lumixtether::DeviceAdapter::adp_LMX_func_api_LiveView_Str_Get_Trans_Img_Start(Recom_Img_Start);
    }
  }
  return 1;
}
