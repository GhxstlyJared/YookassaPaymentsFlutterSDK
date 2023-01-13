class GooglePayParameters {
  final List<GooglePayCardNetwork> paymentSystems;
  const GooglePayParameters([this.paymentSystems = const [GooglePayCardNetwork.mastercard, GooglePayCardNetwork.visa]]);

  List<String> jsonList() {
    return paymentSystems.map((e) => e.toString()).toList();
  }
}

enum GooglePayCardNetwork {
  amex,
  discover,
  jcb,
  mastercard,
  visa,
  interac,
  other
}