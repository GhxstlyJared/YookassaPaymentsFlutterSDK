package ru.yoomoney.sdk.kassa.payments.flutter

import android.graphics.Color;
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.io.StringReader
import java.math.BigDecimal
import java.util.Currency
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.Amount
import ru.yoomoney.sdk.kassa.payments.Checkout
import ru.yoomoney.sdk.kassa.payments.ui.color.ColorScheme
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.HostParameters;
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.GooglePayParameters
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.GooglePayCardNetwork
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.MockConfiguration
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.PaymentMethodType
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.SavePaymentMethod
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.PaymentParameters
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.SavedBankCardPaymentParameters
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.TestParameters
import ru.yoomoney.sdk.kassa.payments.TokenizationResult
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.UiParameters

private const val CANCELED_RESULT = "{\"status\":\"canceled\"}"
private const val ERROR_RESULT = "{\"status\":\"error\"}"

class YookassaPaymentsFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener  {

  private lateinit var flutterResult: Result
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity
  private var binding: ActivityPluginBinding? = null

  private val REQUEST_CODE_TOKENIZE = 33
  private val REQUEST_CODE_CONFIRMATION = 44

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ru.yoomoney.yookassa_payments_flutter/yoomoney")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    flutterResult = result

    val data: HashMap<String, Object> = call.arguments as HashMap<String, Object>

    when (call.method) {
      "tokenization" -> tokenization(data)
      "confirmation" -> confirmation(data)
      "repeat" -> repeat(data)
    }
  }

  fun confirmation(data: HashMap<String, Object>) {
    val paymentMethod = when (data["paymentMethod"] as String) {
      "bankCard" -> PaymentMethodType.BANK_CARD
      "yooMoney" -> PaymentMethodType.YOO_MONEY
      "sberbank" -> PaymentMethodType.SBERBANK
      "googlePay" -> PaymentMethodType.GOOGLE_PAY
      else -> PaymentMethodType.BANK_CARD
    }

    val url = data["url"] as String

    val intent: Intent = Checkout.createConfirmationIntent(
      context = context,
      confirmationUrl = url,
      paymentMethodType = paymentMethod
    )

    activity.startActivityForResult(intent, REQUEST_CODE_CONFIRMATION)
  }

  fun repeat(data: HashMap<String, Object>) {
    val showLogs = data["isLoggingEnabled"] as Boolean
    val mockConfiguration: MockConfiguration? = MockConfiguration(data)
    val uiParameters = UiParameters(data)
    var hostParameters = HostParameters(data)
    val testParameters = TestParameters(
      showLogs = showLogs,
      mockConfiguration = mockConfiguration,
      hostParameters = hostParameters
    )

    val parameters = SavedBankCardPaymentParameters(data)

    val intent = Checkout.createSavedCardTokenizeIntent(context, parameters, testParameters)
    activity.startActivityForResult(intent, REQUEST_CODE_TOKENIZE)
  }

  fun tokenization(data: HashMap<String, Object>) {
    val showLogs = data["isLoggingEnabled"] as Boolean
    val mockConfiguration: MockConfiguration? = MockConfiguration(data)
    val uiParameters = UiParameters(data)
    var hostParameters = HostParameters(data)
    val googlePayTestEnvironment = data["googlePayTestEnvironment"] as Boolean
    val testParameters = TestParameters(
      showLogs = showLogs,
      googlePayTestEnvironment = googlePayTestEnvironment,
      mockConfiguration = mockConfiguration,
      hostParameters = hostParameters
    )

    val paymentParameters = PaymentParameters(data)

    val intent = Checkout.createTokenizeIntent(context, paymentParameters, testParameters, uiParameters)
    activity.startActivityForResult(intent, REQUEST_CODE_TOKENIZE)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == REQUEST_CODE_TOKENIZE) {
      if (resultCode == Activity.RESULT_CANCELED) {
        flutterResult.success(CANCELED_RESULT)
      } else if (resultCode == Activity.RESULT_OK && data != null) {
        val result: TokenizationResult = Checkout.createTokenizationResult(data);
        flutterResult.success(result.toJson())
      } else {
        flutterResult.success(ERROR_RESULT)
      }
    } else if (requestCode == REQUEST_CODE_CONFIRMATION) {
      flutterResult.success(resultCode)
    }

    return false
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
    this.binding = binding
  }

  override fun onDetachedFromActivity() {
    binding?.removeActivityResultListener(this)
    binding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.binding?.removeActivityResultListener(this)
    this.binding = binding
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    binding?.removeActivityResultListener(this)
    binding = null
  }
}

private fun PaymentParameters(data: Map<String, Object>): PaymentParameters {
  val amountMap: HashMap<String, Object> = data["amount"] as HashMap<String, Object>
  val amount = Amount(BigDecimal(amountMap["value"] as Double), Currency.getInstance(amountMap["currency"] as String))

  val clientApplicationKey = data["clientApplicationKey"] as String
  val title = data["title"] as String
  val subtitle = data["subtitle"] as String
  val shopId = data["shopId"] as String
  val authCenterClientId = data["moneyAuthClientId"] as? String
  val gatewayId = data["gatewayId"] as? String
  val userPhoneNumber = data["userPhoneNumber"] as? String
  val customReturnUrl = data["returnUrl"] as? String
  val applicationScheme = data["applicationScheme"] as? String
  val customerId = data["customerId"] as? String
  val savePaymentMethod: SavePaymentMethod = SavePaymentMethod(data)
  val paymentMethodTypes = PaymentMethodType(data)
  val googlePayParameters = GooglePayParameters(data)

  return PaymentParameters(
    amount = amount,
    title = title,
    subtitle = subtitle,
    clientApplicationKey = clientApplicationKey,
    shopId = shopId,
    customerId = customerId,
    savePaymentMethod = savePaymentMethod,
    authCenterClientId = authCenterClientId,
    gatewayId = gatewayId,
    userPhoneNumber = userPhoneNumber,
    customReturnUrl = customReturnUrl,
    paymentMethodTypes = paymentMethodTypes,
    googlePayParameters = googlePayParameters
  )
}

private fun PaymentMethodType(data: Map<String, Object>): Set<PaymentMethodType> {
  val flutterPaymentMethodTypes = (data["tokenizationSettings"] as HashMap<String, Object>)["paymentMethodTypes"] as ArrayList<String>
  val paymentMethodTypes: MutableSet<PaymentMethodType> = mutableSetOf()

  for(type in flutterPaymentMethodTypes){
    when (type) {
      "PaymentMethod.bankCard" -> paymentMethodTypes.add(PaymentMethodType.BANK_CARD)
      "PaymentMethod.yooMoney" -> paymentMethodTypes.add(PaymentMethodType.YOO_MONEY)
      "PaymentMethod.sberbank" -> paymentMethodTypes.add(PaymentMethodType.SBERBANK)
      "PaymentMethod.googlePay" -> paymentMethodTypes.add(PaymentMethodType.GOOGLE_PAY)
    }
  }
  return paymentMethodTypes
}

private fun GooglePayParameters(data: Map<String, Object>): GooglePayParameters {
  val flutterGooglePayParameters = data["googlePayParameters"] as ArrayList<String>
  val googlePayParameters: MutableSet<GooglePayCardNetwork> = mutableSetOf()

  for(type in flutterGooglePayParameters){
    when (type) {
      "GooglePayCardNetwork.AMEX" -> googlePayParameters.add(GooglePayCardNetwork.AMEX)
      "GooglePayCardNetwork.DISCOVER" -> googlePayParameters.add(GooglePayCardNetwork.DISCOVER)
      "GooglePayCardNetwork.JCB" -> googlePayParameters.add(GooglePayCardNetwork.JCB)
      "GooglePayCardNetwork.MASTERCARD" -> googlePayParameters.add(GooglePayCardNetwork.MASTERCARD)
      "GooglePayCardNetwork.VISA" -> googlePayParameters.add(GooglePayCardNetwork.VISA)
      "GooglePayCardNetwork.INTERAC" -> googlePayParameters.add(GooglePayCardNetwork.INTERAC)
      "GooglePayCardNetwork.OTHER" -> googlePayParameters.add(GooglePayCardNetwork.OTHER)
    }
  }
  return GooglePayParameters(googlePayParameters)
}

private fun SavedBankCardPaymentParameters(data: Map<String, Object>): SavedBankCardPaymentParameters {
  val amountMap: HashMap<String, Object> = data["amount"] as HashMap<String, Object>
  val amount = Amount(BigDecimal(amountMap["value"] as Double), Currency.getInstance(amountMap["currency"] as String))
  val title = data["title"] as String
  val subtitle = data["subtitle"] as String
  val clientApplicationKey = data["clientApplicationKey"] as String
  val shopId = data["shopId"] as String
  val paymentId = data["paymentMethodId"] as String
  val savePaymentMethod: SavePaymentMethod = SavePaymentMethod(data)

  return SavedBankCardPaymentParameters(
    amount = amount,
    title = title,
    subtitle = subtitle,
    clientApplicationKey = clientApplicationKey,
    shopId = shopId,
    paymentMethodId = paymentId,
    savePaymentMethod = savePaymentMethod
  )
}

private fun SavePaymentMethod(data: Map<String, Object>): SavePaymentMethod {
  return when (data["savePaymentMethod"] as String) {
    "SavePaymentMethod.on" -> SavePaymentMethod.ON
    "SavePaymentMethod.off" -> SavePaymentMethod.OFF
    else -> {
      SavePaymentMethod.USER_SELECTS
    }
  }
}

private fun HostParameters(data: Map<String, Object>): HostParameters {
  val hostParametersData = data["hostParameters"] as? HashMap<String, Object>
  return if (hostParametersData != null) {
    HostParameters(
      hostParametersData["apiHost"] as String,
      hostParametersData["paymentAuthApiHost"] as String,
      hostParametersData["authApiHost"] as String,
      hostParametersData["configHost"] as String,
    )
  } else {
    HostParameters()
  }
}

private fun UiParameters(data: Map<String, Object>): UiParameters {
  val customizationSettings = data["customizationSettings"] as HashMap<String, Object>
  val showLogo = customizationSettings["showYooKassaLogo"] as Boolean
  val dataColor = customizationSettings["mainScheme"] as HashMap<String, Object>

  val alpha = dataColor["alpha"] as Int
  val red = dataColor["red"] as Int
  val blue = dataColor["blue"] as Int
  val green = dataColor["green"] as Int

  return UiParameters(showLogo, ColorScheme(Color.argb(alpha, red, green, blue)))
}

private fun MockConfiguration(data: Map<String, Object>): MockConfiguration? {
  val testModeSettings = data["testModeSettings"] as? HashMap<String, Object>
  if (testModeSettings == null) return null

  val paymentAuthPassed = testModeSettings["paymentAuthorizationPassed"] as Boolean
  val completeWithError = testModeSettings["enablePaymentError"] as Boolean
  val linkedCardsCount = testModeSettings["cardsCount"] as Int
  val serviceFeeMap: HashMap<String, Object> = testModeSettings["charge"] as HashMap<String, Object>
  val serviceFee = Amount(BigDecimal(serviceFeeMap["value"] as Double), Currency.getInstance(serviceFeeMap["currency"] as String))

  return MockConfiguration(completeWithError, paymentAuthPassed, linkedCardsCount, serviceFee)
}