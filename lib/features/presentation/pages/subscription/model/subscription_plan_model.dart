class SubscriptionPlan {
  final int id;
  final String name;
  final String price;
  final int durationDays;
  final String planType;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.planType,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      durationDays: json['duration_days'],
      planType: json['plan_type'],
    );
  }
}
