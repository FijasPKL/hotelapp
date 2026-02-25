// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../Models/Dinning.dart';
// import '../../Pages/Dashboard.dart';
// import '../../Utils/GlobalFn.dart';
// import 'CatogoryTA.dart';
// import 'ItemsTabTA.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: HomeScreenTA(),
//     );
//   }
// }
//
// class HomeScreenTA extends StatefulWidget {
//   const HomeScreenTA({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<HomeScreenTA> createState() => _HomepageState();
// }
//
// class _HomepageState extends State<HomeScreenTA>
//     with SingleTickerProviderStateMixin {
//   late TabController tabController;
//   String? DeviceId = "";
//   SQLMessage? sqlMessage;
//   List<ExtraAddOn>? extraddon;
//   List<Category>? category;
//   List<Items>? items;
//   List<Voucher>? voucher;
//   Future<Dinning>? dinningData;
//   int? selectedCategoryId;
//   List<String> selectedItemrate = [];
//   Map<String, int> itemQuantities = {};
//   List<String> selectedItemsname = [];
//
//   void _removeItem(String itemName) {
//     setState(() {
//       selectedItemsname.remove(itemName);
//       selectedItemrate.remove(
//           itemRates); // Assuming you also want to remove it from selectedItemrate
//       itemQuantities.remove(itemName);
//     });
//   }
//
//   double calculateOverallTotal() {
//     double overallTotal = 0.0;
//     for (int i = 0; i < selectedItemsname.length; i++) {
//       String rate = selectedItemrate.elementAt(i);
//       int quantity = itemQuantities[selectedItemsname.elementAt(i)] ?? 0;
//       double total = double.parse(rate) * quantity;
//       overallTotal += total;
//     }
//     return overallTotal;
//   }
//
//   // Add this function in your _HomepageState class
//   void showExtraAddonDialog(BuildContext context, ExtraAddOn extraAddon) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Center(child: Text('Extra Add-On')),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Item ID: ${extraAddon.itemId}'),
//               Text('Name: ${extraAddon.name}'),
//               Text('Rate: ${extraAddon.sRate}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void showExtraAddonDialog2(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Center(child: Text('Extra Add-On')),
//           content: const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Item ID: '),
//               Text('Name:'),
//               Text('Rate:'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     dinningData = fetchData2();
//     tabController = TabController(length: 2, vsync: this);
//   }
//
//   Future<Dinning> fetchData2() async {
//     DeviceId = await fnGetDeviceId();
//     final String? baseUrl = await fnGetBaseUrl();
//     String apiUrl = '${baseUrl}api/Dinein/alldata';
//
//     try {
//       apiUrl = '$apiUrl?DeviceId=$DeviceId';
//       final response = await http.get(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//       );
//       if (response.statusCode == 200) {
//         Dinning dinning = Dinning.fromJson(json.decode(response.body));
//         sqlMessage = dinning.data?.sQLMessage;
//
//         if (sqlMessage?.code == "200") {
//           extraddon = dinning.data?.extraAddOn;
//           category = dinning.data?.category;
//           items = dinning.data?.items;
//           voucher = dinning.data?.voucher;
//         }
//         return dinning; // Return the fetched data
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       print('Error: $e');
//       rethrow; // Rethrow the exception to propagate it
//     }
//   }
//
//   Map<String, double> itemRates = {};
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blueGrey,
//         hintColor: Colors.black87,
//       ),
//       darkTheme: ThemeData(
//         brightness: Brightness.dark,
//       ),
//       home: Scaffold(
//         body: LayoutBuilder(
//           builder: (BuildContext context, BoxConstraints constraints) {
//             bool isPortrait =
//                 MediaQuery.of(context).orientation == Orientation.portrait;
//
//             return isPortrait ? buildPortraitLayout() : buildLandscapeLayout();
//           },
//         ),
//       ),
//     );
//   }
//
//
//
//
//
//
//
//
//   Widget buildPortraitLayout() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueGrey,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             int currentIndex = tabController.index;
//             if (currentIndex == 0) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const Dashboardpage(),
//                 ),
//               );
//             }
//           },
//         ),
//         centerTitle: true,
//         bottom: TabBar(
//           controller: tabController,
//           indicatorColor: Colors.white,
//           unselectedLabelColor: Colors.black87,
//           labelColor: Colors.white,
//           tabs: const [
//             Tab(text: "CATEGORY"),
//             Tab(text: "ITEMS"),
//           ],
//         ),
//       ),
//       body: FutureBuilder<Dinning>(
//         future: dinningData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.data == null ||
//               snapshot.data!.data == null) {
//             return const Center(child: Text('No data available'));
//           } else {
//             Dinning dinning = snapshot.data!;
//             List<Tables>? tables = dinning.data?.tables;
//
//             return TabBarView(
//               controller: tabController,
//               children: [
//                 Center(
//                   child: CategoryTabTA(
//                     category: category,
//                     tabIndex: 0,
//                     tabController: tabController,
//                     onCategorySelected: (categoryId) {
//                       setState(() {
//                         selectedCategoryId = categoryId;
//                       });
//                     },
//                     items: items,
//                   ),
//                 ),
//                 Center(
//                   child: ItemsTabTA(
//                     tabIndex: 1,
//                     items: items,
//                     selectedCategoryId: selectedCategoryId,
//                     onItemSelected: (itemName, rate, quantity) {
//                       setState(() {
//                         if (itemName != null) {
//                           if (!selectedItemsname.contains(itemName)) {
//                             selectedItemsname.add(itemName);
//                             selectedItemrate.add(rate?.toString() ?? '');
//                           } else {
//                             int currentIndex =
//                                 selectedItemsname.indexOf(itemName);
//                             itemQuantities[itemName] = quantity;
//                             selectedItemrate[currentIndex] =
//                                 rate?.toString() ?? '';
//                           }
//                         }
//                       });
//                     },
//                     onQuantitiesUpdated: (updatedQuantities) {
//                       setState(() {
//                         itemQuantities = updatedQuantities;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: SingleChildScrollView(
//         child: Container(
//           child: Card(
//             color: Colors.white70,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   const Row(
//                     children: [
//                       Text(
//                         "KOT:",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const Divider(thickness: 2, color: Colors.black87),
//                   SizedBox(
//                     width: double.infinity,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Row(
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.all(15.0),
//                                     child: Text(
//                                       "Item",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   Padding(
//                                     padding: EdgeInsets.all(15.0),
//                                     child: Text(
//                                       "Quadity",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(15.0),
//                                     child: Text(
//                                       "Rate",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: 30,),
//                                   Padding(
//                                     padding: EdgeInsets.all(15.0),
//                                     child: Text(
//                                       "Total",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: 80),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 280,
//                                 child: ListView.builder(
//                                   itemCount: selectedItemsname.length,
//                                   itemBuilder: (context, index) {
//                                     String rate =
//                                     selectedItemrate.elementAt(index);
//                                     String itemName =
//                                     selectedItemsname.elementAt(index);
//                                     int quantity =
//                                         itemQuantities[itemName] ?? 0;
//                                     double total =
//                                         double.parse(rate) * quantity;
//
//                                     return ListTile(
//                                       title: Row(
//                                         children: [
//                                           InkWell(
//                                             onTap: () {
//                                               showExtraAddonDialog2(
//                                                 context,
//                                               );
//                                               print(
//                                                   "Selected itemName: $itemName");
//                                               print("extraddon: $extraddon");
//                                             },
//                                             child: Text(itemName),
//                                           ),
//                                           const Spacer(),
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 right: 70),
//                                             child: Text("$quantity"),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 right: 80),
//                                             child: Text(rate),
//                                           ),
//                                           Text("$total"),
//                                           const SizedBox(width: 20),
//                                           IconButton(
//                                             iconSize: 30,
//                                             icon: const Icon(Icons.delete),
//                                             onPressed: () {
//                                               _removeItem(itemName);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 40,
//                                 child: Row(
//                                   children: [
//                                     const Spacer(),
//                                     const Text("Total : ",
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                         )),
//                                     const SizedBox(width: 5),
//                                     Text(calculateOverallTotal().toString(),
//                                         style: const TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                         )),
//                                     const SizedBox(
//                                       width: 80,
//                                     )
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   //Container(height: 300),
//                   Container(
//                     child: Row(
//                       children: [
//                         Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(17.0),
//                           ),
//                           elevation: 5,
//                           child: IconButton(
//                             iconSize: 30,
//                             icon: const Icon(
//                               Icons.add,
//                             ),
//                             onPressed: () {
//                               // Implement your logic
//                             },
//                           ),
//                         ),
//                         Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(17.0),
//                           ),
//                           elevation: 5,
//                           child: IconButton(
//                             iconSize: 30,
//                             icon: const Icon(
//                               Icons.remove,
//                             ),
//                             onPressed: () {
//                               // Implement your logic
//                             },
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 100,
//                         ),
//                         const Card(
//                           color: Colors.black87,
//                           child: Padding(
//                             padding: EdgeInsets.all(15.0),
//                             child: Text("NOTE",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white)),
//                           ),
//                         ),
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedItemsname.clear();
//                               selectedItemrate.clear();
//                             });
//                           },
//                           child: const Card(
//                             color: Colors.black87,
//                             child: Padding(
//                               padding: EdgeInsets.all(15.0),
//                               child: Text(
//                                 "CLEAR",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 30,
//                         ),
//                         const Icon(Icons.print, size: 35),
//                         const SizedBox(
//                           width: 20,
//                         ),
//                         GestureDetector(
//                           onTap: () {},
//                           child: InkWell(
//                             onTap: () {
//                               //handleKOTCardTap();
//                             },
//                             child: const Card(
//                               color: Colors.black87,
//                               child: Padding(
//                                 padding: EdgeInsets.all(15.0),
//                                 child: Text(
//                                   "   KOT  ",
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 20,
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // ),
//         ),
//       ),
//     );
//   }
//
//
//
//
//
//   Widget buildLandscapeLayout() {
//     return Row(
//       children: [
//         Expanded(
//           child: Card(
//             color: Colors.white70,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   const Row(
//                     children: [
//                       Text(
//                         "KOT:",
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const Divider(thickness: 2, color: Colors.black87),
//                   SizedBox(
//                     width: double.infinity,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Row(
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 20,right: 10,bottom: 0,top: 0),
//                                     child: Text(
//                                       "Item",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: 60),
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 15.0,right: 15),
//                                     child: Text(
//                                       "Rate",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 15.0,right: 15),
//                                     child: Text(
//                                       "Total",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: 18),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 300,
//                                 child: ListView.builder(
//                                   itemCount: selectedItemsname.length,
//                                   itemBuilder: (context, index) {
//                                     String rate = selectedItemrate.elementAt(index);
//                                     String itemName = selectedItemsname.elementAt(index);
//                                     int quantity = itemQuantities[itemName] ?? 0;
//                                     double total = double.parse(rate) * quantity;
//
//                                     return ListTile(
//                                       title: Row(
//                                         children: [
//                                           InkWell(
//                                             onTap: () {
//                                               showExtraAddonDialog2(
//                                                 context,
//                                               );
//                                               // print("Selected itemName: $itemName");
//                                               // print("extraddon: $extraddon");
//                                             },
//                                             child: Column(
//                                               children: [
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(left:0,right: 100),
//                                                   child: SizedBox(
//                                                     width:200,
//                                                     child: Text(
//                                                       itemName,
//                                                       overflow: TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Row(
//                                                   children: [
//                                                     Card(
//                                                       shape: RoundedRectangleBorder(
//                                                         borderRadius: BorderRadius.circular(6.0),
//                                                       ),
//                                                       child: Padding(
//                                                         padding: const EdgeInsets.all(3.0),
//                                                         child: Text("qty : $quantity"),
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 90,),
//                                                     Text(rate),
//                                                     const SizedBox(width:50),
//                                                     Text("$total"),
//                                                     const SizedBox(width: 10,),
//                                                     IconButton(
//                                                       iconSize: 30,
//                                                       icon: const Icon(Icons.delete),
//                                                       onPressed: () {
//                                                         _removeItem(itemName);
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const Divider(),
//                               SizedBox(
//                                 height: 30,
//                                 child: Row(
//                                   children: [
//                                     const Spacer(),
//                                     const Text(
//                                       "Total : ",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       calculateOverallTotal().toString(),
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 70,
//                                     )
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             SizedBox(
//                               height:50,
//                               width: 50,
//                               child: Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(17.0),
//                                 ),
//                                 elevation: 5,
//                                 child: IconButton(
//                                   iconSize: 25,
//                                   icon: const Center(
//                                     child: Icon(
//                                       Icons.add,
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     // Implement your logic
//                                   },
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 50,
//                               width: 50,
//                               child: Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(17.0),
//                                 ),
//                                 elevation: 5,
//                                 child: IconButton(
//                                   iconSize: 25,
//                                   icon: const Center(
//                                     child: Icon(
//                                       Icons.remove,
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     // Implement your logic
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const Spacer(),
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedItemsname.clear();
//                                   selectedItemrate.clear();
//                                 });
//                               },
//                               child: const Card(
//                                 color: Colors.black87,
//                                 child: Padding(
//                                   padding: EdgeInsets.all(12.0),
//                                   child: Text(
//                                     "CLEAR",
//                                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             const Card(
//                               color: Colors.black87,
//                               child: Padding(
//                                 padding: EdgeInsets.all(10.0),
//                                 child: Text("NOTE",
//                                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//                               ),
//                             ),
//                             const Icon(Icons.print, size: 35),
//                             const SizedBox(
//                               width: 20,
//                             ),
//                             GestureDetector(
//                               onTap: () {},
//                               child: InkWell(
//                                 onTap: () {
//                                   //handleKOTCardTap();
//                                 },
//                                 child: const Card(
//                                   color: Colors.black87,
//                                   child: Padding(
//                                     padding: EdgeInsets.all(10.0),
//                                     child: Text(
//                                       "   KOT  ",
//                                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 20,
//                             )
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           height: double.infinity,
//           width: 600,
//           child: Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.blueGrey,
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   int currentIndex = tabController.index;
//                   if (currentIndex == 0) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const Dashboardpage(),
//                       ),
//                     );
//                   }
//                 },
//               ),
//               centerTitle: true,
//               bottom: TabBar(
//                 controller: tabController,
//                 indicatorColor: Colors.white,
//                 unselectedLabelColor: Colors.black87,
//                 labelColor: Colors.white,
//                 tabs: const [
//                   Tab(text: "CATEGORY"),
//                   Tab(text: "ITEMS"),
//                 ],
//               ),
//             ),
//             body: Expanded(
//               child: FutureBuilder<Dinning>(
//                 future: dinningData,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else if (snapshot.data == null || snapshot.data!.data == null) {
//                     return const Center(child: Text('No data available'));
//                   } else {
//                     Dinning dinning = snapshot.data!;
//                     List<Tables>? tables = dinning.data?.tables;
//
//                     return TabBarView(
//                       controller: tabController,
//                       children: [
//                         Center(
//                           child: CategoryTabTA(
//                             category: category,
//                             tabIndex: 0,
//                             tabController: tabController,
//                             onCategorySelected: (categoryId) {
//                               setState(() {
//                                 selectedCategoryId = categoryId;
//                               });
//                             },
//                           ),
//                         ),
//                         Center(
//                           child: ItemsTabTA(
//                             tabIndex: 1,
//                             items: items,
//                             selectedCategoryId: selectedCategoryId,
//                             onItemSelected: (itemName, rate, quantity) {
//                               setState(() {
//                                 if (itemName != null) {
//                                   if (!selectedItemsname.contains(itemName)) {
//                                     selectedItemsname.add(itemName);
//                                     selectedItemrate.add(rate?.toString() ?? '');
//                                   } else {
//                                     int currentIndex = selectedItemsname.indexOf(itemName);
//                                     itemQuantities[itemName] = quantity;
//                                     selectedItemrate[currentIndex] = rate?.toString() ?? '';
//                                   }
//                                 }
//                               });
//                             },
//                             onQuantitiesUpdated: (updatedQuantities) {
//                               setState(() {
//                                 itemQuantities = updatedQuantities;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
