import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rickandmortyapp/models/character_model.dart';
import 'package:rickandmortyapp/providers/api_provider.dart';

class SearchCharacter extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final characterProvider = Provider.of<ApiProvider>(context);
    Widget circleLoading() {
      return Center(
        child: CircleAvatar(
          radius: 100,
          backgroundImage: AssetImage('assets/images/giphy.webp'),
        ),
      );
    }

    if (query.isEmpty) {
      return circleLoading();
    }

    return FutureBuilder(
      future: characterProvider.getCharacter(query),
      builder: (context, AsyncSnapshot<List<Character>> snapshot) {
        if (!snapshot.hasData) {
          return circleLoading();
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final characeter = snapshot.data![index];
            return ListTile(
              onTap: () {
                context.go('/character', extra: characeter);
              },
              title: Text(characeter.name!),
              leading: Hero(
                  tag: characeter.id,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(characeter.image),
                  )),
            );
          },
        );
      },
    );
  }
}
