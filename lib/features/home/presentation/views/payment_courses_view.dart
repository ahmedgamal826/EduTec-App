import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class PaymentCoursesView extends StatefulWidget {
  const PaymentCoursesView({super.key});

  @override
  State<PaymentCoursesView> createState() => _PaymentCoursesViewState();
}

class _PaymentCoursesViewState extends State<PaymentCoursesView> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameOnCardController = TextEditingController();

  bool _isLoading = false;

  // Function to generate random 5-digit premium code
  String _generatePremiumCode() {
    Random random = Random();
    String code = '';
    for (int i = 0; i < 5; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  // Function to show premium code dialog
  void _showPremiumCodeDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 15),
              const Text(
                'Payment Successful',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your premium code is:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy code',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Use this code to register for premium courses',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeaderText('Course Payment'),
              const SizedBox(height: 10),
              _buildInfoText(
                  'Please enter your card details to purchase premium courses'),
              const SizedBox(height: 30),

              // Credit Card UI
              _buildCreditCardUI(),
              const SizedBox(height: 40),

              // Card Details Form
              _buildCardField(
                title: 'Card Number',
                controller: _cardNumberController,
                hintText: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildCardField(
                      title: 'Expiry Date',
                      controller: _expiryDateController,
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildCardField(
                      title: 'CVV',
                      controller: _cvvController,
                      hintText: '123',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildCardField(
                title: 'Name on Card',
                controller: _nameOnCardController,
                hintText: 'John Doe',
                inputFormatters: [
                  LengthLimitingTextInputFormatter(40), // حد أقصى 40 حرف للاسم
                ],
              ),

              const SizedBox(height: 40),

              // Payment Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Security Info
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: Colors.grey, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      'Secure Payment',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildPaymentIcon('assets/images/visa.png'),
                    _buildPaymentIcon('assets/images/mastercard.png'),
                    _buildPaymentIcon('assets/images/paypal.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildCreditCardUI() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Premium Course',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Image.asset(
                'assets/images/chip.png',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('CHIP', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
          Text(
            _cardNumberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _cardNumberController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CARD HOLDER',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _nameOnCardController.text.isEmpty
                            ? 'Your Name'
                            : _nameOnCardController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EXPIRES',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _expiryDateController.text.isEmpty
                          ? 'MM/YY'
                          : _expiryDateController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'VISA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // التحقق ما إذا كان حقل اسم البطاقة
    final bool isNameField = title == 'Name on Card';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: (value) {
            setState(() {
              // لحقل الاسم، تقييد طول النص إذا كان طويلًا جدًا
              if (isNameField && value.length > 25) {
                // إظهار رسالة للمستخدم أن الاسم طويل
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(
                //     content: Text(
                //         'Name is too long, it will be displayed scaled down'),
                //     backgroundColor: Colors.orange,
                //     duration: Duration(seconds: 1),
                //   ),
                // );
              }
            });
          },
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.grey.shade100,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentIcon(String assetPath) {
    return Container(
      width: 60,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.credit_card,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _processPayment() async {
    // Validate fields
    if (_cardNumberController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _cvvController.text.isEmpty ||
        _nameOnCardController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Generate premium code and show dialog
    final premiumCode = _generatePremiumCode();

    // Save the generated code to shared preferences or a database
    // This is where you'd normally save the code to validate it later
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('premium_code', premiumCode);

    // For simplicity, I'm storing the code statically
    PremiumCodeManager.addPremiumCode(premiumCode);

    // Show premium code dialog
    if (mounted) {
      _showPremiumCodeDialog(premiumCode);
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameOnCardController.dispose();
    super.dispose();
  }
}

// Custom formatter for credit card number
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    StringBuffer result = StringBuffer();
    for (int i = 0; i < newValue.text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result.write(' ');
      }
      result.write(newValue.text[i]);
    }

    return TextEditingValue(
      text: result.toString(),
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// Custom formatter for expiry date
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    StringBuffer result = StringBuffer();
    for (int i = 0; i < newValue.text.length; i++) {
      if (i == 2) {
        result.write('/');
      }
      result.write(newValue.text[i]);
    }

    return TextEditingValue(
      text: result.toString(),
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// Static class to manage premium codes
class PremiumCodeManager {
  static final Set<String> _premiumCodes = {'PREMIUM123'}; // Predefined code

  static void addPremiumCode(String code) {
    _premiumCodes.add(code);
  }

  static bool isValidCode(String code) {
    return _premiumCodes.contains(code);
  }
}
