import 'package:flutter/material.dart';

class AutomaticListBuilder extends StatefulWidget {
  const AutomaticListBuilder({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List<String> list;

  @override
  State<AutomaticListBuilder> createState() => _ListBuilderState(list);
}

class _ListBuilderState extends State<AutomaticListBuilder> {
  
  late List<String> data_list;

  _ListBuilderState(List<String> list){
    data_list = list;
  }

  @override
  Widget build(BuildContext context) {
  final List<String> entries = data_list;

  return ListView.builder(
    itemCount: data_list.length,
    itemBuilder: (_, int index) {
      return Column(
        children: [
          Container(
             decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: ListTile(
              /* onTap: () => _toggle(index), */
              title: Text(entries[index]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // ignore: avoid_print
                      print("Do action to remove budget from database");
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text("Delete"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade400),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // ignore: avoid_print
                      print("Do action to edit budget in database");
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      );
    },
  );}
}