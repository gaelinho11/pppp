import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/card_component.dart'; 

class BlackjackGame extends FlameGame {
  // aqui creo llistes de cartes per gestionar la logica
  List<Carta> baralla = [];
  List<Carta> maJugador = [];
  List<Carta> maBanca = [];

  // simulo un tapet de casino verd
  @override
  Color backgroundColor() => const Color(0xFF0E5D2F);

  @override
  Future<void> onLoad() async {
    _generarBaralla();
    _barrejar();
    
    // reparteixo 2 cartes al jugador utilitzant await perque es carreguii tot be
    await repartirCartaBanca();
    await repartirCartaJugador();
    await repartirCartaJugador();
    
    print("Joc de Blackjack iniciat amb ${baralla.length} cartes restants.");
  }

  // aqui omplo la llista amb les 52 cartes utilitzant valors de l'1 al 13 (per simular les j, q, k)
  void _generarBaralla() {
    baralla.clear();
    for (var pal in Pal.values) { //afegeixo totes les cartes de cada pal.
      for (var i = 1; i <= 13; i++) {
        baralla.add(Carta(pal: pal, valor: i));
      }
    }
  }

  // amb aixo barrejo la baralla de forma aleatoria
  void _barrejar() {
    baralla.shuffle();
  }

  // amb aquest metode trec una carta de la baralla i la poso a la pantalla
  Future<void> repartirCartaJugador() async {
    if (baralla.isNotEmpty) {
      // sempre trec la ultima carta de la baralla
      Carta novaCarta = baralla.removeLast();
      maJugador.add(novaCarta);

      // creo el component visual que he fet a card_component
      var cartaVisual = CartaComponent(novaCarta);
      


      // Calculem la posició a la pantalla:
      // x: desplaçament horitzontal segons quantes cartes ja té
      // y: alçada de la pantalla menys un marge per estar a baix
      double offsetX = 50.0 + (maJugador.length - 1) * 45.0;
      double offsetY = size.y - 200; 
      
      cartaVisual.position = Vector2(offsetX, offsetY);
      
      // Afegim el component al motor Flame per pintar-lo
      add(cartaVisual);
    }
  }

  // amb això calculo els punts de la mà
  int calcularPunts(List<Carta> ma) {
    int total = 0;
    int asos = 0;// això ho utilitzo per la logica de que l'as pot valdre 1 i 11

    for (var carta in ma) {
      total += carta.valorBlackjack;
      if (carta.valor == 1) asos++;
    }

    // si el jugador es passa de 21 i te asos, els faig valdre 1 en comptes de11
    while (total > 21 && asos > 0) {
      total -= 10;
      asos--;
    }
    return total;
  }
  Future<void> repartirCartaBanca({bool oculta = false}) async {
    if (baralla.isNotEmpty) {
      Carta novaCarta = baralla.removeLast();
      maBanca.add(novaCarta);

      var cartaVisual = CartaComponent(novaCarta);
      
      // la posiciono a la part superior perque es el dealer
      double offsetX = 50.0 + (maBanca.length - 1) * 45.0;
      double offsetY = 50; // A dalt
      
      cartaVisual.position = Vector2(offsetX, offsetY);
      add(cartaVisual);
    }
  }

  void plantarse() {
    print("Jugador es planta amb ${calcularPunts(maJugador)} punts");
    jugarTornBanca();
  }

  Future<void> jugarTornBanca() async {
    // aqui faig que quan el jugador es planta la banca demana cartes fins arribar a 17 o pasarse
    while (calcularPunts(maBanca) < 17) {
      await repartirCartaBanca();
      await Future.delayed(const Duration(milliseconds: 500)); // aqui afecire el efecte visual en aquesta pausa
    }
    _determinarGuanyador();
  }

  void _determinarGuanyador() {
    int puntsJ = calcularPunts(maJugador);
    int puntsB = calcularPunts(maBanca);
    
    String missatge = "";
    if (puntsJ > 21) missatge = "T'has passat! Guanya la banca.";
    else if (puntsB > 21) missatge = "La banca es passa! Guanyes tu!";
    else if (puntsJ > puntsB) missatge = "Guanyes tu!";
    else if (puntsB > puntsJ) missatge = "Guanya la banca!";
    else missatge = "Empat!";
    
    print(missatge);
    // Aquí podríem mostrar un diàleg a Flutter
  }
}