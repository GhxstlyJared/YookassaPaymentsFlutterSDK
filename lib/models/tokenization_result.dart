import 'package:yookassa_payments_flutter/models/payment_method_types.dart';

class TokenizationResult {
  TokenizationResult._();

  factory TokenizationResult.success(
          String token, PaymentMethod? paymentMethodType) =
      SuccessTokenizationResult;
  factory TokenizationResult.canceled() = CanceledTokenizationResult;
  factory TokenizationResult.error(String error) = ErrorTokenizationResult;

  factory TokenizationResult.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    switch (status) {
      case 'success':
        {
          final token = json['paymentToken'];
          PaymentMethod? paymentMethodType =
              _paymentMethodFromString(json['paymentMethodType']);
          return TokenizationResult.success(token, paymentMethodType);
        }
      case 'canceled':
        return TokenizationResult.canceled();
      default:
        return TokenizationResult.error(json['error'] ?? 'Unknown error');
    }
  }
}

class SuccessTokenizationResult extends TokenizationResult {
  final String token;
  final PaymentMethod? paymentMethodType;

  SuccessTokenizationResult(this.token, this.paymentMethodType) : super._();
}

class CanceledTokenizationResult extends TokenizationResult {
  CanceledTokenizationResult() : super._();
}

class ErrorTokenizationResult extends TokenizationResult {
  final String error;

  ErrorTokenizationResult(this.error) : super._();
}

PaymentMethod? _paymentMethodFromString(String type) {
  switch (type) {
    case "sberbank":
      return PaymentMethod.sberbank;
    case "bank_card":
      return PaymentMethod.bankCard;
    case "yoo_money":
      return PaymentMethod.yooMoney;
    case "apple_pay":
      return PaymentMethod.applePay;
    case "google_pay":
      return PaymentMethod.googlePay;
    default:
      return null;
  }
}
