// __ZN11lumixtether21DeviceAdapterCallbackC2EP7QObject @ 0x1000d9de8 (imagebase-relative)
double __fastcall lumixtether::DeviceAdapterCallback::DeviceAdapterCallback(
        lumixtether::DeviceAdapterCallback *this,
        QObject *a2)
{
  QObject *v2; // x0

  v2 = QObject::QObject(this, a2);
  *(_QWORD *)v2 = &off_1009EE608;
  *((_QWORD *)v2 + 12) = 0;
  *((_OWORD *)v2 + 1) = 0u;
  *((_OWORD *)v2 + 2) = 0u;
  *((_OWORD *)v2 + 3) = 0u;
  *((_OWORD *)v2 + 4) = 0u;
  *((_QWORD *)v2 + 10) = 0;
  return 0.0;
}
