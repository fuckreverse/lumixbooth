// __ZN11lumixtether13DeviceAdapter18stopCallbackThreadEv @ 0x100034738 (imagebase-relative)
lumixtether::DeviceAdapterCallback *__fastcall lumixtether::DeviceAdapter::stopCallbackThread(
        lumixtether::DeviceAdapter *this)
{
  lumixtether::DeviceAdapterCallback *result; // x0

  result = *((lumixtether::DeviceAdapterCallback **)this + 143);
  if ( result )
    return (lumixtether::DeviceAdapterCallback *)lumixtether::DeviceAdapterCallback::RequestInterruption(result);
  return result;
}
