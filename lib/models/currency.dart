class Currency {
  final String value;
  const Currency(this.value);

  static const Currency rub = Currency('RUB');
  static const Currency usd = Currency('USD');
  static const Currency eur = Currency('EUR');
}