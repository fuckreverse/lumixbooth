// __ZN11lumixtether13DeviceAdapter29registerEventIdStillImageInfoEjj @ 0x10003b470 (imagebase-relative)
lumixtether::DeviceAdapter *__fastcall lumixtether::DeviceAdapter::registerEventIdStillImageInfo(
        lumixtether::DeviceAdapter *this,
        int a2)
{
  lumixtether::DeviceAdapter *v2; // x19

  if ( a2 == 33554592 )
  {
    v2 = this;
    this = (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::adp_LMX_func_api_ImageInfo_GetCapability(this);
    if ( !(_DWORD)this )
      return (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::adp_LMX_func_api_GetImageInfo(v2);
  }
  return this;
}
