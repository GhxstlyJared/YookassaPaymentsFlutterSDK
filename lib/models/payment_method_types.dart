class PaymentMethodTypes {
  final List<PaymentMethod> paymentMethodTypes;
  const PaymentMethodTypes(this.paymentMethodTypes);

  List<String> jsonList() {
    return paymentMethodTypes.map((e) => e.toString()).toList();
  }

  static const PaymentMethodTypes bankCard =
      PaymentMethodTypes([PaymentMethod.bankCard]);
  static const PaymentMethodTypes yooMoney =
      PaymentMethodTypes([PaymentMethod.yooMoney]);
  static const PaymentMethodTypes sberbank =
      PaymentMethodTypes([PaymentMethod.sberbank]);
  static const PaymentMethodTypes applePay =
      PaymentMethodTypes([PaymentMethod.applePay]);
  static const PaymentMethodTypes googlePay =
      PaymentMethodTypes([PaymentMethod.googlePay]);
  static const PaymentMethodTypes all = PaymentMethodTypes([
    PaymentMethod.bankCard,
    PaymentMethod.yooMoney,
    PaymentMethod.sberbank,
    PaymentMethod.applePay,
    PaymentMethod.googlePay
  ]);
}

enum PaymentMethod { bankCard, yooMoney, applePay, googlePay, sberbank }

extension PaymentMethodExtension on PaymentMethod {
  static PaymentMethod fromStringValue(String rawValue) {
    switch (rawValue) {
      case 'bank_card':
        return PaymentMethod.bankCard;
      case 'yoo_money':
        return PaymentMethod.yooMoney;
      case 'sberbank':
        return PaymentMethod.sberbank;
      case 'apple_pay':
        return PaymentMethod.applePay;
      case 'google_pay':
        return PaymentMethod.googlePay;
    }
    return PaymentMethod.bankCard;
  }
}
