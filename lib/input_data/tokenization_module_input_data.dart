import 'package:yookassa_payments_flutter/models/amount.dart';
import 'package:yookassa_payments_flutter/models/customization_settings.dart';
import 'package:yookassa_payments_flutter/models/google_pay_parameters.dart';
import 'package:yookassa_payments_flutter/models/method_save_payment.dart';
import 'package:yookassa_payments_flutter/models/test_mode_settings.dart';
import 'package:yookassa_payments_flutter/models/tokenization_settings.dart';
import 'package:yookassa_payments_flutter/models/host_parameters.dart';

class TokenizationModuleInputData {
  String clientApplicationKey;
  String title;
  String subtitle;
  Amount amount;
  SavePaymentMethod savePaymentMethod;
  String shopId;
  String? moneyAuthClientId;
  HostParameters? hostParameters;
  String? gatewayId;
  TokenizationSettings tokenizationSettings;
  TestModeSettings? testModeSettings;
  String? returnUrl;
  bool isLoggingEnabled;
  String? userPhoneNumber;
  CustomizationSettings customizationSettings;
  String? applicationScheme;
  String? customerId;
  GooglePayParameters googlePayParameters;
  bool googlePayTestEnvironment;
  String? applePayID;

  TokenizationModuleInputData(
      {required this.clientApplicationKey,
      required this.title,
      required this.subtitle,
      required this.amount,
      required this.savePaymentMethod,
      required this.shopId,
      this.moneyAuthClientId,
      this.hostParameters,
      this.gatewayId,
      this.tokenizationSettings = const TokenizationSettings(),
      this.testModeSettings,
      this.returnUrl,
      this.isLoggingEnabled = false,
      this.userPhoneNumber,
      this.customizationSettings = const CustomizationSettings(),
      this.applicationScheme,
      this.customerId,
      this.googlePayParameters = const GooglePayParameters(),
      this.googlePayTestEnvironment = false,
      this.applePayID});

  Map<String, dynamic> toJson() => {
        'clientApplicationKey': clientApplicationKey,
        'title': title,
        'subtitle': subtitle,
        'amount': amount.toJson(),
        'savePaymentMethod': savePaymentMethod.toString(),
        'hostParameters': hostParameters?.toJson(),
        'gatewayId': gatewayId,
        'tokenizationSettings': tokenizationSettings.toJson(),
        'testModeSettings': testModeSettings?.toJson(),
        'applePayMerchantIdentifier': applePayID,
        'shopId': shopId,
        'returnUrl': returnUrl,
        'isLoggingEnabled': isLoggingEnabled,
        'userPhoneNumber': userPhoneNumber,
        'customizationSettings': customizationSettings.toJson(),
        'moneyAuthClientId': moneyAuthClientId,
        'applicationScheme': applicationScheme,
        'customerId': customerId,
        'googlePayParameters': googlePayParameters.jsonList(),
        'googlePayTestEnvironment': googlePayTestEnvironment
      };
}
