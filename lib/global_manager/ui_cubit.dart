import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/global_manager/ui_state.dart';

class UiCubit extends Cubit<UiState> {
  UiCubit() : super(Initial());
  static UiCubit get(context) => BlocProvider.of(context);
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isCart = false;
  bool isNotification = false;
  bool isSettings = false;

  void changeIsCart() {
    isCart = true;
    isNotification = false;
    isSettings = false;
    emit(ChangeBottomNav());
  }

  void changeIsNotification() {
    isNotification = true;
    isCart = false;
    isSettings = false;
    emit(ChangeBottomNav());
  }

  void changeIsSettings() {
    isSettings = true;
    isCart = false;
    isNotification = false;
    emit(ChangeBottomNav());
  }

  bool switchedButton = CachHelper.getData(key: 'lang') != null
      ? CachHelper.getData(key: 'lang') == 'ar'
            ? false
            : true
      : true;

  Locale locale = const Locale('en');
  Future changeLange({required bool switched}) async {
    if (switched) {
      locale = const Locale('en');
      switchedButton = switched;
      await CachHelper.saveData(key: 'lang', value: 'en');
      emit(ChangeLanguage());
    } else {
      locale = const Locale('ar');
      switchedButton = switched;
      await CachHelper.saveData(key: 'lang', value: 'ar');
      emit(ChangeLanguage());
    }
  }
}
