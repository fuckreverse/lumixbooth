// __ZN11lumixtether10ObjectCopy14startObjectAddEi @ 0x1000c7f30 (imagebase-relative)
__int64 __fastcall lumixtether::ObjectCopy::startObjectAdd(lumixtether::ObjectCopy *this, int a2)
{
  lumixtether::ObjectCopy *v3; // x19
  QObject *v4; // x21
  QThread *v5; // x21
  __int64 DeviceAdapter; // x20
  unsigned int v7; // w21
  __int64 result; // x0
  int v9; // w20
  unsigned int v10; // w21
  __int64 v11; // x20
  unsigned int v12; // w21
  _BOOL4 Object_DataSize; // w20
  __int64 v14; // x8
  _QWORD *v15; // x22
  int v16; // w24
  unsigned __int64 v17; // x23
  __int64 v18; // x8
  QObject *v19; // x0
  __int64 v20; // x20
  __int64 v21; // x21
  _QWORD *v22; // x0
  __int64 v23; // x20
  _QWORD *v24; // x0
  __int64 v25; // [xsp+8h] [xbp-A8h] BYREF
  __int64 v26; // [xsp+10h] [xbp-A0h] BYREF
  __int128 v27; // [xsp+18h] [xbp-98h] BYREF
  __int64 v28; // [xsp+28h] [xbp-88h]
  __int128 v29; // [xsp+30h] [xbp-80h] BYREF
  __int64 v30; // [xsp+40h] [xbp-70h]
  unsigned int v31; // [xsp+4Ch] [xbp-64h] BYREF
  unsigned __int64 v32; // [xsp+50h] [xbp-60h] BYREF
  __int128 v33; // [xsp+58h] [xbp-58h] BYREF
  __int64 v34; // [xsp+68h] [xbp-48h]
  __int64 (__fastcall *v35)(ObjectAdd *__hidden); // [xsp+70h] [xbp-40h] BYREF
  __int64 v36; // [xsp+78h] [xbp-38h]

  v3 = this;
  v32 = 0;
  v31 = 0;
  if ( *((_QWORD *)this + 4) )
  {
    if ( *((_QWORD *)this + 5) )
      goto LABEL_6;
  }
  else
  {
    v4 = (QObject *)operator new(0x78u);
    this = QObject::QObject(v4, nullptr);
    *(_QWORD *)v4 = &off_1009ED3E8;
    *((_QWORD *)v4 + 13) = 0;
    *((_OWORD *)v4 + 1) = 0u;
    *((_OWORD *)v4 + 2) = 0u;
    *((_OWORD *)v4 + 3) = 0u;
    *((_OWORD *)v4 + 4) = 0u;
    *((_QWORD *)v4 + 10) = 0;
    *((_QWORD *)v3 + 4) = v4;
    if ( *((_QWORD *)v3 + 5) )
      goto LABEL_6;
  }
  v5 = (QThread *)operator new(0x10u);
  this = QThread::QThread(v5, nullptr);
  *((_QWORD *)v3 + 5) = v5;
LABEL_6:
  *((_DWORD *)v3 + 6) = a2;
  DeviceAdapter = ApplicationData::getDeviceAdapter(this);
  v7 = *((_DWORD *)v3 + 6);
  QString::fromUtf8(&v33, 0, &unk_10014269A);
  v29 = v33;
  v30 = v34;
  result = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_FormatType(DeviceAdapter, v7, &v31, (__int64)&v29);
  v9 = result;
  if ( (_QWORD)v29 && atomic_fetch_add((atomic_uint *volatile)v29, 0xFFFFFFFF) == 1 )
    result = QArrayData::deallocate(v29, 2, 8);
  if ( v9 != 1 )
    return lumixtether::ObjectCopy::objectAddErrorNotify(v3);
  v10 = v31;
  if ( v31 - 4 >= 2 )
  {
    if ( v31 != 1 )
      return result;
    goto LABEL_18;
  }
  v11 = ApplicationData::getDeviceAdapter((ApplicationData *)result);
  v12 = *((_DWORD *)v3 + 6);
  QString::fromUtf8(&v33, 0, &unk_10014269A);
  v27 = v33;
  v28 = v34;
  Object_DataSize = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(v11, v12, &v32, (__int64)&v27);
  if ( (_QWORD)v27 && atomic_fetch_add((atomic_uint *volatile)v27, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v27, 2, 8);
  if ( !Object_DataSize )
    return lumixtether::ObjectCopy::objectAddErrorNotify(v3);
  v10 = v31;
LABEL_18:
  v14 = 0;
  v15 = *((_QWORD **)v3 + 4);
  v16 = *((_DWORD *)v3 + 6);
  v17 = v32;
  atomic_compare_exchange_strong_explicit(
    v15 + 13,
    (unsigned __int64 *)&v14,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v14 )
    QBasicMutex::lockInternal((QBasicMutex *)(v15 + 13));
  LODWORD(v33) = v16;
  sub_1000BDA18(v15 + 2, v15[4], &v33);
  LODWORD(v33) = v10;
  sub_1000BDA18(v15 + 5, v15[7], &v33);
  *(_QWORD *)&v33 = v17;
  sub_1000C9050(v15 + 8, v15[10], &v33);
  v18 = 1;
  atomic_compare_exchange_strong_explicit(
    v15 + 13,
    (unsigned __int64 *)&v18,
    0,
    memory_order_release,
    memory_order_relaxed);
  if ( v18 != 1 )
    QBasicMutex::unlockInternal((QBasicMutex *)(v15 + 13));
  if ( !*((_DWORD *)v3 + 7) )
  {
    v19 = *((QObject **)v3 + 4);
    *((_QWORD *)v19 + 11) = v3;
    QObject::moveToThread(v19, *((QThread **)v3 + 5));
    v21 = *((_QWORD *)v3 + 4);
    v20 = *((_QWORD *)v3 + 5);
    *(_QWORD *)&v33 = &QThread::finished;
    *((_QWORD *)&v33 + 1) = 0;
    v35 = (__int64 (__fastcall *)(ObjectAdd *__hidden))&QObject::deleteLater;
    v36 = 0;
    v22 = operator new(0x20u);
    *(_DWORD *)v22 = 1;
    v22[1] = QtPrivate::QSlotObject<void (QObject::*)(void),QtPrivate::List<>,void>::impl;
    v22[2] = &QObject::deleteLater;
    v22[3] = 0;
    QObject::connectImpl(&v26, v20, &v33, v21, &v35, v22, 0, 0, &QThread::staticMetaObject);
    QMetaObject::Connection::~Connection((QMetaObject::Connection *)&v26);
    v23 = *((_QWORD *)v3 + 4);
    *(_QWORD *)&v33 = lumixtether::ObjectCopy::operateObjectAdd;
    *((_QWORD *)&v33 + 1) = 0;
    v35 = ObjectAdd::doWork;
    v36 = 0;
    v24 = operator new(0x20u);
    *(_DWORD *)v24 = 1;
    v24[1] = QtPrivate::QSlotObject<void (ObjectAdd::*)(void),QtPrivate::List<>,void>::impl;
    v24[2] = ObjectAdd::doWork;
    v24[3] = 0;
    QObject::connectImpl(&v25, v3, &v33, v23, &v35, v24, 130, 0, &lumixtether::ObjectCopy::staticMetaObject);
    QMetaObject::Connection::~Connection((QMetaObject::Connection *)&v25);
    QThread::start(*((_QWORD *)v3 + 5), 7);
    *((_DWORD *)v3 + 7) = 1;
  }
  return lumixtether::ObjectCopy::operateObjectAdd(v3);
}
