// ignore_for_file: avoid_print, invalid_return_type_for_catch_error

import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:stripe_payment/stripe_payment.dart';
//import 'package:stripe_payment_flutter/stripe_payment.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';

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
  final CreditCard testCard = CreditCard(
    number: '4000002760003184',
    expMonth: 12,
    expYear: 21,
  );

  //=> représente une clé unique qui sera généré par Stripe pour chaque tentative de paiement.
  late String _currentSecret;

  //=> représente toutes les informations du futur paiement stockées par Stripe.
  late PaymentMethod _paymentMethod;

  //=> 2 autres variables pour gérer le comportement de notre formulaire et le rafraichissement de notre widget
  final ScrollController _controller = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  //=> on initialise le Widget "Scaffold" avec la méthode "initState()"
  @override
  void initState() {
    super.initState();
    initStripe();
    //- on affecte la "clé" secrète de Stripe à l'initialisation du Widget
    _currentSecret = '*********************************';
  }

  //- on déclare la logique avec la clé publique
  void initStripe() {
    StripePayment.setOptions(
      StripeOptions(
          publishableKey: "pk_test_*********************",
          merchantId: "Test",
          androidPayMode: 'test'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, //=> actualise le widget "Scaffold"
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Flutter Stripe'),
      ),
      body: ListView(
        controller: _controller,
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 200,
            child: Image.network(productInfo['imageUrl']),
          ),
          Text(
            productInfo['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
          Text(
            '${productInfo['price']}€',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            onPressed: _addCard,
            child: const Text('Ajouter une carte bancaire'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text('Payer ${productInfo['price']}€'),
            onPressed: () => _pay(),
          ),
          const SizedBox(height: 10),
          Image.network(
              'https://paymentsplugin.com/assets/blog-images/stripe-badge-transparent.png'),
        ],
      ),
    );
  }

  //- on déclare la méthode "_addCard()"
  void _addCard() {
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Received ${paymentMethod.id}')));
      setState(() {
        _paymentMethod = paymentMethod;
      });
    }).catchError(setError);
  }

  //- on déclare la méthode "_pay()"
  void _pay() {
    StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: testCard,
      ),
    ).then((paymentMethod) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Received ${paymentMethod.id}')));
      setState(() {
        _paymentMethod = paymentMethod;
        _showOptions(context);
      });
    }).catchError(setError);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Êtes-vous sûr de vouloir acheter ?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 70,
                    child: Image.network(productInfo['imageUrl']),
                  ),
                  Text(
                    productInfo['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  Text(
                    '${productInfo['price']}€',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: _confirmPayment,
                child: const Text("Confirmer le paiement"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmPayment() {
    StripePayment.confirmPaymentIntent(
      PaymentIntent(
        clientSecret: _currentSecret,
        paymentMethodId: _paymentMethod.id,
      ),
    ).then((paymentIntent) {
      Navigator.pop(context);
      showAlertDialog(context);
    }).catchError(setError);
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Paiement réussi!"),
          content: Text(
              "Vous venez d'effectuer un paiement de ${productInfo['price']}€ via la plateforme Stripe. Nous vous remercions de votre confiance."),
          actions: [
            TextButton(
              child: const Text("Acheter à nouveau"),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  //- on déclare une méthode
  FutureOr<void> setError(dynamic error) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      print(error);
    });
  }
}
