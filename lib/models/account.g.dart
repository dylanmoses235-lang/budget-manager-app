// GENERATED CODE - Hive Type Adapter for Account

part of 'account.dart';

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 0;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      name: fields[0] as String,
      startingBalance: fields[1] as double,
      overdraftLimit: fields[2] as double,
      overdraftUsed: fields[3] as double,
      autoPaychecks: fields[4] as bool,
      icon: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.startingBalance)
      ..writeByte(2)
      ..write(obj.overdraftLimit)
      ..writeByte(3)
      ..write(obj.overdraftUsed)
      ..writeByte(4)
      ..write(obj.autoPaychecks)
      ..writeByte(5)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
