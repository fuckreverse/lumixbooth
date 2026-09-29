// __ZN11lumixtether13DeviceAdapter30registerAddEventReceivedNotifyEjj7QString @ 0x100041cf0
__int64 __fastcall lumixtether::DeviceAdapter::registerAddEventReceivedNotify(__int64 result, int a2)
{
  lumixtether::DeviceAdapter *v2; // x19
  __int64 v3; // x8
  _DWORD *v4; // x20
  int v5; // w21
  __int64 v6; // x9
  _QWORD *v7; // x24
  _QWORD *v8; // x22
  int v9; // w23
  _QWORD *v10; // x25
  _QWORD *v11; // x8
  __int64 v12; // x8
  __int64 v13; // x9
  _QWORD *v14; // t1

  if ( a2 == 268435520 )
  {
    v2 = (lumixtether::DeviceAdapter *)result;
    v3 = *(_QWORD *)(result + 1120);
    if ( (unsigned int)(*(_DWORD *)(v3 + 1460) - 1) <= 1 )
    {
      v4 = (_DWORD *)(v3 + 19316);
      v5 = *(_DWORD *)(v3 + 19316);
      if ( v5 >= 1 && *(_DWORD *)(v3 + 410376) == 1 )
      {
        v5 = 0;
        *v4 = 0;
      }
      v6 = *(_QWORD *)(v3 + 410272);
      if ( v6 )
        v7 = *(_QWORD **)(v6 + 8);
      else
        v7 = nullptr;
      if ( v6 )
        v8 = (_QWORD *)(v6 + 16);
      else
        v8 = nullptr;
      if ( v7 == v8 )
        goto LABEL_30;
      v9 = 0;
      v10 = (_QWORD *)(v3 + 307856);
      do
      {
        if ( *((_BYTE *)v7 + 208) )
        {
          if ( *((_BYTE *)v7 + 242)
            || (result = v7[6], result == v10[1])
            && (result = QtPrivate::compareStrings(result, v7[5], v7[6], *v10, 1), !(_DWORD)result) )
          {
            ++v9;
          }
        }
        v11 = (_QWORD *)v7[1];
        if ( v11 )
        {
          do
          {
            v7 = v11;
            v11 = (_QWORD *)*v11;
          }
          while ( v11 );
        }
        else
        {
          v12 = (__int64)(v7 + 2);
          if ( *(_QWORD **)v7[2] == v7 )
          {
            v7 = (_QWORD *)v7[2];
          }
          else
          {
            do
            {
              v13 = *(_QWORD *)v12;
              v14 = *(_QWORD **)(*(_QWORD *)v12 + 16LL);
              v12 = *(_QWORD *)v12 + 16LL;
              v7 = v14;
            }
            while ( *v14 != v13 );
          }
        }
      }
      while ( v7 != v8 );
      if ( v9 <= 1 )
      {
LABEL_30:
        if ( v5 >= 1 )
          return lumixtether::DeviceAdapter::objectAddEventReceivedNotify(v2);
      }
      else if ( v5 >= 1 )
      {
        *v4 = 0;
      }
    }
  }
  return result;
}
