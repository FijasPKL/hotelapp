// import 'package:flutter/material.dart';
// import '../../Models/Dinning.dart';
//
// class ItemsTabTA extends StatefulWidget {
//   final int tabIndex;
//   final List<Items>? items;
//   final int? selectedCategoryId;
//   final void Function(Map<String, int>)? onItemQuantitiesUpdated;
//   final void Function(Map<String, int>)? onQuantitiesUpdated;
//   final void Function(int?)? onCategorySelected;
//   final void Function(String?, double?, int)? onItemSelected;
//
//   const ItemsTabTA({super.key,
//     required this.tabIndex,
//     this.items,
//     this.selectedCategoryId,
//     this.onCategorySelected,
//     this.onItemSelected,
//     this.onItemQuantitiesUpdated,
//     required this.onQuantitiesUpdated, // Remove the duplicate line
//   });
//
//   @override
//   _ItemsTabTAState createState() => _ItemsTabTAState();
// }
//
// class _ItemsTabTAState extends State<ItemsTabTA> {
//   Map<String, int> itemQuantities = {};
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.tabIndex == 1) {
//       List<Items> selectedCatItems = (widget.items ?? [])
//           .where((item) => item.catId == widget.selectedCategoryId)
//           .toList();
//
//       return GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 5,
//           crossAxisSpacing: 3.0,
//           mainAxisSpacing: 3.0,
//         ),
//         itemCount: selectedCatItems.length,
//         itemBuilder: (context, index) {
//           String itemName = selectedCatItems[index].name ?? '';
//           double rate = selectedCatItems[index].sRate ?? 0.0;
//
//           return InkWell(
//             onTap: () {
//               int currentQuantity = itemQuantities[itemName] ?? 0;
//               widget.onItemSelected?.call(itemName, rate, currentQuantity + 1);
//               setState(() {
//                 itemQuantities[itemName] = currentQuantity + 1;
//                 widget.onQuantitiesUpdated?.call(itemQuantities);
//               });
//             },
//             child: Card(
//               elevation: 3,
//               margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   children: [
//                     Column(
//                       children: [
//                         Text(
//                           selectedCatItems[index].name ?? '',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Add more widgets here for additional details or actions
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       return const CircularProgressIndicator();
//     }
//   }
// }
