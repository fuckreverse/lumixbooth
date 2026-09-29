// __ZN12VideoAdapter12setVideoSinkEP10QVideoSink @ 0x1000d4ea0 (imagebase-relative)
void __fastcall VideoAdapter::setVideoSink(__int64 a1, __int64 a2)
{
  std::recursive_mutex *v4; // x19
  __int64 v5; // x8
  bool v6; // zf
  QThread *v7; // x22
  QThread *v8; // x21

  v4 = (std::recursive_mutex *)(a1 + 48);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 48));
  v5 = *(_QWORD *)(a1 + 16);
  if ( v5 )
    v6 = v5 == a2;
  else
    v6 = 1;
  if ( !v6 )
  {
    v7 = (QThread *)QObject::thread(QCoreApplication::self);
    if ( v7 == (QThread *)QThread::currentThread(v7) )
      QTimer::stop((QTimer *)(a1 + 24));
    else
      QMetaObject::invokeMethod(a1 + 24, "stop", 2, 0, 0, 0, 0);
  }
  if ( *(_QWORD *)(a1 + 16) != a2 )
  {
    *(_QWORD *)(a1 + 16) = a2;
    if ( a2 )
    {
      VideoAdapter::videoSinkChanged((VideoAdapter *)a1);
      v8 = (QThread *)QObject::thread(QCoreApplication::self);
      if ( v8 == (QThread *)QThread::currentThread(v8) )
        QTimer::start((QTimer *)(a1 + 24));
      else
        QMetaObject::invokeMethod(a1 + 24, "start", 2, 0, 0, 0, 0);
    }
  }
  std::recursive_mutex::unlock(v4);
}
