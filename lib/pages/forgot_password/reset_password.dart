import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'verification_code.dart';

class ResetPasswordInputPage extends StatefulWidget {
  final String method;

  const ResetPasswordInputPage({Key? key, required this.method})
    : super(key: key);

  @override
  State<ResetPasswordInputPage> createState() => _ResetPasswordInputPageState();
}

class _ResetPasswordInputPageState extends State<ResetPasswordInputPage> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendEmailCode(String email, String code) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Code sent to $email: $code')));
  }

  Future<void> _sendSMSCode(String phone, String code) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Code sent to $phone: $code')));
  }

  Future<void> _sendResetCode() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your ${widget.method}')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final contact = _controller.text.trim();

      // Generate a 4-digit code for both email and phone
      final code = (1000 + Random().nextInt(9000)).toString();

      // Store the code in reset_codes table
      await Supabase.instance.client.from('reset_codes').insert({
        'method': widget.method,
        'contact': contact,
        'code': code,
      });

      if (widget.method == 'email') {
        await _sendEmailCode(contact, code);
      } else {
        await _sendSMSCode(contact, code);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VerificationCodePage(method: widget.method, contact: contact),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmail = widget.method == 'email';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Reset Password',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEmail
                  ? 'Please enter your email, we will send a verification code to your email.'
                  : 'Please enter your phone number, we will send a verification code to your phone number.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Label
            Text(
              isEmail ? 'Email' : 'Phone Number',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Text field
            TextField(
              controller: _controller,
              keyboardType: isEmail
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              decoration: InputDecoration(
                hintText: isEmail ? 'Your email' : '(+965) 123 435 7565',
                prefixIcon: isEmail
                    ? null
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/icons/phone.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54408C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
