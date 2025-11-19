import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Resultados para: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: ['Documentos', 'Contratos', 'Relatórios']
          .map((item) => ListTile(
                title: Text(item),
                onTap: () {
                  query = item;
                  showResults(context);
                },
              ))
          .toList(),
    );
  }
}