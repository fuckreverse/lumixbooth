// __ZN11lumixtether10ObjectCopy12makeFileNameEjR7QStringS2_S2_iibS1_ @ 0x1000beb58
__int64 __fastcall lumixtether::ObjectCopy::makeFileName(
        int a1,
        __int64 a2,
        atomic_uint **a3,
        __int64 a4,
        int a5,
        unsigned int a6,
        int a7,
        atomic_uint **a8)
{
  atomic_uint *v14; // x19
  atomic_uint *v15; // x20
  atomic_uint *v16; // x27
  atomic_uint *v17; // x0
  ApplicationData *v18; // x0
  __int64 DeviceAdapter; // x0
  ApplicationData *camera_serialNo_DisplayList; // x0
  unsigned __int128 v21; // kr00_16
  atomic_uint *v22; // x9
  lumixtether::DeviceAdapter *v23; // x0
  ApplicationData *v24; // x0
  unsigned __int128 v25; // kr10_16
  atomic_uint *v26; // x9
  lumixtether::DeviceAdapter *v27; // x0
  unsigned __int128 v28; // kr20_16
  atomic_uint *v29; // x24
  __int64 ApplicationSettings; // x0
  ApplicationData *StoreLocationTypeFromFile; // x0
  int v32; // w23
  lumixtether::ApplicationSettings *v33; // x0
  ApplicationData *v34; // x0
  lumixtether::ApplicationSettings *v35; // x0
  ApplicationData *v36; // x0
  atomic_uint *v37; // x8
  atomic_uint *v38; // x9
  atomic_uint *v39; // x9
  lumixtether::ApplicationSettings *v40; // x0
  ApplicationData *v41; // x0
  lumixtether::ApplicationSettings *v42; // x0
  ApplicationData *v43; // x0
  int v44; // w26
  unsigned __int128 v45; // q0
  atomic_uint *v46; // x9
  atomic_uint *v47; // x21
  atomic_uint *volatile *v48; // x23
  atomic_uint *v49; // x8
  __int64 v50; // x24
  QDate *v51; // x0
  unsigned __int128 v52; // kr40_16
  atomic_uint *v53; // x24
  void *v54; // x2
  __int64 v55; // x0
  void *v56; // x0
  ApplicationData *v57; // x0
  __int64 v58; // x0
  unsigned __int128 v59; // kr50_16
  atomic_uint *v60; // x9
  atomic_uint *volatile *v61; // x21
  __int64 v62; // x23
  ApplicationData *v63; // x0
  lumixtether::ApplicationSettings *v64; // x0
  ApplicationData *v65; // x0
  QDate *v66; // x0
  unsigned __int128 v67; // kr60_16
  atomic_uint *v68; // x24
  void *v69; // x2
  lumixtether::ApplicationSettings *v70; // x0
  ApplicationData *v71; // x0
  __int64 v72; // x21
  int v73; // w24
  ApplicationData *v74; // x0
  unsigned __int128 v75; // kr70_16
  atomic_uint *v76; // x9
  lumixtether::ApplicationSettings *v77; // x0
  atomic_uint *v78; // x8
  __int64 v79; // x0
  void *v80; // x0
  ApplicationData *v81; // x0
  __int64 v82; // x0
  unsigned __int128 v83; // kr80_16
  atomic_uint *v84; // x9
  ApplicationData *v85; // x0
  unsigned __int128 v86; // kr90_16
  atomic_uint *v87; // x9
  lumixtether::ApplicationSettings *v88; // x0
  ApplicationData *v89; // x0
  unsigned __int128 v90; // krA0_16
  atomic_uint *v91; // x9
  lumixtether::ApplicationSettings *v92; // x0
  int v93; // w21
  ApplicationData *v94; // x0
  ApplicationData *v95; // x0
  unsigned __int128 v96; // krB0_16
  atomic_uint *v97; // x9
  lumixtether::ApplicationSettings *v98; // x0
  ApplicationData *v99; // x0
  unsigned __int128 v100; // krC0_16
  atomic_uint *v101; // x9
  lumixtether::ApplicationSettings *v102; // x0
  ApplicationData *v103; // x0
  unsigned __int128 v104; // krD0_16
  atomic_uint *v105; // x9
  lumixtether::ApplicationSettings *v106; // x0
  __int64 v107; // x0
  ApplicationData *objCopyFileNumber; // x0
  ApplicationData *v109; // x21
  lumixtether::ApplicationSettings *v110; // x0
  __int64 v111; // x0
  ApplicationData *v112; // x0
  ApplicationData *v113; // x21
  lumixtether::ApplicationSettings *v114; // x0
  __int64 v115; // x0
  ApplicationData *v116; // x0
  ApplicationData *v117; // x21
  lumixtether::ApplicationSettings *v118; // x0
  __int64 v119; // x0
  ApplicationData *v120; // x0
  ApplicationData *v121; // x21
  lumixtether::ApplicationSettings *v122; // x0
  unsigned __int128 v123; // krE0_16
  atomic_uint *v124; // x9
  lumixtether::ApplicationSettings *v125; // x0
  ApplicationData *v126; // x0
  lumixtether::ApplicationSettings *v127; // x0
  __int64 *Object_FileName; // x0
  int v129; // w28
  __int64 v130; // x0
  int v131; // w21
  size_t v132; // x0
  ApplicationData *v133; // x0
  unsigned __int128 v134; // krF0_16
  atomic_uint *v135; // x9
  int v136; // w21
  lumixtether::ApplicationSettings *v137; // x0
  atomic_uint *v138; // x21
  lumixtether::ApplicationSettings *v139; // x0
  unsigned __int128 v140; // kr100_16
  atomic_uint *v141; // x9
  __int64 v142; // x0
  __int64 v143; // x21
  ApplicationData *DriveMode; // x0
  lumixtether::ApplicationSettings *v145; // x0
  ApplicationData *v146; // x0
  lumixtether::ApplicationSettings *v147; // x0
  ApplicationData *v148; // x0
  lumixtether::ApplicationSettings *v149; // x0
  lumixtether::ApplicationSettings *v150; // x0
  lumixtether::ApplicationSettings *v151; // x0
  lumixtether::ApplicationSettings *v152; // x0
  __int64 v153; // x0
  void *v154; // x0
  ApplicationData *v155; // x0
  __int64 v156; // x0
  unsigned __int128 v157; // kr110_16
  atomic_uint *v158; // x9
  unsigned __int128 v159; // kr120_16
  atomic_uint *v160; // x9
  atomic_uint *v161; // x20
  int v162; // w24
  __int64 v163; // x25
  __int64 v164; // x21
  unsigned __int128 v165; // kr130_16
  atomic_uint *v166; // x9
  unsigned __int128 v167; // kr140_16
  atomic_uint *v168; // x9
  unsigned __int128 v169; // kr150_16
  atomic_uint *v170; // x9
  __int64 v171; // x0
  __int64 v172; // x0
  __int64 v173; // x0
  atomic_uint *v174; // x8
  __int64 v175; // x9
  atomic_uint *v176; // x9
  ApplicationData *v177; // x0
  __int64 v178; // x0
  atomic_uint *volatile *v179; // x19
  __int64 v180; // x20
  int v182; // w21
  int v183; // w21
  int v184; // w21
  lumixtether::ApplicationSettings *v185; // x0
  unsigned __int128 v186; // kr160_16
  atomic_uint *v187; // x9
  lumixtether::ApplicationSettings *v188; // x0
  ApplicationData *v189; // x0
  int v190; // w0
  unsigned __int128 v191; // kr170_16
  atomic_uint *v192; // x9
  atomic_uint *v193; // x8
  __int64 v194; // x9
  atomic_uint *v195; // x9
  lumixtether::ApplicationSettings *v196; // x0
  ApplicationData *v197; // x0
  __int64 v198; // x0
  void *v199; // x0
  ApplicationData *v200; // x0
  __int64 v201; // x0
  unsigned __int128 v202; // kr180_16
  atomic_uint *v203; // x9
  atomic_uint *v204; // [xsp+10h] [xbp-4B0h]
  int v206; // [xsp+18h] [xbp-4A8h]
  int v207; // [xsp+1Ch] [xbp-4A4h]
  __int64 v209; // [xsp+28h] [xbp-498h]
  int v210; // [xsp+30h] [xbp-490h]
  __int64 v211; // [xsp+30h] [xbp-490h]
  atomic_uint *v212[3]; // [xsp+38h] [xbp-488h] BYREF
  unsigned __int128 v213; // [xsp+50h] [xbp-470h] BYREF
  atomic_uint *v214; // [xsp+60h] [xbp-460h]
  unsigned __int128 v215; // [xsp+68h] [xbp-458h] BYREF
  atomic_uint *v216; // [xsp+78h] [xbp-448h]
  atomic_uint *v217[3]; // [xsp+80h] [xbp-440h] BYREF
  atomic_uint *v218[3]; // [xsp+98h] [xbp-428h] BYREF
  atomic_uint *v219[3]; // [xsp+B0h] [xbp-410h] BYREF
  int v220; // [xsp+CCh] [xbp-3F4h] BYREF
  atomic_uint *v221[3]; // [xsp+D0h] [xbp-3F0h] BYREF
  atomic_uint *v222[3]; // [xsp+E8h] [xbp-3D8h] BYREF
  atomic_uint *v223[3]; // [xsp+100h] [xbp-3C0h] BYREF
  atomic_uint *v224[3]; // [xsp+118h] [xbp-3A8h] BYREF
  atomic_uint *v225[3]; // [xsp+130h] [xbp-390h] BYREF
  atomic_uint *v226[3]; // [xsp+148h] [xbp-378h] BYREF
  atomic_uint *v227[3]; // [xsp+160h] [xbp-360h] BYREF
  atomic_uint *v228[3]; // [xsp+178h] [xbp-348h] BYREF
  atomic_uint *v229[3]; // [xsp+190h] [xbp-330h] BYREF
  __int64 v230; // [xsp+1A8h] [xbp-318h] BYREF
  atomic_uint *v231[3]; // [xsp+1B0h] [xbp-310h] BYREF
  atomic_uint *v232[3]; // [xsp+1C8h] [xbp-2F8h] BYREF
  __int64 v233; // [xsp+1E0h] [xbp-2E0h] BYREF
  unsigned __int128 v234; // [xsp+1E8h] [xbp-2D8h] BYREF
  atomic_uint *v235; // [xsp+1F8h] [xbp-2C8h]
  unsigned __int128 v236; // [xsp+200h] [xbp-2C0h] BYREF
  atomic_uint *v237; // [xsp+210h] [xbp-2B0h]
  atomic_uint *v238[3]; // [xsp+218h] [xbp-2A8h] BYREF
  unsigned __int128 v239; // [xsp+230h] [xbp-290h] BYREF
  atomic_uint *v240; // [xsp+240h] [xbp-280h]
  unsigned __int128 v241; // [xsp+248h] [xbp-278h] BYREF
  atomic_uint *v242; // [xsp+258h] [xbp-268h]
  char v243[8]; // [xsp+260h] [xbp-260h] BYREF
  unsigned __int128 v244; // [xsp+268h] [xbp-258h] BYREF
  atomic_uint *v245; // [xsp+278h] [xbp-248h]
  unsigned __int128 v246; // [xsp+280h] [xbp-240h] BYREF
  atomic_uint *v247; // [xsp+290h] [xbp-230h]
  atomic_uint *v248[3]; // [xsp+298h] [xbp-228h] BYREF
  unsigned __int128 v249; // [xsp+2B0h] [xbp-210h] BYREF
  atomic_uint *v250; // [xsp+2C0h] [xbp-200h]
  unsigned __int128 v251; // [xsp+2C8h] [xbp-1F8h] BYREF
  atomic_uint *v252; // [xsp+2D8h] [xbp-1E8h]
  unsigned __int128 v253; // [xsp+2E0h] [xbp-1E0h] BYREF
  atomic_uint *v254; // [xsp+2F0h] [xbp-1D0h]
  unsigned __int128 v255; // [xsp+2F8h] [xbp-1C8h] BYREF
  atomic_uint *v256; // [xsp+308h] [xbp-1B8h]
  unsigned __int128 v257; // [xsp+310h] [xbp-1B0h] BYREF
  atomic_uint *v258; // [xsp+320h] [xbp-1A0h]
  unsigned __int128 v259; // [xsp+328h] [xbp-198h]
  atomic_uint *v260; // [xsp+338h] [xbp-188h]
  unsigned __int128 v261; // [xsp+340h] [xbp-180h] BYREF
  atomic_uint *v262; // [xsp+350h] [xbp-170h]
  atomic_uint *v263[33]; // [xsp+358h] [xbp-168h] BYREF

  v259 = 0u;
  v260 = nullptr;
  v257 = 0u;
  v258 = nullptr;
  v255 = 0u;
  v256 = nullptr;
  v253 = 0u;
  v254 = nullptr;
  v251 = 0u;
  v252 = nullptr;
  v249 = 0u;
  v250 = nullptr;
  memset(v248, 0, sizeof(v248));
  v246 = 0u;
  v247 = nullptr;
  v244 = 0u;
  v245 = nullptr;
  memset(v263, 0, 24);
  QDir::QDir((QDir *)v243, (const QString *)v263);
  v209 = a2;
  v207 = a5;
  if ( v263[0] && atomic_fetch_add(v263[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v263[0], 2, 8);
  v14 = *a8;
  v15 = a8[1];
  v16 = a8[2];
  if ( *a8 )
    atomic_fetch_add(v14, 1u);
  QString::fromUtf8(&v261, 1, "/");
  v241 = v261;
  v242 = v262;
  QString::fromUtf8(&v261, 0, &unk_10014269A);
  v239 = v261;
  v240 = v262;
  if ( v15 )
    v17 = v15;
  else
    v17 = (atomic_uint *)&QString::_empty;
  v18 = (ApplicationData *)QString::compare_helper(v17, v16, &unk_10014269A, -1, 1);
  v210 = a1;
  if ( (_DWORD)v18 )
  {
    DeviceAdapter = ApplicationData::getDeviceAdapter(v18);
    v238[0] = v14;
    v238[1] = v15;
    v238[2] = v16;
    if ( v14 )
      atomic_fetch_add(v14, 1u);
    camera_serialNo_DisplayList = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_camera_serialNo_DisplayList(
                                                       &v261,
                                                       DeviceAdapter,
                                                       v238);
    v21 = v239;
    v239 = v261;
    v261 = v21;
    v22 = v240;
    v240 = v262;
    v262 = v22;
    if ( (_QWORD)v21 && atomic_fetch_add((atomic_uint *volatile)v21, 0xFFFFFFFF) == 1 )
      camera_serialNo_DisplayList = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
    if ( v238[0] && atomic_fetch_add(v238[0], 0xFFFFFFFF) == 1 )
      camera_serialNo_DisplayList = (ApplicationData *)QArrayData::deallocate(v238[0], 2, 8);
  }
  else
  {
    v23 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(v18);
    v24 = (ApplicationData *)lumixtether::DeviceAdapter::camCurrentSelectedSerialNo((__int64 *)&v261, v23);
    v25 = v239;
    v239 = v261;
    v261 = v25;
    v26 = v240;
    v240 = v262;
    v262 = v26;
    if ( (_QWORD)v25 && atomic_fetch_add((atomic_uint *volatile)v25, 0xFFFFFFFF) == 1 )
      v24 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
    v27 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(v24);
    camera_serialNo_DisplayList = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_selected_camera_uuid(
                                                       (__int64 *)&v261,
                                                       v27);
    v28 = v261;
    *(_QWORD *)&v261 = v14;
    *((_QWORD *)&v261 + 1) = v15;
    v29 = v262;
    v262 = v16;
    if ( v14 && atomic_fetch_add(v14, 0xFFFFFFFF) == 1 )
      camera_serialNo_DisplayList = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
    v15 = (atomic_uint *)(v28 >> 64);
    v14 = (atomic_uint *)v28;
    v16 = v29;
  }
  ApplicationSettings = ApplicationData::getApplicationSettings(camera_serialNo_DisplayList);
  v236 = v239;
  v237 = v240;
  if ( (_QWORD)v239 )
    atomic_fetch_add((atomic_uint *volatile)v239, 1u);
  StoreLocationTypeFromFile = (ApplicationData *)lumixtether::ApplicationSettings::getStoreLocationTypeFromFile(
                                                   ApplicationSettings,
                                                   &v236);
  v32 = (int)StoreLocationTypeFromFile;
  if ( (_QWORD)v236 && atomic_fetch_add((atomic_uint *volatile)v236, 0xFFFFFFFF) == 1 )
    StoreLocationTypeFromFile = (ApplicationData *)QArrayData::deallocate(v236, 2, 8);
  v33 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(StoreLocationTypeFromFile);
  v34 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderType(v33);
  if ( (_DWORD)v34 )
  {
    if ( (_DWORD)v34 == 1 )
    {
      v35 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v34);
      v36 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderUrl((__int64 *)&v261, v35);
      v37 = *a3;
      v38 = a3[1];
      *(_OWORD *)a3 = v261;
      *(_QWORD *)&v261 = v37;
      *((_QWORD *)&v261 + 1) = v38;
      v39 = a3[2];
      a3[2] = v262;
      v262 = v39;
      if ( v37 && atomic_fetch_add(v37, 0xFFFFFFFF) == 1 )
        v36 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      v40 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v36);
      v41 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderDate(v40);
      if ( !(_DWORD)v41 )
      {
        v51 = (QDate *)QString::append((QString *)a3, (const QString *)&v241);
        *(_QWORD *)&v215 = QDate::currentDate(v51);
        QString::fromUtf8(&v261, 8, "yyyyMMdd");
        v52 = v261;
        v53 = v262;
        QCalendar::QCalendar((QCalendar *)&v230);
        if ( *((_QWORD *)&v52 + 1) )
          v54 = *((void **)&v52 + 1);
        else
          v54 = &QString::_empty;
        QDate::toString(&v234, &v215, v53, v54, v230);
        v41 = (ApplicationData *)QString::append((QString *)a3, (const QString *)&v234);
        if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
          v41 = (ApplicationData *)QArrayData::deallocate(v234, 2, 8);
        if ( (_QWORD)v52 && atomic_fetch_add((atomic_uint *volatile)v52, 0xFFFFFFFF) == 1 )
          v41 = (ApplicationData *)QArrayData::deallocate(v52, 2, 8);
      }
      v42 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v41);
      v43 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderCamera(v42);
      if ( !(_DWORD)v43 )
      {
        v55 = ApplicationData::getDeviceAdapter(v43);
        v229[0] = v14;
        v229[1] = v15;
        v229[2] = v16;
        if ( v14 )
          atomic_fetch_add(v14, 1u);
        lumixtether::DeviceAdapter::camera_list_get_camera_individual_id(&v234, v55, v229);
        if ( v229[0] && atomic_fetch_add(v229[0], 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v229[0], 2, 8);
        if ( *((_QWORD *)&v234 + 1) )
          v56 = *((void **)&v234 + 1);
        else
          v56 = &QString::_empty;
        v57 = (ApplicationData *)QString::compare_helper(v56, v235, &unk_10014269A, -1, 1);
        if ( !(_DWORD)v57 )
        {
          v58 = ApplicationData::getDeviceAdapter(v57);
          v228[0] = v14;
          v228[1] = v15;
          v228[2] = v16;
          if ( v14 )
            atomic_fetch_add(v14, 1u);
          lumixtether::DeviceAdapter::camera_list_get_camera_modelName(&v261, v58, v228);
          v59 = v234;
          v234 = v261;
          v261 = v59;
          v60 = v235;
          v235 = v262;
          v262 = v60;
          if ( (_QWORD)v59 && atomic_fetch_add((atomic_uint *volatile)v59, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v261, 2, 8);
          if ( v228[0] && atomic_fetch_add(v228[0], 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v228[0], 2, 8);
          QString::fromUtf8(&v261, 1, "_");
          QString::append((QString *)&v234, (const QString *)&v261);
          if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v261, 2, 8);
          QString::append((QString *)&v234, (const QString *)&v239);
        }
        QString::append((QString *)a3, (const QString *)&v241);
        QString::append((QString *)a3, (const QString *)&v234);
        if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v234, 2, 8);
      }
      QDir::mkpath((QDir *)v243, (const QString *)a3);
      goto LABEL_102;
    }
LABEL_108:
    v72 = 0;
LABEL_109:
    v78 = (atomic_uint *)v239;
    if ( (_QWORD)v239 )
      goto LABEL_420;
    goto LABEL_422;
  }
  v44 = v32;
  QStandardPaths::standardLocations(&v261, 6);
  v45 = v261;
  v46 = v262;
  v262 = nullptr;
  v261 = 0u;
  v48 = *((atomic_uint *volatile **)&v259 + 1);
  v47 = (atomic_uint *)v259;
  v259 = v45;
  v49 = v260;
  v260 = v46;
  if ( v47 && atomic_fetch_add(v47, 0xFFFFFFFF) == 1 )
  {
    if ( v49 )
    {
      v50 = 24LL * (_QWORD)v49;
      do
      {
        if ( *v48 && atomic_fetch_add(*v48, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(*v48, 2, 8);
        v48 += 3;
        v50 -= 24;
      }
      while ( v50 );
    }
    QArrayData::deallocate(v47, 24, 8);
  }
  if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
  {
    if ( v262 )
    {
      v61 = *((atomic_uint *volatile **)&v261 + 1);
      v62 = 24LL * (_QWORD)v262;
      do
      {
        if ( *v61 && atomic_fetch_add(*v61, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(*v61, 2, 8);
        v61 += 3;
        v62 -= 24;
      }
      while ( v62 );
    }
    QArrayData::deallocate(v261, 24, 8);
  }
  if ( !v260 )
    goto LABEL_108;
  v63 = (ApplicationData *)QString::operator=(a3, *((_QWORD *)&v259 + 1));
  v64 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v63);
  v32 = v44;
  v65 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderDate(v64);
  if ( !(_DWORD)v65 )
  {
    v66 = (QDate *)QString::append((QString *)a3, (const QString *)&v241);
    *(_QWORD *)&v215 = QDate::currentDate(v66);
    QString::fromUtf8(&v261, 8, "yyyyMMdd");
    v67 = v261;
    v68 = v262;
    QCalendar::QCalendar((QCalendar *)&v233);
    if ( *((_QWORD *)&v67 + 1) )
      v69 = *((void **)&v67 + 1);
    else
      v69 = &QString::_empty;
    QDate::toString(&v234, &v215, v68, v69, v233);
    QString::append((QString *)a3, (const QString *)&v234);
    v32 = v44;
    if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v234, 2, 8);
    if ( (_QWORD)v67 && atomic_fetch_add((atomic_uint *volatile)v67, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v67, 2, 8);
    v65 = (ApplicationData *)QDir::mkpath((QDir *)v243, (const QString *)a3);
  }
  v70 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v65);
  v71 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderCamera(v70);
  if ( !(_DWORD)v71 )
  {
    v79 = ApplicationData::getDeviceAdapter(v71);
    v232[0] = v14;
    v232[1] = v15;
    v232[2] = v16;
    if ( v14 )
      atomic_fetch_add(v14, 1u);
    lumixtether::DeviceAdapter::camera_list_get_camera_individual_id(&v234, v79, v232);
    if ( v232[0] && atomic_fetch_add(v232[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v232[0], 2, 8);
    if ( *((_QWORD *)&v234 + 1) )
      v80 = *((void **)&v234 + 1);
    else
      v80 = &QString::_empty;
    v81 = (ApplicationData *)QString::compare_helper(v80, v235, &unk_10014269A, -1, 1);
    if ( !(_DWORD)v81 )
    {
      v82 = ApplicationData::getDeviceAdapter(v81);
      v231[0] = v14;
      v231[1] = v15;
      v231[2] = v16;
      if ( v14 )
        atomic_fetch_add(v14, 1u);
      lumixtether::DeviceAdapter::camera_list_get_camera_modelName(&v261, v82, v231);
      v83 = v234;
      v234 = v261;
      v261 = v83;
      v84 = v235;
      v235 = v262;
      v262 = v84;
      if ( (_QWORD)v83 && atomic_fetch_add((atomic_uint *volatile)v83, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v261, 2, 8);
      if ( v231[0] && atomic_fetch_add(v231[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v231[0], 2, 8);
      QString::fromUtf8(&v261, 1, "_");
      QString::append((QString *)&v234, (const QString *)&v261);
      if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v261, 2, 8);
      QString::append((QString *)&v234, (const QString *)&v239);
    }
    QString::append((QString *)a3, (const QString *)&v241);
    QString::append((QString *)a3, (const QString *)&v234);
    QDir::mkpath((QDir *)v243, (const QString *)a3);
    if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v234, 2, 8);
  }
LABEL_102:
  QDir::setPath((QDir *)v243, (const QString *)a3);
  v72 = 0;
  v73 = v210 - 1;
  switch ( v210 )
  {
    case 1:
      v74 = (ApplicationData *)QString::fromUtf8(&v261, 4, "IMG_");
      v75 = v246;
      v246 = v261;
      v261 = v75;
      v76 = v247;
      v247 = v262;
      v262 = v76;
      if ( (_QWORD)v75 && atomic_fetch_add((atomic_uint *volatile)v75, 0xFFFFFFFF) == 1 )
        v74 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      if ( a7 )
      {
        v77 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v74);
        v211 = (unsigned int)lumixtether::ApplicationSettings::fileNumber(v77) + 1;
      }
      else
      {
        v107 = ApplicationData::getDeviceAdapter(v74);
        v227[0] = v14;
        v227[1] = v15;
        v227[2] = v16;
        if ( v14 )
          atomic_fetch_add(v14, 1u);
        objCopyFileNumber = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_objCopyFileNumber(v107, v227);
        v109 = objCopyFileNumber;
        if ( v227[0] && atomic_fetch_add(v227[0], 0xFFFFFFFF) == 1 )
          objCopyFileNumber = (ApplicationData *)QArrayData::deallocate(v227[0], 2, 8);
        v211 = (__int64)v109;
        if ( (_DWORD)v109 == -1 )
        {
          v110 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(objCopyFileNumber);
          v211 = lumixtether::ApplicationSettings::fileNumber(v110);
        }
      }
      v94 = (ApplicationData *)QString::fromUtf8(&v261, 4, ".jpg");
      break;
    case 2:
      v85 = (ApplicationData *)QString::fromUtf8(&v261, 4, "IMG_");
      v86 = v246;
      v246 = v261;
      v261 = v86;
      v87 = v247;
      v247 = v262;
      v262 = v87;
      if ( (_QWORD)v86 && atomic_fetch_add((atomic_uint *volatile)v86, 0xFFFFFFFF) == 1 )
        v85 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      if ( a7 )
      {
        v88 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v85);
        v211 = (unsigned int)lumixtether::ApplicationSettings::fileNumber(v88) + 1;
      }
      else
      {
        v111 = ApplicationData::getDeviceAdapter(v85);
        v226[0] = v14;
        v226[1] = v15;
        v226[2] = v16;
        if ( v14 )
          atomic_fetch_add(v14, 1u);
        v112 = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_objCopyFileNumber(v111, v226);
        v113 = v112;
        if ( v226[0] && atomic_fetch_add(v226[0], 0xFFFFFFFF) == 1 )
          v112 = (ApplicationData *)QArrayData::deallocate(v226[0], 2, 8);
        v211 = (__int64)v113;
        if ( (_DWORD)v113 == -1 )
        {
          v114 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v112);
          v211 = lumixtether::ApplicationSettings::fileNumber(v114);
        }
      }
      v94 = (ApplicationData *)QString::fromUtf8(&v261, 4, ".rw2");
      break;
    case 4:
      v89 = (ApplicationData *)QString::fromUtf8(&v261, 4, "MOV_");
      v90 = v246;
      v246 = v261;
      v261 = v90;
      v91 = v247;
      v247 = v262;
      v262 = v91;
      if ( (_QWORD)v90 && atomic_fetch_add((atomic_uint *volatile)v90, 0xFFFFFFFF) == 1 )
        v89 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      v92 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v89);
      v93 = lumixtether::ApplicationSettings::fileNumber(v92);
      v94 = (ApplicationData *)QString::fromUtf8(&v261, 4, ".mov");
      goto LABEL_148;
    case 5:
      v95 = (ApplicationData *)QString::fromUtf8(&v261, 4, "MOV_");
      v96 = v246;
      v246 = v261;
      v261 = v96;
      v97 = v247;
      v247 = v262;
      v262 = v97;
      if ( (_QWORD)v96 && atomic_fetch_add((atomic_uint *volatile)v96, 0xFFFFFFFF) == 1 )
        v95 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      v98 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v95);
      v93 = lumixtether::ApplicationSettings::fileNumber(v98);
      v94 = (ApplicationData *)QString::fromUtf8(&v261, 4, ".mp4");
LABEL_148:
      v211 = (unsigned int)(v93 + 1);
      break;
    case 6:
      v103 = (ApplicationData *)QString::fromUtf8(&v261, 4, "IMG_");
      v104 = v246;
      v246 = v261;
      v261 = v104;
      v105 = v247;
      v247 = v262;
      v262 = v105;
      if ( (_QWORD)v104 && atomic_fetch_add((atomic_uint *volatile)v104, 0xFFFFFFFF) == 1 )
        v103 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      if ( a7 )
      {
        v106 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v103);
        v211 = (unsigned int)lumixtether::ApplicationSettings::fileNumber(v106) + 1;
      }
      else
      {
        v119 = ApplicationData::getDeviceAdapter(v103);
        v225[0] = v14;
        v225[1] = v15;
        v225[2] = v16;
        if ( v14 )
          atomic_fetch_add(v14, 1u);
        v120 = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_objCopyFileNumber(v119, v225);
        v121 = v120;
        if ( v225[0] && atomic_fetch_add(v225[0], 0xFFFFFFFF) == 1 )
          v120 = (ApplicationData *)QArrayData::deallocate(v225[0], 2, 8);
        v211 = (__int64)v121;
        if ( (_DWORD)v121 == -1 )
        {
          v122 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v120);
          v211 = lumixtether::ApplicationSettings::fileNumber(v122);
        }
      }
      v94 = (ApplicationData *)QString::fromUtf8(&v261, 4, ".hsp");
      break;
    case 7:
      v99 = (ApplicationData *)QString::fromUtf8(&v261, 4, "IMG_");
      v100 = v246;
      v246 = v261;
      v261 = v100;
      v101 = v247;
      v247 = v262;
      v262 = v101;
      if ( (_QWORD)v100 && atomic_fetch_add((atomic_uint *volatile)v100, 0xFFFFFFFF) == 1 )
        v99 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      if ( a7 )
      {
        v102 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v99);
        v211 = (unsigned int)lumixtether::ApplicationSettings::fileNumber(v102) + 1;
      }
      else
      {
        v115 = ApplicationData::getDeviceAdapter(v99);
        v224[0] = v14;
        v224[1] = v15;
        v224[2] = v16;
        if ( v14 )
          atomic_fetch_add(v14, 1u);
        v116 = (ApplicationData *)lumixtether::DeviceAdapter::camera_list_get_objCopyFileNumber(v115, v224);
        v117 = v116;
        if ( v224[0] && atomic_fetch_add(v224[0], 0xFFFFFFFF) == 1 )
          v116 = (ApplicationData *)QArrayData::deallocate(v224[0], 2, 8);
        v211 = (__int64)v117;
        if ( (_DWORD)v117 == -1 )
        {
          v118 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v116);
          v211 = lumixtether::ApplicationSettings::fileNumber(v118);
        }
      }
      v94 = (ApplicationData *)QString::fromUtf8(&v261, 4, ".hif");
      break;
    default:
      goto LABEL_109;
  }
  v123 = v244;
  v244 = v261;
  v261 = v123;
  v124 = v245;
  v245 = v262;
  v262 = v124;
  if ( (_QWORD)v123 && atomic_fetch_add((atomic_uint *volatile)v123, 0xFFFFFFFF) == 1 )
    v94 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
  v125 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v94);
  v126 = (ApplicationData *)lumixtether::ApplicationSettings::folderNameType(v125);
  if ( (_DWORD)v126 == 1 || v32 == 2 )
  {
    v137 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v126);
    Object_FileName = lumixtether::ApplicationSettings::folderNamePrefix((__int64 *)&v261, v137);
    v138 = v262;
    if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
      Object_FileName = (__int64 *)QArrayData::deallocate(v261, 2, 8);
    if ( v138 )
    {
      v139 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings((ApplicationData *)Object_FileName);
      Object_FileName = lumixtether::ApplicationSettings::folderNamePrefix((__int64 *)&v261, v139);
      v140 = v246;
      v246 = v261;
      v261 = v140;
      v141 = v247;
      v247 = v262;
      v262 = v141;
      if ( (_QWORD)v140 )
      {
        if ( atomic_fetch_add((atomic_uint *volatile)v140, 0xFFFFFFFF) == 1 )
          Object_FileName = (__int64 *)QArrayData::deallocate(v261, 2, 8);
      }
    }
    v129 = 0;
  }
  else
  {
    v127 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v126);
    Object_FileName = (__int64 *)lumixtether::ApplicationSettings::folderNameType(v127);
    v129 = 0;
    if ( !a6 || (_DWORD)Object_FileName )
      goto LABEL_221;
    v130 = ApplicationData::getDeviceAdapter((ApplicationData *)Object_FileName);
    v223[0] = v14;
    v223[1] = v15;
    v223[2] = v16;
    if ( v14 )
      atomic_fetch_add(v14, 1u);
    Object_FileName = (__int64 *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Object_FileName(v130, a6, v263, v223);
    v131 = (int)Object_FileName;
    if ( v223[0] && atomic_fetch_add(v223[0], 0xFFFFFFFF) == 1 )
      Object_FileName = (__int64 *)QArrayData::deallocate(v223[0], 2, 8);
    if ( v131 == 1 )
    {
      v132 = strlen((const char *)v263 + 1);
      v133 = (ApplicationData *)QString::fromUtf8(&v261, v132, (char *)v263 + 1);
      v134 = v257;
      v257 = v261;
      v261 = v134;
      v135 = v258;
      v258 = v262;
      v262 = v135;
      if ( (_QWORD)v134 && atomic_fetch_add((atomic_uint *volatile)v134, 0xFFFFFFFF) == 1 )
        v133 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      v129 = 0;
      v131 = 1;
      switch ( v73 )
      {
        case 0:
          sub_1000BE134((int)&v261, "CARDLESS.JPG");
          v133 = (ApplicationData *)QString::compare(&v257, &v261, 1);
          v136 = (int)v133;
          if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
            v133 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
          if ( v136 )
            goto LABEL_477;
          goto LABEL_478;
        case 1:
          sub_1000BE134((int)&v261, "CARDLESS.RW2");
          v133 = (ApplicationData *)QString::compare(&v257, &v261, 1);
          v182 = (int)v133;
          if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
            v133 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
          if ( !v182 )
            goto LABEL_478;
          goto LABEL_477;
        case 5:
          sub_1000BE134((int)&v261, "CARDLESS.HSP");
          v133 = (ApplicationData *)QString::compare(&v257, &v261, 1);
          v183 = (int)v133;
          if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
            v133 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
          if ( !v183 )
            goto LABEL_478;
          goto LABEL_477;
        case 6:
          sub_1000BE134((int)&v261, "CARDLESS.HIF");
          v133 = (ApplicationData *)QString::compare(&v257, &v261, 1);
          v184 = (int)v133;
          if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
            v133 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
          if ( v184 )
          {
LABEL_477:
            v129 = 0;
            v131 = 1;
          }
          else
          {
LABEL_478:
            v185 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v133);
            v133 = (ApplicationData *)lumixtether::ApplicationSettings::folderNamePrefix((__int64 *)&v261, v185);
            v186 = v246;
            v246 = v261;
            v261 = v186;
            v187 = v247;
            v247 = v262;
            v262 = v187;
            if ( (_QWORD)v186 && atomic_fetch_add((atomic_uint *volatile)v186, 0xFFFFFFFF) == 1 )
              v133 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
            v131 = 0;
            v129 = 1;
          }
          break;
        default:
          break;
      }
      v188 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v133);
      v189 = (ApplicationData *)lumixtether::ApplicationSettings::storeFileNameCamera(v188);
      if ( !(_DWORD)v189 )
      {
        v196 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v189);
        v197 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderCamera(v196);
        if ( (_DWORD)v197 )
        {
          v198 = ApplicationData::getDeviceAdapter(v197);
          v222[0] = v14;
          v222[1] = v15;
          v222[2] = v16;
          if ( v14 )
            atomic_fetch_add(v14, 1u);
          lumixtether::DeviceAdapter::camera_list_get_camera_individual_id(&v261, v198, v222);
          if ( v222[0] && atomic_fetch_add(v222[0], 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v222[0], 2, 8);
          if ( *((_QWORD *)&v261 + 1) )
            v199 = *((void **)&v261 + 1);
          else
            v199 = &QString::_empty;
          v200 = (ApplicationData *)QString::compare_helper(v199, v262, &unk_10014269A, -1, 1);
          if ( !(_DWORD)v200 )
          {
            v201 = ApplicationData::getDeviceAdapter(v200);
            v221[0] = v14;
            v221[1] = v15;
            v221[2] = v16;
            if ( v14 )
              atomic_fetch_add(v14, 1u);
            lumixtether::DeviceAdapter::camera_list_get_camera_modelName(&v234, v201, v221);
            v202 = v261;
            v261 = v234;
            v234 = v202;
            v203 = v262;
            v262 = v235;
            v235 = v203;
            if ( (_QWORD)v202 && atomic_fetch_add((atomic_uint *volatile)v202, 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v234, 2, 8);
            if ( v221[0] && atomic_fetch_add(v221[0], 0xFFFFFFFF) == 1 )
              QArrayData::deallocate(v221[0], 2, 8);
            sub_1000C750C((int)&v261, "_");
            QString::append((QString *)&v261, (const QString *)&v239);
          }
          sub_1000C750C((int)&v261, "_");
          sub_1000C5C34(&v234, &v261, &v257);
          QString::operator=(&v257, &v234);
          if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v234, 2, 8);
          if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
            QArrayData::deallocate(v261, 2, 8);
        }
      }
      if ( (QDir::exists((QDir *)v243, (const QString *)&v257) & 1) != 0 )
      {
        v190 = QString::lastIndexOf(&v257, 46, -1, 1);
        if ( v190 < 1 )
        {
          Object_FileName = (__int64 *)QString::operator=(&v246, &v257);
        }
        else
        {
          Object_FileName = QString::left(&v261, (QString *)&v257, v190);
          v191 = v246;
          v246 = v261;
          v261 = v191;
          v192 = v247;
          v247 = v262;
          v262 = v192;
          if ( (_QWORD)v191 && atomic_fetch_add((atomic_uint *volatile)v191, 0xFFFFFFFF) == 1 )
            Object_FileName = (__int64 *)QArrayData::deallocate(v261, 2, 8);
        }
        goto LABEL_221;
      }
      Object_FileName = QDir::filePath(&v261, (QDir *)v243, (const QString *)&v257);
      v193 = *(atomic_uint **)a4;
      v194 = *(_QWORD *)(a4 + 8);
      *(_OWORD *)a4 = v261;
      *(_QWORD *)&v261 = v193;
      *((_QWORD *)&v261 + 1) = v194;
      v195 = *(atomic_uint **)(a4 + 16);
      *(_QWORD *)(a4 + 16) = v262;
      v262 = v195;
      if ( v193 && atomic_fetch_add(v193, 0xFFFFFFFF) == 1 )
        Object_FileName = (__int64 *)QArrayData::deallocate(v261, 2, 8);
    }
    else
    {
      v129 = 0;
    }
    if ( v131 )
      goto LABEL_413;
  }
LABEL_221:
  v220 = -1;
  v142 = ApplicationData::getDeviceAdapter((ApplicationData *)Object_FileName);
  v143 = v211;
  v219[0] = v14;
  v219[1] = v15;
  v219[2] = v16;
  if ( v14 )
    atomic_fetch_add(v14, 1u);
  DriveMode = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Get_DriveMode(
                                   v142,
                                   &v220,
                                   v219);
  if ( v219[0] && atomic_fetch_add(v219[0], 0xFFFFFFFF) == 1 )
    DriveMode = (ApplicationData *)QArrayData::deallocate(v219[0], 2, 8);
  v145 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(DriveMode);
  v146 = (ApplicationData *)lumixtether::ApplicationSettings::storeFileNameCamera(v145);
  if ( !(_DWORD)v146 )
  {
    v152 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v146);
    v146 = (ApplicationData *)lumixtether::ApplicationSettings::storeFolderCamera(v152);
    if ( (_DWORD)v146 )
    {
      v153 = ApplicationData::getDeviceAdapter(v146);
      v218[0] = v14;
      v218[1] = v15;
      v218[2] = v16;
      if ( v14 )
        atomic_fetch_add(v14, 1u);
      lumixtether::DeviceAdapter::camera_list_get_camera_individual_id(&v234, v153, v218);
      if ( v218[0] && atomic_fetch_add(v218[0], 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v218[0], 2, 8);
      if ( *((_QWORD *)&v234 + 1) )
        v154 = *((void **)&v234 + 1);
      else
        v154 = &QString::_empty;
      v155 = (ApplicationData *)QString::compare_helper(v154, v235, &unk_10014269A, -1, 1);
      if ( !(_DWORD)v155 )
      {
        v156 = ApplicationData::getDeviceAdapter(v155);
        v217[0] = v14;
        v217[1] = v15;
        v217[2] = v16;
        if ( v14 )
          atomic_fetch_add(v14, 1u);
        lumixtether::DeviceAdapter::camera_list_get_camera_modelName(&v261, v156, v217);
        v157 = v234;
        v234 = v261;
        v261 = v157;
        v158 = v235;
        v235 = v262;
        v262 = v158;
        if ( (_QWORD)v157 && atomic_fetch_add((atomic_uint *volatile)v157, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v261, 2, 8);
        if ( v217[0] && atomic_fetch_add(v217[0], 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(v217[0], 2, 8);
        sub_1000C750C((int)&v234, "_");
        QString::append((QString *)&v234, (const QString *)&v239);
      }
      QString::fromUtf8(&v261, 1, "_");
      QString::append((QString *)&v234, (const QString *)&v261);
      if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v261, 2, 8);
      v261 = v234;
      v262 = v235;
      if ( (_QWORD)v234 )
        atomic_fetch_add((atomic_uint *volatile)v234, 1u);
      QString::append((QString *)&v261, (const QString *)&v246);
      v146 = (ApplicationData *)QString::operator=(&v246, &v261);
      if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
        v146 = (ApplicationData *)QArrayData::deallocate(v261, 2, 8);
      if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
        v146 = (ApplicationData *)QArrayData::deallocate(v234, 2, 8);
    }
  }
  v147 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v146);
  v148 = (ApplicationData *)lumixtether::ApplicationSettings::folderNameType(v147);
  if ( !(_DWORD)v148 )
  {
    v149 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v148);
    v148 = (ApplicationData *)lumixtether::ApplicationSettings::folderNameType(v149);
    if ( ((_DWORD)v148 || v32 != 2) && (v129 | (v220 == 5)) != 1 )
    {
      v204 = v15;
      v161 = v16;
      v206 = a7;
      v162 = 0;
      goto LABEL_284;
    }
  }
  if ( (int)v211 < 10000 )
  {
    v151 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v148);
    if ( (_DWORD)v211 == 9999 )
    {
      lumixtether::ApplicationSettings::setFileNumber(v151, 0);
      v143 = 9999;
    }
    else
    {
      lumixtether::ApplicationSettings::setFileNumber(v151, v211);
    }
  }
  else
  {
    v150 = (lumixtether::ApplicationSettings *)ApplicationData::getApplicationSettings(v148);
    v143 = 1;
    lumixtether::ApplicationSettings::setFileNumber(v150, 1);
  }
  QString::operator=(&v255, &v246);
  QString::fromUtf8(&v261, 2, "%1");
  v215 = v261;
  v216 = v262;
  QString::arg(&v234, &v215, (int)v143, 4, 10, 48);
  v159 = v253;
  v253 = v234;
  v234 = v159;
  v160 = v254;
  v254 = v235;
  v235 = v160;
  if ( (_QWORD)v159 && atomic_fetch_add((atomic_uint *volatile)v159, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v234, 2, 8);
  if ( (_QWORD)v215 && atomic_fetch_add((atomic_uint *volatile)v215, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v215, 2, 8);
  QString::operator=(&v251, &v244);
  v234 = v255;
  v235 = v256;
  if ( (_QWORD)v255 )
    atomic_fetch_add((atomic_uint *volatile)v255, 1u);
  QString::append((QString *)&v234, (const QString *)&v253);
  v261 = v234;
  v262 = v235;
  if ( (_QWORD)v234 )
    atomic_fetch_add((atomic_uint *volatile)v234, 1u);
  QString::append((QString *)&v261, (const QString *)&v251);
  QString::operator=(&v257, &v261);
  if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v261, 2, 8);
  if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v234, 2, 8);
  if ( (QDir::exists((QDir *)v243, (const QString *)&v257) & 1) == 0 )
  {
    if ( v207 )
    {
      v234 = v255;
      v235 = v256;
      if ( (_QWORD)v255 )
        atomic_fetch_add((atomic_uint *volatile)v255, 1u);
      QString::append((QString *)&v234, (const QString *)&v253);
      v261 = v234;
      v262 = v235;
      if ( (_QWORD)v234 )
        atomic_fetch_add((atomic_uint *volatile)v234, 1u);
      QString::append((QString *)&v261, (const QString *)&v251);
      QString::operator=(&v257, &v261);
      if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v261, 2, 8);
      if ( !(_QWORD)v234 || atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) != 1 )
        goto LABEL_398;
      v173 = v234;
    }
    else
    {
      v261 = v255;
      v262 = v256;
      if ( (_QWORD)v255 )
        atomic_fetch_add((atomic_uint *volatile)v255, 1u);
      QString::append((QString *)&v261, (const QString *)&v253);
      QString::operator=(&v257, &v261);
      if ( !(_QWORD)v261 || atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) != 1 )
        goto LABEL_398;
      v173 = v261;
    }
    QArrayData::deallocate(v173, 2, 8);
LABEL_398:
    QDir::filePath(&v261, (QDir *)v243, (const QString *)&v257);
    v211 = v143;
    goto LABEL_410;
  }
  v204 = v15;
  v161 = v16;
  v206 = a7;
  v162 = 1;
LABEL_284:
  if ( (int)v143 > 9999 )
    v143 = 1;
  else
    v143 = (unsigned int)v143;
  v211 = v143;
  v163 = (int)v143;
  v164 = 1;
  do
  {
    QString::operator=(&v255, &v246);
    QString::fromUtf8(&v261, 2, "%1");
    v215 = v261;
    v216 = v262;
    QString::arg(&v234, &v215, v163, 4, 10, 48);
    v165 = v253;
    v253 = v234;
    v234 = v165;
    v166 = v254;
    v254 = v235;
    v235 = v166;
    if ( (_QWORD)v165 && atomic_fetch_add((atomic_uint *volatile)v165, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v234, 2, 8);
    if ( (_QWORD)v215 && atomic_fetch_add((atomic_uint *volatile)v215, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v215, 2, 8);
    QString::fromUtf8(&v261, 1, "_");
    v167 = v251;
    v251 = v261;
    v261 = v167;
    v168 = v252;
    v252 = v262;
    v262 = v168;
    if ( (_QWORD)v167 && atomic_fetch_add((atomic_uint *volatile)v167, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v261, 2, 8);
    QString::fromUtf8(&v261, 2, "%1");
    v215 = v261;
    v216 = v262;
    QString::arg(&v234, &v215, v164, 2, 10, 48);
    v169 = v249;
    v249 = v234;
    v234 = v169;
    v170 = v250;
    v250 = v235;
    v235 = v170;
    if ( (_QWORD)v169 && atomic_fetch_add((atomic_uint *volatile)v169, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v234, 2, 8);
    if ( (_QWORD)v215 && atomic_fetch_add((atomic_uint *volatile)v215, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v215, 2, 8);
    QString::operator=(v248, &v244);
    if ( v162 )
    {
      v213 = v255;
      v214 = v256;
      if ( (_QWORD)v255 )
        atomic_fetch_add((atomic_uint *volatile)v255, 1u);
      QString::append((QString *)&v213, (const QString *)&v253);
      v215 = v213;
      v216 = v214;
      if ( (_QWORD)v213 )
        atomic_fetch_add((atomic_uint *volatile)v213, 1u);
      QString::append((QString *)&v215, (const QString *)&v251);
      v234 = v215;
      v235 = v216;
      if ( (_QWORD)v215 )
        atomic_fetch_add((atomic_uint *volatile)v215, 1u);
      QString::append((QString *)&v234, (const QString *)&v249);
      v261 = v234;
      v262 = v235;
      if ( (_QWORD)v234 )
        atomic_fetch_add((atomic_uint *volatile)v234, 1u);
      QString::append((QString *)&v261, (const QString *)v248);
      QString::operator=(&v257, &v261);
      if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v261, 2, 8);
      if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v234, 2, 8);
      if ( (_QWORD)v215 && atomic_fetch_add((atomic_uint *volatile)v215, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v215, 2, 8);
      if ( (_QWORD)v213 && atomic_fetch_add((atomic_uint *volatile)v213, 0xFFFFFFFF) == 1 )
      {
        v171 = v213;
LABEL_339:
        QArrayData::deallocate(v171, 2, 8);
      }
    }
    else
    {
      v215 = v255;
      v216 = v256;
      if ( (_QWORD)v255 )
        atomic_fetch_add((atomic_uint *volatile)v255, 1u);
      QString::append((QString *)&v215, (const QString *)&v251);
      v234 = v215;
      v235 = v216;
      if ( (_QWORD)v215 )
        atomic_fetch_add((atomic_uint *volatile)v215, 1u);
      QString::append((QString *)&v234, (const QString *)&v249);
      v261 = v234;
      v262 = v235;
      if ( (_QWORD)v234 )
        atomic_fetch_add((atomic_uint *volatile)v234, 1u);
      QString::append((QString *)&v261, (const QString *)v248);
      QString::operator=(&v257, &v261);
      if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v261, 2, 8);
      if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v234, 2, 8);
      if ( (_QWORD)v215 && atomic_fetch_add((atomic_uint *volatile)v215, 0xFFFFFFFF) == 1 )
      {
        v171 = v215;
        goto LABEL_339;
      }
    }
    ++v164;
  }
  while ( (QDir::exists((QDir *)v243, (const QString *)&v257) & 1) != 0 );
  if ( !v207 )
  {
    a7 = v206;
    v16 = v161;
    if ( !v162 )
    {
      sub_1000C5C34(&v234, &v255, &v251);
      v15 = v204;
      sub_1000C5C34(&v261, &v234, &v249);
      QString::operator=(&v257, &v261);
      if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
        QArrayData::deallocate(v261, 2, 8);
      if ( !(_QWORD)v234 || atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) != 1 )
        goto LABEL_409;
      v172 = v234;
LABEL_408:
      QArrayData::deallocate(v172, 2, 8);
      goto LABEL_409;
    }
    sub_1000C5C34(&v215, &v255, &v253);
    v15 = v204;
    sub_1000C5C34(&v234, &v215, &v251);
    sub_1000C5C34(&v261, &v234, &v249);
LABEL_383:
    QString::operator=(&v257, &v261);
    if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v261, 2, 8);
    if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v234, 2, 8);
    if ( !(_QWORD)v215 || atomic_fetch_add((atomic_uint *volatile)v215, 0xFFFFFFFF) != 1 )
      goto LABEL_409;
    v172 = v215;
    goto LABEL_408;
  }
  a7 = v206;
  v16 = v161;
  if ( !v162 )
  {
    v215 = v255;
    v216 = v256;
    v15 = v204;
    if ( (_QWORD)v255 )
      atomic_fetch_add((atomic_uint *volatile)v255, 1u);
    QString::append((QString *)&v215, (const QString *)&v251);
    v234 = v215;
    v235 = v216;
    if ( (_QWORD)v215 )
      atomic_fetch_add((atomic_uint *volatile)v215, 1u);
    QString::append((QString *)&v234, (const QString *)&v249);
    v261 = v234;
    v262 = v235;
    if ( (_QWORD)v234 )
      atomic_fetch_add((atomic_uint *volatile)v234, 1u);
    QString::append((QString *)&v261, (const QString *)v248);
    goto LABEL_383;
  }
  v213 = v255;
  v214 = v256;
  v15 = v204;
  if ( (_QWORD)v255 )
    atomic_fetch_add((atomic_uint *volatile)v255, 1u);
  QString::append((QString *)&v213, (const QString *)&v253);
  v215 = v213;
  v216 = v214;
  if ( (_QWORD)v213 )
    atomic_fetch_add((atomic_uint *volatile)v213, 1u);
  QString::append((QString *)&v215, (const QString *)&v251);
  v234 = v215;
  v235 = v216;
  if ( (_QWORD)v215 )
    atomic_fetch_add((atomic_uint *volatile)v215, 1u);
  QString::append((QString *)&v234, (const QString *)&v249);
  v261 = v234;
  v262 = v235;
  if ( (_QWORD)v234 )
    atomic_fetch_add((atomic_uint *volatile)v234, 1u);
  QString::append((QString *)&v261, (const QString *)v248);
  QString::operator=(&v257, &v261);
  if ( (_QWORD)v261 && atomic_fetch_add((atomic_uint *volatile)v261, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v261, 2, 8);
  if ( (_QWORD)v234 && atomic_fetch_add((atomic_uint *volatile)v234, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v234, 2, 8);
  if ( (_QWORD)v215 && atomic_fetch_add((atomic_uint *volatile)v215, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v215, 2, 8);
  if ( (_QWORD)v213 && atomic_fetch_add((atomic_uint *volatile)v213, 0xFFFFFFFF) == 1 )
  {
    v172 = v213;
    goto LABEL_408;
  }
LABEL_409:
  QDir::filePath(&v261, (QDir *)v243, (const QString *)&v257);
LABEL_410:
  v174 = *(atomic_uint **)a4;
  v175 = *(_QWORD *)(a4 + 8);
  *(_OWORD *)a4 = v261;
  *(_QWORD *)&v261 = v174;
  *((_QWORD *)&v261 + 1) = v175;
  v176 = *(atomic_uint **)(a4 + 16);
  *(_QWORD *)(a4 + 16) = v262;
  v262 = v176;
  if ( v174 && atomic_fetch_add(v174, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v261, 2, 8);
LABEL_413:
  v177 = (ApplicationData *)QString::operator=(v209, &v257);
  if ( a7 )
  {
    v178 = ApplicationData::getDeviceAdapter(v177);
    v212[0] = v14;
    v212[1] = v15;
    v212[2] = v16;
    if ( v14 )
      atomic_fetch_add(v14, 1u);
    lumixtether::DeviceAdapter::camera_list_set_objCopyFileNumber(v178, v212, v211);
    if ( v212[0] && atomic_fetch_add(v212[0], 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v212[0], 2, 8);
  }
  v72 = 1;
  v78 = (atomic_uint *)v239;
  if ( (_QWORD)v239 )
  {
LABEL_420:
    if ( atomic_fetch_add(v78, 0xFFFFFFFF) == 1 )
      QArrayData::deallocate(v239, 2, 8);
  }
LABEL_422:
  if ( (_QWORD)v241 && atomic_fetch_add((atomic_uint *volatile)v241, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v241, 2, 8);
  if ( v14 && atomic_fetch_add(v14, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v14, 2, 8);
  QDir::~QDir((QDir *)v243);
  if ( (_QWORD)v244 && atomic_fetch_add((atomic_uint *volatile)v244, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v244, 2, 8);
  if ( (_QWORD)v246 && atomic_fetch_add((atomic_uint *volatile)v246, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v246, 2, 8);
  if ( v248[0] && atomic_fetch_add(v248[0], 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v248[0], 2, 8);
  if ( (_QWORD)v249 && atomic_fetch_add((atomic_uint *volatile)v249, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v249, 2, 8);
  if ( (_QWORD)v251 && atomic_fetch_add((atomic_uint *volatile)v251, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v251, 2, 8);
  if ( (_QWORD)v253 && atomic_fetch_add((atomic_uint *volatile)v253, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v253, 2, 8);
  if ( (_QWORD)v255 && atomic_fetch_add((atomic_uint *volatile)v255, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v255, 2, 8);
  if ( (_QWORD)v257 && atomic_fetch_add((atomic_uint *volatile)v257, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(v257, 2, 8);
  if ( (_QWORD)v259 && atomic_fetch_add((atomic_uint *volatile)v259, 0xFFFFFFFF) == 1 )
  {
    if ( v260 )
    {
      v179 = *((atomic_uint *volatile **)&v259 + 1);
      v180 = 24LL * (_QWORD)v260;
      do
      {
        if ( *v179 && atomic_fetch_add(*v179, 0xFFFFFFFF) == 1 )
          QArrayData::deallocate(*v179, 2, 8);
        v179 += 3;
        v180 -= 24;
      }
      while ( v180 );
    }
    QArrayData::deallocate(v259, 24, 8);
  }
  return v72;
}
