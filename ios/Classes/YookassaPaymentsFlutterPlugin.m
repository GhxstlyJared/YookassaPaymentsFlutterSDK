#import "YookassaPaymentsFlutterPlugin.h"
#if __has_include(<yookassa_payments_flutter/yookassa_payments_flutter-Swift.h>)
#import <yookassa_payments_flutter/yookassa_payments_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "yookassa_payments_flutter-Swift.h"
#endif

@implementation YookassaPaymentsFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYookassaPaymentsFlutterPlugin registerWithRegistrar:registrar];
}
@end
