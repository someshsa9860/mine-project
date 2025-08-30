// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripModelAdapter extends TypeAdapter<TripModel> {
  @override
  final int typeId = 2;

  @override
  TripModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripModel(
      id: fields[0] as String,
      tokenId: fields[1] as String,
      grossWeight: fields[2] as double,
      underloadWeight: fields[3] as double,
      overloadWeight: fields[4] as double,
      rweight: fields[5] as double,
      rweightRate: fields[6] as double,
      tokenNumber: fields[15] as String?,
      nweight: fields[7] as double,
      nweightRate: fields[8] as double,
      totalAmount: fields[9] as double,
      finalBalance: fields[10] as double,
      status: fields[11] as String,
      remark: fields[12] as String,
      collected_amount: fields[17] as double?,
      exitDate: fields[13] as String,
      tokenModel: fields[16] as TokenModel?,
      staffId: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tokenId)
      ..writeByte(2)
      ..write(obj.grossWeight)
      ..writeByte(3)
      ..write(obj.underloadWeight)
      ..writeByte(4)
      ..write(obj.overloadWeight)
      ..writeByte(5)
      ..write(obj.rweight)
      ..writeByte(6)
      ..write(obj.rweightRate)
      ..writeByte(7)
      ..write(obj.nweight)
      ..writeByte(8)
      ..write(obj.nweightRate)
      ..writeByte(9)
      ..write(obj.totalAmount)
      ..writeByte(10)
      ..write(obj.finalBalance)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.remark)
      ..writeByte(13)
      ..write(obj.exitDate)
      ..writeByte(14)
      ..write(obj.staffId)
      ..writeByte(15)
      ..write(obj.tokenNumber)
      ..writeByte(16)
      ..write(obj.tokenModel)
      ..writeByte(17)
      ..write(obj.collected_amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
