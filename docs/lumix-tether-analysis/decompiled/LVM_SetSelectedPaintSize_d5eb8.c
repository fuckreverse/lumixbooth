// __ZN15LiveViewManager20SetSelectedPaintSizeEdddd @ 0x1000d5eb8 (imagebase-relative)
__int64 __fastcall LiveViewManager::SetSelectedPaintSize(__int64 this, double a2, double a3, double a4, double a5)
{
  if ( *(double *)(this + 760) != a2
    || *(double *)(this + 768) != a3
    || *(double *)(this + 776) != a4
    || *(double *)(this + 784) != a5 )
  {
    *(double *)(this + 760) = a2;
    *(double *)(this + 768) = a3;
    *(double *)(this + 776) = a4;
    *(double *)(this + 784) = a5;
    return LiveViewManager::selctedPaintSizeChanged(
             (LiveViewManager *)this,
             *(_DWORD *)(this + 524) != 0,
             a2,
             a3,
             a4,
             a5);
  }
  return this;
}
