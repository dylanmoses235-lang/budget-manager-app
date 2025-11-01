// GENERATED CODE - Hive Type Adapter for Config

part of 'config.dart';

class ConfigAdapter extends TypeAdapter<Config> {
  @override
  final int typeId = 3;

  @override
  Config read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Config(
      firstPaycheckDate: fields[0] as DateTime,
      paycheckAmount: fields[1] as double,
      payFrequencyDays: fields[2] as int,
      defaultDepositAccount: fields[3] as String,
      viewingMonth: fields[4] as DateTime,
      splitPaycheck: fields[5] as bool? ?? false,
      secondaryDepositAccount: fields[6] as String?,
      primaryDepositAmount: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Config obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.firstPaycheckDate)
      ..writeByte(1)
      ..write(obj.paycheckAmount)
      ..writeByte(2)
      ..write(obj.payFrequencyDays)
      ..writeByte(3)
      ..write(obj.defaultDepositAccount)
      ..writeByte(4)
      ..write(obj.viewingMonth)
      ..writeByte(5)
      ..write(obj.splitPaycheck)
      ..writeByte(6)
      ..write(obj.secondaryDepositAccount)
      ..writeByte(7)
      ..write(obj.primaryDepositAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
