// __ZN11lumixtether21DeviceAdapterCallback6doWorkEv @ 0x1000dbc7c (imagebase-relative)
__int64 __fastcall lumixtether::DeviceAdapterCallback::doWork(atomic_ullong *this, const char *a2)
{
  const char *v3; // x1
  const char *v4; // x1
  const char *v5; // x1
  const char *v6; // x1
  const char *v7; // x1
  const char *v8; // x1
  const char *v9; // x1
  const char *v10; // x1
  const char *v11; // x1
  const char *v12; // x1
  const char *v13; // x1
  const char *v14; // x1
  const char *v15; // x1
  const char *v16; // x1
  const char *v17; // x1
  const char *v18; // x1
  const char *v19; // x1
  const char *v20; // x1
  const char *v21; // x1
  const char *v22; // x1
  const char *v23; // x1
  const char *v24; // x1
  const char *v25; // x1
  const char *v26; // x1
  const char *v27; // x1
  const char *v28; // x1
  const char *v29; // x1
  const char *v30; // x1
  const char *v31; // x1
  const char *v32; // x1
  const char *v33; // x1
  const char *v34; // x1
  const char *v35; // x1
  const char *v36; // x1
  const char *v37; // x1
  const char *v38; // x1
  const char *v39; // x1
  const char *v40; // x1
  const char *v41; // x1
  const char *v42; // x1
  const char *v43; // x1
  const char *v44; // x1
  const char *v45; // x1
  const char *v46; // x1
  const char *v47; // x1
  const char *v48; // x1
  const char *v49; // x1
  const char *v50; // x1
  const char *v51; // x1
  const char *v52; // x1
  const char *v53; // x1
  const char *v54; // x1
  const char *v55; // x1
  const char *v56; // x1
  const char *v57; // x1
  const char *v58; // x1
  const char *v59; // x1
  const char *v60; // x1
  const char *v61; // x1
  const char *v62; // x1
  const char *v63; // x1
  const char *v64; // x1
  const char *v65; // x1
  const char *v66; // x1
  const char *v67; // x1
  const char *v68; // x1
  const char *v69; // x1
  const char *v70; // x1
  const char *v71; // x1
  const char *v72; // x1
  const char *v73; // x1
  const char *v74; // x1
  const char *v75; // x1
  const char *v76; // x1
  const char *v77; // x1
  const char *v78; // x1
  const char *v79; // x1
  const char *v80; // x1
  const char *v81; // x1
  lumixtether::DeviceAdapterCallback *v82; // x0
  __int64 Info; // x0
  __int64 v84; // x8
  atomic_ullong *v85; // x20
  __int64 v86; // x8
  __int64 v87; // x8
  int v88; // w21
  __int64 v89; // x9
  __int64 v90; // x0
  lumixtether::DeviceAdapter *v91; // x0
  lumixtether::DeviceAdapter *v92; // x0
  lumixtether::DeviceAdapter *v93; // x0
  lumixtether::DeviceAdapter *v94; // x0
  lumixtether::DeviceAdapter *v95; // x0
  __int64 v96; // x0
  atomic_uint *tv_sec; // x0
  lumixtether::DeviceAdapter *v98; // x0
  lumixtether::DeviceAdapter *v99; // x0
  lumixtether::DeviceAdapter *v100; // x0
  lumixtether::DeviceAdapter *v101; // x0
  lumixtether::DeviceAdapter *v102; // x0
  lumixtether::DeviceAdapter *v103; // x0
  lumixtether::DeviceAdapter *v104; // x0
  lumixtether::DeviceAdapter *v105; // x0
  lumixtether::DeviceAdapter *v106; // x0
  __int64 v107; // x0
  __int64 v108; // x1
  __int64 v109; // x2
  lumixtether::DeviceAdapter *v110; // x0
  lumixtether::DeviceAdapter *v111; // x0
  lumixtether::DeviceAdapter *v112; // x0
  __int64 v113; // x0
  __int64 v114; // x1
  __int64 v115; // x2
  __int64 v116; // x0
  __int64 v117; // x1
  __int64 v118; // x2
  lumixtether::DeviceAdapter *v119; // x0
  lumixtether::DeviceAdapter *v120; // x0
  __int64 v121; // x0
  __int64 v122; // x1
  __int64 v123; // x2
  lumixtether::DeviceAdapter *v124; // x0
  lumixtether::DeviceAdapter *v125; // x0
  lumixtether::DeviceAdapter *v126; // x0
  lumixtether::DeviceAdapter *v127; // x0
  lumixtether::DeviceAdapter *v128; // x0
  lumixtether::DeviceAdapter *v129; // x0
  lumixtether::DeviceAdapter *v130; // x0
  lumixtether::DeviceAdapter *v131; // x0
  __int64 v132; // x0
  unsigned int v133; // w1
  __int64 v134; // x2
  lumixtether::DeviceAdapter *v135; // x0
  lumixtether::DeviceAdapter *v136; // x0
  lumixtether::DeviceAdapter *v137; // x0
  lumixtether::DeviceAdapter *v138; // x0
  lumixtether::DeviceAdapter *v139; // x0
  lumixtether::DeviceAdapter *v140; // x0
  lumixtether::DeviceAdapter *v141; // x0
  lumixtether::DeviceAdapter *v142; // x0
  lumixtether::DeviceAdapter *v143; // x0
  __int64 DeviceAdapter; // x0
  __int64 v145; // x1
  __int64 v146; // x2
  lumixtether::DeviceAdapter *v147; // x0
  lumixtether::DeviceAdapter *v148; // x0
  lumixtether::DeviceAdapter *v149; // x0
  lumixtether::DeviceAdapter *v150; // x0
  __int64 v151; // x0
  lumixtether::DeviceAdapter *v152; // x0
  lumixtether::DeviceAdapter *v153; // x0
  lumixtether::DeviceAdapter *v154; // x0
  lumixtether::DeviceAdapter *v155; // x0
  lumixtether::DeviceAdapter *v156; // x0
  lumixtether::DeviceAdapter *v157; // x0
  lumixtether::DeviceAdapter *v158; // x0
  lumixtether::DeviceAdapter *v159; // x0
  lumixtether::DeviceAdapter *v160; // x0
  lumixtether::DeviceAdapter *v161; // x0
  lumixtether::FlashAdapter *v162; // x0
  lumixtether::DeviceAdapter *v163; // x0
  lumixtether::DeviceAdapter *v164; // x0
  lumixtether::DeviceAdapter *v165; // x0
  lumixtether::DeviceAdapter *v166; // x0
  lumixtether::DeviceAdapter *v167; // x0
  lumixtether::DeviceAdapter *v168; // x0
  lumixtether::DeviceAdapter *v169; // x0
  lumixtether::DeviceAdapter *v170; // x0
  lumixtether::DeviceAdapter *v171; // x0
  lumixtether::DeviceAdapter *v172; // x0
  lumixtether::DeviceAdapter *v173; // x0
  lumixtether::DeviceAdapter *v174; // x0
  __int64 v175; // x0
  __int64 v176; // x1
  __int64 v177; // x2
  __int64 v178; // x0
  unsigned int v179; // w8
  __int64 v180; // x0
  __int64 v181; // x0
  __int64 v182; // x0
  __int64 v183; // x0
  __int64 v184; // x0
  __int64 v185; // x0
  __int64 v186; // x0
  __int64 v187; // x0
  lumixtether::DeviceAdapter *v188; // x0
  __int64 v189; // x0
  __int64 v190; // x0
  lumixtether::DeviceAdapter *v191; // x0
  lumixtether::DeviceAdapter *v192; // x0
  __int64 v193; // x0
  __int64 v194; // x0
  __int64 v195; // x0
  __int64 v196; // x0
  __int64 v197; // x0
  __int64 v198; // x0
  __int64 v199; // x0
  __int64 v200; // x0
  __int64 v201; // x0
  __int64 v202; // x0
  __int64 v203; // x0
  __int64 v204; // x0
  lumixtether::DeviceAdapter *v205; // x0
  __int64 v206; // x0
  __int64 v207; // x0
  __int64 v208; // x0
  lumixtether::DeviceAdapter *v209; // x0
  lumixtether::DeviceAdapter *v210; // x0
  lumixtether::DeviceAdapter *v211; // x0
  lumixtether::DeviceAdapter *v212; // x0
  lumixtether::DeviceAdapter *v213; // x0
  lumixtether::DeviceAdapter *v214; // x0
  lumixtether::DeviceAdapter *v215; // x0
  lumixtether::DeviceAdapter *v216; // x0
  lumixtether::DeviceAdapter *v217; // x0
  lumixtether::DeviceAdapter *v218; // x0
  lumixtether::DeviceAdapter *v219; // x0
  lumixtether::DeviceAdapter *v220; // x0
  lumixtether::DeviceAdapter *v221; // x0
  lumixtether::DeviceAdapter *v222; // x0
  __int64 v223; // x0
  lumixtether::DeviceAdapter *v224; // x21
  __int64 v225; // x1
  lumixtether::DeviceAdapter *v226; // x0
  lumixtether::DeviceAdapter *v227; // x0
  lumixtether::DeviceAdapter *v228; // x0
  lumixtether::DeviceAdapter *v229; // x0
  __int64 v230; // x0
  __int64 v231; // x0
  __int64 v232; // x0
  __int64 v233; // x0
  __int64 v234; // x1
  lumixtether::DeviceAdapter *v235; // x0
  lumixtether::DeviceAdapter *v236; // x0
  lumixtether::DeviceAdapter *v237; // x0
  lumixtether::DeviceAdapter *v238; // x0
  lumixtether::DeviceAdapter *v239; // x0
  lumixtether::DeviceAdapter *v240; // x0
  lumixtether::DeviceAdapter *v241; // x0
  lumixtether::DeviceAdapter *v242; // x0
  lumixtether::DeviceAdapter *v243; // x0
  lumixtether::DeviceAdapter *v244; // x0
  lumixtether::DeviceAdapter *v245; // x0
  lumixtether::DeviceAdapter *v246; // x0
  lumixtether::DeviceAdapter *v247; // x0
  lumixtether::FlashAdapter *FlashAdapter; // x0
  lumixtether::DeviceAdapter *v249; // x0
  lumixtether::DeviceAdapter *v250; // x0
  __int64 v251; // x21
  lumixtether::DeviceAdapter *v252; // x0
  lumixtether::DeviceAdapter *v253; // x0
  lumixtether::DeviceAdapter *v254; // x0
  lumixtether::DeviceAdapter *v255; // x0
  lumixtether::DeviceAdapter *v256; // x0
  lumixtether::DeviceAdapter *v257; // x0
  lumixtether::DeviceAdapter *v258; // x0
  lumixtether::DeviceAdapter *v259; // x0
  lumixtether::DeviceAdapter *v260; // x0
  lumixtether::DeviceAdapter *v261; // x0
  lumixtether::DeviceAdapter *v262; // x0
  lumixtether::DeviceAdapter *v263; // x0
  atomic_ullong *v264; // x0
  lumixtether::DeviceAdapter *v265; // x0
  lumixtether::DeviceAdapter *v266; // x0
  lumixtether::DeviceAdapter *v267; // x0
  __int64 result; // x0
  atomic_uint *v269[3]; // [xsp+8h] [xbp-1A8h] BYREF
  atomic_uint *v270[3]; // [xsp+20h] [xbp-190h] BYREF
  atomic_uint *v271[3]; // [xsp+38h] [xbp-178h] BYREF
  timespec v272; // [xsp+50h] [xbp-160h] BYREF
  __int64 v273; // [xsp+60h] [xbp-150h]
  atomic_uint *v274[3]; // [xsp+68h] [xbp-148h] BYREF
  atomic_uint *v275[3]; // [xsp+80h] [xbp-130h] BYREF
  atomic_uint *v276[3]; // [xsp+98h] [xbp-118h] BYREF
  atomic_uint *v277[3]; // [xsp+B0h] [xbp-100h] BYREF
  atomic_uint *v278[3]; // [xsp+C8h] [xbp-E8h] BYREF
  atomic_uint *v279[3]; // [xsp+E0h] [xbp-D0h] BYREF
  atomic_uint *v280[3]; // [xsp+F8h] [xbp-B8h] BYREF
  atomic_uint *v281; // [xsp+110h] [xbp-A0h] BYREF
  atomic_uint *v282; // [xsp+118h] [xbp-98h]
  atomic_uint *v283; // [xsp+120h] [xbp-90h]
  unsigned int v284; // [xsp+128h] [xbp-88h] BYREF
  unsigned int v285; // [xsp+12Ch] [xbp-84h] BYREF
  timespec __rqtp; // [xsp+130h] [xbp-80h] BYREF
  __int64 v287; // [xsp+140h] [xbp-70h]

  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::RecordingMode", a2);
  sub_1000DEC54((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::IntelligentAutoMode", v3);
  sub_1000DEF48((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CreativeVideoAE", v4);
  sub_1000DF23C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::Custom3Set", v5);
  sub_1000DF530((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CreativeControlFilter", v6);
  sub_1000DF824((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::SceneGuideScene", v7);
  sub_1000DFB18((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::Picture4K6K", v8);
  sub_1000DFE0C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::DriveMode", v9);
  sub_1000E0100((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::BurstSpeed", v10);
  sub_1000E03F4((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FocusSelect", v11);
  sub_1000E06E8((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::SelfTimer", v12);
  sub_1000E09DC((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::SelfTimerCustom", v13);
  sub_1000E0CD0((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::IntervalMode", v14);
  sub_1000EAC40((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ShutterSpeed", v15);
  sub_1000E0FC4((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::Iso", v16);
  sub_1000E12B8((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FocusMode", v17);
  sub_1000E15AC((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::AutoFocusMode", v18);
  sub_1000E18A0((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CustomMulti", v19);
  sub_1000EAF3C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::MeteringMode", v20);
  sub_1000E1B94((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ExTelecon", v21);
  sub_1000E1E88((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::PhotoStyle", v22);
  sub_1000E217C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::Exposure", v23);
  sub_1000E2470((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::MotionPictureFormat", v24);
  sub_1000E2764((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::SystemFrequency", v25);
  sub_1000E2A58((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FileTarget", v26);
  sub_1000E2D4C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::WhiteBalance", v27);
  sub_1000E3334((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::WhiteBalanceAdjust", v28);
  sub_1000E3628((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::WhiteBalanceKSet", v29);
  sub_1000E391C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ImgInfoSize", v30);
  sub_1000E3C10((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ImgInfoQuality", v31);
  sub_1000E3F04((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ImgInfoAspect", v32);
  sub_1000E41F8((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ImgInfoFoamet", v33);
  sub_1000E47E0((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ImgInfoJpegHiefMode", v34);
  sub_1000E4AD4((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ImgInfoJpegHiefQuality", v35);
  sub_1000E4DC8((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::RecPreviewMode", v36);
  sub_1000E44EC((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::AFMFMode", v37);
  sub_1000E50BC((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::MFAssistMode", v38);
  sub_1000E53B0((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::PinpointMode", v39);
  sub_1000E56A4((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::LVMagMode", v40);
  sub_1000E5998((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::PinPAspectRatio", v41);
  sub_1000E5C8C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FlashDimmer", v42);
  sub_1000BB6A8((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FlashMode", v43);
  sub_1000BB99C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FlashSync", v44);
  sub_1000BBC90((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FlashAdjust", v45);
  sub_1000BBF84((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::FlashManual", v46);
  sub_1000BC278((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ExposureLink", v47);
  sub_1000BC56C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::WirelessMode", v48);
  sub_1000BC860((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::WirelessChannel", v49);
  sub_1000BCB54((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::WirelessFP", v50);
  sub_1000BCE48((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::WirelessComPower", v51);
  sub_1000BD13C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::BuildInFlashDimmer", v52);
  sub_1000BD430((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::GroupFlashDimmer", v53);
  sub_1000BD724((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::GroupFlashTarget", v54);
  sub_1000E5F80((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CursorType", v55);
  sub_1000EB238((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"DeviceAdapter::MovieConfigQuality", v56);
  sub_1000E9D7C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"AspectRatio", v57);
  sub_1000EA070((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"BatteryLevel", v58);
  sub_1000EA364((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"StatusOfCards", v59);
  sub_1000EA658((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"UsbMode", v60);
  sub_1000E6274((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Cut6K4KState", v61);
  sub_1000EA94C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::LiveViewImageQuality", v62);
  sub_1000E3040((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::LvShootingStatus", v63);
  sub_1000E6560((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::PtpipConnectType", v64);
  sub_1000E7130((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::ConnectDevType", v65);
  sub_1000E7424((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CameraIDList", v66);
  sub_1000E7718((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CameraConnectStatus", v67);
  sub_1000E7A0C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::PowerSavingTetherMode", v68);
  sub_1000E7D00((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::SSGain", v69);
  sub_1000E6854((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CameraSettingFile", v70);
  sub_1000E6B48((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::CameraSettingStatus", v71);
  sub_1000E6E3C((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::PtpIpPasswordMode", v72);
  sub_1000E7FF4((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::PtpIpPasswordError", v73);
  sub_1000E82E8((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::DialogType", v74);
  sub_1000E85DC((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::IconType", v75);
  sub_1000E88D0((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::AutoRecognizeAnimal", v76);
  sub_1000E8BC4((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::AutoRecognizeGeneral", v77);
  sub_1000E8EB8((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::HDMI_SDI_Status", v78);
  sub_1000E91AC((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::TetherModeDisableStatus", v79);
  sub_1000E94A0((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::AutomaticReco", v80);
  sub_1000E9794((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  QMetaObject::normalizedType(&__rqtp, (QMetaObject *)"Utilities::AFFramesMax", v81);
  v82 = (lumixtether::DeviceAdapterCallback *)sub_1000E9A88((QByteArray *)&__rqtp);
  if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
    v82 = (lumixtether::DeviceAdapterCallback *)QArrayData::deallocate(__rqtp.tv_sec, 1, 8);
  Info = lumixtether::DeviceAdapterCallback::CallbackRegist(v82);
  v84 = 0;
  v85 = this + 12;
  atomic_compare_exchange_strong_explicit(
    this + 12,
    (unsigned __int64 *)&v84,
    1u,
    memory_order_acquire,
    memory_order_acquire);
  if ( v84 )
    Info = QBasicMutex::lockInternal((QBasicMutex *)(this + 12));
  *((_BYTE *)this + 88) = 0;
  v86 = 1;
  atomic_compare_exchange_strong_explicit(v85, (unsigned __int64 *)&v86, 0, memory_order_release, memory_order_relaxed);
  if ( v86 != 1 )
    Info = QBasicMutex::unlockInternal((QBasicMutex *)(this + 12));
  v281 = nullptr;
  v282 = nullptr;
  v283 = nullptr;
  while ( 1 )
  {
    v87 = 0;
    atomic_compare_exchange_strong_explicit(
      v85,
      (unsigned __int64 *)&v87,
      1u,
      memory_order_acquire,
      memory_order_acquire);
    if ( v87 )
      Info = QBasicMutex::lockInternal((QBasicMutex *)(this + 12));
    v88 = *((unsigned __int8 *)this + 88);
    v89 = 1;
    atomic_compare_exchange_strong_explicit(
      this + 12,
      (unsigned __int64 *)&v89,
      0,
      memory_order_release,
      memory_order_relaxed);
    if ( v89 != 1 )
      Info = QBasicMutex::unlockInternal((QBasicMutex *)(this + 12));
    if ( v88 )
      break;
    Info = lumixtether::DeviceAdapterCallback::popArgument(this, &v285, &v284, (QString *)&v281);
    if ( (Info & 1) != 0 )
    {
      if ( (int)v285 > 33554447 )
      {
        if ( (int)v285 > 134217743 )
        {
          if ( (int)v285 > 302055583 )
          {
            if ( (int)v285 > 364904463 )
            {
              if ( (int)v285 > 535887871 )
              {
                if ( v285 == 535887872 )
                {
                  DeviceAdapter = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  v146 = v284;
                  v145 = v285;
                  v276[0] = v281;
                  v276[1] = v282;
                  v276[2] = v283;
                  if ( v281 )
                    atomic_fetch_add(v281, 1u);
                  Info = lumixtether::DeviceAdapter::registerEventIdFrameDataTransferRead(
                           DeviceAdapter,
                           v145,
                           v146,
                           v276);
                  if ( v276[0] && atomic_fetch_add(v276[0], 0xFFFFFFFF) == 1 )
                  {
                    tv_sec = v276[0];
                    goto LABEL_500;
                  }
                }
                else if ( v285 == 535953409 )
                {
                  v107 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  v109 = v284;
                  v108 = v285;
                  v275[0] = v281;
                  v275[1] = v282;
                  v275[2] = v283;
                  if ( v281 )
                    atomic_fetch_add(v281, 1u);
                  Info = lumixtether::DeviceAdapter::registerEventIdDeviceStray(v107, v108, v109, v275);
                  if ( v275[0] )
                  {
                    if ( atomic_fetch_add(v275[0], 0xFFFFFFFF) == 1 )
                    {
                      tv_sec = v275[0];
                      goto LABEL_500;
                    }
                  }
                }
              }
              else if ( v285 == 364904464 )
              {
                v132 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                v134 = v284;
                v133 = v285;
                v280[0] = v281;
                v280[1] = v282;
                v280[2] = v283;
                if ( v281 )
                  atomic_fetch_add(v281, 1u);
                Info = lumixtether::DeviceAdapter::registerEventIdNotifyError(v132, v133, v134, v280);
                if ( v280[0] && atomic_fetch_add(v280[0], 0xFFFFFFFF) == 1 )
                {
                  tv_sec = v280[0];
                  goto LABEL_500;
                }
              }
              else if ( v285 == 369098768 )
              {
                v99 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdRecMonitorInfo(v99, v285, v284);
              }
            }
            else
            {
              switch ( v285 )
              {
                case 0x12800110u:
                  v94 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = lumixtether::DeviceAdapter::registerEventId4K6KCfg(v94, v285, v284);
                  break;
                case 0x12800111u:
                  v121 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  v123 = v284;
                  v122 = v285;
                  v277[0] = v281;
                  v277[1] = v282;
                  v277[2] = v283;
                  if ( v281 )
                    atomic_fetch_add(v281, 1u);
                  Info = lumixtether::DeviceAdapter::registerEventId4K6KReady(v121, v122, v123, v277);
                  if ( v277[0] && atomic_fetch_add(v277[0], 0xFFFFFFFF) == 1 )
                  {
                    tv_sec = v277[0];
                    goto LABEL_500;
                  }
                  break;
                case 0x12800112u:
                  v124 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = lumixtether::DeviceAdapter::registerEventId4K6KStart(v124, v285, v284);
                  break;
                case 0x12800113u:
                  v125 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = lumixtether::DeviceAdapter::registerEventId4K6KStop(v125, v285, v284);
                  break;
                default:
                  if ( v285 == 302055584 )
                  {
                    v139 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                    Info = lumixtether::DeviceAdapter::adp_LMX_func_api_LensZoom_Get_Info(v139);
                  }
                  else if ( v285 == 310378562 )
                  {
                    v102 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                    Info = lumixtether::DeviceAdapter::registerEventIdWbsetFailed(v102, v285, v284);
                  }
                  break;
              }
            }
          }
          else if ( (int)v285 <= 268435519 )
          {
            if ( (int)v285 <= 226492431 )
            {
              if ( v285 == 134217744 )
              {
                v142 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdSetupConfig(v142, v285, v284);
              }
              else if ( v285 == 134217808 )
              {
                v105 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdPowerSavingInfo(v105, v285, v284);
              }
            }
            else
            {
              switch ( v285 )
              {
                case 0xD800010u:
                  v128 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = lumixtether::DeviceAdapter::registerEventIdLvImageQuality(v128, v285, v284);
                  break;
                case 0xE000011u:
                  v129 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = lumixtether::DeviceAdapter::registerEventIdErrComTimeOut(v129, v285, v284);
                  break;
                case 0xE000020u:
                  v96 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  v270[0] = v281;
                  v270[1] = v282;
                  v270[2] = v283;
                  if ( v281 )
                    atomic_fetch_add(v281, 1u);
                  Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Net_Get_BasicStreaming_Function_UUID(v96, v270);
                  if ( v270[0] )
                  {
                    if ( atomic_fetch_add(v270[0], 0xFFFFFFFF) == 1 )
                    {
                      tv_sec = v270[0];
                      goto LABEL_500;
                    }
                  }
                  break;
              }
            }
          }
          else if ( (int)v285 > 301989903 )
          {
            switch ( v285 )
            {
              case 0x12000010u:
                v137 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdRecInfo(v137, v285, v284);
                break;
              case 0x12000020u:
                v138 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdExpInShot(v138, v285, v284);
                break;
              case 0x12000070u:
                v101 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = (__int64)lumixtether::DeviceAdapter::registerEventIdLiveViewComposite(v101, v285);
                break;
            }
          }
          else
          {
            switch ( v285 )
            {
              case 0x10000040u:
                v113 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                v115 = v284;
                v114 = v285;
                v279[0] = v281;
                v279[1] = v282;
                v279[2] = v283;
                if ( v281 )
                  atomic_fetch_add(v281, 1u);
                Info = lumixtether::DeviceAdapter::registerEventIdObjectAdd(v113, v114, v115, v279);
                if ( v279[0] && atomic_fetch_add(v279[0], 0xFFFFFFFF) == 1 )
                {
                  tv_sec = v279[0];
                  goto LABEL_500;
                }
                break;
              case 0x10000043u:
                v116 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                v118 = v284;
                v117 = v285;
                v278[0] = v281;
                v278[1] = v282;
                v278[2] = v283;
                if ( v281 )
                  atomic_fetch_add(v281, 1u);
                Info = lumixtether::DeviceAdapter::registerEventIdObjectReqTransfer(v116, v117, v118, v278);
                if ( v278[0] && atomic_fetch_add(v278[0], 0xFFFFFFFF) == 1 )
                {
                  tv_sec = v278[0];
                  goto LABEL_500;
                }
                break;
              case 0x11000000u:
                v92 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdDataProg(v92, v285, v284);
                break;
            }
          }
        }
        else if ( (int)v285 <= 33554623 )
        {
          if ( (int)v285 > 33554527 )
          {
            if ( (int)v285 <= 33554559 )
            {
              if ( v285 == 33554528 )
              {
                v143 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdExposure(v143, v285, v284);
              }
              else if ( v285 == 33554544 )
              {
                v106 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdAfConfig(v106, v285, v284);
              }
            }
            else
            {
              switch ( v285 )
              {
                case 0x2000080u:
                  v130 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = lumixtether::DeviceAdapter::registerEventIdCameraMode(v130, v285, v284);
                  break;
                case 0x20000A0u:
                  v131 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = (__int64)lumixtether::DeviceAdapter::registerEventIdStillImageInfo(v131, v285);
                  break;
                case 0x20000B0u:
                  v98 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                  Info = lumixtether::DeviceAdapter::registerEventIdRecConfig(v98, v285, v284);
                  break;
              }
            }
          }
          else if ( (int)v285 <= 33554479 )
          {
            if ( v285 == 33554448 )
            {
              v140 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdPhotoStyle(v140, v285, v284);
            }
            else if ( v285 == 33554464 )
            {
              v103 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdIso(v103, v285, v284);
            }
          }
          else
          {
            switch ( v285 )
            {
              case 0x2000030u:
                v119 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdShutter(v119, v285, v284);
                break;
              case 0x2000040u:
                v120 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdAperture(v120, v285, v284);
                break;
              case 0x2000050u:
                v93 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdWhiteBalance(v93, v285, v284);
                break;
            }
          }
        }
        else if ( (int)v285 <= 33554847 )
        {
          if ( (int)v285 <= 33554719 )
          {
            if ( v285 == 33554624 )
            {
              v141 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdIntervalConfig(v141, v285, v284);
            }
            else if ( v285 == 33554656 )
            {
              v104 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdRecDispConfig(v104, v285, v284);
            }
          }
          else
          {
            switch ( v285 )
            {
              case 0x2000120u:
                v126 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdAfConfig2(v126, v285, v284);
                break;
              case 0x2000140u:
                v127 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdBurstbracketConfig(v127, v285, v284);
                break;
              case 0x2000170u:
                v95 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
                Info = lumixtether::DeviceAdapter::registerEventIdRecPreview(v95, v285, v284);
                break;
            }
          }
        }
        else if ( (int)v285 > 33554901 )
        {
          switch ( v285 )
          {
            case 0x20001D6u:
              v135 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdAfFrameSmallFrame(v135, v285, v284);
              break;
            case 0x20001F0u:
              v136 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdPhotoStyle2(v136, v285, v284);
              break;
            case 0x6000010u:
              v100 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdMoiveConfig(v100, v285, v284);
              break;
          }
        }
        else
        {
          switch ( v285 )
          {
            case 0x20001A0u:
              v111 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdSelftimerConfig(v111, v285, v284);
              break;
            case 0x20001C0u:
              v112 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventId4k6kConfig(v112, v285, v284);
              break;
            case 0x20001D0u:
              v91 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdAfFrameDispConfig(v91, v285, v284);
              break;
          }
        }
      }
      else
      {
        switch ( v285 )
        {
          case 0xFFFF0101:
            v90 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Set_Mode_Pos(v90, v284);
            continue;
          case 0xFFFF0102:
            v180 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Set_iA_Mode(v180, v284);
            continue;
          case 0xFFFF0103:
            v181 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Set_C3_Param(v181, v284);
            continue;
          case 0xFFFF0104:
            v182 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Mov_Config_Set_C_Movie_mode_Param(v182, v284);
            continue;
          case 0xFFFF0105:
            v183 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Set_CreatvieMode(v183, v284);
            continue;
          case 0xFFFF0106:
            v184 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_BurstBracker_Set_Burst_Param(v184, v284);
            continue;
          case 0xFFFF0107:
            v185 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_4K6K_Set_FocusSelect_Param(v185, v284);
            continue;
          case 0xFFFF0108:
            v186 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_SelfTimer_Set_Param(v186, v284);
            continue;
          case 0xFFFF0109:
            v187 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_IntervalInfo_Set_Mode(v187, v284);
            continue;
          case 0xFFFF010A:
            v188 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Aperture_Set_Param(v188, v284);
            continue;
          case 0xFFFF010B:
            v189 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_SS_SetParam(v189, v284);
            continue;
          case 0xFFFF010C:
            v190 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Set_DriveMode(v190, v284);
            continue;
          case 0xFFFF010D:
            v191 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ISO_SetParam(v191, v284);
            continue;
          case 0xFFFF010E:
            v192 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ISO_SetParam_Auto(v192, v284);
            continue;
          case 0xFFFF010F:
            v193 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Set_K_Set(v193, v284);
            continue;
          case 0xFFFF0110:
            v194 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_AF_Config_Set_AF_Area_Param(v194, v284);
            continue;
          case 0xFFFF0111:
            v195 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_AF_Config_Set_AF_Area_Param_CustomMulti(v195, v284);
            continue;
          case 0xFFFF0112:
            v196 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_MeteringInfo_Set_Mode(v196, v284);
            continue;
          case 0xFFFF0113:
            v197 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_ExTelecon_Set_Cfg(v197, v284);
            continue;
          case 0xFFFF0114:
            v198 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_StyleMode(v198, v284);
            continue;
          case 0xFFFF0115:
            v199 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_Set_ImageQuality(v199, v284);
            continue;
          case 0xFFFF0116:
            v200 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Set_4k_Mode(v200, v284);
            continue;
          case 0xFFFF0117:
            v201 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Set_Param(v201, v284);
            continue;
          case 0xFFFF0118:
            v202 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Set_ADJ_AB(v202, v284);
            continue;
          case 0xFFFF0119:
            v203 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Set_ADJ_AB_Sep(v203, v284);
            continue;
          case 0xFFFF011A:
            v204 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Set_ADJ_GM(v204, v284);
            continue;
          case 0xFFFF011B:
            v205 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Set_ADJ(v205, v284);
            continue;
          case 0xFFFF011C:
            v206 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Exposure_Set_Param(v206, v284);
            continue;
          case 0xFFFF011D:
            v207 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_Set_ImageAspect(v207, v284);
            continue;
          case 0xFFFF011E:
            v208 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecPreview_Cfg_Info_Set_Monitor_Disp(v208, v284);
            continue;
          case 0xFFFF011F:
            v209 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Contrast(v209, v284);
            continue;
          case 0xFFFF0120:
            v210 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Sharpness(v210, v284);
            continue;
          case 0xFFFF0121:
            v211 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_NoiseReduction(v211, v284);
            continue;
          case 0xFFFF0122:
            v212 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Saturation(v212, v284);
            continue;
          case 0xFFFF0123:
            v213 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Filter(v213, v284);
            continue;
          case 0xFFFF0124:
            v147 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_ChromaPhase(v147, v284);
            continue;
          case 0xFFFF0125:
            v148 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Grain(v148, v284);
            continue;
          case 0xFFFF0126:
            v149 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_KneeMode(v149, v284);
            continue;
          case 0xFFFF0127:
            v214 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_ColorTone(v214, v284);
            continue;
          case 0xFFFF0128:
            v215 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_HighLight(v215, v284);
            continue;
          case 0xFFFF0129:
            v216 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Shadow(v216, v284);
            continue;
          case 0xFFFF012A:
            v217 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_ISO(v217, v284);
            continue;
          case 0xFFFF012B:
            v218 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_WB(v218, v284);
            continue;
          case 0xFFFF012C:
            v150 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Base(v150, v284);
            continue;
          case 0xFFFF012D:
            v219 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_DualISO(v219, v284);
            continue;
          case 0xFFFF012E:
            v220 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ISO_SetParam_Gain(v220, v284);
            continue;
          case 0xFFFF012F:
            v221 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_SS_Angle_SetParam(v221, v284);
            continue;
          case 0xFFFF0130:
            v151 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Mov_Config_Set_SS_Gain_Param(v151, v284);
            continue;
          case 0xFFFF0131:
          case 0xFFFF013F:
          case 0xFFFF0140:
          case 0xFFFF0141:
          case 0xFFFF0142:
          case 0xFFFF0143:
          case 0xFFFF0144:
          case 0xFFFF0145:
          case 0xFFFF0146:
          case 0xFFFF0147:
          case 0xFFFF0148:
          case 0xFFFF0149:
          case 0xFFFF014A:
          case 0xFFFF014B:
          case 0xFFFF014C:
          case 0xFFFF014D:
          case 0xFFFF014E:
          case 0xFFFF014F:
          case 0xFFFF0150:
          case 0xFFFF0151:
          case 0xFFFF0152:
          case 0xFFFF0153:
          case 0xFFFF0154:
          case 0xFFFF0155:
          case 0xFFFF0156:
          case 0xFFFF0157:
          case 0xFFFF0158:
          case 0xFFFF0159:
          case 0xFFFF015A:
          case 0xFFFF015B:
          case 0xFFFF015C:
          case 0xFFFF015D:
          case 0xFFFF015E:
          case 0xFFFF015F:
          case 0xFFFF0160:
          case 0xFFFF0161:
          case 0xFFFF0162:
          case 0xFFFF0163:
          case 0xFFFF0164:
          case 0xFFFF0165:
          case 0xFFFF0166:
          case 0xFFFF0167:
          case 0xFFFF0168:
          case 0xFFFF0169:
          case 0xFFFF016A:
          case 0xFFFF016B:
          case 0xFFFF016C:
          case 0xFFFF016D:
          case 0xFFFF016E:
          case 0xFFFF016F:
          case 0xFFFF0170:
          case 0xFFFF0171:
          case 0xFFFF0172:
          case 0xFFFF0173:
          case 0xFFFF0174:
          case 0xFFFF0175:
          case 0xFFFF0176:
          case 0xFFFF0177:
          case 0xFFFF0178:
          case 0xFFFF0179:
          case 0xFFFF017A:
          case 0xFFFF017B:
          case 0xFFFF017C:
          case 0xFFFF017D:
          case 0xFFFF017E:
          case 0xFFFF017F:
          case 0xFFFF0180:
          case 0xFFFF0181:
          case 0xFFFF0182:
          case 0xFFFF0183:
          case 0xFFFF0184:
          case 0xFFFF0185:
          case 0xFFFF0186:
          case 0xFFFF0187:
          case 0xFFFF0188:
          case 0xFFFF0189:
          case 0xFFFF018A:
          case 0xFFFF018B:
          case 0xFFFF018C:
          case 0xFFFF018D:
          case 0xFFFF018E:
          case 0xFFFF018F:
          case 0xFFFF0191:
          case 0xFFFF0192:
          case 0xFFFF0193:
          case 0xFFFF0194:
          case 0xFFFF0195:
          case 0xFFFF0196:
          case 0xFFFF0197:
          case 0xFFFF0198:
          case 0xFFFF0199:
          case 0xFFFF019A:
          case 0xFFFF019B:
          case 0xFFFF019C:
          case 0xFFFF019D:
          case 0xFFFF019E:
          case 0xFFFF019F:
          case 0xFFFF01A0:
          case 0xFFFF01A1:
          case 0xFFFF01A2:
          case 0xFFFF01A3:
          case 0xFFFF01A4:
          case 0xFFFF01A5:
          case 0xFFFF01A6:
          case 0xFFFF01A7:
          case 0xFFFF01A8:
          case 0xFFFF01A9:
          case 0xFFFF01AA:
          case 0xFFFF01AB:
          case 0xFFFF01AC:
          case 0xFFFF01AD:
          case 0xFFFF01AE:
          case 0xFFFF01AF:
          case 0xFFFF01B0:
          case 0xFFFF01B1:
          case 0xFFFF01B2:
          case 0xFFFF01B3:
          case 0xFFFF01B4:
          case 0xFFFF01B5:
          case 0xFFFF01B6:
          case 0xFFFF01B7:
          case 0xFFFF01B8:
          case 0xFFFF01B9:
          case 0xFFFF01BA:
          case 0xFFFF01BB:
          case 0xFFFF01BC:
          case 0xFFFF01BD:
          case 0xFFFF01BE:
          case 0xFFFF01BF:
          case 0xFFFF01C0:
          case 0xFFFF01C1:
          case 0xFFFF01C2:
          case 0xFFFF01C3:
          case 0xFFFF01C4:
          case 0xFFFF01C5:
          case 0xFFFF01C6:
          case 0xFFFF01C7:
          case 0xFFFF01C8:
          case 0xFFFF01C9:
          case 0xFFFF01CA:
          case 0xFFFF01CB:
          case 0xFFFF01CC:
          case 0xFFFF01CD:
          case 0xFFFF01CE:
          case 0xFFFF01CF:
          case 0xFFFF01D0:
          case 0xFFFF01D1:
          case 0xFFFF01D2:
          case 0xFFFF01D3:
          case 0xFFFF01D4:
          case 0xFFFF01D5:
          case 0xFFFF01D6:
          case 0xFFFF01D7:
          case 0xFFFF01D8:
          case 0xFFFF01D9:
          case 0xFFFF01DA:
          case 0xFFFF01DB:
          case 0xFFFF01DC:
          case 0xFFFF01DD:
          case 0xFFFF01DE:
          case 0xFFFF01DF:
          case 0xFFFF01E0:
          case 0xFFFF01E1:
          case 0xFFFF01E2:
          case 0xFFFF01E3:
          case 0xFFFF01E4:
          case 0xFFFF01E5:
          case 0xFFFF01E6:
          case 0xFFFF01E7:
          case 0xFFFF01E8:
          case 0xFFFF01E9:
          case 0xFFFF01EA:
          case 0xFFFF01EB:
          case 0xFFFF01EC:
          case 0xFFFF01ED:
          case 0xFFFF01EE:
          case 0xFFFF01EF:
          case 0xFFFF01F0:
          case 0xFFFF01F1:
          case 0xFFFF01F2:
          case 0xFFFF01F3:
          case 0xFFFF01F4:
          case 0xFFFF01F5:
          case 0xFFFF01F6:
          case 0xFFFF01F7:
          case 0xFFFF01F8:
          case 0xFFFF01F9:
          case 0xFFFF01FA:
          case 0xFFFF01FB:
          case 0xFFFF01FC:
          case 0xFFFF01FD:
          case 0xFFFF01FE:
          case 0xFFFF01FF:
          case 0xFFFF0200:
          case 0xFFFF022C:
          case 0xFFFF022D:
          case 0xFFFF022E:
          case 0xFFFF022F:
          case 0xFFFF0230:
          case 0xFFFF0231:
          case 0xFFFF0232:
          case 0xFFFF0233:
          case 0xFFFF0234:
          case 0xFFFF0235:
          case 0xFFFF0236:
          case 0xFFFF0237:
          case 0xFFFF0238:
          case 0xFFFF0239:
          case 0xFFFF023A:
          case 0xFFFF023B:
          case 0xFFFF023C:
          case 0xFFFF023D:
          case 0xFFFF023E:
          case 0xFFFF023F:
          case 0xFFFF0240:
          case 0xFFFF0241:
          case 0xFFFF0242:
          case 0xFFFF0243:
          case 0xFFFF0244:
          case 0xFFFF0245:
          case 0xFFFF0246:
          case 0xFFFF0247:
          case 0xFFFF0248:
          case 0xFFFF0249:
          case 0xFFFF024A:
          case 0xFFFF024B:
          case 0xFFFF024C:
          case 0xFFFF024D:
          case 0xFFFF024E:
          case 0xFFFF024F:
          case 0xFFFF0250:
          case 0xFFFF0251:
          case 0xFFFF0252:
          case 0xFFFF0253:
          case 0xFFFF0254:
          case 0xFFFF0255:
          case 0xFFFF0256:
          case 0xFFFF0257:
          case 0xFFFF0258:
          case 0xFFFF0259:
          case 0xFFFF025A:
          case 0xFFFF025B:
          case 0xFFFF025C:
          case 0xFFFF025D:
          case 0xFFFF025E:
          case 0xFFFF025F:
          case 0xFFFF0260:
          case 0xFFFF0261:
          case 0xFFFF0262:
          case 0xFFFF0263:
          case 0xFFFF0264:
          case 0xFFFF0265:
          case 0xFFFF0266:
          case 0xFFFF0267:
          case 0xFFFF0268:
          case 0xFFFF0269:
          case 0xFFFF026A:
          case 0xFFFF026B:
          case 0xFFFF026C:
          case 0xFFFF026D:
          case 0xFFFF026E:
          case 0xFFFF026F:
          case 0xFFFF0270:
          case 0xFFFF0271:
          case 0xFFFF0272:
          case 0xFFFF0273:
          case 0xFFFF0274:
          case 0xFFFF0275:
          case 0xFFFF0276:
          case 0xFFFF0277:
          case 0xFFFF0278:
          case 0xFFFF0279:
          case 0xFFFF027A:
          case 0xFFFF027B:
          case 0xFFFF027C:
          case 0xFFFF027D:
          case 0xFFFF027E:
          case 0xFFFF027F:
          case 0xFFFF0280:
          case 0xFFFF0281:
          case 0xFFFF0282:
          case 0xFFFF0283:
          case 0xFFFF0284:
          case 0xFFFF0285:
          case 0xFFFF0286:
          case 0xFFFF0287:
          case 0xFFFF0288:
          case 0xFFFF0289:
          case 0xFFFF028A:
          case 0xFFFF028B:
          case 0xFFFF028C:
          case 0xFFFF028D:
          case 0xFFFF028E:
          case 0xFFFF028F:
          case 0xFFFF0290:
          case 0xFFFF0291:
          case 0xFFFF0292:
          case 0xFFFF0293:
          case 0xFFFF0294:
          case 0xFFFF0295:
          case 0xFFFF0296:
          case 0xFFFF0297:
          case 0xFFFF0298:
          case 0xFFFF0299:
          case 0xFFFF029A:
          case 0xFFFF029B:
          case 0xFFFF029C:
          case 0xFFFF029D:
          case 0xFFFF029E:
          case 0xFFFF029F:
          case 0xFFFF02A0:
          case 0xFFFF02A1:
          case 0xFFFF02A2:
          case 0xFFFF02A3:
          case 0xFFFF02A4:
          case 0xFFFF02A5:
          case 0xFFFF02A6:
          case 0xFFFF02A7:
          case 0xFFFF02A8:
          case 0xFFFF02A9:
          case 0xFFFF02AA:
          case 0xFFFF02AB:
          case 0xFFFF02AC:
          case 0xFFFF02AD:
          case 0xFFFF02AE:
          case 0xFFFF02AF:
          case 0xFFFF02B0:
          case 0xFFFF02B1:
          case 0xFFFF02B2:
          case 0xFFFF02B3:
          case 0xFFFF02B4:
          case 0xFFFF02B5:
          case 0xFFFF02B6:
          case 0xFFFF02B7:
          case 0xFFFF02B8:
          case 0xFFFF02B9:
          case 0xFFFF02BA:
          case 0xFFFF02BB:
          case 0xFFFF02BC:
          case 0xFFFF02BD:
          case 0xFFFF02BE:
          case 0xFFFF02BF:
          case 0xFFFF02C0:
          case 0xFFFF02C1:
          case 0xFFFF02C2:
          case 0xFFFF02C3:
          case 0xFFFF02C4:
          case 0xFFFF02C5:
          case 0xFFFF02C6:
          case 0xFFFF02C7:
          case 0xFFFF02C8:
          case 0xFFFF02C9:
          case 0xFFFF02CA:
          case 0xFFFF02CB:
          case 0xFFFF02CC:
          case 0xFFFF02CD:
          case 0xFFFF02CE:
          case 0xFFFF02CF:
          case 0xFFFF02D0:
          case 0xFFFF02D1:
          case 0xFFFF02D2:
          case 0xFFFF02D3:
          case 0xFFFF02D4:
          case 0xFFFF02D5:
          case 0xFFFF02D6:
          case 0xFFFF02D7:
          case 0xFFFF02D8:
          case 0xFFFF02D9:
          case 0xFFFF02DA:
          case 0xFFFF02DB:
          case 0xFFFF02DC:
          case 0xFFFF02DD:
          case 0xFFFF02DE:
          case 0xFFFF02DF:
          case 0xFFFF02E0:
          case 0xFFFF02E1:
          case 0xFFFF02E2:
          case 0xFFFF02E3:
          case 0xFFFF02E4:
          case 0xFFFF02E5:
          case 0xFFFF02E6:
          case 0xFFFF02E7:
          case 0xFFFF02E8:
          case 0xFFFF02E9:
          case 0xFFFF02EA:
          case 0xFFFF02EB:
          case 0xFFFF02EC:
          case 0xFFFF02ED:
          case 0xFFFF02EE:
          case 0xFFFF02EF:
          case 0xFFFF02F0:
          case 0xFFFF02F1:
          case 0xFFFF02F2:
          case 0xFFFF02F3:
          case 0xFFFF02F4:
          case 0xFFFF02F5:
          case 0xFFFF02F6:
          case 0xFFFF02F7:
          case 0xFFFF02F8:
          case 0xFFFF02F9:
          case 0xFFFF02FA:
          case 0xFFFF02FB:
          case 0xFFFF02FC:
          case 0xFFFF02FD:
          case 0xFFFF02FE:
          case 0xFFFF02FF:
          case 0xFFFF0300:
            continue;
          case 0xFFFF0132:
            v222 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_ColorNoise(v222, v284);
            continue;
          case 0xFFFF0133:
            v223 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_SelfTimer_Set_Custom_Param(v223, v284);
            continue;
          case 0xFFFF0134:
            v152 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_LUT(v152, v284);
            continue;
          case 0xFFFF0135:
            v224 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            QString::toLocal8Bit_helper(&__rqtp, v282, v283);
            if ( !__rqtp.tv_sec || *(int *)__rqtp.tv_sec >= 2 )
              QByteArray::reallocData(&__rqtp, v287, 1);
            Info = lumixtether::DeviceAdapter::registerEventPtpipDisconnectProc(
                     v224,
                     4u,
                     nullptr,
                     (void *)__rqtp.tv_nsec);
            if ( __rqtp.tv_sec && atomic_fetch_add((atomic_uint *volatile)__rqtp.tv_sec, 0xFFFFFFFF) == 1 )
            {
              tv_sec = (atomic_uint *)__rqtp.tv_sec;
              v225 = 1;
              goto LABEL_501;
            }
            continue;
          case 0xFFFF0136:
            v226 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::setLiveviewMode(v226, v284 != 0);
            continue;
          case 0xFFFF0137:
            v153 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Gain(v153, v284);
            continue;
          case 0xFFFF0138:
            v227 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Base2(v227, v284);
            continue;
          case 0xFFFF0139:
            v228 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_LUT2(v228, v284);
            continue;
          case 0xFFFF013A:
            v154 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Density(v154, v284);
            continue;
          case 0xFFFF013B:
            v229 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_Set_Density2(v229, v284);
            continue;
          case 0xFFFF013C:
            v230 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_Set_PhotoExposure_Param(v230, v284);
            continue;
          case 0xFFFF013D:
            v231 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_Set_ImageFormat(v231, v284);
            continue;
          case 0xFFFF013E:
            v232 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_Set_ImageJpegHeifQuality(v232, v284);
            continue;
          case 0xFFFF0190:
            v233 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            v234 = v284;
            v274[0] = v281;
            v274[1] = v282;
            v274[2] = v283;
            if ( v281 )
              atomic_fetch_add(v281, 1u);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_HLG_Set_Cfg(v233, v234, v274);
            if ( v274[0] && atomic_fetch_add(v274[0], 0xFFFFFFFF) == 1 )
            {
              tv_sec = v274[0];
              break;
            }
            continue;
          case 0xFFFF0201:
            v235 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_GetCapability(v235);
            continue;
          case 0xFFFF0202:
            v236 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_BurstBracket_GetCapability(v236);
            continue;
          case 0xFFFF0203:
            v237 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_SelfTimer_GetCapability(v237);
            continue;
          case 0xFFFF0204:
            v238 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_IntervalInfo_GetCapability(v238);
            continue;
          case 0xFFFF0205:
            v155 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_4K6K_GetCapability(v155);
            continue;
          case 0xFFFF0206:
            v239 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_SetupCfgInfo_GetCapability(v239);
            continue;
          case 0xFFFF0207:
            v240 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_SetupFilesCfgInfo_GetCapability(v240);
            continue;
          case 0xFFFF0208:
            v241 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Mov_Config_GetCapability(v241);
            continue;
          case 0xFFFF0209:
            v156 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Aperture_GetCapability(v156);
            continue;
          case 0xFFFF020A:
            v157 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_SS_Get_Capability(v157);
            continue;
          case 0xFFFF020B:
            v242 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_GetCapability(v242);
            continue;
          case 0xFFFF020C:
            v243 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ISO_GetCapability(v243);
            continue;
          case 0xFFFF020D:
            v244 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_GetCapability(v244);
            continue;
          case 0xFFFF020E:
            v158 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_AF_Config_GetCapability(v158);
            continue;
          case 0xFFFF020F:
            v245 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_Metering_GetCapability(v245);
            continue;
          case 0xFFFF0210:
            v159 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Exposure_GetCapability(v159);
            continue;
          case 0xFFFF0211:
            v246 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_GetCapability(v246);
            continue;
          case 0xFFFF0212:
            v160 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecPreview_Cfg_GetCapability(v160);
            continue;
          case 0xFFFF0213:
            v161 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_AF_Frame_GetCapability(v161);
            continue;
          case 0xFFFF0214:
            v247 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_AFMF_Cfg2_GetCapability(v247);
            continue;
          case 0xFFFF0215:
            FlashAdapter = (lumixtether::FlashAdapter *)ApplicationData::getFlashAdapter((ApplicationData *)Info);
            Info = lumixtether::FlashAdapter::adp_LMX_func_api_Strobe_GetCapability(FlashAdapter);
            continue;
          case 0xFFFF0216:
            v162 = (lumixtether::FlashAdapter *)ApplicationData::getFlashAdapter((ApplicationData *)Info);
            Info = lumixtether::FlashAdapter::adp_LMX_func_api_Strobe2_GetCapability(v162);
            continue;
          case 0xFFFF0217:
            v163 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_GetBatteryInfo(v163);
            continue;
          case 0xFFFF0218:
            v249 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_GetCameraStatus(v249);
            continue;
          case 0xFFFF0219:
            v250 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_GetElapsedInMovieRec(v250);
            continue;
          case 0xFFFF021A:
            v251 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            QString::fromUtf8(&__rqtp, 0, &unk_10014269A);
            v272 = __rqtp;
            v273 = v287;
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_GetStatusOfCards(v251, nullptr, (__int64)&v272);
            if ( v272.tv_sec && atomic_fetch_add((atomic_uint *volatile)v272.tv_sec, 0xFFFFFFFF) == 1 )
            {
              tv_sec = (atomic_uint *)v272.tv_sec;
              break;
            }
            continue;
          case 0xFFFF021B:
            v164 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_GetDetailedFreeSpaces(v164);
            continue;
          case 0xFFFF021C:
            v252 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_AFAE_DisplayState(v252);
            continue;
          case 0xFFFF021D:
            v253 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_GetParam(v253);
            continue;
          case 0xFFFF021E:
            v165 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Get_KSet(v165);
            continue;
          case 0xFFFF021F:
            v254 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Get_ADJ_AB(v254);
            continue;
          case 0xFFFF0220:
            v166 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Get_ADJ_GM(v166);
            continue;
          case 0xFFFF0221:
            v255 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_Get_ADJ_AB_Sep(v255);
            continue;
          case 0xFFFF0222:
            v256 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_GetAFInfo(v256);
            continue;
          case 0xFFFF0223:
            v167 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_Set_ImageSize(v167, v284);
            continue;
          case 0xFFFF0224:
            v257 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_AF_Frame_Get_Small_Frame(v257);
            continue;
          case 0xFFFF0225:
            v258 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_AFC_StartPositionState(v258);
            goto LABEL_509;
          case 0xFFFF0226:
LABEL_509:
            v259 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Mov_Filter_GetCapability(v259);
            continue;
          case 0xFFFF0227:
            v260 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle2_GetCapability(v260);
            continue;
          case 0xFFFF0228:
            v261 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_LiveView_Str_Get_Recom_Img(v261);
            continue;
          case 0xFFFF0229:
            v168 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_LiveView_Str_Get_Trans_Img(v168);
            continue;
          case 0xFFFF022A:
            v262 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Rec_Info(v262);
            continue;
          case 0xFFFF022B:
            v263 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_WB_Info(v263);
            continue;
          case 0xFFFF0301:
            v169 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_LiveView_data(v169);
            continue;
          case 0xFFFF0302:
            v170 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Ctrl_LiveView_Start(v170);
            continue;
          case 0xFFFF0303:
            v171 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Ctrl_LiveView_Stop(v171);
            continue;
          case 0xFFFF0304:
            v172 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_NoiseReduction_RemainingTime(v172);
            continue;
          case 0xFFFF0305:
            v173 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_PowerSaving_GetCapability(v173);
            continue;
          case 0xFFFF0306:
            v174 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_FirmwareUpdate(v174);
            continue;
          case 0xFFFF0307:
            v264 = (atomic_ullong *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Search_Camera_List(v264, v284 != 0);
            continue;
          case 0xFFFF0308:
            v265 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_HDMI_SDI_Status(v265);
            continue;
          case 0xFFFF0309:
            v175 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            v177 = v284;
            v176 = v285;
            v271[0] = v281;
            v271[1] = v282;
            v271[2] = v283;
            if ( v281 )
              atomic_fetch_add(v281, 1u);
            Info = lumixtether::DeviceAdapter::registerEventIdRecInfoAnother(v175, v176, v177, v271);
            if ( !v271[0] || atomic_fetch_add(v271[0], 0xFFFFFFFF) != 1 )
              continue;
            tv_sec = v271[0];
            break;
          case 0xFFFF030A:
            v178 = ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            v179 = v284;
            v269[0] = v281;
            v269[1] = v282;
            v269[2] = v283;
            if ( v281 )
              atomic_fetch_add(v281, 1u);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_SetEventTypeFromCamera(v178, v179 != 0, v269);
            if ( !v269[0] || atomic_fetch_add(v269[0], 0xFFFFFFFF) != 1 )
              continue;
            tv_sec = v269[0];
            break;
          case 0xFFFF030B:
            v266 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Select_Device(v266, v284);
            continue;
          case 0xFFFF030C:
            v267 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
            Info = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Shot_Mode_Status(v267);
            continue;
          default:
            if ( v285 == 16777232 )
            {
              v110 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter((ApplicationData *)Info);
              Info = lumixtether::DeviceAdapter::registerEventIdAfInfo(v110, v285, v284);
            }
            continue;
        }
LABEL_500:
        v225 = 2;
LABEL_501:
        Info = QArrayData::deallocate(tv_sec, v225, 8);
      }
    }
    else
    {
      __rqtp = (timespec)xmmword_100148840;
      Info = nanosleep(&__rqtp, nullptr);
    }
  }
  result = lumixtether::DeviceAdapterCallback::CallbackUnRegist((lumixtether::DeviceAdapterCallback *)Info);
  if ( v281 && atomic_fetch_add(v281, 0xFFFFFFFF) == 1 )
    return QArrayData::deallocate(v281, 2, 8);
  return result;
}
