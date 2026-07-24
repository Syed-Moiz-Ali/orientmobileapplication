import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class AddVehicleDialog extends ConsumerStatefulWidget {
  const AddVehicleDialog({super.key});

  @override
  ConsumerState<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends ConsumerState<AddVehicleDialog> {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final plateController = TextEditingController();
  final vinController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Vehicle"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: brandController, decoration: const InputDecoration(labelText: "Brand")),
            TextField(controller: modelController, decoration: const InputDecoration(labelText: "Model")),
            TextField(controller: plateController, decoration: const InputDecoration(labelText: "Plate Number")),
            TextField(controller: vinController, decoration: const InputDecoration(labelText: "VIN")),
            TextField(controller: yearController, decoration: const InputDecoration(labelText: "Year")),
            TextField(controller: colorController, decoration: const InputDecoration(labelText: "Color")),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (brandController.text.isEmpty || modelController.text.isEmpty) {
              return;
            }

            final vehicle = CustomerVehicleEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              brand: brandController.text,
              model: modelController.text,
              plateNumber: plateController.text,
              vin: vinController.text,
              color: colorController.text,
              year: int.tryParse(yearController.text) ?? 2024,
              mileage: "0 km",
              lastService: "N/A",
              nextDue: "N/A",
              healthScore: 100,
            );

            Navigator.pop(context, vehicle);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
