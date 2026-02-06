import 'package:equatable/equatable.dart';

/// Entity representing a route that a lounge serves
/// Each lounge can serve multiple routes, and for each route,
/// the lounge specifies two consecutive stops where it is located between
class LoungeRoute extends Equatable {
  final String? id;
  final String? loungeId;
  final String masterRouteId;
  final String stopBeforeId;
  final String stopAfterId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LoungeRoute({
    this.id,
    this.loungeId,
    required this.masterRouteId,
    required this.stopBeforeId,
    required this.stopAfterId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        loungeId,
        masterRouteId,
        stopBeforeId,
        stopAfterId,
        createdAt,
        updatedAt,
      ];

  LoungeRoute copyWith({
    String? id,
    String? loungeId,
    String? masterRouteId,
    String? stopBeforeId,
    String? stopAfterId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoungeRoute(
      id: id ?? this.id,
      loungeId: loungeId ?? this.loungeId,
      masterRouteId: masterRouteId ?? this.masterRouteId,
      stopBeforeId: stopBeforeId ?? this.stopBeforeId,
      stopAfterId: stopAfterId ?? this.stopAfterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
