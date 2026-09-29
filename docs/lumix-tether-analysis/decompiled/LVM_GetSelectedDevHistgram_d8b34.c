// __ZN15LiveViewManager22GetSelectedDevHistgramEP38_tag_LMX_STRUCT_LIVEVIEW_INFO_HISTGRAM @ 0x1000d8b34 (imagebase-relative)
void __fastcall LiveViewManager::GetSelectedDevHistgram(__int64 a1, __int64 a2)
{
  std::recursive_mutex *v4; // x21
  __int128 v5; // q0
  __int128 v6; // q1
  __int128 v7; // q2

  v4 = (std::recursive_mutex *)(a1 + 616);
  std::recursive_mutex::lock((std::recursive_mutex *)(a1 + 616));
  *(_QWORD *)a2 = *(_QWORD *)(a1 + 680);
  *(_DWORD *)(a2 + 8) = *(_DWORD *)(a1 + 688);
  v5 = *(_OWORD *)(a1 + 692);
  v6 = *(_OWORD *)(a1 + 708);
  v7 = *(_OWORD *)(a1 + 724);
  *(_OWORD *)(a2 + 60) = *(_OWORD *)(a1 + 740);
  *(_OWORD *)(a2 + 44) = v7;
  *(_OWORD *)(a2 + 28) = v6;
  *(_OWORD *)(a2 + 12) = v5;
  std::recursive_mutex::unlock(v4);
}
