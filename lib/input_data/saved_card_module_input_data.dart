import '../models/amount.dart';
import '../models/customization_settings.dart';
import '../models/method_save_payment.dart';
import '../models/test_mode_settings.dart';
import '../models/host_parameters.dart';

class SavedBankCardModuleInputData {
  String clientApplicationKey;
  String title;
  String subtitle;
  Amount amount;
  SavePaymentMethod savePaymentMethod;
  String shopId;
  String paymentMethodId;
  String? gatewayId;
  TestModeSettings? testModeSettings;
  String? returnUrl;
  bool isLoggingEnabled;
  CustomizationSettings customizationSettings;
  String? customerId;
  bool isSafeDeal;
  HostParameters? hostParameters;
  String? applePayID;

  SavedBankCardModuleInputData(
      {required this.clientApplicationKey,
      required this.title,
      required this.subtitle,
      required this.amount,
      required this.savePaymentMethod,
      required this.shopId,
      required this.paymentMethodId,
      required this.isSafeDeal,
      this.gatewayId,
      this.testModeSettings,
      this.returnUrl,
      this.isLoggingEnabled = false,
      this.customizationSettings = const CustomizationSettings(),
      this.customerId,
      this.hostParameters,
      this.applePayID});

  Map<String, dynamic> toJson() => {
        'clientApplicationKey': clientApplicationKey,
        'title': title,
        'subtitle': subtitle,
        'amount': amount.toJson(),
        'savePaymentMethod': savePaymentMethod.toString(),
        'gatewayId': gatewayId,
        'testModeSettings': testModeSettings?.toJson(),
        'applePayMerchantIdentifier': applePayID,
        'shopId': shopId,
        'returnUrl': returnUrl,
        'isLoggingEnabled': isLoggingEnabled,
        'customizationSettings': customizationSettings.toJson(),
        'paymentMethodId': paymentMethodId,
        'customerId': customerId,
        'isSafeDeal': isSafeDeal,
        'hostParameters': hostParameters?.toJson(),
      };
}
