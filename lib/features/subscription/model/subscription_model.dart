class SubscriptionsModel {
  SubscriptionsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(SubscriptionItem.fromJson(v)));
    }
  }
  SubscriptionsModel() : data = [];
  String? message;
  List<SubscriptionItem>? data;
}

class SubscriptionItem {
  SubscriptionItem.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    status = json['status']?.toString();
    amount = json['amount']?.toString();
    taxRate = json['tax_rate']?.toString();
    nextBillingCycle = json['next_billing_cycle']?.toString();
    dateSubscribed = json['date_subscribed']?.toString();
    clientName = json['client_name']?.toString();
    currency = json['currency_name']?.toString();
    quantity = json['quantity']?.toString();
    dateCancelled = json['date_cancelled']?.toString();
  }
  String? id;
  String? name;
  String? description;
  String? status;
  String? amount;
  String? taxRate;
  String? nextBillingCycle;
  String? dateSubscribed;
  String? clientName;
  String? currency;
  String? quantity;
  String? dateCancelled;

  String get statusLabel {
    switch (status) {
      case '0':
        return 'Inactive';
      case '1':
        return 'Active';
      case '2':
        return 'Cancelled';
      default:
        return status ?? '';
    }
  }
}
