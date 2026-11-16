# Excess Baggage Calculator

A Flutter application that estimates excess baggage fees for air travel. Enter a baggage weight, select the ticket class, and provide the airline's excess baggage rate per kilogram to view the excess weight, charge, service tax, and total payable amount.

## Features

- Economy Class baggage allowance of 20 kg and Business Class allowance of 40 kg.
- Input validation for baggage weight and the per-kilogram rate.
- Excess baggage charge calculation with an 8% service tax.
- Responsive Home and About pages with airline-inspired navy and soft-blue styling.
- Result breakdown for the allowance, rate, charge, tax, and total payable amount.

## Calculation

The calculation uses the selected ticket class allowance and the rate entered by the user:

```text
excessWeight = max(0, baggageWeight - baggageAllowance)
excessCharge = excessWeight × ratePerKg
serviceTax = excessCharge × 0.08
totalPayable = excessCharge + serviceTax
```

Currency amounts are displayed in Malaysian ringgit (RM) to two decimal places. Baggage within the allowance has no excess charge.

## Technologies

- Flutter and Dart
- Material Design (Material 3)
- `url_launcher` for the repository link on the About page

## Run the project

Install Flutter and configure a target device (Android emulator, connected device, or a supported desktop/browser target), then run:

```bash
flutter pub get
flutter run
```

To run the automated Flutter tests and static analysis:

```bash
flutter test
flutter analyze
```

## Author

- **Name:** Anis Natasya Binti Mohamad Nasir
- **Matric number:** 2023466258
- **Course:** CS266 Bachelor of Information Systems (Hons.) Information Systems Engineering
- **GitHub:** [anixnataxya](https://github.com/anixnataxya)

Repository: [https://github.com/anixnataxya/excess-baggage-calculator](https://github.com/anixnataxya/excess-baggage-calculator)
