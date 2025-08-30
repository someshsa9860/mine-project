import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  List<Role>? roles;

  bool isOwner() {
    return role != "staff";
  }

  bool isStaff() {
    return role == "staff";
  }

  String? get role {
    return roles == null
        ? null
        : roles!.isEmpty
        ? null
        : roles!.first.slug?.toLowerCase();
  }

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['username'],
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e))
          .toList(),
    );
  }
}

@HiveType(typeId: 6)
class Role extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? slug;

  Role({this.id, this.name, this.slug});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json['id'], name: json['name'], slug: json['slug']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};
}

@HiveType(typeId: 7)
class AdminPermission extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? slug;

  @HiveField(3)
  String? httpMethod;

  @HiveField(4)
  String? httpPath;

  AdminPermission({
    this.id,
    this.name,
    this.slug,
    this.httpMethod,
    this.httpPath,
  });

  factory AdminPermission.fromJson(Map<String, dynamic> json) {
    return AdminPermission(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      httpMethod: json['http_method'],
      httpPath: json['http_path'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'http_method': httpMethod,
    'http_path': httpPath,
  };
}
