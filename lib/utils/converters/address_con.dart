import 'package:bulletin_board/data/entities/address/address.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class NullableAddressConverters
    implements JsonConverter<Address?, Map<String, dynamic>?> {
  const NullableAddressConverters();

  @override
  Address? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    try {
      return Address.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Map<String, dynamic>? toJson(Address? address) {
    return address?.toJson();
  }
}
