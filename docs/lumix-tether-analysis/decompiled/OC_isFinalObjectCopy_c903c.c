// __ZN11lumixtether10ObjectCopy17isFinalObjectCopyEv @ 0x1000c903c
bool __fastcall lumixtether::ObjectCopy::isFinalObjectCopy(lumixtether::ObjectCopy *this)
{
  return *((_QWORD *)this + 16) <= (__int64)*((unsigned int *)this + 40);
}
