import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B87),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _firstValue;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _inputDigit(String digit) {
    setState(() {
      if (_display == 'Erro' || _shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_display == 'Erro' || _shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _chooseOperator(String operator) {
    final value = double.tryParse(_display);
    if (value == null) return;
    setState(() {
      if (_firstValue != null && _operator != null && !_shouldResetDisplay) {
        _calculate();
      } else {
        _firstValue = value;
      }
      _operator = operator;
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    final secondValue = double.tryParse(_display);
    if (_firstValue == null || _operator == null || secondValue == null) return;
    double result;
    switch (_operator) {
      case '+':
        result = _firstValue! + secondValue;
      case '-':
        result = _firstValue! - secondValue;
      case '×':
        result = _firstValue! * secondValue;
      case '÷':
        if (secondValue == 0) {
          _display = 'Erro';
          _firstValue = null;
          _operator = null;
          _shouldResetDisplay = true;
          return;
        }
        result = _firstValue! / secondValue;
      default:
        return;
    }
    _display = _formatNumber(result);
    _firstValue = result;
  }

  void _equals() {
    setState(() {
      _calculate();
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _firstValue = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display != '0' && _display != 'Erro') {
        _display = _display.startsWith('-')
            ? _display.substring(1)
            : '-$_display';
      }
    });
  }

  void _percentage() {
    final value = double.tryParse(_display);
    if (value == null) return;
    setState(() => _display = _formatNumber(value / 100));
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Widget _button(String label, VoidCallback onPressed, {bool accent = false, bool action = false}) {
    final background = accent
        ? const Color(0xFF176B87)
        : action
            ? const Color(0xFFDCE8EC)
            : Colors.white;
    final foreground = accent
        ? Colors.white
        : action
            ? const Color(0xFF176B87)
            : const Color(0xFF17242B);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 64,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 14),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('CALCULADORA', style: TextStyle(color: Color(0xFF176B87), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.8)),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_display, key: const Key('display'), style: const TextStyle(color: Color(0xFF17242B), fontSize: 64, fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(children: [
                    _button('AC', _clear, action: true), _button('+/-', _toggleSign, action: true),
                    _button('%', _percentage, action: true), _button('÷', () => _chooseOperator('÷'), accent: true),
                  ]),
                  Row(children: [
                    _button('7', () => _inputDigit('7')), _button('8', () => _inputDigit('8')),
                    _button('9', () => _inputDigit('9')), _button('×', () => _chooseOperator('×'), accent: true),
                  ]),
                  Row(children: [
                    _button('4', () => _inputDigit('4')), _button('5', () => _inputDigit('5')),
                    _button('6', () => _inputDigit('6')), _button('-', () => _chooseOperator('-'), accent: true),
                  ]),
                  Row(children: [
                    _button('1', () => _inputDigit('1')), _button('2', () => _inputDigit('2')),
                    _button('3', () => _inputDigit('3')), _button('+', () => _chooseOperator('+'), accent: true),
                  ]),
                  Row(children: [
                    _button('0', () => _inputDigit('0')), _button('.', _inputDecimal),
                    _button('=', _equals, accent: true),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}