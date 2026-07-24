import 'package:hive/hive.dart';

class SyncOperation extends HiveObject {
  final String id;
  final String entityType;
  final String entityId;
  final ChangeType changeType;
  final Map<String, dynamic> payload;
  final int timestamp;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'entityId': entityId,
        'changeType': changeType.index,
        'payload': payload,
        'timestamp': timestamp,
        'retryCount': retryCount,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'] as String,
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        changeType: ChangeType.values[json['changeType'] as int],
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        timestamp: json['timestamp'] as int,
        retryCount: json['retryCount'] as int? ?? 0,
      );

  SyncOperation copyWith({int? retryCount}) {
    return SyncOperation(
      id: id,
      entityType: entityType,
      entityId: entityId,
      changeType: changeType,
      payload: payload,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

enum ChangeType { create, update, delete }

class SyncOperationAdapter extends TypeAdapter<SyncOperation> {
  @override
  final int typeId = 0;

  @override
  SyncOperation read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      switch (key) {
        case 0:
          fields[0] = reader.readString();
          break;
        case 1:
          fields[1] = reader.readString();
          break;
        case 2:
          fields[2] = reader.readString();
          break;
        case 3:
          fields[3] = ChangeType.values[reader.readByte()];
          break;
        case 4:
          fields[4] = reader.readMap().cast<String, dynamic>();
          break;
        case 5:
          fields[5] = reader.readInt();
          break;
        case 6:
          fields[6] = reader.readInt();
          break;
      }
    }
    return SyncOperation(
      id: fields[0] as String,
      entityType: fields[1] as String,
      entityId: fields[2] as String,
      changeType: fields[3] as ChangeType,
      payload: Map<String, dynamic>.from(fields[4] as Map),
      timestamp: fields[5] as int,
      retryCount: fields[6] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, SyncOperation obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.writeString(obj.id);
    writer.writeByte(1);
    writer.writeString(obj.entityType);
    writer.writeByte(2);
    writer.writeString(obj.entityId);
    writer.writeByte(3);
    writer.writeByte(obj.changeType.index);
    writer.writeByte(4);
    writer.writeMap(obj.payload);
    writer.writeByte(5);
    writer.writeInt(obj.timestamp);
    writer.writeByte(6);
    writer.writeInt(obj.retryCount);
  }
}

class ChangeTypeAdapter extends TypeAdapter<ChangeType> {
  @override
  final int typeId = 1;

  @override
  ChangeType read(BinaryReader reader) {
    return ChangeType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ChangeType obj) {
    writer.writeByte(obj.index);
  }
}
