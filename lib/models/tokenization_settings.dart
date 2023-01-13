import 'payment_method_types.dart';

class TokenizationSettings {
  final PaymentMethodTypes paymentMethodTypes;

  const TokenizationSettings([this.paymentMethodTypes = PaymentMethodTypes.all]);

  Map<String, dynamic> toJson() =>
      {
        'paymentMethodTypes': paymentMethodTypes.jsonList(),
      };
}
