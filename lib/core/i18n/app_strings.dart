import 'package:flutter/widgets.dart';

/// Tiny, dependency-free localization table.
///
/// The app ships English plus five common languages for the screens that own
/// the language picker (Settings and Backup). Anything missing falls back to
/// English, so adding a key never breaks a language.
class AppStrings {
  const AppStrings(this.code);

  final String code;

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context).languageCode);

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('hi'),
    Locale('ar'),
  ];

  String _t(String key) {
    final row = _table[key];
    if (row == null) return key;
    return row[code] ?? row['en'] ?? key;
  }

  // Settings
  String get settings => _t('settings');
  String get preferences => _t('preferences');
  String get appearance => _t('appearance');
  String get counting => _t('counting');
  String get data => _t('data');
  String get backupTitle => _t('backupTitle');

  String get theme => _t('theme');
  String get language => _t('language');
  String get numberPosition => _t('numberPosition');
  String get tapArea => _t('tapArea');
  String get haptics => _t('haptics');
  String get hapticsHint => _t('hapticsHint');
  String get sound => _t('sound');
  String get soundHint => _t('soundHint');
  String get reduceMotion => _t('reduceMotion');
  String get reduceMotionHint => _t('reduceMotionHint');
  String get accidentalTapProtection => _t('accidentalTapProtection');
  String get accidentalTapProtectionHint => _t('accidentalTapProtectionHint');
  String get volumeButtons => _t('volumeButtons');
  String get volumeButtonsHint => _t('volumeButtonsHint');
  String get notificationCounting => _t('notificationCounting');
  String get notificationCountingHint => _t('notificationCountingHint');
  String get counterShown => _t('counterShown');
  String get backupReminder => _t('backupReminder');
  String get backupReminderHint => _t('backupReminderHint');
  String get days => _t('days');
  String get off => _t('off');
  String get neverBackedUp => _t('neverBackedUp');
  String backupDaysAgo(int n) => _t('backupDaysAgo').replaceAll('{n}', '$n');
  String get showOnboarding => _t('showOnboarding');

  // Backup screen
  String get exportData => _t('exportData');
  String get importData => _t('importData');
  String get exportHint => _t('exportHint');
  String get importHint => _t('importHint');
  String get encrypt => _t('encrypt');
  String get password => _t('password');
  String get passwordHint => _t('passwordHint');
  String get compress => _t('compress');
  String get includeSettings => _t('includeSettings');
  String get share => _t('share');
  String get saveToFiles => _t('saveToFiles');
  String get pickFile => _t('pickFile');
  String get csvExport => _t('csvExport');
  String get csvHint => _t('csvHint');
  String get preview => _t('preview');
  String get counters => _t('counters');
  String get totalTaps => _t('totalTaps');
  String get dateRange => _t('dateRange');
  String get replaceAll => _t('replaceAll');
  String get replaceAllHint => _t('replaceAllHint');
  String get merge => _t('merge');
  String get mergeHint => _t('mergeHint');
  String get confirm => _t('confirm');
  String get cancel => _t('cancel');
  String get importDone => _t('importDone');
  String get importFailed => _t('importFailed');
  String get exportDone => _t('exportDone');
  String get nothingToImport => _t('nothingToImport');
  String get wrongPassword => _t('wrongPassword');
  String get invalidFile => _t('invalidFile');
  String get fileTooNew => _t('fileTooNew');
  String get ok => _t('ok');
  String get autoBackup => _t('autoBackup');

  static const Map<String, Map<String, String>> _table = <String, Map<String, String>>{
    'settings': {
      'en': 'Settings', 'es': 'Ajustes', 'fr': 'Réglages', 'de': 'Einstellungen',
      'hi': 'सेटिंग्स', 'ar': 'الإعدادات',
    },
    'preferences': {
      'en': 'Preferences', 'es': 'Preferencias', 'fr': 'Préférences', 'de': 'Einstellungen',
      'hi': 'प्राथमिकताएँ', 'ar': 'التفضيلات',
    },
    'appearance': {
      'en': 'Appearance', 'es': 'Apariencia', 'fr': 'Apparence', 'de': 'Darstellung',
      'hi': 'रूप', 'ar': 'المظهر',
    },
    'counting': {
      'en': 'Counting', 'es': 'Conteo', 'fr': 'Comptage', 'de': 'Zählen',
      'hi': 'गिनती', 'ar': 'العد',
    },
    'data': {
      'en': 'Data', 'es': 'Datos', 'fr': 'Données', 'de': 'Daten',
      'hi': 'डेटा', 'ar': 'البيانات',
    },
    'backupTitle': {
      'en': 'Backup & Export', 'es': 'Copia y exportar', 'fr': 'Sauvegarde et export',
      'de': 'Backup & Export', 'hi': 'बैकअप और निर्यात', 'ar': 'النسخ الاحتياطي والتصدير',
    },
    'theme': {'en': 'Theme', 'es': 'Tema', 'fr': 'Thème', 'de': 'Design', 'hi': 'थीम', 'ar': 'السمة'},
    'language': {'en': 'Language', 'es': 'Idioma', 'fr': 'Langue', 'de': 'Sprache', 'hi': 'भाषा', 'ar': 'اللغة'},
    'numberPosition': {
      'en': 'Number position', 'es': 'Posición del número', 'fr': 'Position du nombre',
      'de': 'Position der Zahl', 'hi': 'संख्या की स्थिति', 'ar': 'موضع الرقم',
    },
    'tapArea': {
      'en': 'Tap area', 'es': 'Área táctil', 'fr': 'Zone tactile', 'de': 'Tippfläche',
      'hi': 'टैप क्षेत्र', 'ar': 'منطقة اللمس',
    },
    'haptics': {'en': 'Haptics', 'es': 'Vibración', 'fr': 'Vibrations', 'de': 'Haptik', 'hi': 'कंपन', 'ar': 'الاهتزاز'},
    'hapticsHint': {
      'en': 'Springy button feedback', 'es': 'Respuesta táctil', 'fr': 'Retour tactile',
      'de': 'Taktiles Feedback', 'hi': 'बटन कंपन प्रतिक्रिया', 'ar': 'استجابة الاهتزاز',
    },
    'sound': {'en': 'Sound', 'es': 'Sonido', 'fr': 'Son', 'de': 'Ton', 'hi': 'ध्वनि', 'ar': 'الصوت'},
    'soundHint': {
      'en': 'Click on every count', 'es': 'Clic en cada conteo', 'fr': 'Clic à chaque compte',
      'de': 'Klick bei jedem Zählen', 'hi': 'हर गिनती पर क्लिक', 'ar': 'نقرة عند كل عد',
    },
    'reduceMotion': {
      'en': 'Reduce motion', 'es': 'Reducir movimiento', 'fr': 'Réduire les animations',
      'de': 'Bewegung reduzieren', 'hi': 'गति कम करें', 'ar': 'تقليل الحركة',
    },
    'reduceMotionHint': {
      'en': 'Disable non-essential animations', 'es': 'Desactivar animaciones no esenciales',
      'fr': 'Désactiver les animations non essentielles', 'de': 'Unnötige Animationen aus',
      'hi': 'गैर-आवश्यक एनिमेशन बंद करें', 'ar': 'تعطيل الحركات غير الضرورية',
    },
    'accidentalTapProtection': {
      'en': 'Accidental-tap protection', 'es': 'Protección de toques accidentales',
      'fr': 'Protection anti double-tap', 'de': 'Schutz vor Versehen',
      'hi': 'गलती से टैप सुरक्षा', 'ar': 'حماية اللمس الخاطئ',
    },
    'accidentalTapProtectionHint': {
      'en': 'Ignore rapid double taps', 'es': 'Ignorar toques dobles rápidos',
      'fr': 'Ignorer les doubles taps rapides', 'de': 'Schnelle Doppeltipps ignorieren',
      'hi': 'तेज़ दोहरे टैप अनदेखा करें', 'ar': 'تجاهل اللمسات المزدوجة السريعة',
    },
    'volumeButtons': {
      'en': 'Volume-button counting', 'es': 'Contar con botones de volumen',
      'fr': 'Compter avec les boutons de volume', 'de': 'Zählen mit Lautstärketasten',
      'hi': 'वॉल्यूम बटन से गिनें', 'ar': 'العد بأزرار الصوت',
    },
    'volumeButtonsHint': {
      'en': 'Volume up counts, volume down undoes', 'es': 'Subir cuenta, bajar deshace',
      'fr': 'Volume + compte, volume − annule', 'de': 'Lauter zählt, leiser macht rückgängig',
      'hi': 'वॉल्यूम अप गिनता है, डाउन पूर्ववत', 'ar': 'الرفع يعد والنخفض يتراجع',
    },
    'notificationCounting': {
      'en': 'Live count on lock screen', 'es': 'Conteo en pantalla de bloqueo',
      'fr': 'Compte sur l\u2019écran verrouillé', 'de': 'Zähler auf dem Sperrbildschirm',
      'hi': 'लॉक स्क्रीन पर लाइव गिनती', 'ar': 'العد المباشر على شاشة القفل',
    },
    'notificationCountingHint': {
      'en': 'Updates without opening the app', 'es': 'Se actualiza sin abrir la app',
      'fr': 'Mis à jour sans ouvrir l\u2019app', 'de': 'Aktualisiert ohne App-Start',
      'hi': 'ऐप खोले बिना अपडेट', 'ar': 'يتحدث دون فتح التطبيق',
    },
    'counterShown': {
      'en': 'Counter shown', 'es': 'Contador mostrado', 'fr': 'Compteur affiché',
      'de': 'Angezeigter Zähler', 'hi': 'दिखाया गया काउंटर', 'ar': 'العداد المعروض',
    },
    'backupReminder': {
      'en': 'Backup reminder', 'es': 'Recordatorio de copia', 'fr': 'Rappel de sauvegarde',
      'de': 'Backup-Erinnerung', 'hi': 'बैकअप अनुस्मारक', 'ar': 'تذكير النسخ الاحتياطي',
    },
    'backupReminderHint': {
      'en': 'How often to nudge you', 'es': 'Con qué frecuencia avisarte',
      'fr': 'Fréquence des rappels', 'de': 'Wie oft erinnert wird',
      'hi': 'कितनी बार याद दिलाएँ', 'ar': 'عدد مرات التذكير',
    },
    'days': {'en': 'days', 'es': 'días', 'fr': 'jours', 'de': 'Tage', 'hi': 'दिन', 'ar': 'أيام'},
    'off': {'en': 'Off', 'es': 'Apagado', 'fr': 'Désactivé', 'de': 'Aus', 'hi': 'बंद', 'ar': 'إيقاف'},
    'neverBackedUp': {
      'en': 'Never backed up', 'es': 'Nunca respaldado', 'fr': 'Jamais sauvegardé',
      'de': 'Noch nie gesichert', 'hi': 'कभी बैकअप नहीं', 'ar': 'لم يتم النسخ بعد',
    },
    'backupDaysAgo': {
      'en': 'Last backup {n} days ago', 'es': 'Última copia hace {n} días',
      'fr': 'Dernière sauvegarde il y a {n} jours', 'de': 'Letztes Backup vor {n} Tagen',
      'hi': 'अंतिम बैकअप {n} दिन पहले', 'ar': 'آخر نسخة قبل {n} أيام',
    },
    'showOnboarding': {
      'en': 'Show onboarding', 'es': 'Ver introducción', 'fr': 'Voir l\u2019introduction',
      'de': 'Einführung zeigen', 'hi': 'परिचय दिखाएँ', 'ar': 'عرض المقدمة',
    },
    'exportData': {'en': 'Export', 'es': 'Exportar', 'fr': 'Exporter', 'de': 'Exportieren', 'hi': 'निर्यात', 'ar': 'تصدير'},
    'importData': {'en': 'Import', 'es': 'Importar', 'fr': 'Importer', 'de': 'Importieren', 'hi': 'आयात', 'ar': 'استيراد'},
    'exportHint': {
      'en': 'Everything as one versioned file', 'es': 'Todo en un archivo versionado',
      'fr': 'Tout dans un fichier versionné', 'de': 'Alles in einer versionierten Datei',
      'hi': 'सब कुछ एक वर्शन फ़ाइल में', 'ar': 'كل شيء في ملف واحد',
    },
    'importHint': {
      'en': 'Restore from a backup file', 'es': 'Restaurar desde un archivo',
      'fr': 'Restaurer depuis un fichier', 'de': 'Aus Datei wiederherstellen',
      'hi': 'फ़ाइल से पुनर्स्थापित करें', 'ar': 'الاستعادة من ملف',
    },
    'encrypt': {'en': 'Encrypt (AES)', 'es': 'Cifrar (AES)', 'fr': 'Chiffrer (AES)', 'de': 'Verschlüsseln (AES)', 'hi': 'एन्क्रिप्ट (AES)', 'ar': 'تشفير (AES)'},
    'password': {'en': 'Password', 'es': 'Contraseña', 'fr': 'Mot de passe', 'de': 'Passwort', 'hi': 'पासवर्ड', 'ar': 'كلمة المرور'},
    'passwordHint': {
      'en': 'Required to restore', 'es': 'Necesaria para restaurar', 'fr': 'Nécessaire pour restaurer',
      'de': 'Zum Wiederherstellen nötig', 'hi': 'पुनर्स्थापित करने हेतु आवश्यक', 'ar': 'مطلوبة للاستعادة',
    },
    'compress': {'en': 'Compress (zip)', 'es': 'Comprimir (zip)', 'fr': 'Compresser (zip)', 'de': 'Komprimieren (zip)', 'hi': 'संपीड़ित (zip)', 'ar': 'ضغط (zip)'},
    'includeSettings': {
      'en': 'Include settings', 'es': 'Incluir ajustes', 'fr': 'Inclure les réglages',
      'de': 'Einstellungen einschließen', 'hi': 'सेटिंग्स शामिल करें', 'ar': 'تضمين الإعدادات',
    },
    'share': {'en': 'Share', 'es': 'Compartir', 'fr': 'Partager', 'de': 'Teilen', 'hi': 'साझा करें', 'ar': 'مشاركة'},
    'saveToFiles': {'en': 'Save to Files', 'es': 'Guardar en Archivos', 'fr': 'Enregistrer dans Fichiers', 'de': 'In Dateien sichern', 'hi': 'फ़ाइलों में सहेजें', 'ar': 'حفظ في الملفات'},
    'pickFile': {'en': 'Pick a file', 'es': 'Elegir archivo', 'fr': 'Choisir un fichier', 'de': 'Datei wählen', 'hi': 'फ़ाइल चुनें', 'ar': 'اختر ملفًا'},
    'csvExport': {'en': 'Export CSV', 'es': 'Exportar CSV', 'fr': 'Exporter CSV', 'de': 'CSV exportieren', 'hi': 'CSV निर्यात', 'ar': 'تصدير CSV'},
    'csvHint': {
      'en': 'Spreadsheet-ready tap log', 'es': 'Registro listo para hoja de cálculo',
      'fr': 'Journal prêt pour tableur', 'de': 'Tabelle-fähiges Protokoll',
      'hi': 'स्प्रेडशीट-तैयार लॉग', 'ar': 'سجل جاهز للجداول',
    },
    'preview': {'en': 'Preview', 'es': 'Vista previa', 'fr': 'Aperçu', 'de': 'Vorschau', 'hi': 'पूर्वावलोकन', 'ar': 'معاينة'},
    'counters': {'en': 'Counters', 'es': 'Contadores', 'fr': 'Compteurs', 'de': 'Zähler', 'hi': 'काउंटर', 'ar': 'العدادات'},
    'totalTaps': {'en': 'Total taps', 'es': 'Toques totales', 'fr': 'Taps au total', 'de': 'Taps gesamt', 'hi': 'कुल टैप', 'ar': 'إجمالي اللمسات'},
    'dateRange': {'en': 'Date range', 'es': 'Rango de fechas', 'fr': 'Plage de dates', 'de': 'Zeitraum', 'hi': 'तिथि सीमा', 'ar': 'النطاق الزمني'},
    'replaceAll': {'en': 'Replace all', 'es': 'Reemplazar todo', 'fr': 'Tout remplacer', 'de': 'Alles ersetzen', 'hi': 'सब बदलें', 'ar': 'استبدال الكل'},
    'replaceAllHint': {
      'en': 'Delete current data first', 'es': 'Borrar los datos actuales primero',
      'fr': 'Effacer d\u2019abord', 'de': 'Zuerst aktuelle Daten löschen',
      'hi': 'पहले मौजूदा डेटा हटाएँ', 'ar': 'حذف البيانات الحالية أولاً',
    },
    'merge': {'en': 'Merge', 'es': 'Combinar', 'fr': 'Fusionner', 'de': 'Zusammenführen', 'hi': 'मिलाएँ', 'ar': 'دمج'},
    'mergeHint': {
      'en': 'Keep existing, skip duplicates', 'es': 'Conservar y omitir duplicados',
      'fr': 'Conserver, ignorer les doublons', 'de': 'Behalten, Duplikate überspringen',
      'hi': 'मौजूदा रखें, डुप्लिकेट छोड़ें', 'ar': 'الاحتفاظ وتجاهل المكرر',
    },
    'confirm': {'en': 'Confirm', 'es': 'Confirmar', 'fr': 'Confirmer', 'de': 'Bestätigen', 'hi': 'पुष्टि करें', 'ar': 'تأكيد'},
    'cancel': {'en': 'Cancel', 'es': 'Cancelar', 'fr': 'Annuler', 'de': 'Abbrechen', 'hi': 'रद्द करें', 'ar': 'إلغاء'},
    'importDone': {'en': 'Import complete', 'es': 'Importación completa', 'fr': 'Importation terminée', 'de': 'Import abgeschlossen', 'hi': 'आयात पूर्ण', 'ar': 'اكتمل الاستيراد'},
    'importFailed': {'en': 'Import failed', 'es': 'Error al importar', 'fr': 'Échec de l\u2019importation', 'de': 'Import fehlgeschlagen', 'hi': 'आयात विफल', 'ar': 'فشل الاستيراد'},
    'exportDone': {'en': 'Export ready', 'es': 'Exportación lista', 'fr': 'Export prêt', 'de': 'Export bereit', 'hi': 'निर्यात तैयार', 'ar': 'التصدير جاهز'},
    'nothingToImport': {
      'en': 'This file has nothing to import', 'es': 'Este archivo no tiene nada que importar',
      'fr': 'Ce fichier n\u2019a rien à importer', 'de': 'Diese Datei enthält nichts',
      'hi': 'इस फ़ाइल में कुछ नहीं है', 'ar': 'لا يوجد شيء للاستيراد',
    },
    'wrongPassword': {
      'en': 'Wrong password', 'es': 'Contraseña incorrecta', 'fr': 'Mot de passe incorrect',
      'de': 'Falsches Passwort', 'hi': 'गलत पासवर्ड', 'ar': 'كلمة مرور خاطئة',
    },
    'invalidFile': {
      'en': 'Not a valid backup file', 'es': 'Archivo no válido', 'fr': 'Fichier invalide',
      'de': 'Ungültige Datei', 'hi': 'अमान्य फ़ाइल', 'ar': 'ملف غير صالح',
    },
    'fileTooNew': {
      'en': 'Backup is from a newer app version', 'es': 'La copia es de una versión más nueva',
      'fr': 'Sauvegarde d\u2019une version plus récente', 'de': 'Backup aus neuerer Version',
      'hi': 'बैकअप नए संस्करण का है', 'ar': 'النسخة من إصدار أحدث',
    },
    'ok': {'en': 'OK', 'es': 'Aceptar', 'fr': 'OK', 'de': 'OK', 'hi': 'ठीक', 'ar': 'حسنًا'},
    'autoBackup': {
      'en': 'Auto-backup', 'es': 'Copia automática', 'fr': 'Sauvegarde auto', 'de': 'Auto-Backup',
      'hi': 'स्वतः बैकअप', 'ar': 'نسخ تلقائي',
    },
  };
}
