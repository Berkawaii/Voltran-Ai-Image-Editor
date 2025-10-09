import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isTurkish => _locale.languageCode == 'tr';

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('tr')
        : const Locale('en');
    notifyListeners();
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'AI Image Editor',
      'powered_by': 'Powered by fal.ai',
      'transform_images': 'Transform Your Images with AI',
      'upload_describe':
          'Upload an image and describe the changes you want to make',
      'upload_image_description':
          'Upload an image and describe the changes you want to make',
      'upload_image': 'Upload Image',
      'click_to_upload': 'Click to upload image',
      'drag_and_drop': 'or drag and drop',
      'supported_formats': 'JPG, PNG, WEBP up to 10MB',
      'change': 'Change',
      'describe_edit': 'Describe Your Edit',
      'prompt_hint':
          'Example:\n• Add a sunset background\n• Make it look like a painting\n• Change the sky to starry night',
      'generate_edit': 'Generate Edit',
      'processing': 'Processing...',
      'result': 'Result',
      'download': 'Download',
      'before_after': 'Before & After Comparison',
      'before': 'BEFORE',
      'after': 'AFTER',
      'history': 'History',
      'job_history': 'Job History',
      'your_edits': 'Your Edits',
      'private_history': 'Only visible to you on this device',
      'no_jobs': 'No jobs yet',
      'create_first': 'Create your first edit!',
      'error_loading': 'Error loading history',
      'retry': 'Retry',
      'completed': 'Completed',
      'failed': 'Failed',
      'processing_status': 'Processing',
      'pending': 'Pending',
      'job_queued': 'Job queued...',
      'ai_editing': 'AI is editing your image...',
      'complete': 'Complete!',
      'may_take_minutes': 'This may take a few minutes...',
      'select_image_first': 'Please select an image first',
      'enter_prompt': 'Please enter a prompt',
      'no_images_compare': 'No images to compare',
      'created_by': 'Created by',
      'view_github': 'View on GitHub',
      'select_model': 'Select AI Model',
      'model_seedream': 'Seedream V4',
      'model_seedream_desc': 'Fast and efficient image editing',
      'model_nano_banana': 'Nano Banana',
      'model_nano_banana_desc': 'Quick edits with smaller model',
      'model_flux_dev': 'FLUX Dev',
      'model_flux_dev_desc': 'Advanced image-to-image transformation',
      'server_waking_up': 'Server is waking up...',
      'server_cold_start': 'Free server is starting (30-60 seconds)',
      'please_wait': 'Please wait a moment',
    },
    'tr': {
      'app_title': 'Yapay Zeka Görsel Editörü',
      'powered_by': 'fal.ai ile güçlendirildi',
      'transform_images': 'Görsellerinizi Yapay Zeka ile Dönüştürün',
      'upload_describe':
          'Bir görsel yükleyin ve yapmak istediğiniz değişiklikleri açıklayın',
      'upload_image_description':
          'Bir görsel yükleyin ve yapmak istediğiniz değişiklikleri açıklayın',
      'upload_image': 'Görsel Yükle',
      'click_to_upload': 'Görsel yüklemek için tıklayın',
      'drag_and_drop': 'veya sürükleyip bırakın',
      'supported_formats': 'JPG, PNG, WEBP - 10MB\'a kadar',
      'change': 'Değiştir',
      'describe_edit': 'Düzenlemenizi Açıklayın',
      'prompt_hint':
          'Örnek:\n• Gün batımı arkaplanı ekle\n• Resim gibi yap\n• Gökyüzünü yıldızlı geceye çevir',
      'generate_edit': 'Düzenleme Oluştur',
      'processing': 'İşleniyor...',
      'result': 'Sonuç',
      'download': 'İndir',
      'before_after': 'Önce & Sonra Karşılaştırması',
      'before': 'ÖNCE',
      'after': 'SONRA',
      'history': 'Geçmiş',
      'job_history': 'İş Geçmişi',
      'your_edits': 'Düzenlemeleriniz',
      'private_history': 'Sadece bu cihazda size görünür',
      'no_jobs': 'Henüz iş yok',
      'create_first': 'İlk düzenlemenizi oluşturun!',
      'error_loading': 'Geçmiş yüklenirken hata',
      'retry': 'Tekrar Dene',
      'completed': 'Tamamlandı',
      'failed': 'Başarısız',
      'processing_status': 'İşleniyor',
      'pending': 'Bekliyor',
      'job_queued': 'İş sıraya alındı...',
      'ai_editing': 'Yapay zeka görselinizi düzenliyor...',
      'complete': 'Tamamlandı!',
      'may_take_minutes': 'Bu birkaç dakika sürebilir...',
      'select_image_first': 'Lütfen önce bir görsel seçin',
      'enter_prompt': 'Lütfen bir açıklama girin',
      'no_images_compare': 'Karşılaştırılacak görsel yok',
      'created_by': 'Oluşturan',
      'view_github': 'GitHub\'da Görüntüle',
      'select_model': 'Yapay Zeka Modeli Seç',
      'model_seedream': 'Seedream V4',
      'model_seedream_desc': 'Hızlı ve verimli görsel düzenleme',
      'model_nano_banana': 'Nano Banana',
      'model_nano_banana_desc': 'Küçük model ile hızlı düzenlemeler',
      'model_flux_dev': 'FLUX Dev',
      'model_flux_dev_desc': 'Gelişmiş görsel dönüştürme',
      'server_waking_up': 'Sunucu uyanıyor...',
      'server_cold_start': 'Ücretsiz sunucu başlatılıyor (30-60 saniye)',
      'please_wait': 'Lütfen biraz bekleyin',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get poweredBy => translate('powered_by');
  String get transformImages => translate('transform_images');
  String get uploadDescribe => translate('upload_describe');
  String get uploadImageDescription => translate('upload_image_description');
  String get uploadImage => translate('upload_image');
  String get clickToUpload => translate('click_to_upload');
  String get dragAndDrop => translate('drag_and_drop');
  String get supportedFormats => translate('supported_formats');
  String get change => translate('change');
  String get describeEdit => translate('describe_edit');
  String get promptHint => translate('prompt_hint');
  String get generateEdit => translate('generate_edit');
  String get processing => translate('processing');
  String get result => translate('result');
  String get download => translate('download');
  String get beforeAfter => translate('before_after');
  String get before => translate('before');
  String get after => translate('after');
  String get history => translate('history');
  String get jobHistory => translate('job_history');
  String get yourEdits => translate('your_edits');
  String get privateHistory => translate('private_history');
  String get noJobs => translate('no_jobs');
  String get createFirst => translate('create_first');
  String get errorLoading => translate('error_loading');
  String get retry => translate('retry');
  String get completed => translate('completed');
  String get failed => translate('failed');
  String get processingStatus => translate('processing_status');
  String get pending => translate('pending');
  String get jobQueued => translate('job_queued');
  String get aiEditing => translate('ai_editing');
  String get complete => translate('complete');
  String get mayTakeMinutes => translate('may_take_minutes');
  String get selectImageFirst => translate('select_image_first');
  String get enterPrompt => translate('enter_prompt');
  String get noImagesCompare => translate('no_images_compare');
  String get createdBy => translate('created_by');
  String get viewGithub => translate('view_github');
  String get selectModel => translate('select_model');
  String get modelSeedream => translate('model_seedream');
  String get modelSeedreamDesc => translate('model_seedream_desc');
  String get modelNanoBanana => translate('model_nano_banana');
  String get modelNanoBananaDesc => translate('model_nano_banana_desc');
  String get modelFluxDev => translate('model_flux_dev');
  String get modelFluxDevDesc => translate('model_flux_dev_desc');
  String get serverWakingUp => translate('server_waking_up');
  String get serverColdStart => translate('server_cold_start');
  String get pleaseWait => translate('please_wait');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
