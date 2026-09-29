// __ZN11lumixtether13DeviceAdapter10searchListEv @ 0x1000a3534
__int64 __usercall lumixtether::DeviceAdapter::searchList@<X0>(__int64 this@<X0>, _QWORD *a2@<X8>)
{
  __int64 v2; // x10
  atomic_uint *v3; // x9
  __int64 v4; // x11

  v2 = *(_QWORD *)(this + 1120) + 410280LL;
  v3 = *(atomic_uint **)v2;
  v4 = *(_QWORD *)(*(_QWORD *)(this + 1120) + 410288LL);
  *a2 = *(_QWORD *)v2;
  a2[1] = v4;
  a2[2] = *(_QWORD *)(v2 + 16);
  if ( v3 )
    atomic_fetch_add(v3, 1u);
  return this;
}
