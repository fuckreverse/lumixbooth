// __ZN11lumixtether12DeviceSearch16GetSDKCapabilityEv @ 0x10000a580 (imagebase-relative)
__int64 __fastcall lumixtether::DeviceSearch::GetSDKCapability(lumixtether::DeviceSearch *this)
{
  lumixtether::DeviceAdapter *DeviceAdapter; // x0
  int Capability; // w20
  bool IsConnectTreadCancel; // w8
  __int64 result; // x0
  lumixtether::DeviceAdapter *v6; // x0
  bool v7; // w8
  lumixtether::DeviceAdapter *v8; // x0
  bool v9; // w8
  lumixtether::DeviceAdapter *v10; // x0
  bool v11; // w8
  lumixtether::DeviceAdapter *v12; // x0
  bool v13; // w8
  lumixtether::DeviceAdapter *v14; // x0
  bool v15; // w8
  lumixtether::DeviceAdapter *v16; // x0
  bool v17; // w8
  lumixtether::DeviceAdapter *v18; // x0
  bool v19; // w8
  lumixtether::DeviceAdapter *v20; // x0
  bool v21; // w8
  lumixtether::DeviceAdapter *v22; // x0
  bool v23; // w8
  bool v24; // w8
  lumixtether::DeviceAdapter *v25; // x0
  bool v26; // w8
  lumixtether::DeviceAdapter *v27; // x0
  bool v28; // w8
  lumixtether::DeviceAdapter *v29; // x0
  bool v30; // w8
  lumixtether::DeviceAdapter *v31; // x0
  bool v32; // w8
  lumixtether::DeviceAdapter *v33; // x0
  bool v34; // w8
  lumixtether::DeviceAdapter *v35; // x0
  bool v36; // w8
  lumixtether::DeviceAdapter *v37; // x0
  bool v38; // w8
  lumixtether::DeviceAdapter *v39; // x0
  bool v40; // w8
  lumixtether::DeviceAdapter *v41; // x0
  bool v42; // w8
  lumixtether::DeviceAdapter *v43; // x0
  bool v44; // w8
  bool v45; // w8
  lumixtether::DeviceAdapter *v46; // x0
  ApplicationData *isMultiviewMode; // x0
  lumixtether::DeviceAdapter *v48; // x0
  ApplicationData *v49; // x0
  lumixtether::DeviceAdapter *v50; // x0
  bool v51; // w8
  bool v52; // w8
  lumixtether::DeviceAdapter *v53; // x0
  bool v54; // w8
  lumixtether::FlashAdapter *FlashAdapter; // x0
  bool v56; // w8
  lumixtether::FlashAdapter *v57; // x0
  bool v58; // w8
  lumixtether::DeviceAdapter *v59; // x0
  bool v60; // w8
  lumixtether::DeviceAdapter *v61; // x0
  bool v62; // w8
  bool v63; // w8
  lumixtether::DeviceAdapter *v64; // x0

  DeviceAdapter = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(this);
  Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_CameraMode_GetCapability(DeviceAdapter);
  IsConnectTreadCancel = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( IsConnectTreadCancel )
    return result;
  if ( Capability == 1 )
  {
    v6 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_BurstBracket_GetCapability(v6);
  }
  v7 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v7 )
    return result;
  if ( Capability == 1 )
  {
    v8 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_SelfTimer_GetCapability(v8);
  }
  v9 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v9 )
    return result;
  if ( Capability == 1 )
  {
    v10 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_IntervalInfo_GetCapability(v10);
  }
  v11 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v11 )
    return result;
  if ( Capability == 1 )
  {
    v12 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_4K6K_GetCapability(v12);
  }
  v13 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v13 )
    return result;
  if ( Capability == 1 )
  {
    v14 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_SetupCfgInfo_GetCapability(v14);
  }
  v15 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v15 )
    return result;
  if ( Capability == 1 )
  {
    v16 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_SetupFilesCfgInfo_GetCapability(v16);
  }
  v17 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v17 )
    return result;
  if ( Capability == 1 )
  {
    v18 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_Mov_Config_GetCapability(v18);
  }
  v19 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v19 )
    return result;
  if ( Capability == 1 )
  {
    v20 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    lumixtether::DeviceAdapter::adp_LMX_func_api_Mov_Filter_GetCapability(v20);
    v21 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    result = 0;
    if ( v21 )
      return result;
    v22 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_Aperture_GetCapability(v22);
  }
  else
  {
    v23 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    result = 0;
    if ( v23 )
      return result;
  }
  v24 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v24 )
    return result;
  if ( Capability == 1 )
  {
    v25 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_SS_Get_Capability(v25);
  }
  v26 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v26 )
    return result;
  if ( Capability == 1 )
  {
    v27 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_WB_GetCapability(v27);
  }
  v28 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v28 )
    return result;
  if ( Capability == 1 )
  {
    v29 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_ISO_GetCapability(v29);
  }
  v30 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v30 )
    return result;
  if ( Capability == 1 )
  {
    v31 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_GetCapability(v31);
  }
  v32 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v32 )
    return result;
  if ( Capability == 1 )
  {
    v33 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_AF_Config_GetCapability(v33);
  }
  v34 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v34 )
    return result;
  if ( Capability == 1 )
  {
    v35 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_Metering_GetCapability(v35);
  }
  v36 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v36 )
    return result;
  if ( Capability == 1 )
  {
    v37 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_Exposure_GetCapability(v37);
  }
  v38 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v38 )
    return result;
  if ( Capability == 1 )
  {
    v39 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle_GetCapability(v39);
  }
  v40 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v40 )
    return result;
  if ( Capability == 1 )
  {
    v41 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    lumixtether::DeviceAdapter::adp_LMX_func_api_PhotoStyle2_GetCapability(v41);
    v42 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    result = 0;
    if ( v42 )
      return result;
    v43 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_RecPreview_Cfg_GetCapability(v43);
  }
  else
  {
    v44 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    result = 0;
    if ( v44 )
      return result;
  }
  v45 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v45 )
    return result;
  v46 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
  isMultiviewMode = (ApplicationData *)lumixtether::DeviceAdapter::isMultiviewMode(v46);
  if ( !(_DWORD)isMultiviewMode && Capability == 1 )
  {
    v48 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(isMultiviewMode);
    v49 = (ApplicationData *)lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_AF_Frame_GetCapability(v48);
    Capability = (int)v49;
    if ( (_DWORD)v49 == 1 )
    {
      v50 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(v49);
      lumixtether::DeviceAdapter::adp_LMX_func_api_RecInfo_AF_Frame_Get_Small_Frame(v50);
      v51 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
      result = 0;
      if ( v51 )
        return result;
      goto LABEL_64;
    }
  }
  v52 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( v52 )
    return result;
  if ( Capability == 1 )
  {
LABEL_64:
    v53 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
    Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_AFMF_Cfg2_GetCapability(v53);
  }
  v54 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( !v54 )
  {
    if ( Capability == 1 )
    {
      FlashAdapter = (lumixtether::FlashAdapter *)ApplicationData::getFlashAdapter(nullptr);
      Capability = lumixtether::FlashAdapter::adp_LMX_func_api_Strobe_GetCapability(FlashAdapter);
    }
    v56 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    result = 0;
    if ( !v56 )
    {
      if ( Capability == 1 )
      {
        v57 = (lumixtether::FlashAdapter *)ApplicationData::getFlashAdapter(nullptr);
        Capability = lumixtether::FlashAdapter::adp_LMX_func_api_Strobe2_GetCapability(v57);
      }
      v58 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
      result = 0;
      if ( !v58 )
      {
        if ( Capability == 1 )
        {
          v59 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
          lumixtether::DeviceAdapter::adp_LMX_func_api_PowerSaving_GetCapability(v59);
          v60 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
          result = 0;
          if ( v60 )
            return result;
          v61 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
          Capability = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_HDMI_SDI_Status(v61);
        }
        else
        {
          v62 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
          result = 0;
          if ( v62 )
            return result;
        }
        v63 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
        result = 0;
        if ( !v63 )
        {
          if ( Capability == 1 )
          {
            v64 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
            lumixtether::DeviceAdapter::adp_LMX_func_api_LensZoom_Get_Info(v64);
          }
          return (Capability == 1) & (unsigned int)~lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
        }
      }
    }
  }
  return result;
}
