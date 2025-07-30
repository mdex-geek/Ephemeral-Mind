import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../services/auth_service.dart';
import '../../review/bloc/entry_bloc.dart';
import 'profile_page.dart';

/// Wrapper widget that provides necessary BLoCs to ProfilePage
class ProfilePageWrapper extends StatelessWidget {
  const ProfilePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authService: AuthService())
                ..add(const CheckAuthStatus()),
        ),
        BlocProvider<EntryBloc>(create: (context) => EntryBloc()),
      ],
      child: const ProfilePage(),
    );
  }
}
