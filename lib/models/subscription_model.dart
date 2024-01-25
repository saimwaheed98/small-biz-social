// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  late final String id;
  late final double price;
  late final DateTime endDate;
  late final DateTime startDate;

  SubscriptionModel({
    required this.id,
    required this.price,
    required this.endDate,
    required this.startDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'price': price,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      price: map['price'] as double,
      endDate: (map['endDate'] as Timestamp).toDate(),
      startDate: (map['startDate'] as Timestamp).toDate(),
    );
  }

  String toJson() => json.encode(toMap());
  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
