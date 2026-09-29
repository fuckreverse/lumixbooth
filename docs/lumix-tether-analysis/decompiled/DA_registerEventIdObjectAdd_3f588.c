// __ZN11lumixtether13DeviceAdapter24registerEventIdObjectAddEjj7QString @ 0x10003f588
lumixtether::DeviceAdapter *__fastcall lumixtether::DeviceAdapter::registerEventIdObjectAdd(
        lumixtether::DeviceAdapter *result,
        int a2,
        int a3)
{
  lumixtether::DeviceAdapter *v4; // x20
  __int64 v5; // x8
  lumixtether::ObjectCopy *ObjectCopy; // x0

  if ( a2 == 268435520 )
  {
    v4 = result;
    result = (lumixtether::DeviceAdapter *)lumixtether::DeviceAdapter::getSendCmdDevNum(result, 0);
    if ( (int)result <= 1 )
    {
      v5 = *((_QWORD *)v4 + 140);
      if ( *(_DWORD *)(v5 + 410376) != 1 || (*(_DWORD *)(v5 + 19316) & 0x80000000) != 0 )
      {
        ObjectCopy = (lumixtether::ObjectCopy *)ApplicationData::getObjectCopy(result);
        return (lumixtether::DeviceAdapter *)lumixtether::ObjectCopy::startObjectAdd(ObjectCopy, a3);
      }
    }
  }
  return result;
}
