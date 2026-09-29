// __ZN11lumixtether12DeviceSearch11GetSDKValueEv @ 0x10000aa9c (imagebase-relative)
bool __fastcall lumixtether::DeviceSearch::GetSDKValue(lumixtether::DeviceSearch *this)
{
  lumixtether::DeviceAdapter *DeviceAdapter; // x0
  int BatteryInfo; // w20
  bool IsConnectTreadCancel; // w8
  _BOOL8 result; // x0
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
  bool v16; // w8

  DeviceAdapter = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(this);
  BatteryInfo = lumixtether::DeviceAdapter::adp_LMX_func_api_GetBatteryInfo(DeviceAdapter);
  IsConnectTreadCancel = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
  result = 0;
  if ( !IsConnectTreadCancel )
  {
    if ( BatteryInfo == 1 )
    {
      v6 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
      BatteryInfo = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Rec_Info(v6);
    }
    v7 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
    result = 0;
    if ( !v7 )
    {
      if ( BatteryInfo == 1 )
      {
        v8 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
        BatteryInfo = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_WB_Info(v8);
      }
      v9 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
      result = 0;
      if ( !v9 )
      {
        if ( BatteryInfo == 1 )
        {
          v10 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
          BatteryInfo = lumixtether::DeviceAdapter::adp_LMX_func_api_GetAFInfo(v10);
        }
        v11 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
        result = 0;
        if ( !v11 )
        {
          if ( BatteryInfo == 1 )
          {
            v12 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
            lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Lv_Composite_Info(v12);
            v13 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
            result = 0;
            if ( v13 )
              return result;
            v14 = (lumixtether::DeviceAdapter *)ApplicationData::getDeviceAdapter(nullptr);
            BatteryInfo = lumixtether::DeviceAdapter::adp_LMX_func_api_Get_NoiseReduction_RemainingTime(v14);
          }
          else
          {
            v15 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
            result = 0;
            if ( v15 )
              return result;
          }
          v16 = lumixtether::DeviceSearch::IsConnectTreadCancel(this, 0);
          result = 0;
          if ( !v16 )
            return BatteryInfo == 1;
        }
      }
    }
  }
  return result;
}
