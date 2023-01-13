import Flutter
import UIKit
import YooKassaPayments
import Foundation

var flutterResult: FlutterResult?
var tokenizationModuleInput: TokenizationModuleInput?
var flutterController: FlutterViewController?
var yoomoneyController: UIViewController?

public class SwiftYookassaPaymentsFlutterPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ru.yoomoney.yookassa_payments_flutter/yoomoney", binaryMessenger: registrar.messenger())
    let instance = SwiftYookassaPaymentsFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    flutterResult = result

    // Tokenezation Flow

    if (call.method == YooMoneyService.tokenization.rawValue) {
        guard let data = call.arguments as? [String:AnyObject],
            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
            let tokenizationModuleInputData = try? JSONDecoder().decode(TokenizationModuleInputData.self, from: jsonData)
        else {
            result(YooMoneyErrors.tokenizationData.rawValue)
            return
        }
        
        let controller = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController
        let inputData: TokenizationFlow = .tokenization(tokenizationModuleInputData)

        if let flutterVC = controller {
            let tokenezationViewController = TokenizationAssembly.makeModule(inputData: inputData, moduleOutput: flutterVC)
            yoomoneyController = tokenezationViewController;
            flutterController = flutterVC;

            flutterVC.present(tokenezationViewController, animated: true, completion: nil)
        }
    }

    // Confirmation Flow

    if (call.method == YooMoneyService.confirmation.rawValue) {
        guard let data = call.arguments as? [String:AnyObject],
          let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
          let conformationData = try? JSONDecoder().decode(ConformationData.self, from: jsonData)
              else {
                result(YooMoneyErrors.conformationData.rawValue)
                return
              }

        var paymentMethod: PaymentMethodType?
        switch conformationData.paymentMethod {
        case "bankCard":
          paymentMethod = .bankCard
        case "yooMoney":
          paymentMethod = .yooMoney
        case "sberbank":
          paymentMethod = .sberbank
        case "applePay":
          paymentMethod = .applePay
        default: break
        }

        guard
            let module = tokenizationModuleInput,
            let method = paymentMethod,
            let url = conformationData.url,
            let sheetController = yoomoneyController
        else {
          result(YooMoneyErrors.navigation.rawValue)
          return
        }

        let controller = UIApplication.shared.delegate?.window??.rootViewController as! FlutterViewController
        controller.present(sheetController, animated: true, completion: nil)

        module.startConfirmationProcess(
          confirmationUrl: url,
          paymentMethodType: method
        )
    }

    // BankCardRepeat Flow

    if (call.method == YooMoneyService.repeatPayment.rawValue) {
       guard let data = call.arguments as? [String:AnyObject],
         let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
         let bankCardRepeatModuleInputData = try? JSONDecoder().decode(BankCardRepeatModuleInputData.self, from: jsonData)
         else {
           result(YooMoneyErrors.repeatPaymentData.rawValue)
           return
         }

       let inputData: TokenizationFlow = .bankCardRepeat(bankCardRepeatModuleInputData)

       flutterController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController

       if let controller = flutterController {
            let vc = TokenizationAssembly.makeModule(inputData: inputData, moduleOutput: controller)
            yoomoneyController = vc
            tokenizationModuleInput = vc
            controller.present(vc, animated: true, completion: nil)
       }
    }
  }
}

extension FlutterViewController: TokenizationModuleOutput {

    public func tokenizationModule(
        _ module: TokenizationModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {
        tokenizationModuleInput = module
        
        if let result = flutterResult {
            result("{\"status\":\"success\", \"paymentToken\": \"\(token.paymentToken)\", \"paymentMethodType\": \"\(paymentMethodType.rawValue)\"}")
            DispatchQueue.main.async {
                if let controller = yoomoneyController {
                    controller.dismiss(animated: true)
                }
            }
        }
    }

    public func didFinish(
        on module: TokenizationModuleInput,
        with error: YooKassaPaymentsError?
    ) {
        DispatchQueue.main.async { [weak self] in
            if let controller = yoomoneyController {
                controller.dismiss(animated: true)
            }
        }
        guard let result = flutterResult else { return }
        if let error = error {
            result("{\"status\":\"error\", \"error\": \"\(error.localizedDescription)\"}")
        } else {
            result("{\"status\":\"canceled\"}")
        }
    }

    public func didFinishConfirmation(paymentMethodType: PaymentMethodType) {
        guard let result = flutterResult else { return }
        DispatchQueue.main.async { [weak self] in
            if let controller = yoomoneyController {
                controller.dismiss(animated: true)
            }
        }
        result("{\"paymentMethodType\": \"\(paymentMethodType.rawValue)\"}")
    }
}

struct HostParameters: Codable, Equatable {
    let host: String?
    let paymentAuthorizationHost: String?
    let authHost: String?
    let configHost: String?

    enum CodingKeys: String, CodingKey {
        case host = "host"
        case paymentAuthorizationHost = "paymentAuthorizationHost"
        case authHost = "authHost"
        case configHost = "configHost"
    }
}

struct ConformationData: Codable, Equatable {
    let url: String?
    let paymentMethod: String?

    enum CodingKeys: String, CodingKey {
        case url = "url"
        case paymentMethod = "paymentMethod"
    }
}

enum YooMoneyService: String {
    case tokenization = "tokenization"
    case confirmation = "confirmation"
    case repeatPayment = "repeat"
}

enum YooMoneyErrors: String {
    case navigation = "ErrorNavigation"
    case tokenizationData = "ErrorTokenizationData"
    case conformationData = "ErrorConfirmationData"
    case repeatPaymentData = "ErrorRepeatPaymentData"
    case tokenizationResult = "ErrorTokenizationResult"
}

extension TokenizationModuleInputData: Decodable {
    enum CodingKeys: String, CodingKey {
        case clientApplicationKey = "clientApplicationKey"
        case shopName = "title"
        case purchaseDescription = "subtitle"
        case amount = "amount"
        case savePaymentMethod = "savePaymentMethod"
        case gatewayId = "gatewayId"
        case tokenizationSettings = "tokenizationSettings"
        case testModeSettings = "testModeSettings"
        case applePayMerchantIdentifier = "applePayMerchantIdentifier"
        case returnUrl = "returnUrl"
        case isLoggingEnabled = "isLoggingEnabled"
        case userPhoneNumber = "userPhoneNumber"
        case customizationSettings = "customizationSettings"
        case moneyAuthClientId = "moneyAuthClientId"
        case applicationScheme = "applicationScheme"
        case customerId = "customerId"
        case hostParameters = "hostParameters"
        
        enum CustomizationKeys: String, CodingKey {
            case mainScheme = "mainScheme"
            case showYooKassaLogo = "showYooKassaLogo"
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let clientApplicationKey = try values.decode(String.self, forKey: .clientApplicationKey)
        let shopName = try values.decode(String.self, forKey: .shopName)
        let purchaseDescription = try values.decode(String.self, forKey: .purchaseDescription)
        let amount = try values.decode(Amount.self, forKey: .amount)
        let gatewayId = try? values.decode(String.self, forKey: .gatewayId)
        
        let settings = try values.decode(TokenizationSettings.self, forKey: .tokenizationSettings)
        let customizationContainer = try values.nestedContainer(keyedBy: CodingKeys.CustomizationKeys.self, forKey: .customizationSettings)
        let showYooKassaLogo = try customizationContainer.decode(Bool.self, forKey: .showYooKassaLogo)
        let tokenizationSettings = TokenizationSettings(paymentMethodTypes: settings.paymentMethodTypes, showYooKassaLogo: showYooKassaLogo)
        
        let testModeSettings = try? values.decode(TestModeSettings.self, forKey: .testModeSettings)
        let applePayMerchantIdentifier = try? values.decode(String.self, forKey: .applePayMerchantIdentifier)
        let returnUrl = try? values.decode(String.self, forKey: .returnUrl)
        let isLoggingEnabled = try values.decode(Bool.self, forKey: .isLoggingEnabled)
        let userPhoneNumber = try? values.decode(String.self, forKey: .userPhoneNumber)
        let customizationSettings = try values.decode(CustomizationSettings.self, forKey: .customizationSettings)
        let moneyAuthClientId = try? values.decode(String.self, forKey: .moneyAuthClientId)
        let applicationScheme = try? values.decode(String.self, forKey: .applicationScheme)
        let customerId = try? values.decode(String.self, forKey: .customerId)
        let hostParameters = try? values.decode(HostParameters.self, forKey: .hostParameters)

        var savePaymentMethod: SavePaymentMethod
        switch try values.decode(String.self, forKey: .savePaymentMethod) {
        case "SavePaymentMethod.on":
            savePaymentMethod = .on
        case "SavePaymentMethod.off":
            savePaymentMethod = .off
        default:
            savePaymentMethod = .userSelects
        }

        let userDefaults = UserDefaults.standard
        userDefaults.set(hostParameters != nil, forKey: "dev_host_preference")
        userDefaults.synchronize()

        self.init(
            clientApplicationKey: clientApplicationKey,
            shopName: shopName,
            purchaseDescription: purchaseDescription,
            amount: amount,
            gatewayId: gatewayId,
            tokenizationSettings: tokenizationSettings,
            testModeSettings: testModeSettings,
            applePayMerchantIdentifier: applePayMerchantIdentifier,
            returnUrl: returnUrl,
            isLoggingEnabled: isLoggingEnabled,
            userPhoneNumber: userPhoneNumber,
            customizationSettings: customizationSettings,
            savePaymentMethod: savePaymentMethod,
            moneyAuthClientId: moneyAuthClientId,
            applicationScheme: applicationScheme,
            customerId: customerId
        )
    }
}

extension BankCardRepeatModuleInputData: Decodable {
    enum CodingKeys: String, CodingKey {
        case clientApplicationKey = "clientApplicationKey"
        case shopName = "title"
        case purchaseDescription = "subtitle"
        case amount = "amount"
        case savePaymentMethod = "savePaymentMethod"
        case paymentMethodId = "paymentMethodId"
        case gatewayId = "gatewayId"
        case testModeSettings = "testModeSettings"
        case returnUrl = "returnUrl"
        case isLoggingEnabled = "isLoggingEnabled"
        case customizationSettings = "customizationSettings"
        case cardScanning = "cardScanning"
        case isSafeDeal = "isSafeDeal"
        case customerId = "customerId"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let clientApplicationKey = try values.decode(String.self, forKey: .clientApplicationKey)
        let shopName = try values.decode(String.self, forKey: .shopName)
        let purchaseDescription = try values.decode(String.self, forKey: .purchaseDescription)
        let amount = try values.decode(Amount.self, forKey: .amount)
        let paymentMethodId = try values.decode(String.self, forKey: .paymentMethodId)
        let gatewayId = try? values.decode(String.self, forKey: .gatewayId)
        let testModeSettings = try? values.decode(TestModeSettings.self, forKey: .testModeSettings)
        let returnUrl = try? values.decode(String.self, forKey: .returnUrl)
        let isLoggingEnabled = try values.decode(Bool.self, forKey: .isLoggingEnabled)
        let customizationSettings = try values.decode(CustomizationSettings.self, forKey: .customizationSettings)

        var savePaymentMethod: SavePaymentMethod
                switch try values.decode(String.self, forKey: .savePaymentMethod) {
                case "SavePaymentMethod.on":
                    savePaymentMethod = .on
                case "SavePaymentMethod.off":
                    savePaymentMethod = .off
                default:
                    savePaymentMethod = .userSelects
                }

        self.init(
            clientApplicationKey: clientApplicationKey,
            shopName: shopName,
            purchaseDescription: purchaseDescription,
            paymentMethodId: paymentMethodId,
            amount: amount,
            testModeSettings: testModeSettings,
            returnUrl: returnUrl,
            isLoggingEnabled: isLoggingEnabled,
            customizationSettings: customizationSettings,
            savePaymentMethod: savePaymentMethod,
            gatewayId: gatewayId
        )
    }
}

extension Amount: Decodable {
    enum CodingKeys: String, CodingKey {
        case value = "value"
        case currency = "currency"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let value = try values.decode(Double.self, forKey: .value)
        let currency = try values.decode(String.self, forKey: .currency)
        self.init(value: Decimal(value), currency: .custom(currency))
    }
}

extension TokenizationSettings: Decodable {
    enum CodingKeys: String, CodingKey {
        case paymentMethodTypes = "paymentMethodTypes"
        case showYooKassaLogo = "showYooKassaLogo"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let paymentFlutterMethodTypes = try values.decode([String].self, forKey: .paymentMethodTypes)
        var paymentTypes: PaymentMethodTypes = []
        for type in paymentFlutterMethodTypes {
            switch type {
            case "PaymentMethod.bankCard":
                paymentTypes.insert(.bankCard)
            case "PaymentMethod.yooMoney":
                paymentTypes.insert(.yooMoney)
            case "PaymentMethod.sberbank":
                paymentTypes.insert(.sberbank)
            case "PaymentMethod.applePay":
                paymentTypes.insert(.applePay)
            default: break
            }
        }

        let showYooKassaLogo = try values.decodeIfPresent(Bool.self, forKey: .showYooKassaLogo)
        self.init(paymentMethodTypes: paymentTypes, showYooKassaLogo: showYooKassaLogo ?? true)
    }
}

extension TestModeSettings: Decodable {
    enum CodingKeys: String, CodingKey {
        case paymentAuthorizationPassed = "paymentAuthorizationPassed"
        case cardsCount = "cardsCount"
        case charge = "charge"
        case enablePaymentError = "enablePaymentError"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let paymentAuthorizationPassed = try values.decode(Bool.self, forKey: .paymentAuthorizationPassed)
        let cardsCount = try values.decode(Int.self, forKey: .cardsCount)
        let charge = try values.decode(Amount.self, forKey: .charge)
        let enablePaymentError = try values.decode(Bool.self, forKey: .enablePaymentError)

        self.init(
            paymentAuthorizationPassed: paymentAuthorizationPassed,
            cardsCount: cardsCount,
            charge: charge,
            enablePaymentError: enablePaymentError
        )
    }
}

extension CustomizationSettings: Decodable {
    enum CodingKeys: String, CodingKey {
        case mainScheme = "mainScheme"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemeColor = try values.decode(Color.self, forKey: .mainScheme)

        self.init(mainScheme:
                    UIColor(
                        red: schemeColor.red,
                        green: schemeColor.green,
                        blue: schemeColor.blue,
                        alpha: schemeColor.alpha
                    )
        )
    }
}

struct Color: Decodable {

    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    init(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat,
        alpha: CGFloat
    ) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    enum CodingKeys: String, CodingKey {
        case red = "red"
        case blue = "blue"
        case green = "green"
        case alpha = "alpha"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let red = try values.decode(CGFloat.self, forKey: .red)
        let blue = try values.decode(CGFloat.self, forKey: .blue)
        let green = try values.decode(CGFloat.self, forKey: .green)
        let alpha = try values.decode(CGFloat.self, forKey: .alpha)

        self.init(red: red / 255,
                  green: green / 255,
                  blue: blue / 255,
                  alpha: alpha
        )
    }
}
