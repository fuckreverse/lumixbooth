// __ZN11lumixtether10ObjectCopy22startObjectReqTransferEi7QString @ 0x1000c82fc
ApplicationData *__fastcall lumixtether::ObjectCopy::startObjectReqTransfer(QObject *a1, int a2, atomic_uint **a3)
{
  QObject *v5; // x19
  QObject *v6; // x22
  __int64 DeviceAdapter; // x0
  __int64 v8; // x1
  atomic_uint *v9; // x9
  ApplicationData *result; // x0
  int v11; // w21
  __int64 v12; // x0
  __int64 v13; // x1
  atomic_uint *v14; // x9
  int v15; // w21
  __int64 v16; // x0
  __int64 v17; // x1
  atomic_uint *v18; // x9
  int v19; // w21
  __int64 v20; // x0
  __int64 v21; // x1
  __int64 v22; // x2
  __int64 v23; // x4
  __int64 v24; // x3
  atomic_uint *v25; // x8
  atomic_uint *v26; // x9
  atomic_uint **v27; // x8
  __int64 v28; // x0
  __int64 v29; // x1
  atomic_uint *v30; // x8
  atomic_uint *v31; // x9
  int v32; // w21
  __int64 v33; // x0
  __int64 v34; // x1
  __int64 v35; // x2
  __int64 v36; // x4
  __int64 v37; // x3
  atomic_uint *v38; // x8
  atomic_uint *v39; // x9
  __int64 v40; // x0
  __int64 v41; // x1
  atomic_uint *v42; // x8
  atomic_uint *v43; // x9
  int v44; // w21
  __int64 v45; // x0
  __int64 v46; // x1
  __int64 v47; // x2
  __int64 v48; // x4
  __int64 v49; // x3
  atomic_uint *v50; // x8
  atomic_uint *v51; // x9
  __int64 v52; // x0
  __int64 v53; // x1
  atomic_uint *v54; // x8
  atomic_uint *v55; // x9
  int v56; // w21
  __int64 v57; // x0
  __int64 v58; // x1
  __int64 v59; // x2
  __int64 v60; // x4
  __int64 v61; // x3
  atomic_uint *v62; // x8
  atomic_uint *v63; // x9
  atomic_uint *v64[3]; // [xsp+0h] [xbp-130h] BYREF
  atomic_uint *v65[3]; // [xsp+18h] [xbp-118h] BYREF
  atomic_uint *v66[3]; // [xsp+30h] [xbp-100h] BYREF
  atomic_uint *v67[3]; // [xsp+48h] [xbp-E8h] BYREF
  atomic_uint *v68[3]; // [xsp+60h] [xbp-D0h] BYREF
  atomic_uint *v69[3]; // [xsp+78h] [xbp-B8h] BYREF
  atomic_uint *v70[3]; // [xsp+90h] [xbp-A0h] BYREF
  atomic_uint *v71[3]; // [xsp+A8h] [xbp-88h] BYREF
  atomic_uint *v72[3]; // [xsp+C0h] [xbp-70h] BYREF
  atomic_uint *v73[3]; // [xsp+D8h] [xbp-58h] BYREF
  __int64 v74; // [xsp+F0h] [xbp-40h] BYREF
  __int64 v75; // [xsp+F8h] [xbp-38h] BYREF

  v5 = a1;
  v74 = 0;
  v75 = 0;
  if ( !*((_QWORD *)a1 + 7) )
  {
    v6 = (QObject *)operator new(0x88u);
    a1 = QObject::QObject(v6, nullptr);
    *(_QWORD *)v6 = &off_1009ED470;
    *((_QWORD *)v6 + 15) = 0;
    *((_OWORD *)v6 + 1) = 0u;
    *((_OWORD *)v6 + 2) = 0u;
    *((_OWORD *)v6 + 3) = 0u;
    *((_OWORD *)v6 + 4) = 0u;
    *((_OWORD *)v6 + 5) = 0u;
    *((_OWORD *)v6 + 6) = 0u;
    *((_QWORD *)v5 + 7) = v6;
  }
  *((_DWORD *)v5 + 6) = a2;
  DeviceAdapter = ApplicationData::getDeviceAdapter(a1);
  v8 = *((unsigned int *)v5 + 6);
  v9 = a3[1];
  v73[0] = *a3;
  v73[1] = v9;
  v73[2] = a3[2];
  if ( v73[0] )
    atomic_fetch_add(v73[0], 1u);
  result = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_AssociatType(
                                DeviceAdapter,
                                v8,
                                &v74,
                                v73);
  v11 = (int)result;
  if ( v73[0] && atomic_fetch_add(v73[0], 0xFFFFFFFF) == 1 )
    result = (ApplicationData *)QArrayData::deallocate(v73[0], 2, 8);
  if ( v11 == 1 )
  {
    v12 = ApplicationData::getDeviceAdapter(result);
    v13 = *((unsigned int *)v5 + 6);
    v14 = a3[1];
    v72[0] = *a3;
    v72[1] = v14;
    v72[2] = a3[2];
    if ( v72[0] )
      atomic_fetch_add(v72[0], 1u);
    result = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_FormatType(
                                  v12,
                                  v13,
                                  (char *)&v74 + 4,
                                  v72);
    v15 = (int)result;
    if ( v72[0] && atomic_fetch_add(v72[0], 0xFFFFFFFF) == 1 )
      result = (ApplicationData *)QArrayData::deallocate(v72[0], 2, 8);
    if ( v15 == 1 )
    {
      switch ( HIDWORD(v74) )
      {
        case 1:
          v16 = ApplicationData::getDeviceAdapter(result);
          v17 = *((unsigned int *)v5 + 6);
          v18 = a3[1];
          v71[0] = *a3;
          v71[1] = v18;
          v71[2] = a3[2];
          if ( v71[0] )
            atomic_fetch_add(v71[0], 1u);
          result = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(
                                        v16,
                                        v17,
                                        &v75,
                                        v71);
          v19 = (int)result;
          if ( v71[0] && atomic_fetch_add(v71[0], 0xFFFFFFFF) == 1 )
            result = (ApplicationData *)QArrayData::deallocate(v71[0], 2, 8);
          if ( v19 == 1 )
          {
            v20 = *((_QWORD *)v5 + 7);
            v21 = *((unsigned int *)v5 + 6);
            v23 = (unsigned int)v74;
            v22 = HIDWORD(v74);
            v24 = v75;
            v25 = *a3;
            v26 = a3[1];
            v70[0] = v25;
            v70[1] = v26;
            v70[2] = a3[2];
            if ( v25 )
              atomic_fetch_add(v25, 1u);
            result = (ApplicationData *)ObjectReqTransfer::saveObject(v20, v21, v22, v24, v23, v70);
            if ( v70[0] && atomic_fetch_add(v70[0], 0xFFFFFFFF) == 1 )
            {
              v27 = v70;
              goto LABEL_60;
            }
            goto LABEL_61;
          }
          break;
        case 2:
          v28 = ApplicationData::getDeviceAdapter(result);
          v29 = *((unsigned int *)v5 + 6);
          v30 = *a3;
          v31 = a3[1];
          v69[0] = v30;
          v69[1] = v31;
          v69[2] = a3[2];
          if ( v30 )
            atomic_fetch_add(v30, 1u);
          result = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(
                                        v28,
                                        v29,
                                        &v75,
                                        v69);
          v32 = (int)result;
          if ( v69[0] && atomic_fetch_add(v69[0], 0xFFFFFFFF) == 1 )
            result = (ApplicationData *)QArrayData::deallocate(v69[0], 2, 8);
          if ( v32 == 1 )
          {
            v33 = *((_QWORD *)v5 + 7);
            v34 = *((unsigned int *)v5 + 6);
            v36 = (unsigned int)v74;
            v35 = HIDWORD(v74);
            v37 = v75;
            v38 = *a3;
            v39 = a3[1];
            v68[0] = v38;
            v68[1] = v39;
            v68[2] = a3[2];
            if ( v38 )
              atomic_fetch_add(v38, 1u);
            result = (ApplicationData *)ObjectReqTransfer::saveRAW(v33, v34, v35, v37, v36, v68);
            if ( v68[0] && atomic_fetch_add(v68[0], 0xFFFFFFFF) == 1 )
            {
              v27 = v68;
              goto LABEL_60;
            }
            goto LABEL_61;
          }
          break;
        case 6:
          v40 = ApplicationData::getDeviceAdapter(result);
          v41 = *((unsigned int *)v5 + 6);
          v42 = *a3;
          v43 = a3[1];
          v67[0] = v42;
          v67[1] = v43;
          v67[2] = a3[2];
          if ( v42 )
            atomic_fetch_add(v42, 1u);
          result = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(
                                        v40,
                                        v41,
                                        &v75,
                                        v67);
          v44 = (int)result;
          if ( v67[0] && atomic_fetch_add(v67[0], 0xFFFFFFFF) == 1 )
            result = (ApplicationData *)QArrayData::deallocate(v67[0], 2, 8);
          if ( v44 == 1 )
          {
            v45 = *((_QWORD *)v5 + 7);
            v46 = *((unsigned int *)v5 + 6);
            v48 = (unsigned int)v74;
            v47 = HIDWORD(v74);
            v49 = v75;
            v50 = *a3;
            v51 = a3[1];
            v66[0] = v50;
            v66[1] = v51;
            v66[2] = a3[2];
            if ( v50 )
              atomic_fetch_add(v50, 1u);
            result = (ApplicationData *)ObjectReqTransfer::saveHLG(v45, v46, v47, v49, v48, v66);
            if ( v66[0] && atomic_fetch_add(v66[0], 0xFFFFFFFF) == 1 )
            {
              v27 = v66;
              goto LABEL_60;
            }
            goto LABEL_61;
          }
          break;
        case 7:
          v52 = ApplicationData::getDeviceAdapter(result);
          v53 = *((unsigned int *)v5 + 6);
          v54 = *a3;
          v55 = a3[1];
          v65[0] = v54;
          v65[1] = v55;
          v65[2] = a3[2];
          if ( v54 )
            atomic_fetch_add(v54, 1u);
          result = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_DataSize(
                                        v52,
                                        v53,
                                        &v75,
                                        v65);
          v56 = (int)result;
          if ( v65[0] && atomic_fetch_add(v65[0], 0xFFFFFFFF) == 1 )
            result = (ApplicationData *)QArrayData::deallocate(v65[0], 2, 8);
          if ( v56 == 1 )
          {
            v57 = *((_QWORD *)v5 + 7);
            v58 = *((unsigned int *)v5 + 6);
            v60 = (unsigned int)v74;
            v59 = HIDWORD(v74);
            v61 = v75;
            v62 = *a3;
            v63 = a3[1];
            v64[0] = v62;
            v64[1] = v63;
            v64[2] = a3[2];
            if ( v62 )
              atomic_fetch_add(v62, 1u);
            result = (ApplicationData *)ObjectReqTransfer::saveHEIF(v57, v58, v59, v61, v60, v64);
            if ( v64[0] && atomic_fetch_add(v64[0], 0xFFFFFFFF) == 1 )
            {
              v27 = v64;
LABEL_60:
              result = (ApplicationData *)QArrayData::deallocate(*v27, 2, 8);
            }
LABEL_61:
            if ( !*((_DWORD *)v5 + 12) )
            {
              *(_QWORD *)(*((_QWORD *)v5 + 7) + 112LL) = v5;
              *((_DWORD *)v5 + 12) = 1;
            }
          }
          break;
        default:
          return result;
      }
    }
  }
  return result;
}
