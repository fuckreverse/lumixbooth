// __ZN15LiveViewManager13SetCameraUUIDENSt3__16vectorI23_MULTIVIEW_DEVICE_PARAMNS0_9allocatorIS2_EEEE16_VIEW_SPLIT_MODE @ 0x1000d598c
void __fastcall LiveViewManager::SetCameraUUID(__int64 a1, __int64 a2, int a3)
{
  std::recursive_mutex *v6; // x19
  bool v7; // w8
  int v8; // w9
  __int64 v9; // x8
  bool v10; // zf

  v6 = (std::recursive_mutex *)(a1 + 144);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 144));
  if ( a1 + 272 != a2 )
    sub_1000D9030(a1 + 272, *(std::string **)a2);
  if ( a3 == 6 )
  {
    v7 = 0;
    v8 = 0;
  }
  else
  {
    v9 = *(_QWORD *)(a2 + 8);
    v10 = v9 == *(_QWORD *)a2;
    v7 = v9 != *(_QWORD *)a2;
    if ( v10 )
      v8 = 0;
    else
      v8 = a3;
  }
  *(_BYTE *)(a1 + 880) = v7;
  *(_DWORD *)(a1 + 884) = v8;
  *(_DWORD *)(a1 + 888) = 0;
  std::recursive_mutex::unlock(v6);
}
