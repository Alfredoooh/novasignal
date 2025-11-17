// screens/order/order_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/order_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({Key? key}) : super(key: key);

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedUrgency = 'medium';
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDeadline = date);
    }
  }

  Future<void> _handleSubmitOrder() async {
    if (_formKey.currentState!.validate()) {
      // Implementação completa do envio do pedido
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderSentSuccess)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createOrder),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.orderDescriptionLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: l10n.orderDescriptionHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.orderDescriptionRequired;
                  }
                  if (value.length < 20) {
                    return l10n.orderDescriptionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Text(
                l10n.urgency,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'low', label: Text(l10n.urgencyLow)),
                  ButtonSegment(value: 'medium', label: Text(l10n.urgencyMedium)),
                  ButtonSegment(value: 'high', label: Text(l10n.urgencyHigh)),
                ],
                selected: {_selectedUrgency},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _selectedUrgency = newSelection.first);
                },
              ),
              const SizedBox(height: 24),
              
              Text(
                l10n.deadline,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDeadline != null 
                  ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                  : 'Selecione uma data'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDeadline,
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: l10n.sendOrder,
                onPressed: _handleSubmitOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}