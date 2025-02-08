import 'package:flutter/material.dart';
import 'dart:math';

// корисні копалини
class Minerals {
  final double coal;
  final double mazut;
  final double gas;

  Minerals({
    this.coal = 0.0,
    this.mazut = 0.0,
    this.gas = 0.0,
  });

  Minerals copyWith({
    double? coal,
    double? mazut,
    double? gas,
  }) {
    return Minerals(
      coal: coal ?? this.coal,
      mazut: mazut ?? this.mazut,
      gas: gas ?? this.gas,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final double coalEmissionFactor;
  final double coalEmissionValue;
  final double mazutEmissionFactor;
  final double mazutEmissionValue;
  final double gasEmissionFactor;
  final double gasEmissionValue;

  CalculationResults({
    this.coalEmissionFactor = 0.0,
    this.coalEmissionValue = 0.0,
    this.mazutEmissionFactor = 0.0,
    this.mazutEmissionValue = 0.0,
    this.gasEmissionFactor = 0.0,
    this.gasEmissionValue = 0.0,
  });
}

class EmissionsCalculator extends StatefulWidget {
  const EmissionsCalculator({super.key});

  @override
  State<EmissionsCalculator> createState() => _EmissionsCalculatorState();
}

class _EmissionsCalculatorState extends State<EmissionsCalculator> {
  Minerals minerals = Minerals();
  CalculationResults? results;

  void updateMineral(String field, double value) {
    setState(() {
      switch (field) {
        case 'coal':
          minerals = minerals.copyWith(coal: value);
        case 'mazut':
          minerals = minerals.copyWith(mazut: value);
        case 'gas':
          minerals = minerals.copyWith(gas: value);
      }
    });
  }

  CalculationResults calculateResults(Minerals minerals) {
    // нижча теплота згоряння робочої маси вугілля
    const coalHeatValue = 20.47;
    // нижча теплота згоряння робочої маси мазуту
    const mazutHeatValue = 39.48;
    // частка золи, яка виходить з котла у вигляді леткої золи (вугілля)
    const aCoal = 0.8;
    // частка золи, яка виходить з котла у вигляді леткої золи (мазут)
    const aMazut = 1.0;
    // масовий вміст горючих речовин у леткій золі (вугілля)
    const flammableSubstancesCoal = 1.5;
    // масовий вміст горючих речовин у леткій золі (мазут)
    const flammableSubstancesMazut = 0.0;
    // масовий вміст золи в паливі на робочу масу, % (вугілля)
    const arCoal = 25.2;
    // масовий вміст золи в паливі на робочу масу, % (мазут)
    const arMazut = 0.15;
    // ефективність очищення димових газів від твердих частинок
    const n = 0.985;

    // емісія твердих частинок (вугілля)
    final coalEmissionFactor = (pow(10.0, 6) / coalHeatValue) *
        aCoal *
        (arCoal / (100 - flammableSubstancesCoal)) *
        (1 - n);

    // валовий викид твердих частинок (вугілля)
    final coalEmissionValue =
        pow(10.0, -6) * coalEmissionFactor * coalHeatValue * minerals.coal;

    // емісія твердих частинок (мазут)
    final mazutEmissionFactor = (pow(10.0, 6) / mazutHeatValue) *
        aMazut *
        (arMazut / (100 - flammableSubstancesMazut)) *
        (1 - n);
    // валовий викид твердих частинок (мазут)
    final mazutEmissionValue =
        pow(10.0, -6) * mazutEmissionFactor * mazutHeatValue * minerals.mazut;

    // при спалюванні природного газу тверді частинки відсутні, тоді
    // емісія твердих частинок (газ)
    final gasEmissionFactor = 0.0;
    // валовий викид твердих частинок (газ)
    final gasEmissionValue = 0.0;

    return CalculationResults(
      coalEmissionFactor: coalEmissionFactor,
      coalEmissionValue: coalEmissionValue,
      mazutEmissionFactor: mazutEmissionFactor,
      mazutEmissionValue: mazutEmissionValue,
      gasEmissionFactor: gasEmissionFactor,
      gasEmissionValue: gasEmissionValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Калькулятор валових викидів',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Вугілля, т',
                  value: minerals.coal,
                  onChanged: (value) => updateMineral('coal', value),
                ),
                InputField(
                  label: 'Мазут, т',
                  value: minerals.mazut,
                  onChanged: (value) => updateMineral('mazut', value),
                ),
                InputField(
                  label: 'Газ, тис.м^3',
                  value: minerals.gas,
                  onChanged: (value) => updateMineral('gas', value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                    ),
                    onPressed: () {
                      setState(() {
                        results = calculateResults(minerals);
                      });
                    },
                    child: const Text(
                      'Розрахувати',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (results != null) ResultsDisplay(results: results!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;
  const InputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0.0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        !_controller.text.contains(RegExp(r'[.,]$'))) {
      final selection = _controller.selection;
      _controller.text = widget.value == 0.0 ? '' : widget.value.toString();
      _controller.selection = selection;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          if (value.isEmpty) {
            widget.onChanged(0.0);
            return;
          }
          final normalizedValue = value.replaceAll(',', '.');
          final number = double.tryParse(normalizedValue);
          if (number != null) {
            widget.onChanged(number);
          }
        },
      ),
    );
  }
}

class ResultsDisplay extends StatelessWidget {
  final CalculationResults results;

  const ResultsDisplay({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Результати розрахунків:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ResultSection(
          title: 'Спалювання вугілля:',
          items: {
            'Показник емісії твердих частинок':
                ResultValue(results.coalEmissionFactor, 'г/ГДж'),
            'Валовий викид': ResultValue(results.coalEmissionValue, 'т'),
          },
        ),
        ResultSection(
          title: 'Спалювання мазуту:',
          items: {
            'Показник емісії твердих частинок':
                ResultValue(results.mazutEmissionFactor, 'г/ГДж'),
            'Валовий викид': ResultValue(results.mazutEmissionValue, 'т'),
          },
        ),
        ResultSection(
          title: 'Спалювання газу:',
          items: {
            'Показник емісії твердих частинок':
                ResultValue(results.gasEmissionFactor, 'г/ГДж'),
            'Валовий викид': ResultValue(results.gasEmissionValue, 'т'),
          },
        ),
      ],
    );
  }
}

class ResultValue {
  final double value;
  final String? unit;

  const ResultValue(this.value, [this.unit]);
}

class ResultSection extends StatelessWidget {
  final String title;
  final Map<String, ResultValue> items;

  const ResultSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        ...items.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(entry.value.unit != null
                      ? '${entry.value.value.toStringAsFixed(2)} ${entry.value.unit}'
                      : entry.value.value.toStringAsFixed(2)),
                ],
              ),
            )),
      ],
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: EmissionsCalculator(),
    ),
  );
}
