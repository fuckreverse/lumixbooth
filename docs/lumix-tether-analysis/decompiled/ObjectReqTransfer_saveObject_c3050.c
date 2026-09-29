// __ZN17ObjectReqTransfer10saveObjectEjjmj7QString @ 0x1000c3050
void __fastcall ObjectReqTransfer::saveObject(
        ApplicationData *a1,
        __int64 a2,
        __int64 a3,
        __int64 a4,
        __int64 a5,
        atomic_uint **a6)
{
  int v7; // w19
  atomic_uint *v10; // x9
  atomic_uint *v11; // x0
  __int64 v12; // x1
  lumixtether::DeviceAdapter *DeviceAdapter; // x0
  ApplicationData *v15; // x0
  __int64 v16; // x0
  atomic_uint *v17; // x9
  ApplicationData *StatusOfCards; // x0
  int v19; // w24
  lumixtether::DeviceAdapter *v20; // x0
  ApplicationData *v21; // x0
  __int64 v22; // x0
  atomic_uint *v23; // x8
  atomic_uint *v24; // x9
  ApplicationData *Target; // x0
  int v26; // w24
  __int64 v27; // x0
  atomic_uint *v28; // x8
  atomic_uint *v29; // x9
  __int64 v30; // x0
  atomic_uint *v31; // x8
  atomic_uint *v32; // x9
  ApplicationData *Object_AssociatDesc; // x0
  int v34; // w24
  __int64 v35; // x0
  atomic_uint *v36; // x8
  atomic_uint *v37; // x9
  ApplicationData *objAssociatDesc; // x0
  int v39; // w24
  __int64 v40; // x6
  atomic_uint *v41; // x8
  atomic_uint *v42; // x9
  int FileName; // w24
  ApplicationData *v44; // x0
  __int64 v45; // x24
  __int64 v46; // x2
  atomic_uint *v47; // x8
  atomic_uint *v48; // x9
  int Object; // w21
  ApplicationData *v50; // x0
  __int64 v51; // x0
  __int64 v52; // x0
  atomic_uint *v53; // x8
  atomic_uint *v54; // x9
  atomic_uint *v55[3]; // [xsp+8h] [xbp-1C8h] BYREF
  _BYTE v56[16]; // [xsp+20h] [xbp-1B0h] BYREF
  atomic_uint *v57[3]; // [xsp+30h] [xbp-1A0h] BYREF
  atomic_uint *v58[3]; // [xsp+48h] [xbp-188h] BYREF
  atomic_uint *v59[3]; // [xsp+60h] [xbp-170h] BYREF
  atomic_uint *v60[3]; // [xsp+78h] [xbp-158h] BYREF
  atomic_uint *v61[3]; // [xsp+90h] [xbp-140h] BYREF
  atomic_uint *v62[3]; // [xsp+A8h] [xbp-128h] BYREF
  atomic_uint *v63[3]; // [xsp+C0h] [xbp-110h] BYREF
  atomic_uint *v64[3]; // [xsp+D8h] [xbp-F8h] BYREF
  atomic_uint *v65[3]; // [xsp+F0h] [xbp-E0h] BYREF
  atomic_uint *v66[3]; // [xsp+108h] [xbp-C8h] BYREF
  int v67; // [xsp+124h] [xbp-ACh] BYREF
  __int64 v68; // [xsp+128h] [xbp-A8h] BYREF
  atomic_uint *v69[3]; // [xsp+130h] [xbp-A0h] BYREF
  atomic_uint *v70[3]; // [xsp+148h] [xbp-88h] BYREF
  atomic_uint *v71[3]; // [xsp+160h] [xbp-70h] BYREF
  atomic_uint *v72; // [xsp+178h] [xbp-58h] BYREF
  atomic_uint *v73; // [xsp+180h] [xbp-50h]
  atomic_uint *v74; // [xsp+188h] [xbp-48h]

  v7 = a5;
  v72 = nullptr;
  v73 = nullptr;
  v74 = nullptr;
  memset(v71, 0, sizeof(v71));
  memset(v70, 0, sizeof(v70));
  memset(v69, 0, sizeof(v69));
  v68 = 0xFFFFFFFFLL;
  v67 = -1;
  if ( (_DWORD)a3 == 2 )
  {
    v10 = a6[1];
    v66[0] = *a6;
    v66[1] = v10;
    v66[2] = a6[2];
    if ( v66[0] )
      atomic_fetch_add(v66[0], 1u);
    ObjectReqTransfer::saveRAW(a1, a2, 2, a4, a5, v66);
    if ( v66[0] && atomic_fetch_add(v66[0], 0xFFFFFFFF) == 1 )
    {
      v11 = v66[0];
LABEL_7:
      v12 = 2;
LABEL_8:
      QArrayData::deallocate(v11, v12, 8);
      goto LABEL_70;
    }
    goto LABEL_70;
  }
  DeviceAdapter = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(a1);
  v15 = (ApplicationData *)lumixtether::DeviceAdapter::statusOfCards(DeviceAdapter);
  LODWORD(v68) = (_DWORD)v15;
  v16 = ApplicationData::getDeviceAdapter(v15);
  v17 = a6[1];
  v65[0] = *a6;
  v65[1] = v17;
  v65[2] = a6[2];
  if ( v65[0] )
    atomic_fetch_add(v65[0], 1u);
  StatusOfCards = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_GetStatusOfCards(v16, &v68, v65);
  v19 = (int)StatusOfCards;
  if ( v65[0] && atomic_fetch_add(v65[0], 0xFFFFFFFF) == 1 )
    StatusOfCards = (ApplicationData *)QArrayData::deallocate(v65[0], 2, 8);
  if ( v19 != 1 )
    goto LABEL_70;
  v20 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(StatusOfCards);
  v21 = (ApplicationData *)lumixtether::DeviceAdapter::fileTarget(v20);
  v67 = (int)v21;
  v22 = ApplicationData::getDeviceAdapter(v21);
  v23 = *a6;
  v24 = a6[1];
  v64[0] = v23;
  v64[1] = v24;
  v64[2] = a6[2];
  if ( v23 )
    atomic_fetch_add(v23, 1u);
  Target = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_SetupFilesConfig_Get_Target(v22, &v67, v64);
  v26 = (int)Target;
  if ( v64[0] && atomic_fetch_add(v64[0], 0xFFFFFFFF) == 1 )
    Target = (ApplicationData *)QArrayData::deallocate(v64[0], 2, 8);
  if ( v26 != 1 )
    goto LABEL_70;
  if ( (_DWORD)a3 != 1 || (_DWORD)v68 || v67 == 1 || v67 == 2 )
  {
    v30 = ApplicationData::getDeviceAdapter(Target);
    v31 = *a6;
    v32 = a6[1];
    v62[0] = v31;
    v62[1] = v32;
    v62[2] = a6[2];
    if ( v31 )
      atomic_fetch_add(v31, 1u);
    Object_AssociatDesc = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_AssociatDesc(
                                               v30,
                                               a2,
                                               (char *)&v68 + 4,
                                               v62);
    v34 = (int)Object_AssociatDesc;
    if ( v62[0] && atomic_fetch_add(v62[0], 0xFFFFFFFF) == 1 )
      Object_AssociatDesc = (ApplicationData *)QArrayData::deallocate(v62[0], 2, 8);
    if ( v34 != 1 )
      goto LABEL_70;
    v35 = ApplicationData::getDeviceAdapter(Object_AssociatDesc);
    v36 = *a6;
    v37 = a6[1];
    v61[0] = v36;
    v61[1] = v37;
    v61[2] = a6[2];
    if ( v36 )
      atomic_fetch_add(v36, 1u);
    objAssociatDesc = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_objAssociatDesc(v35, v61);
    v39 = (int)objAssociatDesc;
    if ( v61[0] && atomic_fetch_add(v61[0], 0xFFFFFFFF) == 1 )
      objAssociatDesc = (ApplicationData *)QArrayData::deallocate(v61[0], 2, 8);
    if ( (_DWORD)a3 != 1 || HIDWORD(v68) )
    {
      if ( v39 == HIDWORD(v68) )
      {
        v40 = 0;
LABEL_46:
        v41 = *a6;
        v42 = a6[1];
        v59[0] = v41;
        v59[1] = v42;
        v59[2] = a6[2];
        if ( v41 )
          atomic_fetch_add(v41, 1u);
        FileName = lumixtether::ObjectCopy::makeFileName(a3, v69, v70, v71, 1, a2, v40, v59);
        if ( v59[0] && atomic_fetch_add(v59[0], 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v59[0], 2, 8);
        if ( FileName )
        {
          memset(v58, 0, sizeof(v58));
          v44 = (ApplicationData *)QByteArray::resize((QByteArray *)v58, a4);
          v45 = ApplicationData::getDeviceAdapter(v44);
          v46 = sub_1000C19F8(v58);
          v47 = *a6;
          v48 = a6[1];
          v57[0] = v47;
          v57[1] = v48;
          v57[2] = a6[2];
          if ( v47 )
            atomic_fetch_add(v47, 1u);
          Object = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object(v45, a2, v46, a4, v57);
          if ( v57[0] && atomic_fetch_add(v57[0], 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v57[0], 2, 8);
          if ( Object == 1 )
          {
            QFile::QFile((QFile *)v56, (const QString *)v71);
            if ( (QFile::open(v56, 2) & 1) != 0 )
            {
              QIODevice::write((QIODevice *)v56, (const QByteArray *)v58);
              QFileDevice::close((QFileDevice *)v56);
              v50 = (ApplicationData *)QString::operator=(&v72, v71);
              if ( (_DWORD)a3 == 1 && !v7 )
              {
                v51 = ApplicationData::getDeviceAdapter(v50);
                v55[0] = v72;
                v55[1] = v73;
                v55[2] = v74;
                if ( v72 )
                  atomic_fetch_add(v72, 1u);
                lumixtether::DeviceAdapter::setPcSavedFilePath(v51, v55);
                if ( v55[0] && atomic_fetch_add(v55[0], 0xFFFFFFFF) == 1 )
                  QArrayData::deallocate(v55[0], 2, 8);
              }
            }
            QFile::~QFile((QFile *)v56);
          }
          if ( v58[0] && atomic_fetch_add(v58[0], 0xFFFFFFFF) == 1 )
          {
            v11 = v58[0];
            v12 = 1;
            goto LABEL_8;
          }
        }
        goto LABEL_70;
      }
      v52 = ApplicationData::getDeviceAdapter(objAssociatDesc);
      v53 = *a6;
      v54 = a6[1];
      v60[0] = v53;
      v60[1] = v54;
      v60[2] = a6[2];
      if ( v53 )
        atomic_fetch_add(v53, 1u);
      lumixtether::DeviceAdapter::camera_list_set_objAssociatDesc(v52, v60, HIDWORD(v68));
      if ( v60[0] && atomic_fetch_add(v60[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v60[0], 2, 8);
    }
    v40 = 1;
    goto LABEL_46;
  }
  v27 = ApplicationData::getDeviceAdapter(Target);
  v28 = *a6;
  v29 = a6[1];
  v63[0] = v28;
  v63[1] = v29;
  v63[2] = a6[2];
  if ( v28 )
    atomic_fetch_add(v28, 1u);
  lumixtether::DeviceAdapter::adp_LMX_func_api_Skip_Object_Transfer(v27, a2, v63);
  if ( v63[0] && atomic_fetch_add(v63[0], 0xFFFFFFFF) == 1 )
  {
    v11 = v63[0];
    goto LABEL_7;
  }
LABEL_70:
  if ( v69[0] && atomic_fetch_add(v69[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v69[0], 2, 8);
  if ( v70[0] && atomic_fetch_add(v70[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v70[0], 2, 8);
  if ( v71[0] && atomic_fetch_add(v71[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v71[0], 2, 8);
  if ( v72 )
  {
    if ( atomic_fetch_add(v72, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v72, 2, 8);
  }
}
