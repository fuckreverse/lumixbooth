// __ZN11lumixtether13DeviceAdapter22ptpipConnectThreadProcEv @ 0x1000421cc (imagebase-relative)
void __fastcall lumixtether::DeviceAdapter::ptpipConnectThreadProc(lumixtether::DeviceAdapter *this)
{
  unsigned __int8 v2; // w8
  SearchCameraListItemObject *v3; // x23
  unsigned __int8 v4; // w8
  __int64 v5; // x27
  void **v6; // x23
  unsigned __int64 v7; // x22
  __int64 v8; // x8
  __int64 v9; // x1
  QSettings *v10; // x0
  atomic_uint *v11[2]; // [xsp+8h] [xbp-E68h] BYREF
  __int64 v12; // [xsp+18h] [xbp-E58h]
  atomic_uint *v13[3]; // [xsp+20h] [xbp-E50h] BYREF
  __int128 v14; // [xsp+38h] [xbp-E38h] BYREF
  __int64 v15; // [xsp+48h] [xbp-E28h]
  __int128 v16; // [xsp+50h] [xbp-E20h] BYREF
  __int64 v17; // [xsp+60h] [xbp-E10h]
  __int128 v18; // [xsp+68h] [xbp-E08h] BYREF
  __int64 v19; // [xsp+78h] [xbp-DF8h]
  std::chrono::nanoseconds v20[4]; // [xsp+80h] [xbp-DF0h] BYREF
  std::chrono::nanoseconds __ns[2]; // [xsp+A0h] [xbp-DD0h] BYREF
  __int64 v22; // [xsp+B0h] [xbp-DC0h]
  _DWORD __dst[852]; // [xsp+C0h] [xbp-DB0h] BYREF

  v2 = atomic_load((unsigned __int8 *)this + 1704);
  if ( (v2 & 1) == 0 )
  {
    LODWORD(v3) = 0;
    do
    {
      bzero(__dst, 0xD50u);
      std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 1592));
      v5 = *((_QWORD *)this + 212);
      if ( v5 )
      {
        v6 = *((void ***)this + 208);
        v7 = *((_QWORD *)this + 211);
        memcpy(__dst, *(char **)((char *)v6 + ((v7 >> 1) & 0x7FFFFFFFFFFFFFF8LL)) + 3408 * (v7 & 0xF), sizeof(__dst));
        *((_QWORD *)this + 212) = v5 - 1;
        *((_QWORD *)this + 211) = v7 + 1;
        if ( v7 + 1 >= 0x20 )
        {
          operator delete(*v6);
          *((_QWORD *)this + 208) += 8LL;
          *((_QWORD *)this + 211) -= 16LL;
        }
        std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 1592));
        v8 = *(_QWORD *)(*((_QWORD *)this + 140) + 410272LL);
        if ( !v8 || *(__int64 *)(v8 + 24) < 12 )
        {
          if ( LOBYTE(__dst[584]) )
          {
            QString::fromUtf8(__ns, 0, &unk_10014269A);
            v18 = *(_OWORD *)&__ns[0].__rep_;
            v19 = v22;
            if ( (unsigned int)lumixtether::DeviceAdapter::saveCerFile(this, __dst, &v18) == 1 )
            {
              v9 = __dst[0];
              v16 = v18;
              v17 = v19;
              if ( (_QWORD)v18 )
                atomic_fetch_add((atomic_uint *volatile)v18, 1u);
              lumixtether::DeviceAdapter::adp_LMX_func_api_ptpip_SetCerFilePath(this, v9, &v16);
              if ( (_QWORD)v16 && atomic_fetch_add((atomic_uint *volatile)v16, 0xFFFFFFFF) == 1 )
                QArrayData::deallocate(v16, 2, 8);
              v3 = (SearchCameraListItemObject *)operator new(0x1678u);
              SearchCameraListItemObject::SearchCameraListItemObject(v3, nullptr);
              SearchCameraListItemObject::SetConnectLanDevInfo(v3, __dst);
              v14 = v18;
              v15 = v19;
              if ( (_QWORD)v18 )
                atomic_fetch_add((atomic_uint *volatile)v18, 1u);
              SearchCameraListItemObject::setCAFilePath(v3, &v14);
              if ( (_QWORD)v14 && atomic_fetch_add((atomic_uint *volatile)v14, 0xFFFFFFFF) == 1 )
                QArrayData::deallocate(v14, 2, 8);
              SearchCameraListItemObject::devSerialNo((__int64 *)v13, v3);
              v10 = (QSettings *)(*((_QWORD *)this + 140) + 32LL);
              memset(v20, 0, 24);
              v20[3].__rep_ = 2;
              QSettings::value(__ns, v10, (const QString *)v13, (const QVariant *)v20);
              sub_100013BF8((__int64 *)v11, (QVariant *)__ns);
              QVariant::~QVariant((QVariant *)__ns);
              QVariant::~QVariant((QVariant *)v20);
              lumixtether::DeviceAdapter::createCerSaveFilePath(__ns);
              SearchCameraListItemObject::setEnable(v3, 1);
              if ( v12 >= 1
                && v12 == v22
                && !(unsigned int)QtPrivate::compareStrings(v12, v11[1], v12, __ns[1].__rep_, 1) )
              {
                SearchCameraListItemObject::setAuthorize(v3, 1);
              }
              if ( __ns[0].__rep_ && atomic_fetch_add((atomic_uint *volatile)__ns[0].__rep_, 0xFFFFFFFF) == 1 )
                QArrayData::deallocate(__ns[0].__rep_, 2, 8);
              if ( v11[0] && atomic_fetch_add(v11[0], 0xFFFFFFFF) == 1 )
                QArrayData::deallocate(v11[0], 2, 8);
              if ( v13[0] && atomic_fetch_add(v13[0], 0xFFFFFFFF) == 1 )
                QArrayData::deallocate(v13[0], 2, 8);
            }
            else
            {
              v3 = nullptr;
            }
            if ( (_QWORD)v18 && atomic_fetch_add((atomic_uint *volatile)v18, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v18, 2, 8);
            if ( !v3 )
              goto LABEL_6;
          }
          else
          {
            v3 = (SearchCameraListItemObject *)operator new(0x1678u);
            SearchCameraListItemObject::SearchCameraListItemObject(v3, nullptr);
            SearchCameraListItemObject::SetConnectLanDevInfo(v3, __dst);
            SearchCameraListItemObject::setEnable(v3, 1);
            SearchCameraListItemObject::setAuthorize(v3, 1);
          }
          lumixtether::DeviceAdapter::AddSortSearchList(this, v3);
          lumixtether::DeviceSearch::SetPTPIPSearchEvent((lumixtether::DeviceAdapter *)((char *)this + 1288), 1u);
          lumixtether::DeviceAdapter::searchListChanged(this);
        }
        LODWORD(v3) = 0;
      }
      else
      {
        std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 1592));
        if ( (int)v3 >= 11 )
          break;
        __ns[0].__rep_ = 100000000;
        std::this_thread::sleep_for(__ns);
        LODWORD(v3) = (_DWORD)v3 + 1;
      }
LABEL_6:
      v4 = atomic_load((unsigned __int8 *)this + 1704);
    }
    while ( (v4 & 1) == 0 );
  }
  atomic_store(1u, (unsigned __int8 *)this + 1705);
}
