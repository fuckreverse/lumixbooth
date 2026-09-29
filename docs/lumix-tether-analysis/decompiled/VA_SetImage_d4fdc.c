// __ZN12VideoAdapter8SetImageEPhiiiiN6QImage6FormatE @ 0x1000d4fdc (imagebase-relative)
bool __fastcall VideoAdapter::SetImage(__int64 a1, const void *a2, int a3, int a4, int a5, int a6, int a7)
{
  __int64 v8; // x28
  std::recursive_mutex *v15; // x25
  void *v16; // x0
  size_t v17; // x27
  bool v18; // zf

  v8 = *(_QWORD *)(a1 + 16);
  if ( !a2 || !v8 )
    goto LABEL_10;
  v15 = (std::recursive_mutex *)(a1 + 48);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 48));
  v16 = *(void **)(a1 + 112);
  if ( *(_DWORD *)(a1 + 120) < a3 )
  {
    if ( v16 )
    {
      operator delete[](v16);
      *(_QWORD *)(a1 + 112) = 0;
      *(_DWORD *)(a1 + 120) = 0;
    }
    goto LABEL_8;
  }
  if ( !v16 )
  {
LABEL_8:
    v17 = a3;
    v16 = operator new[](a3);
    *(_QWORD *)(a1 + 112) = v16;
    *(_DWORD *)(a1 + 120) = a3;
    goto LABEL_9;
  }
  v17 = a3;
LABEL_9:
  memcpy(v16, a2, v17);
  *(_DWORD *)(a1 + 124) = a4;
  *(_DWORD *)(a1 + 128) = a5;
  *(_DWORD *)(a1 + 132) = a6;
  *(_DWORD *)(a1 + 136) = a7;
  std::recursive_mutex::unlock(v15);
LABEL_10:
  if ( a2 )
    v18 = v8 == 0;
  else
    v18 = 1;
  return !v18;
}
