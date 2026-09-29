// __ZN9ObjectAdd9saveMovieEv @ 0x1000be514
void __fastcall ObjectAdd::saveMovie(atomic_ullong *this)
{
  atomic_ullong *v1; // x19
  __int64 v2; // x8
  __int64 v3; // x20
  atomic_ullong *v4; // x21
  __int64 v5; // x8
  __int64 DeviceAdapter; // x22
  int Object_FormatType; // w22
  __int64 v8; // x22
  atomic_uint *v9; // x23
  ApplicationData *FileName; // x0
  int v11; // w22
  __int64 v12; // x22
  int Object_DataSize; // w22
  ApplicationData *v14; // x0
  unsigned __int64 v15; // x22
  __int64 v16; // x8
  int v17; // w23
  __int64 v18; // x9
  __int64 v19; // x26
  __int64 v20; // x27
  __int64 v21; // x28
  __int64 v22; // x23
  int Partial_Object; // w23
  __int64 v24; // x7
  atomic_ullong v25; // x0
  __int128 v26; // [xsp+98h] [xbp-158h] BYREF
  __int64 v27; // [xsp+A8h] [xbp-148h]
  _BYTE v28[16]; // [xsp+B0h] [xbp-140h] BYREF
  __int128 v29; // [xsp+C0h] [xbp-130h] BYREF
  __int64 v30; // [xsp+D0h] [xbp-120h]
  __int128 v31; // [xsp+D8h] [xbp-118h] BYREF
  __int64 v32; // [xsp+E8h] [xbp-108h]
  __int128 v33; // [xsp+F0h] [xbp-100h] BYREF
  __int64 v34; // [xsp+100h] [xbp-F0h]
  atomic_uint *v35; // [xsp+108h] [xbp-E8h] BYREF
  __int64 v36; // [xsp+110h] [xbp-E0h]
  __int64 v37; // [xsp+118h] [xbp-D8h]
  __int64 v38; // [xsp+120h] [xbp-D0h] BYREF
  unsigned __int64 v39; // [xsp+128h] [xbp-C8h] BYREF
  atomic_uint *v40[3]; // [xsp+130h] [xbp-C0h] BYREF
  atomic_uint *v41[3]; // [xsp+148h] [xbp-A8h] BYREF
  atomic_uint *v42[3]; // [xsp+160h] [xbp-90h] BYREF
  unsigned int v43; // [xsp+17Ch] [xbp-74h] BYREF
  __int128 v44; // [xsp+180h] [xbp-70h] BYREF
  __int64 v45; // [xsp+190h] [xbp-60h]

  v1 = this;
  v2 = 0;
  memset(v42, 0, sizeof(v42));
  memset(v41, 0, sizeof(v41));
  memset(v40, 0, sizeof(v40));
  v37 = 0;
  v38 = 0;
  v35 = nullptr;
  v36 = 0;
  v3 = *((unsigned int *)this + 28);
  v4 = this + 13;
  atomic_compare_exchange_strong_explicit(
    this + 13,
    (unsigned __int64 *)&v2,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v2 )
    this = (atomic_ullong *)QBasicMutex::lockInternal((QBasicMutex *)(this + 13));
  *((_BYTE *)v1 + 96) = 0;
  v5 = 1;
  atomic_compare_exchange_strong_explicit(v4, (unsigned __int64 *)&v5, 0, memory_order_release, memory_order_relaxed);
  if ( v5 != 1 )
    this = (atomic_ullong *)QBasicMutex::unlockInternal((QBasicMutex *)v4);
  DeviceAdapter = ApplicationData::getDeviceAdapter((ApplicationData *)this);
  QString::fromUtf8(&v44, 0, &unk_10014269A);
  v33 = v44;
  v34 = v45;
  Object_FormatType = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_FormatType(DeviceAdapter, v3, &v43, &v33);
  if ( (_QWORD)v33 && atomic_fetch_add((atomic_uint *volatile)v33, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v33, 2, 8);
  if ( Object_FormatType == 1 )
  {
    v8 = v43;
    QString::fromUtf8(&v44, 0, &unk_10014269A);
    v9 = (atomic_uint *)v44;
    v31 = v44;
    v32 = v45;
    FileName = (ApplicationData *)lumixtether::ObjectCopy::makeFileName(v8, v40, v41, v42, 1, v3, 0, &v31);
    v11 = (int)FileName;
    if ( v9 && atomic_fetch_add(v9, 0xFFFFFFFF) == 1 )
      FileName = (ApplicationData *)QArrayData::deallocate(v31, 2, 8);
    if ( v11 )
    {
      v12 = ApplicationData::getDeviceAdapter(FileName);
      QString::fromUtf8(&v44, 0, &unk_10014269A);
      v29 = v44;
      v30 = v45;
      Object_DataSize = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(v12, v3, &v39, &v29);
      if ( (_QWORD)v29 && atomic_fetch_add((atomic_uint *volatile)v29, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v29, 2, 8);
      if ( Object_DataSize == 1 )
      {
        QFile::QFile((QFile *)v28, (const QString *)v42);
        if ( (QFile::open(v28, 2) & 1) != 0 )
        {
          v14 = (ApplicationData *)QByteArray::resize((QByteArray *)&v35, 31457280);
          v15 = v39;
          while ( v15 )
          {
            v16 = 0;
            atomic_compare_exchange_strong_explicit(
              v4,
              (unsigned __int64 *)&v16,
              1u,
              memory_order_acquire,
              memory_order_acquire);
            if ( v16 )
              v14 = (ApplicationData *)QBasicMutex::lockInternal((QBasicMutex *)v4);
            v17 = *((unsigned __int8 *)v1 + 96);
            v18 = 1;
            atomic_compare_exchange_strong_explicit(
              v1 + 13,
              (unsigned __int64 *)&v18,
              0,
              memory_order_release,
              memory_order_relaxed);
            if ( v18 != 1 )
              v14 = (ApplicationData *)QBasicMutex::unlockInternal((QBasicMutex *)v4);
            if ( v17 )
              goto LABEL_37;
            if ( v15 >> 21 > 0xE )
            {
              v19 = 31457280;
            }
            else
            {
              v14 = (ApplicationData *)QByteArray::resize((QByteArray *)&v35, v15);
              v19 = v15;
            }
            v20 = ApplicationData::getDeviceAdapter(v14);
            if ( !v35 || *v35 >= 2 )
              QByteArray::reallocData(&v35, v37, 1);
            v21 = v36;
            v22 = v38;
            QString::fromUtf8(&v44, 0, &unk_10014269A);
            v26 = v44;
            v27 = v45;
            Partial_Object = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Partial_ObjectEx(
                               v20,
                               v3,
                               v21,
                               v22,
                               v19,
                               &v26);
            if ( (_QWORD)v26 && atomic_fetch_add((atomic_uint *volatile)v26, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v26, 2, 8);
            if ( Partial_Object != 1
              || (QIODevice::write((QIODevice *)v28, (const QByteArray *)&v35),
                  v38 += v19,
                  v25 = v1[11],
                  **(_DWORD **)(v25 + 16) == 2) )
            {
LABEL_37:
              QFileDevice::close((QFileDevice *)v28);
              QFile::remove((QFile *)v28);
              goto LABEL_39;
            }
            v15 -= v19;
            v14 = (ApplicationData *)QMetaObject::invokeMethod(
                                       v25,
                                       "setObjectAddOffsetSizeValue",
                                       130,
                                       0,
                                       0,
                                       &v38,
                                       "ulong",
                                       v24,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0);
          }
          QFileDevice::close((QFileDevice *)v28);
        }
LABEL_39:
        QFile::~QFile((QFile *)v28);
      }
    }
  }
  if ( v35 && atomic_fetch_add(v35, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v35, 1, 8);
  if ( v40[0] && atomic_fetch_add(v40[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v40[0], 2, 8);
  if ( v41[0] && atomic_fetch_add(v41[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v41[0], 2, 8);
  if ( v42[0] )
  {
    if ( atomic_fetch_add(v42[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v42[0], 2, 8);
  }
}
