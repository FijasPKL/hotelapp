import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/Dinning.dart';
import '../Models/KOT.dart';
import '../Models/Provider/Sending KOT.dart';
import '../Srevices/voucher_id.dart';


class ItemsTab extends StatefulWidget {
  final int tabIndex;
  final List<Items>? items;
  final int? selectedCategoryId;
  final void Function(SelectedItems) onItemAdded;
  final void Function(double) removeItemCallback;

  const ItemsTab({
    Key? key,
    required this.tabIndex,
    this.items,
    this.selectedCategoryId,
    required this.onItemAdded,
    required this.removeItemCallback,
  }) : super(key: key);

  @override
  _ItemsTabState createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  int _sinoCounter = 0;

  @override
  Widget build(BuildContext context) {
    final kotProvider = Provider.of<KotProvider>(context);

    if (widget.tabIndex != 2) {
      return const CircularProgressIndicator();
    }

    List<Items> selectedCatItems = (widget.items ?? [])
        .where((item) => item.catId == widget.selectedCategoryId)
        .toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 3.0,
        mainAxisSpacing: 3.0,
      ),
      itemCount: selectedCatItems.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            fetchingvoucherid();
            setState(() {
              String itemName = selectedCatItems[index].name ?? '';
              double itemRate = selectedCatItems[index].sRate ?? 0.0;
              String printer = selectedCatItems[index].printer ?? '';
              int itemId = selectedCatItems[index].itemId ?? 0;
              int catId=selectedCatItems[index].catId ?? 0;
              double netAmount = itemRate * 1;

              String itemModifiedStatus;
              if (kotProvider.kotDatasrunning.isNotEmpty && kotProvider.kotDatasrunning[0].mode == 'U') {
                itemModifiedStatus = 'NEW ORDER';
              } else {
                itemModifiedStatus = 'FRESH';
              }
              int oldqty = (kotProvider.displayedKotItemss.isNotEmpty && kotProvider.displayedKotItemss[0].quantity != null)
                  ? kotProvider.displayedKotItemss[0].quantity!.toInt()
                  : 1;
               String?  itemstatus ='';

                  SelectedItems selectedItems = SelectedItems(
                name: itemName,
                catId: catId,
                sRate: itemRate,
                itemId: itemId,
                quantity: 1,
                oldQuandity: oldqty,
                itemtotal: netAmount,
                NetAmount: netAmount,
                ItemStatus: itemstatus,
                extraNote: '',
                SINO: '${++_sinoCounter}',
                printer: printer,
                itemModifiedStatus: itemModifiedStatus,
              );

              kotProvider.addItemIntoSListee(selectedItems);
              widget.onItemAdded(selectedItems);
            });
          },
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    selectedCatItems[index].name ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
