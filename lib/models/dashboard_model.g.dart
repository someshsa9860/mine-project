// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashboardModelAdapter extends TypeAdapter<DashboardModel> {
  @override
  final int typeId = 5;

  @override
  DashboardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardModel(
      openTokens: fields[0] as int,
      closedTrips: fields[1] as int,
      closedTripsToday: fields[2] as int,
      totalCollectionToday: fields[3] as double?,
      totalCollectionMonth: fields[4] as double?,
      totalTrips: fields[5] as int?,
      dashboardData: fields[6] as String?,
    )..test = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, DashboardModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.openTokens)
      ..writeByte(1)
      ..write(obj.closedTrips)
      ..writeByte(2)
      ..write(obj.closedTripsToday)
      ..writeByte(3)
      ..write(obj.totalCollectionToday)
      ..writeByte(4)
      ..write(obj.totalCollectionMonth)
      ..writeByte(5)
      ..write(obj.totalTrips)
      ..writeByte(6)
      ..write(obj.dashboardData)
      ..writeByte(7)
      ..write(obj.test);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
