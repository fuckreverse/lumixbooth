// __ZN11lumixtether10ObjectCopy16clearObjectCopysEv @ 0x1000c8d08 (imagebase-relative)
__int64 __fastcall lumixtether::ObjectCopy::clearObjectCopys(__int64 this)
{
  __int64 v1; // x19
  __int64 v2; // x8
  __int64 v3; // x3
  __int64 v4; // x8
  __int64 v5; // x8
  __int64 v6; // x3
  __int64 v7; // x8
  __int64 v8; // [xsp+8h] [xbp-18h] BYREF

  v1 = this;
  if ( *(_QWORD *)(this + 128) )
  {
    v2 = *(_QWORD *)(this + 112);
    if ( v2 )
    {
      if ( *(int *)v2 < 2 )
      {
        *(_QWORD *)(this + 128) = 0;
        goto LABEL_10;
      }
      v3 = *(_QWORD *)(v2 + 8);
    }
    else
    {
      v3 = 0;
    }
    v4 = QArrayData::allocate(&v8, 4, 8, v3, 1);
    this = *(_QWORD *)(v1 + 112);
    *(_QWORD *)(v1 + 112) = v8;
    *(_QWORD *)(v1 + 120) = v4;
    *(_QWORD *)(v1 + 128) = 0;
    if ( this && atomic_fetch_add((atomic_uint *volatile)this, 0xFFFFFFFF) == 1 )
      this = QArrayData::deallocate(this, 4, 8);
  }
LABEL_10:
  if ( *(_QWORD *)(v1 + 152) )
  {
    v5 = *(_QWORD *)(v1 + 136);
    if ( v5 )
    {
      if ( *(int *)v5 < 2 )
      {
        *(_QWORD *)(v1 + 152) = 0;
        goto LABEL_19;
      }
      v6 = *(_QWORD *)(v5 + 8);
    }
    else
    {
      v6 = 0;
    }
    v7 = QArrayData::allocate(&v8, 8, 8, v6, 1);
    this = *(_QWORD *)(v1 + 136);
    *(_QWORD *)(v1 + 136) = v8;
    *(_QWORD *)(v1 + 144) = v7;
    *(_QWORD *)(v1 + 152) = 0;
    if ( this && atomic_fetch_add((atomic_uint *volatile)this, 0xFFFFFFFF) == 1 )
      this = QArrayData::deallocate(this, 8, 8);
  }
LABEL_19:
  *(_DWORD *)(v1 + 160) = 0;
  return this;
}
