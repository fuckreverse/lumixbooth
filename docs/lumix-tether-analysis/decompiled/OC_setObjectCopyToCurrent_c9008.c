// __ZN11lumixtether10ObjectCopy22setObjectCopyToCurrentEv @ 0x1000c9008
__int64 __fastcall lumixtether::ObjectCopy::setObjectCopyToCurrent(__int64 this)
{
  __int64 v1; // x8
  __int64 v2; // x10

  v1 = *(unsigned int *)(this + 160);
  v2 = *(_QWORD *)(this + 16);
  *(_DWORD *)(v2 + 4) = *(_DWORD *)(*(_QWORD *)(this + 120) + 4 * v1);
  *(_QWORD *)(v2 + 8) = *(_QWORD *)(*(_QWORD *)(this + 144) + 8 * v1);
  return this;
}
