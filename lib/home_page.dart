import 'package:flutter/material.dart';
import 'package:oneapp/models/subapp.dart';
import 'package:oneapp/repositories/subapp_repository.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final subapps = context.read<SubappRepository>().subapps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ONEAPP'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width / 90,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: subapps.length,
        itemBuilder: (context, index) => _SubappTile(
          subapp: subapps[index],
          onTap: () {},
        ),
      ),
    );
  }
}

class _SubappTile extends StatelessWidget {
  const _SubappTile({required this.subapp, this.onTap});

  final Subapp subapp;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(
        Radius.circular(5),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
          color: subapp.color,
        ),
        child: GridTile(
          child: Text(
            subapp.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
