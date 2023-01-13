import 'amount.dart';

class TestModeSettings {
  bool paymentAuthorizationPassed;
  int cardsCount;
  Amount charge;
  bool enablePaymentError;

  TestModeSettings(this.paymentAuthorizationPassed, this.cardsCount, this.charge, this.enablePaymentError);

  Map<String, dynamic> toJson() =>
      {
        'paymentAuthorizationPassed': paymentAuthorizationPassed,
        'cardsCount': cardsCount,
        'charge': charge.toJson(),
        'enablePaymentError': enablePaymentError
      };
}