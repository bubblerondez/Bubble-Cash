import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BubbleCash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  int _score = 0;
  Timer? _timer;
  double _bubbleSize = 50.0;
  late double _screenWidth, _screenHeight;

  @override
  void initState() {
    super.initState();

    // Initialisation de la publicité banner
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-9735100226388843/4707001347', // Remplace avec ton ID d'annonce
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Échec de la publicité : $error');
          _isBannerAdReady = false;
        },
      ),
    );
    _bannerAd.load();

    // Démarrage du timer pour augmenter la difficulté du jeu
    _startGameTimer();
  }

  void _startGameTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        // Augmenter la taille des bulles avec le temps
        _bubbleSize += 5.0;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerAd.dispose();
    super.dispose();
  }

  void _onBubbleTapped() {
    // Lorsque l'utilisateur tape une bulle, incrémenter le score
    setState(() {
      _score += 10;
    });

    // Affichage d'une publicité récompensée
    _showInterstitialAd();
  }

  void _showInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9735100226388843/2883617932', // Remplace avec ton ID d'annonce interstitielle
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Échec de la publicité interstitielle : $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('BubbleCash'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // Zone de jeu
          Center(
            child: GestureDetector(
              onTap: _onBubbleTapped,
              child: AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                left: (_screenWidth * 0.5 - _bubbleSize / 2),
                top: (_screenHeight * 0.5 - _bubbleSize / 2),
                child: Container(
                  width: _bubbleSize,
                  height: _bubbleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
          // Affichage du score
          Positioned(
            top: 30,
            left: 20,
            child: Text(
              'Score: $_score',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          // Affichage de la publicité banner si elle est prête
          if (_isBannerAdReady)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                height: 50,
                width: _screenWidth,
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
      ),
    );
  }
}
