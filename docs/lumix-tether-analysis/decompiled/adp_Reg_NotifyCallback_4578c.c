// __ZN11lumixtether13DeviceAdapter35adp_LMX_func_api_Reg_NotifyCallbackEv @ 0x10004578c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapter::adp_LMX_func_api_Reg_NotifyCallback(lumixtether::DeviceAdapter *this)
{
  lumixtether::DeviceAdapterCallback *v2; // x20
  QThread *v3; // x1
  QThread *v4; // x20
  __int64 v5; // x20
  __int64 v6; // x21
  _QWORD *v7; // x0
  __int64 v8; // x20
  _QWORD *v9; // x0
  __int64 v11; // [xsp+0h] [xbp-60h] BYREF
  __int64 v12; // [xsp+8h] [xbp-58h] BYREF
  __int64 (__fastcall *v13)(lumixtether::DeviceAdapterCallback *__hidden); // [xsp+10h] [xbp-50h] BYREF
  __int64 v14; // [xsp+18h] [xbp-48h]
  __int64 (__fastcall *v15)(lumixtether::DeviceAdapter *__hidden); // [xsp+20h] [xbp-40h] BYREF
  __int64 v16; // [xsp+28h] [xbp-38h]

  v2 = *((lumixtether::DeviceAdapterCallback **)this + 143);
  if ( v2 )
  {
    v3 = *((QThread **)this + 144);
    if ( !v3 )
      goto LABEL_5;
  }
  else
  {
    v2 = (lumixtether::DeviceAdapterCallback *)operator new(0x68u);
    lumixtether::DeviceAdapterCallback::DeviceAdapterCallback(v2, nullptr);
    *((_QWORD *)this + 143) = v2;
    v3 = *((QThread **)this + 144);
    if ( !v3 )
    {
LABEL_5:
      v4 = (QThread *)operator new(0x10u);
      QThread::QThread(v4, nullptr);
      *((_QWORD *)this + 144) = v4;
      v3 = v4;
      v2 = *((lumixtether::DeviceAdapterCallback **)this + 143);
    }
  }
  QObject::moveToThread(v2, v3);
  v5 = *((_QWORD *)this + 144);
  v6 = *((_QWORD *)this + 143);
  v15 = (__int64 (__fastcall *)(lumixtether::DeviceAdapter *__hidden))&QThread::finished;
  v16 = 0;
  v13 = (__int64 (__fastcall *)(lumixtether::DeviceAdapterCallback *__hidden))&QObject::deleteLater;
  v14 = 0;
  v7 = operator new(0x20u);
  *(_DWORD *)v7 = 1;
  v7[1] = QtPrivate::QSlotObject<void (QObject::*)(void),QtPrivate::List<>,void>::impl;
  v7[2] = &QObject::deleteLater;
  v7[3] = 0;
  QObject::connectImpl(&v12, v5, &v15, v6, &v13, v7, 0, 0, &QThread::staticMetaObject);
  QMetaObject::Connection::~Connection((QMetaObject::Connection *)&v12);
  v8 = *((_QWORD *)this + 143);
  v15 = lumixtether::DeviceAdapter::operateDeviceAdapterCallback;
  v16 = 0;
  v13 = lumixtether::DeviceAdapterCallback::doWork;
  v14 = 0;
  v9 = operator new(0x20u);
  *(_DWORD *)v9 = 1;
  v9[1] = QtPrivate::QSlotObject<void (lumixtether::DeviceAdapterCallback::*)(void),QtPrivate::List<>,void>::impl;
  v9[2] = lumixtether::DeviceAdapterCallback::doWork;
  v9[3] = 0;
  QObject::connectImpl(&v11, this, &v15, v8, &v13, v9, 130, 0, &lumixtether::DeviceAdapter::staticMetaObject);
  QMetaObject::Connection::~Connection((QMetaObject::Connection *)&v11);
  QThread::start(*((_QWORD *)this + 144), 7);
  lumixtether::DeviceAdapter::operateDeviceAdapterCallback(this);
  return 1;
}
