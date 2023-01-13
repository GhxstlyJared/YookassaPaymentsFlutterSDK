package ru.yoomoney.sdk.kassa.payments.flutter

import ru.yoomoney.sdk.kassa.payments.TokenizationResult
import org.json.JSONObject
import ru.yoomoney.sdk.kassa.payments.checkoutParameters.PaymentMethodType

fun TokenizationResult.toJson(): String {
    val json = JSONObject()
    json.put("status", "success")
    json.put("paymentToken", paymentToken)
    json.put("paymentMethodType", when(paymentMethodType) {
        PaymentMethodType.YOO_MONEY -> "yoo_money"
        PaymentMethodType.BANK_CARD -> "bank_card"
        PaymentMethodType.SBERBANK -> "sberbank"
        PaymentMethodType.GOOGLE_PAY -> "google_pay"
    })
    return json.toString()
}