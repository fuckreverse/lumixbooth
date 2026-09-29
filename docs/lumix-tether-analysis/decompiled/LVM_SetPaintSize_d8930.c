// __ZN15LiveViewManager12SetPaintSizeENSt3__112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEEiiii @ 0x1000d8930 (imagebase-relative)
void __fastcall LiveViewManager::SetPaintSize(__int64 a1, unsigned __int8 *a2, int a3, int a4, int a5, int a6)
{
  __int64 v6; // x20
  __int64 v7; // x21
  unsigned __int64 v11; // x26
  std::recursive_mutex *v12; // x25
  __int64 v13; // x27
  _DWORD *v14; // x8
  __int64 v15; // x9
  __int64 v16; // x8
  size_t v17; // x2
  __int64 v18; // x10
  int v19; // w11
  const void *v20; // x0
  unsigned __int8 *v21; // x1
  __int64 v22; // x8
  unsigned __int8 *v23; // x9
  __int64 v24; // x10
  int v25; // w11
  int v26; // t1

  v7 = *(_QWORD *)(a1 + 272);
  v6 = *(_QWORD *)(a1 + 280);
  if ( v6 != v7 )
  {
    v11 = 0;
    v12 = (std::recursive_mutex *)(a1 + 208);
    v13 = 1;
    do
    {
      v15 = v7 + 72 * v11;
      v16 = *(unsigned __int8 *)(v15 + 23);
      if ( (v16 & 0x80u) == 0LL )
        v17 = *(unsigned __int8 *)(v15 + 23);
      else
        v17 = *(_QWORD *)(v15 + 8);
      v18 = a2[23];
      v19 = (char)v18;
      if ( (v18 & 0x80u) != 0LL )
        v18 = *((_QWORD *)a2 + 1);
      if ( v17 != v18 )
        goto LABEL_4;
      if ( (v16 & 0x80u) == 0LL )
        v20 = (const void *)(v7 + 72 * v11);
      else
        v20 = *(const void **)v15;
      if ( v19 >= 0 )
        v21 = a2;
      else
        v21 = *(unsigned __int8 **)a2;
      if ( (v16 & 0x80) != 0 )
      {
        if ( !v17 || !memcmp(v20, v21, v17) )
          goto LABEL_26;
      }
      else
      {
        if ( !v17 )
          goto LABEL_26;
        if ( *v21 == (unsigned __int8)*(_QWORD *)v15 )
        {
          v22 = v16 - 1;
          v23 = v21 + 1;
          v24 = v13;
          while ( v22 )
          {
            v25 = *(unsigned __int8 *)(v7 + v24);
            v26 = *v23++;
            --v22;
            ++v24;
            if ( v25 != v26 )
              goto LABEL_4;
          }
LABEL_26:
          if ( *(_DWORD *)(v7 + 72 * v11 + 40) != a3
            || *(_DWORD *)(v7 + 72 * v11 + 44) != a4
            || *(_DWORD *)(v7 + 72 * v11 + 48) != a5
            || *(_DWORD *)(v7 + 72 * v11 + 52) != a6 )
          {
            std::recursive_mutex::lock(v12);
            v14 = (_DWORD *)(*(_QWORD *)(a1 + 272) + 72 * v11);
            v14[10] = a3;
            v14[11] = a4;
            v14[12] = a5;
            v14[13] = a6;
            std::recursive_mutex::unlock(v12);
            v7 = *(_QWORD *)(a1 + 272);
            v6 = *(_QWORD *)(a1 + 280);
          }
        }
      }
LABEL_4:
      ++v11;
      v13 += 72;
    }
    while ( 0x8E38E38E38E38E39LL * ((v6 - v7) >> 3) > v11 );
  }
}
