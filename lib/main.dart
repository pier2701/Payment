import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Stripe',
      home: PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  //=> on déclare une variable "MAP" (clé/valeur) contenant les infos d'un produit
  final Map productInfo = {
    'name': 'iPhone 12 Pro',
    'price': 99,
    'imageUrl':
        'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-12-pro-blue-hero?wid=940&hei=1112&fmt=png-alpha&qlt=80&.v=1604021661000',
  };

  //=> on déclare une variable contient les informations d’une carte bancaire
  final CardDetails testCard = CardDetails(
    number: '4000002760003184',
    expirationMonth: 12,
    expirationYear: 21,
  );

  //=> représente une clé unique qui sera généré par Stripe pour chaque tentative de paiement.
  late String _currentSecret;

  //=> représente toutes les informations du futur paiement stockées par Stripe.
  late PaymentMethod _paymentMethod;

  //=> 2 autres variables pour gérer le comportement de notre formulaire et le rafraichissement de notre widget
  final ScrollController _controller = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Flutter Stripe'),
      ),
      body: ListView(
        children: const [],
      ),
    );
  }
}
