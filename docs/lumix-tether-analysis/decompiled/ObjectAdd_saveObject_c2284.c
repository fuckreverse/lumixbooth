// __ZN9ObjectAdd10saveObjectEj @ 0x1000c2284
void __fastcall ObjectAdd::saveObject(ObjectAdd *this, __int64 a2)
{
  __int64 DeviceAdapter; // x20
  ApplicationData *Object_AssociatType; // x0
  int v5; // w20
  __int64 v6; // x20
  ApplicationData *Object_FormatType; // x0
  int v8; // w20
  __int64 v9; // x20
  int Object_DataSize; // w20
  __int64 v11; // x20
  atomic_uint *v12; // x21
  int FileName; // w20
  ApplicationData *v14; // x0
  __int64 v15; // x20
  __int64 v16; // x21
  __int64 v17; // x22
  int Object; // w19
  ApplicationData *v19; // x0
  lumixtether::DeviceAdapter *v20; // x0
  ApplicationData *v21; // x0
  __int64 v22; // x0
  atomic_uint **v23; // x8
  __int64 v24; // x0
  atomic_uint *v25[3]; // [xsp+0h] [xbp-180h] BYREF
  atomic_uint *v26[3]; // [xsp+18h] [xbp-168h] BYREF
  __int128 v27; // [xsp+30h] [xbp-150h] BYREF
  __int64 v28; // [xsp+40h] [xbp-140h]
  atomic_uint *v29; // [xsp+48h] [xbp-138h] BYREF
  __int64 v30; // [xsp+50h] [xbp-130h]
  __int64 v31; // [xsp+58h] [xbp-128h]
  __int128 v32; // [xsp+60h] [xbp-120h] BYREF
  __int64 v33; // [xsp+70h] [xbp-110h]
  __int128 v34; // [xsp+78h] [xbp-108h] BYREF
  __int64 v35; // [xsp+88h] [xbp-F8h]
  __int128 v36; // [xsp+90h] [xbp-F0h] BYREF
  __int64 v37; // [xsp+A0h] [xbp-E0h]
  __int128 v38; // [xsp+A8h] [xbp-D8h] BYREF
  __int64 v39; // [xsp+B8h] [xbp-C8h]
  int v40; // [xsp+C4h] [xbp-BCh] BYREF
  __int64 v41; // [xsp+C8h] [xbp-B8h] BYREF
  atomic_uint *v42; // [xsp+D0h] [xbp-B0h] BYREF
  atomic_uint *v43; // [xsp+D8h] [xbp-A8h]
  atomic_uint *v44; // [xsp+E0h] [xbp-A0h]
  atomic_uint *v45[3]; // [xsp+E8h] [xbp-98h] BYREF
  atomic_uint *v46[3]; // [xsp+100h] [xbp-80h] BYREF
  atomic_uint *v47[3]; // [xsp+118h] [xbp-68h] BYREF
  unsigned int v48; // [xsp+134h] [xbp-4Ch] BYREF
  __int128 v49; // [xsp+138h] [xbp-48h] BYREF
  __int64 v50; // [xsp+148h] [xbp-38h]

  memset(v47, 0, sizeof(v47));
  memset(v46, 0, sizeof(v46));
  memset(v45, 0, sizeof(v45));
  v42 = nullptr;
  v43 = nullptr;
  v44 = nullptr;
  DeviceAdapter = ApplicationData::getDeviceAdapter(this);
  QString::fromUtf8(&v49, 0, &unk_10014269A);
  v38 = v49;
  v39 = v50;
  Object_AssociatType = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_AssociatType(
                                             DeviceAdapter,
                                             a2,
                                             &v40,
                                             &v38);
  v5 = (int)Object_AssociatType;
  if ( (_QWORD)v38 && atomic_fetch_add((atomic_uint *volatile)v38, 0xFFFFFFFF) == 1 )
    Object_AssociatType = (ApplicationData *)QArrayData::deallocate(v38, 2, 8);
  if ( v5 == 1 )
  {
    v6 = ApplicationData::getDeviceAdapter(Object_AssociatType);
    QString::fromUtf8(&v49, 0, &unk_10014269A);
    v36 = v49;
    v37 = v50;
    Object_FormatType = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_FormatType(
                                             v6,
                                             a2,
                                             &v48,
                                             &v36);
    v8 = (int)Object_FormatType;
    if ( (_QWORD)v36 && atomic_fetch_add((atomic_uint *volatile)v36, 0xFFFFFFFF) == 1 )
      Object_FormatType = (ApplicationData *)QArrayData::deallocate(v36, 2, 8);
    if ( v8 == 1 )
    {
      v9 = ApplicationData::getDeviceAdapter(Object_FormatType);
      QString::fromUtf8(&v49, 0, &unk_10014269A);
      v34 = v49;
      v35 = v50;
      Object_DataSize = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(v9, a2, &v41, &v34);
      if ( (_QWORD)v34 && atomic_fetch_add((atomic_uint *volatile)v34, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v34, 2, 8);
      if ( Object_DataSize == 1 )
      {
        v11 = v48;
        QString::fromUtf8(&v49, 0, &unk_10014269A);
        v12 = (atomic_uint *)v49;
        v32 = v49;
        v33 = v50;
        FileName = lumixtether::ObjectCopy::makeFileName(v11, v45, v46, v47, 1, a2, 0, &v32);
        if ( v12 && atomic_fetch_add(v12, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v32, 2, 8);
        if ( FileName )
        {
          v29 = nullptr;
          v30 = 0;
          v31 = 0;
          v14 = (ApplicationData *)QByteArray::resize((QByteArray *)&v29, v41);
          v15 = ApplicationData::getDeviceAdapter(v14);
          if ( !v29 || *v29 >= 2 )
            QByteArray::reallocData(&v29, v31, 1);
          v16 = v30;
          v17 = v41;
          QString::fromUtf8(&v49, 0, &unk_10014269A);
          v27 = v49;
          v28 = v50;
          Object = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object(v15, a2, v16, v17, &v27);
          if ( (_QWORD)v27 && atomic_fetch_add((atomic_uint *volatile)v27, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v27, 2, 8);
          if ( Object != 1 )
            goto LABEL_42;
          QFile::QFile((QFile *)&v49, (const QString *)v47);
          if ( (QFile::open(&v49, 2) & 1) != 0 )
          {
            QIODevice::write((QIODevice *)&v49, (const QByteArray *)&v29);
            QFileDevice::close((QFileDevice *)&v49);
            v19 = (ApplicationData *)QString::operator=(&v42, v47);
            v20 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(v19);
            v21 = (ApplicationData *)lumixtether::DeviceAdapter::imgInfoQuality(v20);
            if ( (_DWORD)v21 == 4 )
            {
              if ( v48 != 2 || v40 )
                goto LABEL_41;
              v22 = ApplicationData::getDeviceAdapter(v21);
              v26[0] = v42;
              v26[1] = v43;
              v26[2] = v44;
              if ( v42 )
                atomic_fetch_add(v42, 1u);
              lumixtether::DeviceAdapter::setPcSavedFilePath(v22, v26);
              if ( !v26[0] || atomic_fetch_add(v26[0], 0xFFFFFFFF) != 1 )
                goto LABEL_41;
              v23 = v26;
            }
            else
            {
              if ( v48 != 1 || v40 )
                goto LABEL_41;
              v24 = ApplicationData::getDeviceAdapter(v21);
              v25[0] = v42;
              v25[1] = v43;
              v25[2] = v44;
              if ( v42 )
                atomic_fetch_add(v42, 1u);
              lumixtether::DeviceAdapter::setPcSavedFilePath(v24, v25);
              if ( !v25[0] || atomic_fetch_add(v25[0], 0xFFFFFFFF) != 1 )
                goto LABEL_41;
              v23 = v25;
            }
            QArrayData::deallocate(*v23, 2, 8);
          }
LABEL_41:
          QFile::~QFile((QFile *)&v49);
LABEL_42:
          if ( v29 && atomic_fetch_add(v29, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v29, 1, 8);
        }
      }
    }
  }
  if ( v42 && atomic_fetch_add(v42, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v42, 2, 8);
  if ( v45[0] && atomic_fetch_add(v45[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v45[0], 2, 8);
  if ( v46[0] && atomic_fetch_add(v46[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v46[0], 2, 8);
  if ( v47[0] )
  {
    if ( atomic_fetch_add(v47[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v47[0], 2, 8);
  }
}
