import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ExcessBaggageCalculatorApp());
}

const _navy = Color(0xFF102A43);
const _blue = Color(0xFF2864A5);
const _sky = Color(0xFF5AA9E6);
const _canvas = Color(0xFFF3F6FA);
const _serviceTaxRate = 0.08;

enum TicketClass {
  economy('Economy Class', 20),
  business('Business Class', 40);

  const TicketClass(this.label, this.allowanceKg);

  final String label;
  final double allowanceKg;
}

@immutable
class BaggageCalculation {
  const BaggageCalculation({
    required this.allowanceKg,
    required this.ratePerKg,
    required this.excessWeightKg,
    required this.excessCharge,
    required this.serviceTax,
    required this.totalPayable,
  });

  final double allowanceKg;
  final double ratePerKg;
  final double excessWeightKg;
  final double excessCharge;
  final double serviceTax;
  final double totalPayable;

  factory BaggageCalculation.calculate({
    required double baggageWeightKg,
    required double allowanceKg,
    required double ratePerKg,
  }) {
    final excessWeightKg = (baggageWeightKg - allowanceKg).clamp(0.0, double.infinity);
    final excessCharge = excessWeightKg * ratePerKg;
    final serviceTax = excessCharge * _serviceTaxRate;
    return BaggageCalculation(
      allowanceKg: allowanceKg,
      ratePerKg: ratePerKg,
      excessWeightKg: excessWeightKg,
      excessCharge: excessCharge,
      serviceTax: serviceTax,
      totalPayable: excessCharge + serviceTax,
    );
  }
}

class ExcessBaggageCalculatorApp extends StatelessWidget {
  const ExcessBaggageCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _blue,
      primary: _navy,
      secondary: _sky,
      surface: Colors.white,
    );
    return MaterialApp(
      title: 'Excess Baggage Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _canvas,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8E1EA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8E1EA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _blue, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB42318)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB42318), width: 1.6),
          ),
        ),
      ),
      home: const _AppNavigationShell(),
    );
  }
}

class _AppNavigationShell extends StatefulWidget {
  const _AppNavigationShell();

  @override
  State<_AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<_AppNavigationShell> {
  int _selectedIndex = 0;

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final useRail = viewportWidth >= 600;

    final pages = IndexedStack(
      index: _selectedIndex,
      children: const [CalculatorHomePage(), AboutPage()],
    );

    return Scaffold(
      body: SafeArea(
        child: useRail
            ? Row(
                children: [
                  NavigationRail(
                    key: const ValueKey('desktopNavigationRail'),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectPage,
                    labelType: NavigationRailLabelType.all,
                    minWidth: 88,
                    backgroundColor: Colors.white,
                    indicatorColor: const Color(0xFFE5F0FA),
                    selectedIconTheme: const IconThemeData(color: _navy),
                    selectedLabelTextStyle: const TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w700,
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.info_outline_rounded),
                        selectedIcon: Icon(Icons.info_rounded),
                        label: Text('About'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE6ECF2)),
                  Expanded(child: pages),
                ],
              )
            : pages,
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              key: const ValueKey('mobileNavigationBar'),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectPage,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFE5F0FA),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.info_outline_rounded),
                  selectedIcon: Icon(Icons.info_rounded),
                  label: 'About',
                ),
              ],
            ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static final Uri _repositoryUri = Uri.parse(
    'https://github.com/anixnataxya/excess-baggage-calculator',
  );

  Future<void> _openRepository(BuildContext context) async {
    try {
      final launched = await launchUrl(
        _repositoryUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showLaunchError(context);
      }
    } catch (_) {
      if (context.mounted) _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the GitHub link on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _navy,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 18),
                  const _AboutApplicationCard(),
                  const SizedBox(height: 16),
                  const _AuthorInformationCard(),
                  const SizedBox(height: 16),
                  _RepositoryCard(
                    repositoryUri: _repositoryUri,
                    onTap: () => _openRepository(context),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '© 2026 Excess Baggage Calculator. All Rights Reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF718096), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutApplicationCard extends StatelessWidget {
  const _AboutApplicationCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Icon(Icons.luggage_rounded, color: Colors.white, size: 39),
          ),
          const SizedBox(height: 16),
          const Text(
            'Excess Baggage Calculator',
            textAlign: TextAlign.center,
            style: TextStyle(color: _navy, fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'A mobile application designed to estimate excess baggage fees for air travel.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF62748A), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AuthorInformationCard extends StatelessWidget {
  const _AuthorInformationCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Author information',
            style: TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const _AuthorDetail(label: 'Name', value: 'Anis Natasya Binti Mohamad Nasir'),
          const Divider(height: 22, color: Color(0xFFE6ECF2)),
          const _AuthorDetail(label: 'Matric Number', value: '2023466258'),
          const Divider(height: 22, color: Color(0xFFE6ECF2)),
          const _AuthorDetail(
            label: 'Course',
            value: 'CS266 BACHELOR OF INFORMATION SYSTEMS (HONS.) INFORMATION SYSTEMS ENGINEERING',
          ),
        ],
      ),
    );
  }
}

class _AuthorDetail extends StatelessWidget {
  const _AuthorDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: _navy, fontSize: 14, height: 1.4)),
      ],
    );
  }
}

class _RepositoryCard extends StatelessWidget {
  const _RepositoryCard({required this.repositoryUri, required this.onTap});

  final Uri repositoryUri;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          key: const ValueKey('githubRepositoryLink'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F0FA),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.code_rounded, color: _blue),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Planned GitHub repository',
                        style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        repositoryUri.toString(),
                        softWrap: true,
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 12,
                          height: 1.35,
                          decoration: TextDecoration.underline,
                          decorationColor: _blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new_rounded, color: _blue, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _rateController = TextEditingController();
  TicketClass _ticketClass = TicketClass.economy;
  BaggageCalculation? _calculation;

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the $fieldName.';
    }
    final number = double.tryParse(value.trim());
    if (number == null || !number.isFinite) {
      return 'Enter a valid number.';
    }
    if (number <= 0) {
      return 'The $fieldName must be greater than zero.';
    }
    return null;
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text.trim());
    final rate = double.parse(_rateController.text.trim());
    setState(() {
      _calculation = BaggageCalculation.calculate(
        baggageWeightKg: weight,
        allowanceKg: _ticketClass.allowanceKg,
        ratePerKg: rate,
      );
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    _weightController.clear();
    _rateController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _ticketClass = TicketClass.economy;
      _calculation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: SliverList.list(
                    children: [
                      const _AppHeader(),
                      const SizedBox(height: 24),
                      const _InformationCard(),
                      const SizedBox(height: 24),
                      _InputCard(
                        formKey: _formKey,
                        weightController: _weightController,
                        rateController: _rateController,
                        selectedClass: _ticketClass,
                        onClassChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _ticketClass = value;
                            _calculation = null;
                          });
                        },
                        validator: _validatePositiveNumber,
                        onCalculate: _calculate,
                        onReset: _reset,
                      ),
                      const SizedBox(height: 24),
                      _ResultsSection(calculation: _calculation),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Plan ahead for a smoother journey.',
                          style: TextStyle(color: Color(0xFF718096), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(Icons.luggage_rounded, color: Colors.white, size: 29),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Excess Baggage Calculator',
                style: TextStyle(
                  color: _navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Know your baggage costs before you fly.',
                style: TextStyle(color: Color(0xFF62748A), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173B65), Color(0xFF245E94)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF9DD7FF), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Calculate your excess baggage fee before travelling.',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _InfoChip(label: 'Economy', value: '20 kg'),
              _InfoChip(label: 'Business', value: '40 kg'),
              _InfoChip(label: 'Service tax', value: '8%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(color: Color(0xFFD7E9F8), fontSize: 12),
          children: [
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _NumberValidator = String? Function(String?, String);

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.formKey,
    required this.weightController,
    required this.rateController,
    required this.selectedClass,
    required this.onClassChanged,
    required this.validator,
    required this.onCalculate,
    required this.onReset,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController weightController;
  final TextEditingController rateController;
  final TicketClass selectedClass;
  final ValueChanged<TicketClass?> onClassChanged;
  final _NumberValidator validator;
  final VoidCallback onCalculate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading(
              title: 'Trip details',
              subtitle: 'Enter the details from your ticket.',
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 21),
            _FieldLabel(label: 'Baggage weight', trailing: 'KG'),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('weightField'),
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                hintText: 'e.g. 25.5',
                prefixIcon: Icon(Icons.scale_outlined),
                suffixText: 'kg',
              ),
              validator: (value) => validator(value, 'baggage weight'),
            ),
            const SizedBox(height: 18),
            const _FieldLabel(label: 'Ticket class'),
            const SizedBox(height: 8),
            DropdownButtonFormField<TicketClass>(
              key: const ValueKey('classDropdown'),
              initialValue: selectedClass,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.airline_seat_recline_extra_rounded),
              ),
              items: TicketClass.values
                  .map(
                    (ticketClass) => DropdownMenuItem(
                      value: ticketClass,
                      child: Text(ticketClass.label),
                    ),
                  )
                  .toList(),
              onChanged: onClassChanged,
            ),
            const SizedBox(height: 18),
            const _FieldLabel(label: 'Excess baggage rate', trailing: 'RM / KG'),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('rateField'),
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                hintText: 'e.g. 15.00',
                prefixIcon: Icon(Icons.payments_outlined),
                prefixText: 'RM  ',
              ),
              validator: (value) => validator(value, 'excess baggage rate'),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: onCalculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calculate Fee'),
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset'),
                style: TextButton.styleFrom(foregroundColor: _blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
      ],
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({required this.calculation});

  final BaggageCalculation? calculation;

  @override
  Widget build(BuildContext context) {
    final result = calculation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Your estimate',
          subtitle: 'A clear view of your potential extra costs.',
          icon: Icons.receipt_long_outlined,
        ),
        const SizedBox(height: 14),
        if (result == null)
          const _InitialResultMessage()
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _WithinAllowanceNotice(isWithinAllowance: result.excessWeightKg == 0),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final weightCard = _MetricCard(
              label: 'Excess weight',
              value: result == null ? '—' : '${result.excessWeightKg.toStringAsFixed(2)} kg',
              icon: Icons.monitor_weight_outlined,
            );
            final chargeCard = _MetricCard(
              label: 'Excess charge',
              value: result == null ? '—' : 'RM ${result.excessCharge.toStringAsFixed(2)}',
              icon: Icons.payments_outlined,
            );

            if (constraints.maxWidth >= 560) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: weightCard),
                  const SizedBox(width: 12),
                  Expanded(child: chargeCard),
                ],
              );
            }

            return Column(
              children: [weightCard, const SizedBox(height: 10), chargeCard],
            );
          },
        ),
        const SizedBox(height: 10),
        _TotalCard(amount: result?.totalPayable),
        if (result != null) ...[
          const SizedBox(height: 14),
          _BreakdownCard(calculation: result),
        ],
      ],
    );
  }
}

class _InitialResultMessage extends StatelessWidget {
  const _InitialResultMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enter your baggage details to see an estimate.',
              style: TextStyle(color: _navy, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithinAllowanceNotice extends StatelessWidget {
  const _WithinAllowanceNotice({required this.isWithinAllowance});

  final bool isWithinAllowance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isWithinAllowance ? const Color(0xFFE9F7EF) : const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isWithinAllowance ? Icons.check_circle_outline : Icons.info_outline,
            color: isWithinAllowance ? const Color(0xFF24804A) : const Color(0xFF9B6B10),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isWithinAllowance
                  ? 'Your baggage is within the allowance, so there is no excess charge.'
                  : 'Only the weight above your allowance is charged.',
              style: const TextStyle(color: _navy, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _blue, size: 20),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Color(0xFF718096), fontSize: 11)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              key: ValueKey(label),
              style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.amount});

  final double? amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: _navy.withValues(alpha: 0.14), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF9DD7FF)),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total amount payable',
                      style: TextStyle(color: Color(0xFFD3E3F1), fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Includes 8% service tax',
                      style: TextStyle(color: Color(0xFF9FB5C9), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          );
          final amountText = Text(
            amount == null ? '—' : 'RM ${amount!.toStringAsFixed(2)}',
            key: const ValueKey('totalPayable'),
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
          );

          if (constraints.maxWidth < 380) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: amountText),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: 8),
              amountText,
            ],
          );
        },
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.calculation});

  final BaggageCalculation calculation;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee breakdown',
            style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 13),
          _BreakdownRow(label: 'Baggage allowance', value: '${calculation.allowanceKg.toStringAsFixed(0)} kg'),
          _BreakdownRow(label: 'Excess baggage rate', value: 'RM ${calculation.ratePerKg.toStringAsFixed(2)} / kg'),
          _BreakdownRow(label: 'Excess baggage charge', value: 'RM ${calculation.excessCharge.toStringAsFixed(2)}'),
          _BreakdownRow(label: '8% service tax', value: 'RM ${calculation.serviceTax.toStringAsFixed(2)}', isLast: true),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value, this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 11),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF718096), fontSize: 12))),
          Text(value, style: const TextStyle(color: _navy, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(color: const Color(0xFFE5F0FA), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _blue, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: Color(0xFF718096), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding = const EdgeInsets.all(19)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECF2)),
        boxShadow: [
          BoxShadow(color: _navy.withValues(alpha: 0.035), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}
