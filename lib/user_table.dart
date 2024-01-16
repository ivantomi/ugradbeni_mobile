import 'package:flutter/material.dart';
import 'table_model.dart';

class UserTable extends StatelessWidget {
  final List<Album> albums;

  const UserTable({Key? key, required this.albums}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Last Accessed')),
        ],
        rows: albums
            .map(
              (album) => DataRow(
                cells: [
                  DataCell(FittedBox(child: Text(album.userId))),
                  DataCell(FittedBox(child: Text(album.name))),
                  DataCell(FittedBox(child: Text(album.lastAccessed))),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
