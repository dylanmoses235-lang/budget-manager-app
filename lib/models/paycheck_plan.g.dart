// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paycheck_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaycheckPlanAdapter extends TypeAdapter<PaycheckPlan> {
  @override
  final int typeId = 4;

  @override
  PaycheckPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaycheckPlan(
      paycheckDate: fields[0] as DateTime,
      amount: fields[1] as double,
      assignedBillNames: (fields[2] as List).cast<String>(),
      isReceived: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PaycheckPlan obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.paycheckDate)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.assignedBillNames)
      ..writeByte(3)
      ..write(obj.isReceived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaycheckPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
