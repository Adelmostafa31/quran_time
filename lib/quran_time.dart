import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/routing/app_router.dart';
import 'package:quran_time/core/routing/routes.dart';
import 'package:quran_time/core/theming/theming.dart';
import 'package:quran_time/generated/l10n.dart';
import 'package:quran_time/global_manager/ui_cubit.dart';
import 'package:quran_time/global_manager/ui_state.dart';

class QuranTime extends StatelessWidget {
  const QuranTime({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: BlocProvider(
        create: (context) => UiCubit(),
        child: BlocBuilder<UiCubit, UiState>(
          builder: (context, state) {
            return MaterialApp(
              locale: Locale(CachHelper.getData(key: 'lang') ?? 'en'),
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              debugShowMaterialGrid: false,
              initialRoute: CachHelper.getData(key: 'first_time')
                  ? Routes.intial
                  : Routes.home,
              theme: theme(),
              debugShowCheckedModeBanner: false,
              onGenerateRoute: appRouter.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
