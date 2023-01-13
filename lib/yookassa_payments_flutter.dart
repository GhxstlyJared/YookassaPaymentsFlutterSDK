export 'models/currency.dart';
export 'models/amount.dart';
export 'models/method_save_payment.dart';
export 'models/payment_method_types.dart';
export 'models/tokenization_settings.dart';
export 'models/customization_settings.dart';
export 'models/google_pay_parameters.dart';
export 'models/test_mode_settings.dart';
export 'models/tokenization_result.dart';
export 'input_data/tokenization_module_input_data.dart';

import 'input_data/saved_card_module_input_data.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:yookassa_payments_flutter/models/tokenization_result.dart';
import 'input_data/tokenization_module_input_data.dart';
import 'models/payment_method_types.dart';
import 'models/tokenization_result.dart';

class YookassaPaymentsFlutter {
  static const MethodChannel _channel =
      MethodChannel('ru.yoomoney.yookassa_payments_flutter/yoomoney');

  static Future<TokenizationResult> tokenization(
      TokenizationModuleInputData data) async {
    var inputData = data.toJson();

    return await _channel
        .invokeMethod('tokenization', inputData)
        .then((value) => TokenizationResult.fromJson(json.decode(value)));
  }

  static Future<void> confirmation(
      String url, PaymentMethod? paymentMethod) async {
    var inputData = {'url': url, 'paymentMethod': paymentMethod?.name};
    return await _channel.invokeMethod('confirmation', inputData);
  }

  static Future<TokenizationResult> bankCardRepeat(
      SavedBankCardModuleInputData data) async {
    return await _channel
        .invokeMethod('repeat', data.toJson())
        .then((value) => TokenizationResult.fromJson(json.decode(value)));
  }
}
