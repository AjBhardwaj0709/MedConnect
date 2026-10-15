import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  // final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _specialization = TextEditingController();
  final _registrationNumber = TextEditingController();

  final _dateOfBirth = TextEditingController();
  String? _selectedGender;
  final _address = TextEditingController();

  final _qualification = TextEditingController();
  final _experience = TextEditingController();
  final _consultationFee = TextEditingController();

  UserRole _role = UserRole.patient;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const primary = Color(0xFF167D9A);
  static const ink = Color(0xFF17324D);
  static const muted = Color(0xFF74869A);
  static const background = Color(0xFFF5F9FC);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    // _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _specialization.dispose();
    _registrationNumber.dispose();

    _dateOfBirth.dispose();

    _address.dispose();
    _qualification.dispose();
    _experience.dispose();
    _consultationFee.dispose();

    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // String? _validatePhone(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return 'Phone number is required';
  //   }
  //   if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
  //     return 'Enter a valid 10-digit phone number';
  //   }
  //   return null;
  // }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _dateOfBirth.text =
            '${pickedDate.year.toString().padLeft(4, '0')}-'
            '${pickedDate.month.toString().padLeft(2, '0')}-'
            '${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_role == UserRole.patient && _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final Map<String, dynamic> data = {
      'name': _name.text.trim().toLowerCase(),
      'email': _email.text.trim().toLowerCase(),
      'password': _password.text,
    };

    if (_role == UserRole.patient) {
      data.addAll({
        'dateOfBirth': _dateOfBirth.text.trim(),
        'gender': _selectedGender!.toLowerCase(),
        'address': _address.text.trim().toLowerCase(),
      });
    } else {
      final experience = int.parse(_experience.text.trim());
      final fee = double.parse(_consultationFee.text.trim());

      data.addAll({
        'specialization': _specialization.text.trim().toLowerCase(),
        'registrationNumber': _registrationNumber.text.trim().toLowerCase(),
        'qualification': _qualification.text.trim().toLowerCase(),
        'experience': experience,
        'consultationFee': fee,
      });
    }

    try {
      final controller = ref.read(authControllerProvider.notifier);

      final user = _role == UserRole.patient
          ? await controller.signupPatient(data)
          : await controller.signupDoctor(data);


      if (!mounted || user == null) return;

      if (_role == UserRole.doctor) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Doctor account created successfully. Your verification is pending.',
            ),
          ),
        );

        context.go('/doctor/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient account created successfully.'),
          ),
        );

        context.go('/patient/dashboard');
      }

    
    } catch (error) {
      if (!mounted) return;

      String message = error.toString().replaceFirst('Exception: ', '');

      if (error is DioException) {
        final responseData = error.response?.data;

        if (responseData is Map && responseData['message'] != null) {
          message = responseData['message'].toString();
        } else if (error.response == null) {
          message = 'Cannot connect to MedConnect server.';
        } else {
          message = 'Signup failed (${error.response?.statusCode}).';
        }
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back_rounded, color: ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: ink,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join MedConnect for connected healthcare.',
                    style: TextStyle(color: muted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5EDF3)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'I AM A',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RoleSelector(
                            selectedRole: _role,
                            onChanged: (role) {
                              setState(() => _role = role);
                            },
                          ),
                          const SizedBox(height: 22),
                          AuthTextField(
                            controller: _name,
                            label: 'Full name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => _required(v, 'Full name'),
                          ),
                          const SizedBox(height: 17),
                          AuthTextField(
                            controller: _email,
                            label: 'Email address',
                            hint: 'you@example.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          // const SizedBox(height: 17),
                          // AuthTextField(
                          //   controller: _phone,
                          //   label: 'Phone number',
                          //   hint: '10-digit mobile number',
                          //   icon: Icons.phone_outlined,
                          //   keyboardType: TextInputType.phone,
                          //   validator: _validatePhone,
                          // ),

                          if (_role == UserRole.patient) ...[
                            const SizedBox(height: 17),

                            InkWell(
                              onTap: _selectDateOfBirth,
                              borderRadius: BorderRadius.circular(14),
                              child: IgnorePointer(
                                child: AuthTextField(
                                  controller: _dateOfBirth,
                                  label: 'Date of birth',
                                  hint: 'Select your date of birth',
                                  icon: Icons.calendar_month_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your date of birth';
                                    }
                                    return null;
                                  },
                                  suffixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 17),

                            const Text(
                              'Gender',
                              style: TextStyle(
                                color: ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE5EDF3),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    RadioListTile<String>(
                                      title: const Text('Male'),
                                      value: 'Male',
                                      groupValue: _selectedGender,
                                      activeColor: primary,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                    ),
                                    RadioListTile<String>(
                                      title: const Text('Female'),
                                      value: 'Female',
                                      groupValue: _selectedGender,
                                      activeColor: primary,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                    ),
                                    RadioListTile<String>(
                                      title: const Text('Other'),
                                      value: 'Other',
                                      groupValue: _selectedGender,
                                      activeColor: primary,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_selectedGender == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 6, left: 12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Please select your gender',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 17),
                            AuthTextField(
                              controller: _address,
                              label: 'Address',
                              hint: 'Enter your address',
                              icon: Icons.location_on_outlined,
                              validator: (v) => _required(v, 'Address'),
                            ),
                          ],

                          if (_role == UserRole.doctor) ...[
                            const SizedBox(height: 17),
                            AuthTextField(
                              controller: _specialization,
                              label: 'Medical specialization',
                              hint: 'e.g. Cardiology',
                              icon: Icons.medical_services_outlined,
                              validator: (v) => _required(v, 'Specialization'),
                            ),
                            const SizedBox(height: 17),
                            AuthTextField(
                              controller: _registrationNumber,
                              label: 'Medical registration number',
                              hint: 'Enter registration number',
                              icon: Icons.badge_outlined,
                              validator: (v) =>
                                  _required(v, 'Registration number'),
                            ),
                            const SizedBox(height: 17),
                            AuthTextField(
                              controller: _qualification,
                              label: 'Qualification',
                              hint: 'e.g. MBBS, MD',
                              icon: Icons.school_outlined,
                              validator: (v) => _required(v, 'Qualification'),
                            ),
                            const SizedBox(height: 17),
                            AuthTextField(
                              controller: _experience,
                              label: 'Years of experience',
                              hint: 'e.g. 5',
                              icon: Icons.work_outline,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null ||
                                    int.tryParse(v.trim()) == null) {
                                  return 'Enter valid years of experience';
                                }
                                if (int.parse(v.trim()) < 0) {
                                  return 'Experience cannot be negative';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 17),
                            AuthTextField(
                              controller: _consultationFee,
                              label: 'Consultation fee',
                              hint: 'e.g. 500',
                              icon: Icons.currency_rupee,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null ||
                                    double.tryParse(v.trim()) == null) {
                                  return 'Enter a valid consultation fee';
                                }
                                if (double.parse(v.trim()) < 0) {
                                  return 'Fee cannot be negative';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 17),
                          AuthTextField(
                            controller: _password,
                            label: 'Password',
                            hint: 'At least 8 characters',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 8) {
                                return 'Use at least 8 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 17),
                          AuthTextField(
                            controller: _confirmPassword,
                            label: 'Confirm password',
                            hint: 'Re-enter your password',
                            icon: Icons.lock_reset_rounded,
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _password.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          AuthButton(
                            label: 'Create Account',
                            isLoading: isLoading,
                            onPressed: _signup,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Already have an account?',
                                  style: TextStyle(color: muted, fontSize: 13),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
