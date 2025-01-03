import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rickandmortyapp/providers/api_provider.dart';
import 'package:rickandmortyapp/widgets/search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();
  bool isLoading = false;
  int page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    apiProvider.getCharacters(page);
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        page++;
        await apiProvider.getCharacters(page);
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Rick y morty App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(context: context, delegate: SearchCharacter());
              },
              icon: Icon(Icons.search),
            )
          ],
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: apiProvider.characters.isNotEmpty
              ? CharacterList(
                  apiProvider: apiProvider,
                  isLoading: isLoading,
                  scrollController: scrollController,
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }
}

class CharacterList extends StatelessWidget {
  CharacterList(
      {super.key,
      required this.apiProvider,
      required this.scrollController,
      required this.isLoading});

  final ApiProvider apiProvider;
  final ScrollController scrollController;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.87,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10),
      itemCount: isLoading
          ? apiProvider.characters.length + 2
          : apiProvider.characters.length,
      controller: scrollController,
      itemBuilder: (context, index) {
        if (index < apiProvider.characters.length) {
          final characater = apiProvider.characters[index];
          return GestureDetector(
            onTap: () {
              context.go('/character', extra: characater);
            },
            child: Card(
              child: Column(
                children: [
                  Hero(
                    tag: characater.id,
                    child: FadeInImage(
                      placeholder: AssetImage('assets/images/giphy.webp'),
                      image: NetworkImage(characater.image),
                    ),
                  ),
                  Text(
                    characater.name,
                    style: TextStyle(
                        fontSize: 16, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
