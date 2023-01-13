class HostParameters {

  String host;
  String paymentAuthorizationHost;
  String authHost;
  String configHost;

  HostParameters(
    this.host,
    this.paymentAuthorizationHost,
    this.authHost,
    this.configHost,
  );

  Map<String, dynamic> toJson() =>
      {
        'apiHost': host,
        'paymentAuthApiHost': paymentAuthorizationHost,
        'authApiHost': authHost,
        'configHost': configHost
      };

  factory HostParameters.fromJson(Map<String, dynamic> json) {
    return HostParameters(
      json['apiHost'] as String,
      json['paymentAuthApiHost'] as String,
      json['authApiHost'] as String,
      json['configHost'] as String,
    );
  }
}