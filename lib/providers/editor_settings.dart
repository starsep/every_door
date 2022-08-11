import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

final editorSettingsProvider =
    StateNotifierProvider<EditorSettingsProvider, EditorSettings>(
        (_) => EditorSettingsProvider());

class EditorSettings {
  static const kDefaultPayment = ['visa', 'mastercard'];

  final bool preferContact;
  final bool fixNumKeyboard;
  final bool leftHand;
  final List<String> defaultPayment;
  final int oldAmenityDays;

  const EditorSettings({
    this.preferContact = false,
    this.fixNumKeyboard = false,
    this.leftHand = false,
    this.defaultPayment = kDefaultPayment,
    this.oldAmenityDays = kDefaultOldAmenityDays,
  });

  EditorSettings copyWith({
    bool? preferContact,
    bool? fixNumKeyboard,
    bool? leftHand,
    List<String>? defaultPayment,
    int? oldAmenityDays,
  }) {
    return EditorSettings(
      preferContact: preferContact ?? this.preferContact,
      fixNumKeyboard: fixNumKeyboard ?? this.fixNumKeyboard,
      leftHand: leftHand ?? this.leftHand,
      defaultPayment: defaultPayment ?? this.defaultPayment,
      oldAmenityDays: oldAmenityDays ?? this.oldAmenityDays,
    );
  }

  factory EditorSettings.fromStrings(List<String>? data) {
    if (data == null || data.length < 3) return EditorSettings();
    return EditorSettings(
      preferContact: data[0] == '1',
      fixNumKeyboard: data[1] == '1',
      defaultPayment: data[2].length < 2
          ? kDefaultPayment
          : data[2].split(';').map((s) => s.trim()).toList(),
      leftHand: data.length >= 4 && data[3] == '1',
      oldAmenityDays: (data.length >= 5) ? int.tryParse(data[4]) ?? kDefaultOldAmenityDays : kDefaultOldAmenityDays,
    );
  }

  List<String> toStrings() {
    return [
      preferContact ? '1' : '0',
      fixNumKeyboard ? '1' : '0',
      defaultPayment.join(';'),
      leftHand ? '1' : '0',
      oldAmenityDays.toString(),
    ];
  }

  TextInputType get keyboardType => fixNumKeyboard
      ? TextInputType.visiblePassword
      : TextInputType.numberWithOptions(signed: true, decimal: true);
}

class EditorSettingsProvider extends StateNotifier<EditorSettings> {
  static const kSettingsKey = 'editor_settings';

  EditorSettingsProvider() : super(EditorSettings()) {
    load();
  }

  load() async {
    final prefs = await SharedPreferences.getInstance();
    state = EditorSettings.fromStrings(prefs.getStringList(kSettingsKey));
  }

  store() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kSettingsKey, state.toStrings());
  }

  setPreferContact(bool value) {
    state = state.copyWith(preferContact: value);
    store();
  }

  setFixNumKeyboard(bool value) {
    state = state.copyWith(fixNumKeyboard: value);
    store();
  }

  setLeftHand(bool value) {
    state = state.copyWith(leftHand: value);
    store();
  }

  setDefaultPayment(List<String> values) {
    if (values.isNotEmpty) {
      state = state.copyWith(defaultPayment: values);
      store();
    }
  }

  setOldAmenityDays(int value) {
    state = state.copyWith(oldAmenityDays: value);
    store();
  }
}
