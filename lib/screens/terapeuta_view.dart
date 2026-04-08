

import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class ListaChatsTerapeuta extends StatelessWidget {
  const ListaChatsTerapeuta({super.key}); 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getMissatges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {//quan esta carregnat
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) { // si note cap missatge
          return const Center(child: Text("Encara no tens missatges de pacients."));
        }

        final missatges = snapshot.data as List;
        
        // aqui haure d'agrupar per usuari per no veure missatges repetits, 
        //per provar faig una llista simple:
        return ListView.builder(
          itemCount: missatges.length,
          itemBuilder: (context, index) {
            final m = missatges[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(m['emisor_username']),
              subtitle: Text(m['contenido']),
              onTap: () {
                // aqui obrire el xat individual
              },
            );
          },
        );
      },
    );
  }
}