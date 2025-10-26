// GENERATED CODE - Hive Type Adapter for Bill

part of 'bill.dart';

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 1;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      name: fields[0] as String,
      defaultAmount: fields[1] as double,
      dueDay: fields[2] as int,
      account: fields[3] as String,
      notes: fields[4] as String,
      amount: fields[5] as double?,
      paid: fields[6] as bool,
      paidDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.defaultAmount)
      ..writeByte(2)
      ..write(obj.dueDay)
      ..writeByte(3)
      ..write(obj.account)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.paid)
      ..writeByte(7)
      ..write(obj.paidDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
