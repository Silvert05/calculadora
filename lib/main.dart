import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculadora(),
    );
  }
}

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String userInput = '';
  String resultado = '0';

  final List<String> botones = [
    'AC', 'DEL', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '+',
    '1', '2', '3', '-',
    '0', '.', '=', '',
  ];

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 400; // Tamaño máximo para web

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea( // 🔹 Previene desbordes en la parte superior e inferior
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      // 🔹 Esto evita el overflow cuando el texto del resultado crece
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              userInput,
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            resultado,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 4), // 🔹 Evita el “bottom overflowed”
                    itemCount: botones.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final texto = botones[index];
                      final esOperador = _esOperador(texto);
                      final esEspecial = texto == 'AC' || texto == 'DEL' || texto == '=';

                      return texto.isEmpty
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: () => _botonPresionado(texto),
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    texto,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500,
                                      color: esEspecial || esOperador
                                          ? Colors.deepOrangeAccent
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _esOperador(String x) {
    return ['%', '÷', '×', '-', '+', '='].contains(x);
  }

  void _botonPresionado(String texto) {
    setState(() {
      if (texto == 'AC') {
        userInput = '';
        resultado = '0';
      } else if (texto == 'DEL') {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
        _calcularResultado();
      } else if (texto == '=') {
        _calcularResultado();
      } else {
        userInput += texto;
        _calcularResultado();
      }
    });
  }

  void _calcularResultado() {
    try {
      if (userInput.isEmpty) {
        resultado = '0';
        return;
      }

      String expresion = userInput
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(expresion);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      resultado = eval.toString().endsWith('.0')
          ? eval.toInt().toString()
          : eval.toString();
    } catch (_) {
      resultado = 'Error';
    }
  }
}
