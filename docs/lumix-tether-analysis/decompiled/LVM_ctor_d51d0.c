// __ZN15LiveViewManagerC2EP7QObject @ 0x1000d51d0 (imagebase-relative)
void __fastcall LiveViewManager::LiveViewManager(LiveViewManager *this, QObject *a2)
{
  QObject *v3; // x0
  __int64 v4; // x9
  __int64 v5; // x10
  void *v6; // x22
  size_t v7; // x0
  _BYTE v8[16]; // [xsp+30h] [xbp-80h] BYREF
  __int64 v9; // [xsp+40h] [xbp-70h]
  _QWORD v10[3]; // [xsp+48h] [xbp-68h] BYREF

  v3 = QObject::QObject(this, a2);
  *(_QWORD *)v3 = &off_1009EE530;
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)v3 + 16));
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)this + 80));
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)this + 144));
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)this + 208));
  *((_OWORD *)this + 21) = 0u;
  *((_OWORD *)this + 22) = 0u;
  *((_OWORD *)this + 19) = 0u;
  *((_OWORD *)this + 20) = 0u;
  *((_OWORD *)this + 17) = 0u;
  *((_OWORD *)this + 18) = 0u;
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)this + 424));
  *(_OWORD *)((char *)this + 488) = 0u;
  *(_OWORD *)((char *)this + 504) = 0u;
  *((_OWORD *)this + 33) = 0u;
  *((_OWORD *)this + 34) = 0u;
  QImage::QImage((LiveViewManager *)((char *)this + 568));
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)this + 616));
  std::recursive_mutex::recursive_mutex((std::recursive_mutex *)((char *)this + 792));
  *((_QWORD *)this + 109) = 0;
  *(_OWORD *)((char *)this + 856) = 0u;
  *((_QWORD *)this + 52) = 0;
  atomic_store(0, (unsigned __int8 *)this + 560);
  QImage::QImage(v8, 1280, 960, 5);
  QPaintDevice::QPaintDevice((QPaintDevice *)v10);
  v4 = v9;
  v9 = 0;
  v10[0] = (char *)&`vtable for'QImage + 16;
  v5 = *((_QWORD *)this + 73);
  *((_QWORD *)this + 73) = v4;
  v10[2] = v5;
  QImage::~QImage((QImage *)v10);
  QImage::~QImage((QImage *)v8);
  v6 = (void *)QImage::bits((LiveViewManager *)((char *)this + 568));
  v7 = QImage::sizeInBytes((LiveViewManager *)((char *)this + 568));
  bzero(v6, v7);
  *((_DWORD *)this + 131) = 0;
  *((_BYTE *)this + 592) = 0;
  *((_DWORD *)this + 149) = 0;
  *(_QWORD *)((char *)this + 604) = 0;
  *((_WORD *)this + 306) = 0;
  std::string::assign((std::string *)((char *)this + 344), (const std::string::value_type *)&unk_10014269A);
  *((_QWORD *)this + 47) = 0;
  atomic_store(1u, (unsigned __int8 *)this + 520);
  *((_BYTE *)this + 880) = 0;
  *(_QWORD *)((char *)this + 884) = 0;
}
