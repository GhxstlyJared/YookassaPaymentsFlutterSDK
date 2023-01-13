# YooKassa Payments SDK

Библиотека позволяет встроить прием платежей в мобильные приложения на Flutter и работает как дополнение к API ЮKassa.\
В мобильный SDK входят готовые платежные интерфейсы (форма оплаты и всё, что с ней связано).\
С помощью SDK можно получать токены для проведения оплаты с банковской карты, через Сбербанк Онлайн или из кошелька в ЮMoney.

## Подключение зависимостей

1. В файл `pubspec.yami` добавьте зависимость и запустите `pub get`:

```dart
dependencies:
  flutter:
    sdk: flutter
  yookassa_payments_flutter: ^version
```

или используйте команду `flutter pub add yookassa_payments_flutter`.

2. В Podfile вашего приложения добавьте ссылки на репозитории с podspecs YooKassa:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://git.yoomoney.ru/scm/sdk/cocoa-pod-specs.git'
```

3. Запустите `pod install --repo-update` в директории рядом с Runner.xcworkspace

4. В Info.plist своего приложения добавьте поддержку url-схем для корректной работы mSDK с оплатой через Сбер и ЮMoney:
```
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yookassapaymentsflutter</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>yoomoneyauth</string>
    <string>sberpay</string>
</array>
```

Решение проблем подключения:

А. В случае когда `pod install` завершается с ошибкой – попробуйте команду `pod update YooKassaPayments`

B. В некоторых сложных случаях рекомендуем сбросить кэш cocoapods. Это можно сделать несколькими способам.

   Вариант 1: выполнить набор команд для сброса кэша для пода YooKassaPayments и его зависимостей:
               ```
               pod cache clean FunctionalSwift --all
               pod cache clean MoneyAuth  --all
               pod cache clean ThreatMetrixAdapter  --all
               pod cache clean YooKassaPayments  --all
               pod cache clean YooKassaPaymentsApi  --all
               pod cache clean YooKassaWalletApi  --all
               pod cache clean YooMoneyCoreApi  --all
               pod cache clean TMXProfiling --all
               pod cache clean TMXProfilingConnections --all
               ``` 
   Вариант 2: Удалить полностью кэш cocoapods командой `rm -rf ~/.cocoapods/repos`. Обращаем ваше внимание что после этого
              cocoapods будет восстанавливать свой локальный каталог некоторое время.
              
   Далее рекомендуем выполнить `flutter clean`, `pod clean` и `pod deintegrate YOUR_PROJECT_NAME.xcodeproj`
   для последущей чистой установки командой `pod install`

## Быстрая интеграция

1. Создайте `TokenizationModuleInputData` (понадобится [ключ для клиентских приложений](https://yookassa.ru/my/tunes) из личного кабинета ЮKassa). В этой модели передаются параметры платежа (валюта и сумма) и параметры платежной формы, которые увидит пользователь при оплате (способы оплаты, название магазина и описание заказа).

Пример создания `TokenizationModuleInputData`:

```dart
var clientApplicationKey = "<Ключ для клиентских приложений>";
var amount = Amount(value: 999.9, currency: Currency.rub);
var shopId = "<Идентификатор магазина в ЮKassa)>";
var tokenizationModuleInputData =
          TokenizationModuleInputData(clientApplicationKey: clientApplicationKey,
                                      title: "Космические объекты",
                                      subtitle: "Комета повышенной яркости, период обращения — 112 лет",
                                      amount: amount,
                                      shopId: shopId,
                                      savePaymentMethod: SavePaymentMethod.on);
```

2. Запустите процесс токенизации с кейсом `.tokenization` и передайте `TokenizationModuleInputData`.

```dart
var result = await YookassaPaymentsFlutter.tokenization(tokenizationModuleInputData);
```

3. Получите token в `TokenizationResult`

Пример:

```dart
var result = await YookassaPaymentsFlutter.tokenization(tokenizationModuleInputData);
var token = result.token;
var paymentMethodType = result.paymentMethodType;
```

Закройте модуль SDK и отправьте токен в вашу систему. Затем [создайте платеж](https://yookassa.ru/developers/api#create_payment) по API ЮKassa, в параметре `payment_token` передайте токен, полученный в SDK. Способ подтверждения при создании платежа зависит от способа оплаты, который выбрал пользователь. Он приходит вместе с токеном в `paymentMethodType`.

## Доступные способы оплаты

Сейчас в SDK доступны следующие способы оплаты:

`.yooMoney` — ЮMoney (платежи из кошелька или привязанной картой)\
`.bankCard` — банковская карта (карты можно сканировать)\
`.sberbank` — SberPay (с подтверждением через приложение Сбербанк Онлайн, если оно установленно, иначе с подтверждением по смс)\

## Настройка способов оплаты

У вас есть возможность сконфигурировать способы оплаты.\
Для этого необходимо при создании `TokenizationModuleInputData` в параметре `tokenizationSettings` передать модель типа `TokenizationSettings`.

> Для некоторых способов оплаты нужна дополнительная настройка (см. ниже).\
> По умолчанию используются все доступные способы оплаты.

```dart
// Создайте пустой List<PaymentMethod>
List<PaymentMethod> paymentMethodTypes = [];

if (<Условие для банковской карты>) {
    // Добавляем в paymentMethodTypes элемент `PaymentMethod.bankCard`
    paymentMethodTypes.add(PaymentMethod.bankCard);
}

if (<Условие для Сбербанка Онлайн>) {
    // Добавляем в paymentMethodTypes элемент `PaymentMethod.sberbank`
    paymentMethodTypes.add(PaymentMethod.sberbank);
}

if (<Условие для ЮMoney>) {
    // Добавляем в paymentMethodTypes элемент `PaymentMethod.yooMoney`
    paymentMethodTypes.add(PaymentMethod.yooMoney);
}

var settings = TokenizationSettings(PaymentMethodTypes(paymentMethodTypes));
```

Теперь используйте `tokenizationSettings` при инициализации `TokenizationModuleInputData`.

### ЮMoney

Для подключения способа оплаты `ЮMoney` необходимо:

1. Получить `client id` центра авторизации системы `ЮMoney`.
2. При создании `TokenizationModuleInputData` передать `client id` в параметре `moneyAuthClientId`
3. В `TokenizationSettings` передайте значение `PaymentMethodTypes.yooMoney`.
4. Получите токен.
5. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

#### Как получить `client id` центра авторизации системы `ЮMoney`

1. Авторизуйтесь на [yookassa.ru](https://yookassa.ru)
2. Перейти на страницу регистрации клиентов СЦА - [yookassa.ru/oauth/v2/client](https://yookassa.ru/oauth/v2/client)
3. Нажать [Зарегистрировать](https://yookassa.ru/oauth/v2/client/create)
4. Заполнить поля:\
   4.1. "Название" - `required` поле, отображается при выдаче прав и в списке приложений.\
   4.2. "Описание" - `optional` поле, отображается у пользователя в списке приложений.\
   4.3. "Ссылка на сайт приложения" - `optional` поле, отображается у пользователя в списке приложений.\
   4.4. "Код подтверждения" - выбрать `Передавать в Callback URL`, можно указывать любое значение, например ссылку на сайт.
5. Выбрать доступы:\
   5.1. `Кошелёк ЮMoney` -> `Просмотр`\
   5.2. `Профиль ЮMoney` -> `Просмотр`
6. Нажать `Зарегистрировать`

#### Передать `client id` в параметре `moneyAuthClientId`

При создании `TokenizationModuleInputData` передать `client id` в параметре `moneyAuthClientId`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    moneyAuthClientId: "client_id")
```

Чтобы провести платеж:

1. При создании `TokenizationModuleInputData` передайте значение `.yooMoney` в `paymentMethodTypes.`
2. Получите токен.
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

#### Поддержка авторизации через мобильное приложение

1. В `TokenizationModuleInputData` необходимо передавать `applicationScheme` – схема для возврата в приложение после успешной авторизации в `ЮMoney` через мобильное приложение.

Пример `applicationScheme`:

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applicationScheme: "examplescheme://"
```

2. В `AppDelegate` импортировать зависимость `YooKassaPayments`:

   ```swift
   import YooKassaPayments
   ```

3. Добавить обработку ссылок через `YKSdk` в `AppDelegate`:

```swift
func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?, 
    annotation: Any
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: sourceApplication
    )
}

@available(iOS 9.0, *)
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
    )
}
```

4. В `Info.plist` добавьте следующие строки:

```plistbase
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>yoomoneyauth</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>${BUNDLE_ID}</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>examplescheme</string>
        </array>
    </dict>
</array>
```

где `examplescheme` - схема для открытия вашего приложения, которую вы указали в `applicationScheme` при создании `TokenizationModuleInputData`. Через эту схему будет открываться ваше приложение после успешной авторизации в `ЮMoney` через мобильное приложение.

### Банковская карта

1. При создании `TokenizationModuleInputData` в `TokenizationSettings` передайте значение `PaymentMethodTypes.bankCard`.
2. Получите токен.
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

### SberPay

Чтобы провести платёж:

1. При создании `TokenizationModuleInputData` в `TokenizationSettings` передайте значение `PaymentMethodTypes.sberbank`.
2. Получите токен.
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

Для подтверждения платежа через приложение СберБанк Онлайн:

1. В `AppDelegate` импортируйте зависимость `YooKassaPayments`:

   ```swift
   import YooKassaPayments
   ```

2. Добавьте обработку ссылок через `YKSdk` в `AppDelegate`:

```swift
func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?, 
    annotation: Any
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: sourceApplication
    )
}

@available(iOS 9.0, *)
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
    )
}
```

3. В `Info.plist` добавьте следующие строки:

```plistbase
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>sberpay</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>${BUNDLE_ID}</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>examplescheme</string>
        </array>
    </dict>
</array>
```

где `examplescheme` - схема для открытия вашего приложения, которую вы указали в `applicationScheme` при создании `TokenizationModuleInputData`. Через эту схему будет открываться ваше приложение после успешной оплаты с помощью `SberPay`.

4. Обработка успешного подтверждения уже реализована в плагине. Плагин отобразит алерт с информацией об успешном подтверждении.

## Описание публичных параметров

### TokenizationModuleInputData

>Обязательные:

| Параметр             | Тип    | Описание |
| -------------------- | ------ | -------- |
| clientApplicationKey | String            | Ключ для клиентских приложений из личного кабинета ЮKassa |
| title                | String            | Название магазина в форме оплаты |
| subtitle             | String            | Описание заказа в форме оплаты |
| amount               | Amount            | Объект, содержащий сумму заказа и валюту |
| shopId               | String            | Идентификатор магазина в ЮKassa ([раздел Организации](https://yookassa.ru/my/company/organization) - скопировать shopId у нужного магазина) |
| savePaymentMethod    | SavePaymentMethod | Объект, описывающий логику того, будет ли платеж рекуррентным |

>Необязательные:

| Параметр                   | Тип                   | Описание                                                     |
| -------------------------- | --------------------- | ------------------------------------------------------------ |
| gatewayId                  | String                | По умолчанию `null`. Используется, если у вас несколько платежных шлюзов с разными идентификаторами. |
| tokenizationSettings       | TokenizationSettings  | По умолчанию используется стандартный инициализатор со всеми способами оплаты. Параметр отвечает за настройку токенизации (способы оплаты и логотип ЮKassa). |
| testModeSettings           | TestModeSettings      | По умолчанию `null`. Настройки тестового режима.              |
| cardScanning               | CardScanning          | По умолчанию `null`. Возможность сканировать банковские карты. |
| applePayMerchantIdentifier | String                | По умолчанию `null`. Apple Pay merchant ID (обязательно для платежей через Apple Pay). |
| returnUrl                  | String                | По умолчанию `null`. URL страницы (поддерживается только `https`), на которую надо вернуться после прохождения 3-D Secure. Необходим только при кастомной реализации 3-D Secure. Если вы используете `startConfirmationProcess(confirmationUrl:paymentMethodType:)`, не задавайте этот параметр. |
| isLoggingEnabled           | Bool                  | По умолчанию `false`. Включает логирование сетевых запросов. |
| userPhoneNumber            | String                | По умолчанию `null`. Телефонный номер пользователя.           |
| customizationSettings      | CustomizationSettings | По умолчанию используется цвет blueRibbon. Цвет основных элементов, кнопки, переключатели, поля ввода. |
| moneyAuthClientId          | String                | По умолчанию `null`. Идентификатор для центра авторизации в системе YooMoney. |
| applicationScheme          | String                | По умолчанию `null`. Схема для возврата в приложение после успешной оплаты с помощью `Sberpay` в приложении СберБанк Онлайн или после успешной авторизации в `YooMoney` через мобильное приложение. |
| customerId                      | String                 | По умолчанию `null`. Уникальный идентификатор покупателя в вашей системе, например электронная почта или номер телефона. Не более 200 символов. Используется, если вы хотите запомнить банковскую карту и отобразить ее при повторном платеже в mSdk. Убедитесь, что customerId относится к пользователю, который хочет совершить покупку. Например, используйте двухфакторную аутентификацию. Если передать неверный идентификатор, пользователь сможет выбрать для оплаты чужие банковские карты.|
| googlePayParameters        | GooglePayParameters   | По умолчанию поддерживает mastercard и visa. Настройки для платежей через Google Pay. |

### SavedBankCardModuleInputData

>Обязательные:

| Параметр             | Тип    | Описание |
| -------------------- | ------ | -------- |
| clientApplicationKey | String | Ключ для клиентских приложений из личного кабинета ЮKassa |
| title                | String | Название магазина в форме оплаты |
| subtitle             | String | Описание заказа в форме оплаты |
| paymentMethodId      | String | Идентификатор сохраненного способа оплаты |
| amount               | Amount | Объект, содержащий сумму заказа и валюту |
| shopId               | String            | Идентификатор магазина в ЮKassa ([раздел Организации](https://yookassa.ru/my/company/organization) - скопировать shopId у нужного магазина) |
| savePaymentMethod    | SavePaymentMethod | Объект, описывающий логику того, будет ли платеж рекуррентным |

>Необязательные:

| Параметр              | Тип                   | Описание                                                     |
| --------------------- | --------------------- | ------------------------------------------------------------ |
| gatewayId             | String                | По умолчанию `null`. Используется, если у вас несколько платежных шлюзов с разными идентификаторами. |
| testModeSettings      | TestModeSettings      | По умолчанию `null`. Настройки тестового режима.              |
| returnUrl             | String                | По умолчанию `null`. URL страницы (поддерживается только `https`), на которую надо вернуться после прохождения 3-D Secure. Необходим только при кастомной реализации 3-D Secure. Если вы используете `startConfirmationProcess(confirmationUrl:paymentMethodType:)`, не задавайте этот параметр. |
| isLoggingEnabled      | Bool                  | По умолчанию `false`. Включает логирование сетевых запросов. |
| customizationSettings | CustomizationSettings | По умолчанию используется цвет Color.fromARGB(255, 0, 112, 240). Цвет основных элементов, кнопки, переключатели, поля ввода. |

### TokenizationSettings

Можно настроить список способов оплаты и отображение логотипа ЮKassa в приложении.

| Параметр               | Тип                | Описание |
| ---------------------- | ------------------ | -------- |
| paymentMethodTypes     | PaymentMethodTypes | По умолчанию `PaymentMethodTypes.all`. [Способы оплаты](#настройка-способов-оплаты), доступные пользователю в приложении. |
| showYooKassaLogo       | Bool               | По умолчанию `true`. Отвечает за отображение логотипа ЮKassa. По умолчанию логотип отображается. |

### TestModeSettings

| Параметр                   | Тип    | Описание |
| -------------------------- | ------ | -------- |
| paymentAuthorizationPassed | Bool   | Определяет, пройдена ли платежная авторизация при оплате ЮMoney. |
| cardsCount                 | Int    | Количество привязанные карт к кошельку в ЮMoney. |
| charge                     | Amount | Сумма и валюта платежа. |
| enablePaymentError         | Bool   | Определяет, будет ли платеж завершен с ошибкой. |

### Amount

| Параметр | Тип      | Описание |
| -------- | -------- | -------- |
| value    | Double   | Сумма платежа |
| currency | Currency | Валюта платежа |

### Currency

| Параметр            | Тип      | Описание |
| --------            | -------- | -------- |
| Currency.rub        | String   | ₽ - Российский рубль |
| Currency.usd        | String   | $ - Американский доллар |
| Currency.eur        | String   | € - Евро |
| Currency(“custom”)  | String   | Будет отображаться значение, которое передали |

### CustomizationSettings

| Параметр   | Тип     | Описание |
| ---------- | ------- | -------- |
| mainScheme | Color | По умолчанию используется цвет Color.fromARGB(255, 0, 112, 240). Цвет основных элементов, кнопки, переключатели, поля ввода. |

### SavePaymentMethod

| Параметр                      | Тип               | Описание |
| -----------                   | ----------------- | -------- |
| SavePaymentMethod.on          | SavePaymentMethod | Сохранить платёжный метод для проведения рекуррентных платежей. Пользователю будут доступны только способы оплаты, поддерживающие сохранение. На экране контракта будет отображено сообщение о том, что платёжный метод будет сохранён. |
| SavePaymentMethod.off         | SavePaymentMethod | Не дает пользователю выбрать, сохранять способ оплаты или нет. |
| SavePaymentMethod.userSelects | SavePaymentMethod | Пользователь выбирает, сохранять платёжный метод или нет. Если метод можно сохранить, на экране контракта появится переключатель. |

## Настройка подтверждения платежа

Если вы хотите использовать нашу реализацию подтверждения платежа, не закрывайте модуль SDK после получения токена.\
Отправьте токен на ваш сервер и после успешной оплаты закройте модуль.\
Если ваш сервер сообщил о необходимости подтверждения платежа (т.е. платёж пришёл со статусом `pending`), вызовите метод `confirmation(confirmationUrl, paymentMethodType)`.

Примеры кода:

```dart
await YookassaPaymentsFlutter.confirmation(controller.text, result.paymentMethodType);
)
```

## Логирование

У вас есть возможность включить логирование всех сетевых запросов.\
Для этого необходимо при создании `TokenizationModuleInputData` передать `isLoggingEnabled: true`

## Тестовый режим

У вас есть возможность запустить мобильный SDK в тестовом режиме.\
Тестовый режим не выполняет никаких сетевых запросов и имитирует ответ от сервера.

Если вы хотите запустить SDK в тестовом режиме, необходимо:

1. Сконфигурировать объект с типом `TestModeSettings(paymentAuthorizationPassed, cardsCount, charge, enablePaymentError)`.

```dart
var testModeSettings = TestModeSettings(true, 5, Amount(value: 999, currency: .rub), false);
```

2. Передать его в `TokenizationModuleInputData` в параметре `testModeSettings:`

```dart
var tokenizationModuleInputData = TokenizationModuleInputData(
    ...
    testModeSettings: testModeSettings);
```

## Кастомизация интерфейса

По умолчанию используется цвет Color.fromARGB(255, 0, 112, 240). Цвет основных элементов, кнопки, переключатели, поля ввода.

1. Сконфигурировать объект `CustomizationSettings` и передать его в параметр `customizationSettings` объекта `TokenizationModuleInputData`.

```dart
var tokenizationModuleInputData = TokenizationModuleInputData(
    ...
   customizationSettings: const CustomizationSettings(Colors.black));
```

## Платёж привязанной к магазину картой с дозапросом CVC/CVV

1. Создайте `SavedBankCardModuleInputData`.

```dart
var savedBankCardModuleInputData = SavedBankCardModuleInputData(
    clientApplicationKey: clientApplicationKey,
    title: "Космические объекты",
    subtitle: "Комета повышенной яркости, период обращения — 112 лет",
    amount: amount,
    savePaymentMethod: SavePaymentMethod.on,
    shopId: shopId,
    paymentMethodId: paymentMethodId
);
```

2. Запустите процесс с кейсом `.bankCardRepeat` и передайте `SavedBankCardModuleInputData`.

```dart
var result = await YookassaPaymentsFlutter.bankCardRepeat(savedBankCardModuleInputData);
```

3. Получите token в `TokenizationResult`

## Лицензия

YooKassa Payments SDK доступна под лицензией MIT. Смотрите [LICENSE](https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift/browse/LICENSE) файл для получения дополнительной информации.
