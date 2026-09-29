// __ZN11lumixtether13DeviceAdapter32registerEventIdLiveViewCompositeEjj @ 0x100041e80
lumixtether::DeviceAdapter *__fastcall lumixtether::DeviceAdapter::registerEventIdLiveViewComposite(
        lumixtether::DeviceAdapter *this,
        int a2)
{
  if ( a2 == 301990000 )
    return (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::adp_LMX_func_api_Get_Lv_Composite_Info(this);
  return this;
}
