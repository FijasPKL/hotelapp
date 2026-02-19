import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Dinning.dart';
import '../KOT.dart';
import '../Provider/Sending KOT.dart';

void showExtraAddonDialog(
    BuildContext context,
    List<ExtraAddOn> extraAddonList,
    SelectedItems selectedItem,
    ) {
  List<SelectExtra> selectedExtraAddons = [
    ...selectedItem.selectextra ?? []
  ]; // Create a copy of selectextra
  TextEditingController extraNoteController = TextEditingController();
  final selectKOTprovider = Provider.of<KotProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Center(
              child: Column(
                children: [
                  const Text('Extra Add-On'),
                  TextField(
                    controller: extraNoteController,
                    decoration: const InputDecoration(
                        hintText: "Type ExtraNote here"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var extraAddon in extraAddonList)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            final KotProvider kotProvider = Provider.of<KotProvider>(context, listen: false);
                            String addonModifiedStatus = '';
                            if (kotProvider.kotDatasrunning.isNotEmpty && kotProvider.kotDatasrunning[0].mode == 'U') {
                              addonModifiedStatus = 'NEW ADDONS ADDED';
                            }
                            SelectExtra existingAddon = selectedExtraAddons.firstWhere(
                                  (selected) => selected.itemName == extraAddon.name,
                              orElse: () => SelectExtra(
                                itemId: extraAddon.itemId ?? 0,
                                itemName: extraAddon.name ?? '',
                                AddonModifiedStatus: addonModifiedStatus,
                                sRate: extraAddon.sRate ?? 0.0,
                                parentItemId: selectedItem.itemId,
                                NetAmount: (extraAddon.sRate ?? 0.0),
                                printer: extraAddon.printer ?? '',
                                qty: 1,
                              ),
                            );

                            if (selectedExtraAddons.contains(existingAddon)) {
                              existingAddon.qty = (existingAddon.qty ?? 0) + 1;
                              existingAddon.NetAmount = (existingAddon.qty ?? 0) * (extraAddon.sRate ?? 0.0);
                            } else {
                              selectedExtraAddons.add(existingAddon);
                            }

                            // Update selectedItem with the modified selectextra list
                            selectedItem.selectextra = selectedExtraAddons.toList();
                            print("Updated Add-ons: $selectedExtraAddons");  
                            print("selected ${extraAddon.name}");
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(extraAddon.name ?? ''),
                              const Spacer(),
                              Text(' ${extraAddon.sRate ?? 0.0}'),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    const Text(
                      'Selected Add-Ons:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    for (var selectedAddon in selectedExtraAddons)
                      Row(
                        children: [
                          Text(selectedAddon.itemName ?? 'Item Name Not Available'),
                          Text('Qty: ${selectedAddon.qty ?? 0}'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                selectedExtraAddons.removeWhere(
                                      (selected) => selected.itemName == selectedAddon.itemName,
                                );
                                // Update selectedItem with the modified selectextra list
                                selectedItem.selectextra = selectedExtraAddons.toList();
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedItem.extraNote = extraNoteController.text;
                  });
                  selectKOTprovider.updateSelectExtras(selectedExtraAddons);
                  Navigator.of(context).pop();
                  print("Add-ons confirmed.");
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget buildSelectExtras(List<SelectExtra>? selectExtras) {
  if (selectExtras == null || selectExtras.isEmpty) {
    return const SizedBox.shrink();
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var selectedAddon in selectExtras)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedAddon.itemName}(${selectedAddon.qty})' ?? '',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${selectedAddon.sRate}',
              ),
              const SizedBox(width: 65),
              Text(
                '${selectedAddon.sRate * (selectedAddon.qty ?? 0)}', // Calculate total as sRate * qty
              ),
              const SizedBox(width: 60),
            ],
          ),
      ],
    );
  }
}
