// __ZN11lumixtether10ObjectCopy15pushObjectCopysEv @ 0x1000c8e38
__int64 __fastcall lumixtether::ObjectCopy::pushObjectCopys(lumixtether::ObjectCopy *this)
{
  int v3; // [xsp+4h] [xbp-1Ch] BYREF
  __int64 v4; // [xsp+8h] [xbp-18h] BYREF

  v3 = *(_DWORD *)(*((_QWORD *)this + 2) + 4LL);
  sub_1000BDA18((char *)this + 112, *((_QWORD *)this + 16), &v3);
  v4 = *(_QWORD *)(*((_QWORD *)this + 2) + 8LL);
  return sub_1000C9050((char *)this + 136, *((_QWORD *)this + 19), &v4);
}
