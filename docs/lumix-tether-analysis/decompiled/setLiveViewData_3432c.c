// __ZN11lumixtether13DeviceAdapter15setLiveViewDataEP38_tag_LMX_STRUCT_LIVEVIEW_INFO_HISTGRAMPmP37_tag_LMX_STRUCT_LIVEVIEW_INFO_POSTURES3_P35_tag_LMX_STRUCT_LIVEVIEW_INFO_LEVELS3_PhS8_S3_S3_PlS3_S3_ @ 0x10003432c (imagebase-relative)
__n128 __fastcall lumixtether::DeviceAdapter::setLiveViewData(
        __int64 a1,
        __int64 a2,
        __int64 a3,
        __int64 a4,
        __int64 a5,
        __int64 a6,
        __int64 a7,
        __int64 a8,
        __int128 a9,
        __int128 a10,
        __int64 a11,
        __int64 a12)
{
  *(_QWORD *)(a1 + 1160) = a2;
  *(_QWORD *)(a1 + 1168) = a3;
  *(_QWORD *)(a1 + 1176) = a4;
  *(_QWORD *)(a1 + 1184) = a5;
  *(_QWORD *)(a1 + 1192) = a6;
  *(_QWORD *)(a1 + 1200) = a7;
  *(_QWORD *)(a1 + 1208) = a8;
  *(_OWORD *)(a1 + 1216) = a9;
  *(_OWORD *)(a1 + 1232) = a10;
  *(_QWORD *)(a1 + 1248) = a11;
  *(_QWORD *)(a1 + 1256) = a12;
  return (__n128)a10;
}
