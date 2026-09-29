// __ZN11lumixtether13DeviceAdapter35adp_LMX_func_api_Ctrl_LiveView_StopEv @ 0x10002e5d4
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Ctrl_LiveView_Stop(lumixtether::DeviceAdapter *this)
{
  __int64 v2; // x20
  atomic_uint *v3; // x0
  atomic_uint *v4; // x24
  atomic_uint **v5; // x20
  atomic_uint *v6; // x0
  atomic_uint *v7; // x0
  atomic_uint *v8; // x8
  __int64 v9; // x8
  __int64 v10; // x9
  atomic_uint *v11; // t1

  std::recursive_mutex::lock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
  v2 = *((_QWORD *)this + 140) + 410272LL;
  if ( *(_QWORD *)v2 )
  {
    sub_1000A9464(*((_QWORD *)this + 140) + 410272LL);
  }
  else
  {
    v3 = (atomic_uint *)operator new(0x20u);
    *v3 = 0;
    *((_QWORD *)v3 + 3) = 0;
    *((_QWORD *)v3 + 2) = 0;
    *((_QWORD *)v3 + 1) = v3 + 4;
    *(_QWORD *)v2 = v3;
    atomic_fetch_add(v3, 1u);
  }
  v4 = *(atomic_uint **)(*(_QWORD *)v2 + 8LL);
  while ( 1 )
  {
    v5 = (atomic_uint **)(*((_QWORD *)this + 140) + 410272LL);
    if ( *v5 )
    {
      sub_1000A9464(*((_QWORD *)this + 140) + 410272LL);
    }
    else
    {
      v6 = (atomic_uint *)operator new(0x20u);
      *v6 = 0;
      *((_QWORD *)v6 + 3) = 0;
      *((_QWORD *)v6 + 2) = 0;
      *((_QWORD *)v6 + 1) = v6 + 4;
      *v5 = v6;
      atomic_fetch_add(v6, 1u);
    }
    if ( v4 == *v5 + 4 )
      break;
    v7 = *((atomic_uint **)v4 + 4);
    if ( v7 )
      atomic_fetch_add(v7, 1u);
    v8 = *((atomic_uint **)v4 + 1);
    if ( v8 )
    {
      do
      {
        v4 = v8;
        v8 = *(atomic_uint **)v8;
      }
      while ( v8 );
LABEL_16:
      if ( v7 )
      {
LABEL_17:
        if ( atomic_fetch_add(v7, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v7, 2, 8);
      }
    }
    else
    {
      v9 = (__int64)(v4 + 4);
      if ( **((atomic_uint ***)v4 + 2) != v4 )
      {
        do
        {
          v10 = *(_QWORD *)v9;
          v11 = *(atomic_uint **)(*(_QWORD *)v9 + 16LL);
          v9 = *(_QWORD *)v9 + 16LL;
          v4 = v11;
        }
        while ( *(_QWORD *)v11 != v10 );
        goto LABEL_16;
      }
      v4 = *((atomic_uint **)v4 + 2);
      if ( v7 )
        goto LABEL_17;
    }
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)(*((_QWORD *)this + 140) + 410304LL));
  LiveViewManager::StopLiveAsync((lumixtether::DeviceAdapter *)((char *)this + 224));
  *(_BYTE *)(*((_QWORD *)this + 140) + 410384LL) = 0;
  return 1;
}
