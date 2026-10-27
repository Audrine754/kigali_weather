Future<String> orderBrochette() async {
  await Future.delayed(const Duration(seconds: 3));
  return 'Your brochette is ready';
}

Future<String> orderDrink() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'Your Fanta is ready';
}

void main() async {
  print('1. You order a brochette and a Fanta');
  final brochette = orderBrochette();
  final drink = orderDrink();
  print('2. While they get ready, you chat with your friends');
  final food = await brochette;
  final fanta = await drink;
  print('3. $food');
  print('4. $fanta');
  print('5. You eat');
}