// __ZN12VideoAdapterC2EP7QObject @ 0x1000d4aa0 (imagebase-relative)
void __fastcall VideoAdapter::VideoAdapter(VideoAdapter *this, QObject *a2)
{
  QObject *v3; // x0
  QTimer *v4; // x20
  QThread *v10; // x0
  _QWORD *v11; // x0
  __int64 v12; // [xsp+8h] [xbp-48h] BYREF
  _QWORD v13[2]; // [xsp+10h] [xbp-40h] BYREF
  _QWORD v14[2]; // [xsp+20h] [xbp-30h] BYREF

  v3 = QObject::QObject(this, a2);
  *(_QWORD *)v3 = &off_1009EE380;
  *((_QWORD *)v3 + 2) = 0;
  v4 = (QObject *)((char *)v3 + 24);
  QTimer::QTimer((QObject *)((char *)v3 + 24), nullptr);
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)this + 48));
  *((_QWORD *)this + 14) = 0;
  *((_QWORD *)this + 15) = 0;
  *((_QWORD *)this + 16) = 0;
  *((_DWORD *)this + 34) = 4;
  *((_BYTE *)this + 40) = 0;
  *((_QWORD *)this + 18) = 0;
  *((_QWORD *)this + 19) = 0;
  __asm { FMOV            V0.2D, #1.0 }
  *((_OWORD *)this + 10) = _Q0;
  QTimer::setInterval(v4, 33);
  v10 = (QThread *)QObject::thread(QCoreApplication::self);
  QObject::moveToThread(v4, v10);
  v14[0] = &QTimer::timeout;
  v14[1] = 0;
  v13[0] = VideoAdapter::slotTick;
  v13[1] = 0;
  v11 = operator new(0x20u);
  *(_DWORD *)v11 = 1;
  v11[1] = QtPrivate::QSlotObject<void (VideoAdapter::*)(void),QtPrivate::List<>,void>::impl;
  v11[2] = VideoAdapter::slotTick;
  v11[3] = 0;
  QObject::connectImpl(&v12, v4, v14, this, v13, v11, 2, 0, &QTimer::staticMetaObject);
  QMetaObject::Connection::~Connection((QMetaObject::Connection *)&v12);
}
