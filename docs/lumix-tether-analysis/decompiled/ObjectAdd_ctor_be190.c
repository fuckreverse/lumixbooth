// __ZN9ObjectAddC2EP7QObject @ 0x1000be190
void __fastcall ObjectAdd::ObjectAdd(ObjectAdd *this, QObject *a2)
{
  QObject *v2; // x0

  v2 = QObject::QObject(this, a2);
  *(_QWORD *)v2 = &off_1009ED3E8;
  *((_QWORD *)v2 + 13) = 0;
  *((_OWORD *)v2 + 1) = 0u;
  *((_OWORD *)v2 + 2) = 0u;
  *((_OWORD *)v2 + 3) = 0u;
  *((_OWORD *)v2 + 4) = 0u;
  *((_QWORD *)v2 + 10) = 0;
}
