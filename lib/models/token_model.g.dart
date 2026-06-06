// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TokenModelAdapter extends TypeAdapter<TokenModel> {
  @override
  final int typeId = 3;

  @override
  TokenModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TokenModel(
      id: fields[0] as String,
      tokenNumber: fields[1] as String,
      vehicleNumber: fields[2] as String,
      vehicleType: fields[3] as String,
      tareWeight: fields[4] as double,
      advanceAmount: fields[5] as double,
      status: fields[6] as String,
      staffId: fields[7] as String,
      tokenDate: fields[8] as String,
      customer_name: fields[9] as String,
      registeredNo: fields[10] as String?,
      ownerName: fields[11] as String?,
      cashAmount: fields[12] == null ? 0 : (fields[12] as num).toDouble(),
      phonepayAmount: fields[13] == null ? 0 : (fields[13] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, TokenModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tokenNumber)
      ..writeByte(2)
      ..write(obj.vehicleNumber)
      ..writeByte(3)
      ..write(obj.vehicleType)
      ..writeByte(4)
      ..write(obj.tareWeight)
      ..writeByte(5)
      ..write(obj.advanceAmount)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.staffId)
      ..writeByte(8)
      ..write(obj.tokenDate)
      ..writeByte(9)
      ..write(obj.customer_name)
      ..writeByte(10)
      ..write(obj.registeredNo)
      ..writeByte(11)
      ..write(obj.ownerName)
      ..writeByte(12)
      ..write(obj.cashAmount)
      ..writeByte(13)
      ..write(obj.phonepayAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
