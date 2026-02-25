// import 'package:flutter/material.dart';
// import '../../Models/Dinning.dart';
//
// class CategoryTabTA extends StatefulWidget {
//   final List<Category>? category;
//   final List<Items>? items;
//   final int tabIndex;
//   final TabController tabController;
//   int? selectedCategoryId;
//   final void Function(int?)? onCategorySelected; // Add this line
//
//   CategoryTabTA({super.key,
//     required this.category,
//     required this.tabIndex,
//     required this.tabController,
//     required this.onCategorySelected,
//     this.items,
//   });
//
//   @override
//   _CategoryTabTAState createState() => _CategoryTabTAState();
// }
//
// class _CategoryTabTAState extends State<CategoryTabTA> {
//   int? tappedCategoryId;
//   bool isContainerVisible = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 4,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//         ),
//         itemCount: widget.category?.length ?? 0,
//         itemBuilder: (context, index) {
//           String itemName = widget.category?[index].catName ?? '';
//           return InkWell(
//             onTap: () {
//               setState(() {
//                 tappedCategoryId = widget.category?[index].catId;
//                 widget.tabController.animateTo(1);
//               });
//               widget.selectedCategoryId = tappedCategoryId;
//               widget.onCategorySelected?.call(widget.selectedCategoryId);
//               print("Selected Category Id: ${widget.selectedCategoryId}");
//             },
//             child: Card(
//               elevation: 3,
//               margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'ID: ${widget.category?[index].catId ?? ''}',
//                         ),
//                         Container(
//                           child: Text(
//                             //overflow: TextOverflow.ellipsis,
//                             itemName,
//                             style: const TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
