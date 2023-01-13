import 'package:flutter/material.dart';
import 'package:yookassa_payments_flutter/yookassa_payments_flutter.dart';
import 'package:yookassa_payments_flutter_example/success_tokenization_screen.dart';
import 'package:yookassa_payments_flutter/models/tokenization_result.dart';

class TokenizationScreen extends StatefulWidget {
  const TokenizationScreen({Key? key}) : super(key: key);

  @override
  State<TokenizationScreen> createState() => TokenizationScreenState();
}

class TokenizationScreenState extends State<TokenizationScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: "10.0");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Example App"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: controller,
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                startTokenization();
              },
              child: const Text("Оплатить"))
        ],
      ),
    );
  }

  void startTokenization() async {
    var clientApplicationKey = "<Ключ для клиентских приложений>";
    var amount =
        Amount(value: double.parse(controller.text), currency: Currency.rub);
    var moneyAuthClientId = "<ID для центра авторизации в системе YooMoney>";
    var shopId = "<Идентификатор магазина в ЮKassa>";
    var applicationScheme = "<Схема вашего приложения для deeplink>" "://";
    var tokenizationModuleInputData = TokenizationModuleInputData(
        clientApplicationKey: clientApplicationKey,
        title: "Космические объекты",
        subtitle: "Комета повышенной яркости, период обращения — 112 лет",
        amount: amount,
        savePaymentMethod: SavePaymentMethod.userSelects,
        isLoggingEnabled: true,
        moneyAuthClientId: moneyAuthClientId,
        shopId: shopId,
        customerId: "<Уникальный идентификатор покупателя>",
        applicationScheme: applicationScheme,
        tokenizationSettings: const TokenizationSettings(PaymentMethodTypes([
          PaymentMethod.bankCard,
          PaymentMethod.yooMoney,
          PaymentMethod.sberbank
        ])),
        testModeSettings: null);
    var result =
        await YookassaPaymentsFlutter.tokenization(tokenizationModuleInputData);
    if (result is SuccessTokenizationResult) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => SuccessTokenizationScreen(
                  result: result,
                  tokenizationData: tokenizationModuleInputData)));
    } else if (result is ErrorTokenizationResult) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(content: Text(result.error)));
      return;
    }
  }
}
