// __ZN9ObjectAdd7saveRAWEj @ 0x1000c1b64
void __fastcall ObjectAdd::saveRAW(atomic_ullong *this, __int64 a2)
{
  atomic_ullong *v3; // x20
  __int64 v4; // x8
  atomic_ullong *v5; // x21
  __int64 v6; // x8
  __int64 DeviceAdapter; // x22
  ApplicationData *Object_AssociatType; // x0
  int v9; // w22
  __int64 v10; // x22
  int Object_FormatType; // w22
  __int64 v12; // x22
  atomic_uint *v13; // x23
  ApplicationData *FileName; // x0
  int v15; // w22
  __int64 v16; // x22
  int Object_DataSize; // w22
  ApplicationData *v18; // x0
  unsigned __int64 v19; // x22
  __int64 v20; // x23
  __int64 v21; // x8
  int v22; // w25
  __int64 v23; // x9
  __int64 v24; // x25
  __int64 v25; // x26
  __int64 v26; // x27
  int Partial_Object; // w26
  ApplicationData *v28; // x0
  lumixtether::DeviceAdapter *v29; // x0
  ApplicationData *v30; // x0
  __int64 v31; // x0
  atomic_uint *v32[3]; // [xsp+0h] [xbp-1A0h] BYREF
  __int128 v33; // [xsp+18h] [xbp-188h] BYREF
  __int64 v34; // [xsp+28h] [xbp-178h]
  _BYTE v35[16]; // [xsp+30h] [xbp-170h] BYREF
  __int128 v36; // [xsp+40h] [xbp-160h] BYREF
  __int64 v37; // [xsp+50h] [xbp-150h]
  __int128 v38; // [xsp+58h] [xbp-148h] BYREF
  __int64 v39; // [xsp+68h] [xbp-138h]
  __int128 v40; // [xsp+70h] [xbp-130h] BYREF
  __int64 v41; // [xsp+80h] [xbp-120h]
  __int128 v42; // [xsp+88h] [xbp-118h] BYREF
  __int64 v43; // [xsp+98h] [xbp-108h]
  atomic_uint *v44; // [xsp+A0h] [xbp-100h] BYREF
  __int64 v45; // [xsp+A8h] [xbp-F8h]
  __int64 v46; // [xsp+B0h] [xbp-F0h]
  int v47; // [xsp+BCh] [xbp-E4h] BYREF
  __int64 v48; // [xsp+C0h] [xbp-E0h] BYREF
  atomic_uint *v49; // [xsp+C8h] [xbp-D8h] BYREF
  atomic_uint *v50; // [xsp+D0h] [xbp-D0h]
  atomic_uint *v51; // [xsp+D8h] [xbp-C8h]
  atomic_uint *v52[3]; // [xsp+E0h] [xbp-C0h] BYREF
  atomic_uint *v53[3]; // [xsp+F8h] [xbp-A8h] BYREF
  atomic_uint *v54[3]; // [xsp+110h] [xbp-90h] BYREF
  unsigned int v55; // [xsp+12Ch] [xbp-74h] BYREF
  __int128 v56; // [xsp+130h] [xbp-70h] BYREF
  __int64 v57; // [xsp+140h] [xbp-60h]

  v3 = this;
  v4 = 0;
  memset(v54, 0, sizeof(v54));
  memset(v53, 0, sizeof(v53));
  memset(v52, 0, sizeof(v52));
  v49 = nullptr;
  v50 = nullptr;
  v51 = nullptr;
  v47 = 0;
  v44 = nullptr;
  v45 = 0;
  v5 = this + 13;
  v46 = 0;
  atomic_compare_exchange_strong_explicit(
    this + 13,
    (unsigned __int64 *)&v4,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v4 )
    this = (atomic_ullong *)QBasicMutex::lockInternal((QBasicMutex *)(this + 13));
  *((_BYTE *)v3 + 96) = 0;
  v6 = 1;
  atomic_compare_exchange_strong_explicit(v5, (unsigned __int64 *)&v6, 0, memory_order_release, memory_order_relaxed);
  if ( v6 != 1 )
    this = (atomic_ullong *)QBasicMutex::unlockInternal((QBasicMutex *)v5);
  DeviceAdapter = ApplicationData::getDeviceAdapter((ApplicationData *)this);
  QString::fromUtf8(&v56, 0, &unk_10014269A);
  v42 = v56;
  v43 = v57;
  Object_AssociatType = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_AssociatType(
                                             DeviceAdapter,
                                             a2,
                                             &v47,
                                             &v42);
  v9 = (int)Object_AssociatType;
  if ( (_QWORD)v42 && atomic_fetch_add((atomic_uint *volatile)v42, 0xFFFFFFFF) == 1 )
    Object_AssociatType = (ApplicationData *)QArrayData::deallocate(v42, 2, 8);
  if ( v9 == 1 )
  {
    v10 = ApplicationData::getDeviceAdapter(Object_AssociatType);
    QString::fromUtf8(&v56, 0, &unk_10014269A);
    v40 = v56;
    v41 = v57;
    Object_FormatType = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_FormatType(v10, a2, &v55, &v40);
    if ( (_QWORD)v40 && atomic_fetch_add((atomic_uint *volatile)v40, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v40, 2, 8);
    if ( Object_FormatType == 1 )
    {
      v12 = v55;
      QString::fromUtf8(&v56, 0, &unk_10014269A);
      v13 = (atomic_uint *)v56;
      v38 = v56;
      v39 = v57;
      FileName = (ApplicationData *)lumixtether::ObjectCopy::makeFileName(v12, v52, v53, v54, 1, a2, 0, &v38);
      v15 = (int)FileName;
      if ( v13 && atomic_fetch_add(v13, 0xFFFFFFFF) == 1 )
        FileName = (ApplicationData *)QArrayData::deallocate(v38, 2, 8);
      if ( v15 )
      {
        v16 = ApplicationData::getDeviceAdapter(FileName);
        QString::fromUtf8(&v56, 0, &unk_10014269A);
        v36 = v56;
        v37 = v57;
        Object_DataSize = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(v16, a2, &v48, &v36);
        if ( (_QWORD)v36 && atomic_fetch_add((atomic_uint *volatile)v36, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v36, 2, 8);
        if ( Object_DataSize == 1 )
        {
          QFile::QFile((QFile *)v35, (const QString *)v54);
          if ( (QFile::open(v35, 2) & 1) != 0 )
          {
            v18 = (ApplicationData *)QByteArray::resize((QByteArray *)&v44, 31457280);
            v19 = v48;
            if ( v48 )
            {
              v20 = 0;
              while ( 1 )
              {
                v21 = 0;
                atomic_compare_exchange_strong_explicit(
                  v5,
                  (unsigned __int64 *)&v21,
                  1u,
                  memory_order_acquire,
                  memory_order_acquire);
                if ( v21 )
                  v18 = (ApplicationData *)QBasicMutex::lockInternal((QBasicMutex *)v5);
                v22 = *((unsigned __int8 *)v3 + 96);
                v23 = 1;
                atomic_compare_exchange_strong_explicit(
                  v3 + 13,
                  (unsigned __int64 *)&v23,
                  0,
                  memory_order_release,
                  memory_order_relaxed);
                if ( v23 != 1 )
                  v18 = (ApplicationData *)QBasicMutex::unlockInternal((QBasicMutex *)v5);
                if ( v22 )
                  break;
                if ( v19 >> 21 > 0xE )
                {
                  v24 = 31457280;
                }
                else
                {
                  v18 = (ApplicationData *)QByteArray::resize((QByteArray *)&v44, v19);
                  v24 = v19;
                }
                v25 = ApplicationData::getDeviceAdapter(v18);
                if ( !v44 || *v44 >= 2 )
                  QByteArray::reallocData(&v44, v46, 1);
                v26 = v45;
                QString::fromUtf8(&v56, 0, &unk_10014269A);
                v33 = v56;
                v34 = v57;
                Partial_Object = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Partial_Object(
                                   v25,
                                   a2,
                                   v26,
                                   v20,
                                   v24,
                                   &v33);
                if ( (_QWORD)v33 && atomic_fetch_add((atomic_uint *volatile)v33, 0xFFFFFFFF) == 1 )
                  QArrayData::deallocate(v33, 2, 8);
                if ( Partial_Object != 1 )
                  break;
                v18 = (ApplicationData *)QIODevice::write((QIODevice *)v35, (const QByteArray *)&v44);
                v20 += v24;
                v19 -= v24;
                if ( !v19 )
                  goto LABEL_40;
              }
              QFileDevice::close((QFileDevice *)v35);
              QFile::remove((QFile *)v35);
            }
            else
            {
LABEL_40:
              QFileDevice::close((QFileDevice *)v35);
              v28 = (ApplicationData *)QString::operator=(&v49, v54);
              v29 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(v28);
              v30 = (ApplicationData *)lumixtether::DeviceAdapter::imgInfoQuality(v29);
              if ( (_DWORD)v30 == 4 && v55 == 2 && !v47 )
              {
                v31 = ApplicationData::getDeviceAdapter(v30);
                v32[0] = v49;
                v32[1] = v50;
                v32[2] = v51;
                if ( v49 )
                  atomic_fetch_add(v49, 1u);
                lumixtether::DeviceAdapter::setPcSavedFilePath(v31, v32);
                if ( v32[0] && atomic_fetch_add(v32[0], 0xFFFFFFFF) == 1 )
                  QArrayData::deallocate(v32[0], 2, 8);
              }
            }
          }
          QFile::~QFile((QFile *)v35);
        }
      }
    }
  }
  if ( v44 && atomic_fetch_add(v44, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v44, 1, 8);
  if ( v49 && atomic_fetch_add(v49, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v49, 2, 8);
  if ( v52[0] && atomic_fetch_add(v52[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v52[0], 2, 8);
  if ( v53[0] && atomic_fetch_add(v53[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v53[0], 2, 8);
  if ( v54[0] )
  {
    if ( atomic_fetch_add(v54[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v54[0], 2, 8);
  }
}
