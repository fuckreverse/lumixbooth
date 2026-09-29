// __ZN11lumixtether12DeviceSearchC2EP7QObject @ 0x100009884 (imagebase-relative)
lumixtether::DeviceSearch *__fastcall lumixtether::DeviceSearch::DeviceSearch(
        lumixtether::DeviceSearch *this,
        QObject *a2)
{
  QObject *v3; // x0
  QThread *v4; // x0

  v3 = QObject::QObject(this, a2);
  *(_QWORD *)v3 = &off_1009E6610;
  *((_QWORD *)v3 + 2) = 0;
  *((_QWORD *)v3 + 4) = 850045863;
  *(_OWORD *)((char *)v3 + 40) = 0u;
  *(_OWORD *)((char *)v3 + 56) = 0u;
  *(_OWORD *)((char *)v3 + 72) = 0u;
  *((_QWORD *)v3 + 11) = 0;
  *((_QWORD *)v3 + 12) = 1018212795;
  *(_OWORD *)((char *)v3 + 104) = 0u;
  *(_OWORD *)((char *)v3 + 120) = 0u;
  *((_QWORD *)v3 + 17) = 0;
  *((_QWORD *)v3 + 20) = 0;
  *((_QWORD *)v3 + 22) = 850045863;
  *(_OWORD *)((char *)v3 + 184) = 0u;
  *(_OWORD *)((char *)v3 + 200) = 0u;
  *(_OWORD *)((char *)v3 + 216) = 0u;
  *((_QWORD *)v3 + 29) = 0;
  *((_QWORD *)v3 + 30) = 1018212795;
  *(_OWORD *)((char *)v3 + 248) = 0u;
  *(_OWORD *)((char *)v3 + 264) = 0u;
  *((_QWORD *)v3 + 35) = 0;
  *((_BYTE *)v3 + 24) = 0;
  *((_WORD *)v3 + 72) = 0;
  *((_DWORD *)v3 + 37) = -1;
  *((_WORD *)v3 + 76) = 0;
  *((_BYTE *)v3 + 168) = 0;
  *((_DWORD *)v3 + 39) = 0;
  v4 = (QThread *)QObject::thread(QCoreApplication::self);
  QObject::moveToThread(this, v4);
  return this;
}
