// __ZN15LiveViewManager12UpdateCameraEv @ 0x1000d7034
void __fastcall LiveViewManager::UpdateCamera(LiveViewManager *this)
{
  __int64 v2; // x22
  unsigned __int64 v3; // x23
  __int64 v4; // x8
  __int64 v5; // x27
  __int64 v6; // x8
  __int64 v7; // x28
  unsigned __int64 v8; // x8
  __int64 v9; // x20
  __int64 v10; // x9
  int v11; // w26
  size_t v12; // x21
  __int64 v13; // x25
  __int64 v14; // x8
  __int64 v15; // x9
  int v16; // w10
  const void *v17; // x0
  unsigned __int8 *v18; // x1
  unsigned __int8 *v19; // x8
  unsigned __int8 *v20; // x9
  __int64 v21; // x10
  int v22; // w11
  int v23; // t1
  int v24; // t1
  int v25; // w9
  const std::string *v27; // x1
  std::string *v28; // x21
  __int64 v29; // x8
  __int128 v30; // q0
  __int128 v31; // q1
  __int64 v32; // x27
  unsigned __int64 v33; // x23
  __int64 v34; // x8
  __int64 v35; // x28
  unsigned __int64 v36; // x8
  __int64 v37; // x20
  __int64 v38; // x9
  int v39; // w26
  size_t v40; // x21
  __int64 v41; // x25
  unsigned __int8 **v42; // x8
  unsigned __int8 *v43; // x9
  int v44; // w10
  const void *v45; // x0
  unsigned __int8 *v46; // x1
  unsigned __int8 *v47; // x8
  unsigned __int8 *v48; // x9
  __int64 v49; // x10
  int v50; // w11
  int v51; // t1
  int v52; // t1
  int v53; // w9
  const std::string *v55; // x1
  std::string *v56; // x21
  __int64 v57; // x8
  __int128 v58; // q0
  __int128 v59; // q1
  int v60; // w20
  std::string *v61; // x21
  signed __int64 v62; // x0
  unsigned __int64 v63; // x24
  void **v64; // x20
  void **v65; // x8
  void *v66; // x0
  void **v67; // x21
  int v68; // w20
  std::string *v69; // x21
  signed __int64 v70; // x0
  unsigned __int64 v71; // x24
  void **v72; // x19
  void **v73; // x8
  void *v74; // x0
  void **v75; // x20
  std::string *v76; // x19
  std::string *v77; // x8
  void *v78; // x0
  std::string *v79; // x20
  std::string *v80; // x19
  std::string *v81; // x8
  void *v82; // x0
  std::string *v83; // x20
  void **p_p; // x0
  __int64 v85; // [xsp+18h] [xbp-B8h]
  __int64 v86; // [xsp+18h] [xbp-B8h]
  void *v87; // [xsp+20h] [xbp-B0h] BYREF
  void **v88; // [xsp+28h] [xbp-A8h]
  char *v89; // [xsp+30h] [xbp-A0h] BYREF
  void *__p; // [xsp+38h] [xbp-98h] BYREF
  void **v91; // [xsp+40h] [xbp-90h]
  char *v92; // [xsp+48h] [xbp-88h] BYREF
  void *v93; // [xsp+50h] [xbp-80h] BYREF
  std::string *v94; // [xsp+58h] [xbp-78h]
  std::string *v95; // [xsp+60h] [xbp-70h]
  void *v96; // [xsp+68h] [xbp-68h] BYREF
  std::string *v97; // [xsp+70h] [xbp-60h]
  std::string *v98; // [xsp+78h] [xbp-58h]

  atomic_store(1u, (unsigned __int8 *)this + 560);
  if ( *((_QWORD *)this + 66) )
    std::thread::join((std::thread *)this + 66);
  if ( *((_QWORD *)this + 67) )
    std::thread::join((std::thread *)this + 67);
  if ( *((_QWORD *)this + 68) )
    std::thread::join((std::thread *)this + 68);
  if ( *((_QWORD *)this + 69) )
    std::thread::join((std::thread *)this + 69);
  v96 = nullptr;
  v97 = nullptr;
  v98 = nullptr;
  v93 = nullptr;
  v94 = nullptr;
  v95 = nullptr;
  std::recursive_mutex::lock((std::recursive_mutex *)((char *)this + 144));
  v2 = *((_QWORD *)this + 38);
  if ( v2 != *((_QWORD *)this + 37) )
  {
    v3 = 0;
    v2 = *((_QWORD *)this + 37);
    while ( 1 )
    {
      v5 = *((_QWORD *)this + 34);
      v6 = *((_QWORD *)this + 35) - v5;
      if ( !v6 )
        goto LABEL_45;
      v7 = 0;
      v8 = v6 / 72;
      v9 = v2 + 72 * v3;
      v10 = *(unsigned __int8 *)(v9 + 23);
      v11 = (char)v10;
      if ( (v10 & 0x80u) == 0LL )
        v12 = *(unsigned __int8 *)(v9 + 23);
      else
        v12 = *(_QWORD *)(v9 + 8);
      if ( v8 <= 1 )
        v13 = 1;
      else
        v13 = v8;
      v85 = v10 - 1;
      while ( 1 )
      {
        v14 = v5 + 72 * v7;
        v15 = *(unsigned __int8 *)(v14 + 23);
        v16 = (char)v15;
        if ( (v15 & 0x80u) != 0LL )
          v15 = *(_QWORD *)(v14 + 8);
        if ( v12 != v15 )
          goto LABEL_21;
        v17 = v11 >= 0 ? (const void *)(v2 + 72 * v3) : *(const void **)v9;
        v18 = v16 >= 0 ? (unsigned __int8 *)(v5 + 72 * v7) : *(unsigned __int8 **)v14;
        if ( (v11 & 0x80000000) == 0 )
          break;
        if ( !v12 || !memcmp(v17, v18, v12) )
          goto LABEL_40;
LABEL_21:
        if ( ++v7 == v13 )
          goto LABEL_45;
      }
      if ( !v12 )
        goto LABEL_40;
      if ( *v18 != (unsigned __int8)*(_QWORD *)v9 )
        goto LABEL_21;
      v19 = v18 + 1;
      v20 = (unsigned __int8 *)(v9 + 1);
      v21 = v85;
      while ( v21 )
      {
        v23 = *v20++;
        v22 = v23;
        v24 = *v19++;
        --v21;
        if ( v22 != v24 )
          goto LABEL_21;
      }
LABEL_40:
      v25 = *(unsigned __int8 *)(v5 + 72 * v7 + 56);
      if ( *(unsigned __int8 *)(v2 + 72 * v3 + 56) != v25 && (!*(_BYTE *)(v2 + 72 * v3 + 56) || v25 != 0) )
      {
LABEL_45:
        v27 = (const std::string *)(v2 + 72 * v3);
        v28 = v97;
        if ( v97 == v98 )
        {
          sub_1000ACCF0(&v96, v27);
        }
        else
        {
          std::string::basic_string(v97, v27);
          v29 = v2 + 72 * v3;
          v30 = *(_OWORD *)(v29 + 24);
          v31 = *(_OWORD *)(v29 + 40);
          *(_OWORD *)((char *)v28[2].__r_.__value_.__r.__words + 4) = *(_OWORD *)(v29 + 52);
          *(_OWORD *)&v28[1].__r_.__value_.__r.__words[2] = v31;
          *(_OWORD *)&v28[1].__r_.__value_.__l.__data_ = v30;
          v97 = v28 + 3;
        }
      }
      ++v3;
      v2 = *((_QWORD *)this + 37);
      v4 = *((_QWORD *)this + 38);
      if ( v3 >= 0x8E38E38E38E38E39LL * ((v4 - v2) >> 3) )
        goto LABEL_48;
    }
  }
  v4 = *((_QWORD *)this + 38);
LABEL_48:
  v32 = *((_QWORD *)this + 34);
  if ( *((_QWORD *)this + 35) != v32 )
  {
    v33 = 0;
    v34 = v4 - v2;
    if ( v34 )
      goto LABEL_50;
LABEL_81:
    while ( 2 )
    {
      v55 = (const std::string *)(v32 + 72 * v33);
      v56 = v94;
      if ( v94 == v95 )
      {
        sub_1000ACCF0(&v93, v55);
      }
      else
      {
        std::string::basic_string(v94, v55);
        v57 = v32 + 72 * v33;
        v58 = *(_OWORD *)(v57 + 24);
        v59 = *(_OWORD *)(v57 + 40);
        *(_OWORD *)((char *)v56[2].__r_.__value_.__r.__words + 4) = *(_OWORD *)(v57 + 52);
        *(_OWORD *)&v56[1].__r_.__value_.__r.__words[2] = v59;
        *(_OWORD *)&v56[1].__r_.__value_.__l.__data_ = v58;
        v94 = v56 + 3;
      }
LABEL_84:
      ++v33;
      v32 = *((_QWORD *)this + 34);
      if ( v33 < 0x8E38E38E38E38E39LL * ((*((_QWORD *)this + 35) - v32) >> 3) )
      {
        v2 = *((_QWORD *)this + 37);
        v34 = *((_QWORD *)this + 38) - v2;
        if ( !v34 )
          continue;
LABEL_50:
        v35 = 0;
        v36 = v34 / 72;
        v37 = v32 + 72 * v33;
        v38 = *(unsigned __int8 *)(v37 + 23);
        v39 = (char)v38;
        if ( (v38 & 0x80u) == 0LL )
          v40 = *(unsigned __int8 *)(v37 + 23);
        else
          v40 = *(_QWORD *)(v37 + 8);
        if ( v36 <= 1 )
          v41 = 1;
        else
          v41 = v36;
        v86 = v38 - 1;
        while ( 1 )
        {
          v42 = (unsigned __int8 **)(v2 + 72 * v35);
          v43 = (unsigned __int8 *)*((unsigned __int8 *)v42 + 23);
          v44 = (char)v43;
          if ( (char)v43 < 0 )
            v43 = v42[1];
          if ( (unsigned __int8 *)v40 == v43 )
          {
            if ( v39 >= 0 )
              v45 = (const void *)(v32 + 72 * v33);
            else
              v45 = *(const void **)v37;
            if ( v44 >= 0 )
              v46 = (unsigned __int8 *)(v2 + 72 * v35);
            else
              v46 = *v42;
            if ( v39 < 0 )
            {
              if ( !v40 || !memcmp(v45, v46, v40) )
                goto LABEL_76;
            }
            else
            {
              if ( !v40 )
                goto LABEL_76;
              if ( *v46 == (unsigned __int8)*(_QWORD *)v37 )
              {
                v47 = v46 + 1;
                v48 = (unsigned __int8 *)(v37 + 1);
                v49 = v86;
                while ( v49 )
                {
                  v51 = *v48++;
                  v50 = v51;
                  v52 = *v47++;
                  --v49;
                  if ( v50 != v52 )
                    goto LABEL_57;
                }
LABEL_76:
                v53 = *(unsigned __int8 *)(v2 + 72 * v35 + 56);
                if ( *(unsigned __int8 *)(v32 + 72 * v33 + 56) != v53 && (!*(_BYTE *)(v32 + 72 * v33 + 56) || v53 != 0) )
                  goto LABEL_81;
                goto LABEL_84;
              }
            }
          }
LABEL_57:
          if ( ++v35 == v41 )
            goto LABEL_81;
        }
      }
      break;
    }
  }
  std::recursive_mutex::unlock((std::recursive_mutex *)((char *)this + 144));
  __p = nullptr;
  v91 = nullptr;
  v92 = nullptr;
  v61 = (std::string *)v93;
  v60 = (int)v94;
  v62 = (char *)v94 - (_BYTE *)v93;
  if ( v94 != v93 )
  {
    v63 = 0x8E38E38E38E38E39LL * (v62 >> 3);
    if ( v63 > 0x38E38E38E38E38ELL )
    {
      p_p = &__p;
      goto LABEL_128;
    }
    __p = operator new(v62);
    v92 = (char *)__p + 72 * v63;
    v91 = (void **)sub_1000AA208((int)&v92, v61, v60, (std::string *)__p);
  }
  LiveViewManager::MultiCmd_Start((__int64)this, &__p);
  v64 = (void **)__p;
  if ( __p )
  {
    v65 = v91;
    if ( v91 == __p )
    {
      v66 = __p;
    }
    else
    {
      do
      {
        v67 = v65 - 9;
        if ( *((char *)v65 - 49) < 0 )
          operator delete(*(v65 - 9));
        v65 = v67;
      }
      while ( v67 != v64 );
      v66 = __p;
    }
    v91 = v64;
    operator delete(v66);
  }
  LiveViewManager::StartLive(this, 1);
  v87 = nullptr;
  v88 = nullptr;
  v89 = nullptr;
  v69 = (std::string *)v96;
  v68 = (int)v97;
  v70 = (char *)v97 - (_BYTE *)v96;
  if ( v97 != v96 )
  {
    v71 = 0x8E38E38E38E38E39LL * (v70 >> 3);
    if ( v71 <= 0x38E38E38E38E38ELL )
    {
      v87 = operator new(v70);
      v89 = (char *)v87 + 72 * v71;
      v88 = (void **)sub_1000AA208((int)&v89, v69, v68, (std::string *)v87);
      goto LABEL_101;
    }
    p_p = &v87;
LABEL_128:
    sub_1000AA1F4(p_p);
  }
LABEL_101:
  LiveViewManager::MultiCmd_Stop((__int64)this, &v87);
  v72 = (void **)v87;
  if ( v87 )
  {
    v73 = v88;
    if ( v88 == v87 )
    {
      v74 = v87;
    }
    else
    {
      do
      {
        v75 = v73 - 9;
        if ( *((char *)v73 - 49) < 0 )
          operator delete(*(v73 - 9));
        v73 = v75;
      }
      while ( v75 != v72 );
      v74 = v87;
    }
    v88 = v72;
    operator delete(v74);
  }
  v76 = (std::string *)v93;
  if ( v93 )
  {
    v77 = v94;
    if ( v94 == v93 )
    {
      v78 = v93;
    }
    else
    {
      do
      {
        v79 = v77 - 3;
        if ( SHIBYTE(v77[-3].__r_.__value_.__r.__words[2]) < 0 )
          operator delete(v77[-3].__r_.__value_.__l.__data_);
        v77 = v79;
      }
      while ( v79 != v76 );
      v78 = v93;
    }
    v94 = v76;
    operator delete(v78);
  }
  v80 = (std::string *)v96;
  if ( v96 )
  {
    v81 = v97;
    if ( v97 == v96 )
    {
      v82 = v96;
    }
    else
    {
      do
      {
        v83 = v81 - 3;
        if ( SHIBYTE(v81[-3].__r_.__value_.__r.__words[2]) < 0 )
          operator delete(v81[-3].__r_.__value_.__l.__data_);
        v81 = v83;
      }
      while ( v83 != v80 );
      v82 = v96;
    }
    v97 = v80;
    operator delete(v82);
  }
}
