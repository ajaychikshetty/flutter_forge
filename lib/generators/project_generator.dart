import 'dart:io';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as path;
import 'package:appforge_cli/templates/enhanced_widgets_part2.dart';
import 'package:appforge_cli/templates/enhanced_widgets_template.dart';
import 'package:appforge_cli/templates/app_localization_template.dart';
import 'package:appforge_cli/templates/app_router_template.dart';
import 'package:appforge_cli/templates/native_permissions.dart'
    show NativePermissions;
import 'package:appforge_cli/templates/onboarding_template.dart';
import 'package:appforge_cli/templates/chatbot_templates.dart'
    show ChatbotTemplates;
import 'package:appforge_cli/templates/docker_templates.dart'
    show DockerTemplates;
import 'package:appforge_cli/templates/firebase_operations_template.dart';
import 'package:appforge_cli/templates/main_template.dart';
import 'package:appforge_cli/templates/modules_template.dart'
    show ModulesTemplate;
import 'package:appforge_cli/templates/pubspec_template.dart';
import 'package:appforge_cli/templates/theme_template.dart';
import 'package:appforge_cli/templates/theme_mode_provider_template.dart';
import 'package:appforge_cli/templates/screen_templates.dart';
import 'package:appforge_cli/utils/file_utils.dart';
import 'package:appforge_cli/templates/app_readme_template.dart';

typedef VoidCallBack = void Function();

/// A powerful Flutter project generator that creates production-ready apps
/// with configurable features including Firebase, localization, Docker, and more.
///
/// Example:
/// ```dart
/// final generator = ProjectGenerator(
///   projectName: 'my_app',
///   organization: 'com.example',
///   stateManagement: 'provider',
///   includeFirebase: true,
///   logger: logger,
/// );
/// await generator.generate();
/// ```
///
/// Creates a new [ProjectGenerator] with the specified configuration.
///
/// Required parameters:
/// * [projectName] - The name of the Flutter project (snake_case recommended)
/// * [organization] - The organization identifier (e.g., com.example)
/// * [stateManagement] - State management solution ('provider', 'bloc', 'riverpod')
/// * [includeFirebase] - Whether to include Firebase integration
/// * [themeColor] - Primary theme color for the app
/// * [authType] - Authentication type ('email_password', 'phone_otp', 'social_auth', 'all')
/// * [logger] - Logger instance for output
///
/// Optional parameters:
/// * [firebaseModules] - List of Firebase modules to include (auth, firestore, storage, etc.)
/// * [includeChatbot] - Include AI chatbot feature
/// * [includeDocker] - Generate Docker configuration for web deployment
/// * [selectedModules] - Utility modules to include (camera, speech, recorder, call)
/// * [enabledFeatures] - Additional features to enable
/// * [selectedLanguages] - Languages for localization (defaults to ['en'])
/// * [includeWeb] - Enable Flutter Web support
class ProjectGenerator {
  ProjectGenerator({
    required this.projectName,
    required this.organization,
    required this.stateManagement,
    required this.includeFirebase,
    this.firebaseModules = const [],
    this.includeChatbot = false,
    this.includeDocker = false,
    this.selectedModules = const [],
    this.enabledFeatures = const [],
    List<String>? selectedLanguages,
    required this.themeColor,
    required this.authType,
    required this.logger,
    this.includeWeb = false,
  }) : selectedLanguages =
            (selectedLanguages == null || selectedLanguages.isEmpty)
                ? const ['en']
                : selectedLanguages;

  /// List of additional features to enable in the project.
  final List<String> enabledFeatures;

  /// Whether to include Flutter Web support.
  final bool includeWeb;

  /// The name of the Flutter project being generated.
  final String projectName;

  /// The organization identifier in reverse domain notation (e.g., com.example).
  final String organization;

  /// The state management solution to use ('provider', 'bloc', 'riverpod').
  final String stateManagement;

  /// Whether to include Firebase integration in the project.
  final bool includeFirebase;

  /// List of Firebase modules to include (e.g., 'auth', 'firestore', 'storage').
  final List<String> firebaseModules;

  /// Whether to include an AI chatbot feature with BLoC state management.
  final bool includeChatbot;

  /// Whether to generate Docker configuration for web deployment.
  final bool includeDocker;

  /// List of utility modules to include (e.g., 'camera', 'speech', 'recorder', 'call').
  final List<String> selectedModules;

  /// Languages to support for localization (ISO 639-1 codes).
  final List<String> selectedLanguages;

  /// Primary theme color for the generated app.
  final String themeColor;

  /// Authentication type ('email_password', 'username_password', 'phone_otp', 'social_auth', 'all').
  final String authType;

  /// Logger instance for output during generation.
  final Logger logger;

  /// Generates the complete Flutter project with all configured features.
  ///
  /// This method orchestrates the entire project generation process including:
  /// - Creating the Flutter project structure
  /// - Generating screens and routing
  /// - Configuring Firebase (if enabled)
  /// - Setting up Docker (if web + docker enabled)
  /// - Generating localization files (if multiple languages selected)
  ///
  /// [onBeforeFirebase] - Optional callback executed before Firebase configuration
  ///
  /// Throws [Exception] if project creation fails.

  Future<void> generate({VoidCallBack? onBeforeFirebase}) async {
    final progress = logger.progress('Creating Flutter app: $projectName');

    try {
      // Step 1: Create Flutter project
      await _createFlutterProject();
      progress.update('Creating Flutter app: $projectName');

      // Step 2: Generate folder structure
      await _generateFolderStructure();
      progress.update('Setting up project structure');

      // Step 3: Generate pubspec.yaml with all dependencies
      await _generatePubspec();
      progress.update('Configuring dependencies');

      // Step 4: Generate theme
      await _generateTheme();
      progress.update('Generating theme');

      // Step 4b: Generate ThemeMode provider
      await _generateThemeModeProvider();
      progress.update('Adding theme mode provider');

      // Step 5: Generate reusable widgets
      await _generateEnhancedReusableWidgets();

      // Step 6: Generate chatbot if enabled
      if (includeChatbot) {
        await _generateChatbot();
      }

      // Step 7: Generate Firebase operations if enabled
      if (includeFirebase && firebaseModules.isNotEmpty) {
        await _generateFirebaseOperations();
      }

      await _generateUtilityModules();
      await _configureNative();

      // Step 8: Generate screens
      await _generateScreens();

      // Step 9: Generate router
      await _generateRouter();

      // Step 10: Generate main.dart
      await _generateMainFile();

      // Step 11: Replace default test with a compatible smoke test
      await _generateTestFile();

      // Step 12: Run flutter pub get
      await _runFlutterPubGet();

      // Step 13: Enable Flutter Web if requested
      if (includeWeb) {
        await _enableFlutterWeb();
      }

      // Step 14: Generate Docker setup if Web + Docker enabled
      if (includeWeb && includeDocker) {
        await _generateDockerSetup();
      }

      // Step 15: Generate localization files
      if (selectedLanguages.isNotEmpty && selectedLanguages.length > 1) {
        await _generateLocalization();
      }
      // Step 16: Generate README.md
      await _generateReadme();

      // Complete the progress before Firebase config
      progress.complete('Project created successfully!');

      // Step 16: Configure Firebase AFTER completing progress
      // This is crucial - Firebase config needs interactive input
      if (includeFirebase) {
        onBeforeFirebase?.call();
        await _configureFirebase();
      }

      logger
          .success('✨ Project generated successfully with $themeColor theme!');
    } catch (e, st) {
      progress.fail('Failed to create project');
      logger.err('Error: $e');
      logger.detail(st.toString());
      rethrow;
    }
  }

  /// Prompts the user to select utility modules to include in the project.
  ///
  /// Available modules include:
  /// - Camera: Photo/video capture service
  /// - Speech: Speech-to-text and text-to-speech
  /// - Recorder: Audio recording and playback
  /// - Call: Phone call and VoIP service
  /// - Contacts: Access to device contacts
  ///
  /// Returns a list of selected module identifiers.
  static Future<List<String>> promptForModules(Logger logger) async {
    final modules = <String>[];
    logger.info('📱 Utility Module Selection');
    logger.info('Select which utility modules to include:');

    final availableModules = {
      'camera': {
        'name': '📸 Camera Module',
        'description': 'Camera service for capturing photos/videos',
        'dependencies': ['camera', 'image_picker'],
      },
      'speech': {
        'name': '🎤 Speech Module',
        'description': 'Speech-to-text and Text-to-speech services',
        'dependencies': ['speech_to_text', 'flutter_tts'],
      },
      'recorder': {
        'name': '🎙️ Audio Recorder Module',
        'description': 'Audio recording and playback service',
        'dependencies': ['record', 'path_provider'],
      },
      'call': {
        'name': '📞 Call Module',
        'description': 'Phone call and VoIP service',
        'dependencies': ['url_launcher', 'permission_handler'],
      },
      'location': {
        'name': '📍 Location Module',
        'description': 'GPS location tracking and geolocation services',
        'dependencies': ['geolocator', 'permission_handler'],
      },
    };

    for (final entry in availableModules.entries) {
      final moduleKey = entry.key;
      final moduleInfo = entry.value;

      logger.info('');
      logger.info('${moduleInfo['name']}');
      logger.info('  ${moduleInfo['description']}');
      logger.info(
          '  Dependencies: ${(moduleInfo['dependencies'] as List<String>).join(', ')}');

      final include = logger.confirm(
        'Include ${moduleInfo['name']}?',
        defaultValue: false,
      );

      if (include) {
        modules.add(moduleKey);
        logger.success('✓ Added ${moduleInfo['name']}');
      } else {
        logger.detail('✗ Skipped ${moduleInfo['name']}');
      }
    }

    logger.info('');
    if (modules.isEmpty) {
      logger.info('⚠️  No utility modules selected');
    } else {
      logger.success('Selected modules: ${modules.join(', ')}');
    }

    return modules;
  }

  Future<void> _configureNative() async {
    await _configureAndroidGradleProperties();
    await _configureAndroidBuildGradle();
    await _configureAndroidManifest();
    await _configureIosInfoPlist();
  }

  Future<void> _configureAndroidBuildGradle() async {
    final buildGradlePath = path.join(
      projectName,
      'android',
      'app',
      'build.gradle.kts',
    );

    final buildGradleFile = File(buildGradlePath);
    if (!await buildGradleFile.exists()) {
      logger.warn('build.gradle.kts not found at $buildGradlePath');
      return;
    }

    var content = await buildGradleFile.readAsString();

    content = content.replaceAll(
      'ndkVersion = flutter.ndkVersion',
      'ndkVersion = "27.0.12077973"',
    );

    content = content.replaceAll(
      'compileSdk = flutter.compileSdkVersion',
      'compileSdk = 36',
    );

    content = content.replaceAll(
      'minSdk = flutter.minSdkVersion',
      'minSdk = 24',
    );

    // Use regex to handle varying whitespace when adding isCoreLibraryDesugaringEnabled
    final compileOptionsRegex = RegExp(
      r'(sourceCompatibility\s*=\s*JavaVersion\.VERSION_11\s*\n\s*targetCompatibility\s*=\s*JavaVersion\.VERSION_11)(\s*\n\s*\})',
    );
    if (compileOptionsRegex.hasMatch(content) &&
        !content.contains('isCoreLibraryDesugaringEnabled')) {
      content = content.replaceFirstMapped(
        compileOptionsRegex,
        (match) =>
            '${match.group(1)}\n        isCoreLibraryDesugaringEnabled = true${match.group(2)}',
      );
    }

    if (!content.contains('coreLibraryDesugaring')) {
      final flutterBlockMatch =
          RegExp(r'flutter\s*\{\s*source\s*=\s*"\.\.\/\.\."\s*\}');
      if (flutterBlockMatch.hasMatch(content)) {
        content = content.replaceFirst(
          flutterBlockMatch,
          '''flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}''',
        );
      }
    }

    await buildGradleFile.writeAsString(content);
    logger.detail(
        '✓ Updated Android build.gradle.kts with NDK 27, minSdk 24, and core library desugaring');
  }

  Future<void> _configureAndroidManifest() async {
    final manifestPath = path.join(
      projectName,
      'android',
      'app',
      'src',
      'main',
      'AndroidManifest.xml',
    );

    final file = File(manifestPath);
    if (!file.existsSync()) {
      logger.warn('AndroidManifest.xml not found');
      return;
    }

    var content = await file.readAsString();

    final permissions = <String>{
      'android.permission.INTERNET',
      'android.permission.ACCESS_NETWORK_STATE',
    };

    // Add permissions from enabled features
    for (final feature in enabledFeatures) {
      permissions.addAll(NativePermissions.android[feature] ?? []);
    }

    // Add permissions from selected modules (camera, contacts, speech, etc.)
    for (final module in selectedModules) {
      permissions.addAll(NativePermissions.android[module] ?? []);
    }

    final buffer = StringBuffer();
    for (final p in permissions) {
      if (!content.contains(p)) {
        buffer.writeln('    <uses-permission android:name="$p" />');
      }
    }

    if (buffer.isEmpty) {
      logger.detail('Android permissions already present');
      return;
    }

    if (content.contains('<application')) {
      content = content.replaceFirst(
        '<application',
        '${buffer.toString()}\n    <application',
      );
    } else {
      content = content.replaceFirst(
        '</manifest>',
        '${buffer.toString()}\n</manifest>',
      );
    }

    await file.writeAsString(content);
    logger.detail('✓ Android permissions injected');
  }

  Future<void> _configureIosInfoPlist() async {
    final plistPath = path.join(
      projectName,
      'ios',
      'Runner',
      'Info.plist',
    );

    final file = File(plistPath);
    if (!file.existsSync()) {
      logger.warn('Info.plist not found');
      return;
    }

    var content = await file.readAsString();

    final Map<String, String> entries = {};

    // Add permissions from enabled features
    for (final feature in enabledFeatures) {
      final map = NativePermissions.ios[feature];
      if (map != null) {
        entries.addAll(map);
      }
    }

    // Add permissions from selected modules (camera, contacts, speech, etc.)
    for (final module in selectedModules) {
      final map = NativePermissions.ios[module];
      if (map != null) {
        entries.addAll(map);
      }
    }

    if (entries.isEmpty) {
      logger.detail('No iOS permissions needed');
      return;
    }

    final buffer = StringBuffer();
    for (final entry in entries.entries) {
      if (!content.contains('<key>${entry.key}</key>')) {
        buffer.writeln('    <key>${entry.key}</key>');
        buffer.writeln('    <string>${entry.value}</string>');
      }
    }

    if (buffer.isEmpty) {
      logger.detail('iOS permissions already present');
      return;
    }

    content = content.replaceFirst(
      '</dict>',
      '${buffer.toString()}\n</dict>',
    );

    await file.writeAsString(content);
    logger.detail('✓ iOS permissions injected');
  }

  Future<void> _configureAndroidGradleProperties() async {
    if (Platform.isWindows) {
      logger.warn(
          '⚠️ Windows detected: disabling Kotlin incremental compilation for stability.');
    }
    final gradlePropsPath = path.join(
      projectName,
      'android',
      'gradle.properties',
    );

    final file = File(gradlePropsPath);
    if (!file.existsSync()) {
      logger.warn('gradle.properties not found');
      return;
    }

    var content = await file.readAsString();

    // Prevent Kotlin incremental cache crashes on Windows
    const fixes = '''
# Added by AppForge CLI for Windows & Kotlin stability
kotlin.incremental=false
kotlin.incremental.useClasspathSnapshot=false
org.gradle.caching=false
org.gradle.daemon=true
''';

    if (!content.contains('kotlin.incremental=false')) {
      content += '\n$fixes';
      await file.writeAsString(content);
      logger.detail('✓ Disabled Kotlin incremental compilation (Windows safe)');
    } else {
      logger.detail('Kotlin incremental already disabled');
    }
  }

  Future<void> _generateUtilityModules() async {
    if (selectedModules.isEmpty) {
      logger.info('⚙️  No utility modules selected, skipping...');
      return;
    }
    logger.info('⚙️ Generating utility modules (camera, voice, call)...');

    final modulesRoot = path.join(projectName, 'lib', 'core', 'modules');

    await Directory(modulesRoot).create(recursive: true);

    for (final module in selectedModules) {
      final moduleDir = path.join(modulesRoot, module);
      await Directory(moduleDir).create(recursive: true);

      switch (module) {
        case 'camera':
          await FileUtils.writeFile(
            path.join(moduleDir, 'camera_service.dart'),
            ModulesTemplate.cameraService(projectName),
          );
          logger.detail('✓ Generated camera_service.dart');
          break;

        case 'speech':
          final voiceDir = path.join(modulesRoot, 'voice');
          await Directory(voiceDir).create(recursive: true);

          await FileUtils.writeFile(
            path.join(voiceDir, 'speech_service.dart'),
            ModulesTemplate.speechService(),
          );
          logger.detail('✓ Generated speech_service.dart');

          await FileUtils.writeFile(
            path.join(voiceDir, 'tts_service.dart'),
            ModulesTemplate.ttsService(),
          );
          logger.detail('✓ Generated tts_service.dart');
          break;

        case 'recorder':
          final voiceDir = path.join(modulesRoot, 'voice');
          await Directory(voiceDir).create(recursive: true);

          await FileUtils.writeFile(
            path.join(voiceDir, 'audio_recorder_service.dart'),
            ModulesTemplate.audioRecorderService(),
          );
          logger.detail('✓ Generated audio_recorder_service.dart');
          break;

        case 'call':
          await FileUtils.writeFile(
            path.join(moduleDir, 'call_service.dart'),
            ModulesTemplate.callService(projectName),
          );
          logger.detail('✓ Generated call_service.dart');
          break;

        case 'location':
          await FileUtils.writeFile(
            path.join(moduleDir, 'location_service.dart'),
            ModulesTemplate.locationService(projectName),
          );
          logger.detail('✓ Generated location_service.dart');
          break;

        case 'contacts':
          final contactsDir = path.join(modulesRoot, 'contacts');
          await Directory(contactsDir).create(recursive: true);

          await FileUtils.writeFile(
            path.join(contactsDir, 'contact.dart'),
            ModulesTemplate.contactModel(),
          );
          logger.detail('✓ Generated contact.dart');

          await FileUtils.writeFile(
            path.join(contactsDir, 'phone_contacts_service.dart'),
            ModulesTemplate.contactsService(projectName),
          );
          logger.detail('✓ Generated phone_contacts_service.dart');
          break;
      }
    }

    await _generateModulesBarrelFile(modulesRoot, selectedModules);

    logger.success('✨ Utility modules generated successfully!');
  }

  Future<void> _generateReadme() async {
    final readmePath = path.join(projectName, 'README.md');
    final content = AppReadmeTemplate.generate(
      projectName: projectName,
      stateManagement: stateManagement,
      authType: authType,
      firebaseModules: firebaseModules,
      selectedModules: selectedModules,
      selectedLanguages: selectedLanguages,
      includeChatbot: includeChatbot,
      includeWeb: includeWeb,
      includeDocker: includeDocker,
    );

    await FileUtils.writeFile(readmePath, content);
    logger.detail('✓ Generated README.md');
  }

  Future<void> _generateModulesBarrelFile(
      String modulesRoot, List<String> selectedModules) async {
    final barrelContent = StringBuffer('''
// Barrel file for selected utility modules

''');

    for (final module in selectedModules) {
      switch (module) {
        case 'camera':
          barrelContent.writeln("export 'camera/camera_service.dart';");
          break;
        case 'speech':
          barrelContent.writeln("export 'voice/speech_service.dart';");
          barrelContent.writeln("export 'voice/tts_service.dart';");
          break;
        case 'recorder':
          barrelContent.writeln("export 'voice/audio_recorder_service.dart';");
          break;
        case 'location':
          barrelContent.writeln("export 'location/location_service.dart';");
          break;
        case 'call':
          barrelContent.writeln("export 'call/call_service.dart';");
          break;
        case 'contacts':
          barrelContent.writeln("export 'contacts/contact.dart';");
          barrelContent
              .writeln("export 'contacts/phone_contacts_service.dart';");
          break;
      }
    }

    final barrelPath = path.join(modulesRoot, 'modules.dart');
    await FileUtils.writeFile(barrelPath, barrelContent.toString());
    logger.detail('✓ Generated modules.dart (barrel file)');
  }

  Future<void> _generateEnhancedReusableWidgets() async {
    logger.info('🎨 Generating enhanced reusable widgets...');

    final widgetsBasePath = path.join(projectName, 'lib', 'shared', 'widgets');

    final widgetFiles = {
      'buttons/primary_button.dart':
          EnhancedWidgetsTemplate.generatePrimaryButton(),
      'buttons/secondary_button.dart':
          EnhancedWidgetsTemplate.generateSecondaryButton(),
      'buttons/social_auth_button.dart':
          EnhancedWidgetsTemplate.generateSocialAuthButton(),
      'inputs/app_text_field.dart':
          EnhancedWidgetsTemplate.generateAppTextField(),
      'inputs/password_field.dart':
          EnhancedWidgetsTemplate.generatePasswordField(),
      'inputs/otp_input.dart': EnhancedWidgetsTemplate.generateOTPInput(),
      'cards/info_card.dart': EnhancedWidgetsPart2.generateInfoCard(),
      'cards/profile_card.dart': EnhancedWidgetsPart2.generateProfileCard(),
      'navigation/custom_app_bar.dart':
          EnhancedWidgetsPart2.generateCustomAppBar(),
      'navigation/bottom_nav_bar.dart':
          EnhancedWidgetsPart2.generateBottomNavBar(),
      'states/app_loader.dart': EnhancedWidgetsPart2.generateAppLoader(),
      'states/empty_state.dart': EnhancedWidgetsPart2.generateEmptyState(),
      'states/error_state.dart': EnhancedWidgetsPart2.generateErrorState(),
      'dialogs/confirm_dialog.dart':
          EnhancedWidgetsPart2.generateConfirmDialog(),
    };

    for (final entry in widgetFiles.entries) {
      final filePath = path.join(widgetsBasePath, entry.key);
      await Directory(path.dirname(filePath)).create(recursive: true);
      await FileUtils.writeFile(filePath, entry.value);
      logger.detail('✓ Generated ${entry.key}');
    }

    await _generateWidgetsBarrelFile(widgetsBasePath);

    logger.success('✨ Enhanced widgets generated successfully!');
  }

  Future<void> _generateWidgetsBarrelFile(String widgetsDir) async {
    final barrelContent = '''
// Barrel file for shared widgets
export 'buttons/primary_button.dart';
export 'buttons/secondary_button.dart';
export 'buttons/social_auth_button.dart';
export 'inputs/app_text_field.dart';
export 'inputs/password_field.dart';
export 'inputs/otp_input.dart';
export 'cards/info_card.dart';
export 'cards/profile_card.dart';
export 'navigation/custom_app_bar.dart';
export 'navigation/bottom_nav_bar.dart';
export 'states/app_loader.dart';
export 'states/empty_state.dart';
export 'states/error_state.dart';
export 'dialogs/confirm_dialog.dart';
''';

    final barrelPath = path.join(widgetsDir, 'widgets.dart');
    await FileUtils.writeFile(barrelPath, barrelContent);
    logger.detail('✓ Generated widgets.dart (barrel file)');
  }

  Future<void> _generateTheme() async {
    final themePath =
        path.join(projectName, 'lib', 'app', 'theme', 'app_theme.dart');
    await Directory(path.dirname(themePath)).create(recursive: true);

    final content = ThemeTemplate.generate(themeColor);
    await FileUtils.writeFile(themePath, content);
    logger
        .detail('Generated theme at $themePath with $themeColor color scheme');
  }

  Future<void> _generateThemeModeProvider() async {
    final providerPath =
        path.join(projectName, 'lib', 'core', 'providers', 'theme_mode_provider.dart');
    await Directory(path.dirname(providerPath)).create(recursive: true);

    final content = ThemeModeProviderTemplate.generate();
    await FileUtils.writeFile(providerPath, content);
    logger.detail('Generated ThemeModeProvider at $providerPath');
  }

  Future<void> _generateFirebaseOperations() async {
    final firebaseDir = path.join(projectName, 'lib', 'core', 'firebase');
    await Directory(firebaseDir).create(recursive: true);

    final content = FirebaseOperationsTemplate.generate(firebaseModules);
    final filePath = path.join(firebaseDir, 'firebase_operations.dart');

    await FileUtils.writeFile(filePath, content);
    logger.detail(
        'Generated Firebase operations file with modules: ${firebaseModules.join(', ')}');
  }

  Future<void> _generateChatbot() async {
    logger.info('🤖 Generating AI Chatbot with BLoC...');

    final chatbotBasePath =
        path.join(projectName, 'lib', 'features', 'chatbot');

    final directories = [
      path.join(chatbotBasePath, 'screens'),
      path.join(chatbotBasePath, 'services'),
      path.join(chatbotBasePath, 'models'),
      path.join(chatbotBasePath, 'bloc'),
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }

    final chatbotScreenPath =
        path.join(chatbotBasePath, 'screens', 'chatbot_screen.dart');
    await FileUtils.writeFile(
      chatbotScreenPath,
      ChatbotTemplates.generateChatScreen(projectName),
    );
    logger.detail('✓ Generated chatbot_screen.dart');

    final chatbotServicePath =
        path.join(chatbotBasePath, 'services', 'chatbot_service.dart');
    await FileUtils.writeFile(
      chatbotServicePath,
      ChatbotTemplates.generateChatbotService(projectName),
    );
    logger.detail('✓ Generated chatbot_service.dart');

    final chatMessageModelPath =
        path.join(chatbotBasePath, 'models', 'chat_message_model.dart');
    await FileUtils.writeFile(
      chatMessageModelPath,
      ChatbotTemplates.generateChatMessageModel(),
    );
    logger.detail('✓ Generated chat_message_model.dart');

    final blocPath = path.join(chatbotBasePath, 'bloc');

    await FileUtils.writeFile(
      path.join(blocPath, 'chatbot_bloc.dart'),
      ChatbotTemplates.generateChatbotBloc(),
    );
    logger.detail('✓ Generated chatbot_bloc.dart');

    await FileUtils.writeFile(
      path.join(blocPath, 'chatbot_event.dart'),
      ChatbotTemplates.generateChatbotEvent(),
    );
    logger.detail('✓ Generated chatbot_event.dart');

    await FileUtils.writeFile(
      path.join(blocPath, 'chatbot_state.dart'),
      ChatbotTemplates.generateChatbotState(),
    );
    logger.detail('✓ Generated chatbot_state.dart');

    final constantsDir = path.join(projectName, 'lib', 'core', 'constants');
    await Directory(constantsDir).create(recursive: true);

    final appConstantsPath = path.join(constantsDir, 'app_constants.dart');
    await FileUtils.writeFile(
      appConstantsPath,
      ChatbotTemplates.generateAppConstants(),
    );
    logger.detail('✓ Generated app_constants.dart');

    final envPath = path.join(projectName, '.env');
    await FileUtils.writeFile(envPath, ChatbotTemplates.generateEnvFile());
    logger.detail('✓ Generated .env file');

    final envExamplePath = path.join(projectName, '.env.example');
    await FileUtils.writeFile(
        envExamplePath, ChatbotTemplates.generateEnvExampleFile());
    logger.detail('✓ Generated .env.example file');

    final gitignorePath = path.join(projectName, '.gitignore');
    final gitignoreExists = await File(gitignorePath).exists();

    if (gitignoreExists) {
      final currentContent = await File(gitignorePath).readAsString();
      final addition = ChatbotTemplates.generateGitignoreAddition();

      if (!currentContent.contains('.env')) {
        await File(gitignorePath).writeAsString(
          currentContent + addition,
          mode: FileMode.append,
        );
        logger.detail('✓ Updated .gitignore');
      }
    }

    logger.success(
        '✨ Chatbot generated successfully with BLoC state management!');
  }

  Future<void> _generateScreens() async {
    final splashScreenPath = path.join(
      projectName,
      'lib',
      'features',
      'app',
      'screens',
      'splash_screen.dart',
    );
    await Directory(path.dirname(splashScreenPath)).create(recursive: true);
    await FileUtils.writeFile(
      splashScreenPath,
      ScreenTemplates.generateSplashScreen(projectName),
    );
    logger.detail('Generated SplashScreen at $splashScreenPath');

    final onboardingScreenPath = path.join(
      projectName,
      'lib',
      'features',
      'app',
      'screens',
      'onboarding_screen.dart',
    );
    await FileUtils.writeFile(
      onboardingScreenPath,
      OnboardingTemplate.generate(projectName),
    );
    logger.detail('Generated OnboardingScreen at $onboardingScreenPath');

    final homeScreenPath = path.join(
      projectName,
      'lib',
      'features',
      'home',
      'screens',
      'home_screen.dart',
    );
    await Directory(path.dirname(homeScreenPath)).create(recursive: true);
    await FileUtils.writeFile(
      homeScreenPath,
      ScreenTemplates.generateHomeScreen(
        projectName,
        includeLocalization: selectedLanguages.length > 1,
        includeChatbot: includeChatbot,
      ),
    );
    logger.detail('Generated HomeScreen at $homeScreenPath');

    await _generateAuthScreens();
  }

  Future<void> _generateAuthScreens() async {
    final authDir =
        path.join(projectName, 'lib', 'features', 'auth', 'screens');
    await Directory(authDir).create(recursive: true);

    switch (authType) {
      case 'email_password':
        await _generateEmailPasswordAuth(authDir);
        break;
      case 'username_password':
        await _generateUsernamePasswordAuth(authDir);
        break;
      case 'phone_otp':
        await _generatePhoneOTPAuth(authDir);
        break;
      case 'social_auth':
        await _generateSocialAuth(authDir);
        break;
      case 'all':
        await _generateAllAuth(authDir);
        break;
      default:
        await _generateEmailPasswordAuth(authDir);
    }
  }

  Future<void> _generateEmailPasswordAuth(String authDir) async {
    final loginPath = path.join(authDir, 'login_screen.dart');
    await FileUtils.writeFile(
      loginPath,
      ScreenTemplates.generateEmailPasswordLogin(projectName),
    );
    logger.detail('Generated Email/Password LoginScreen');

    final signupPath = path.join(authDir, 'signup_screen.dart');
    await FileUtils.writeFile(
      signupPath,
      ScreenTemplates.generateEmailPasswordSignup(projectName),
    );
    logger.detail('Generated Email/Password SignupScreen');
  }

  Future<void> _generateUsernamePasswordAuth(String authDir) async {
    final loginPath = path.join(authDir, 'login_screen.dart');
    await FileUtils.writeFile(
      loginPath,
      ScreenTemplates.generateUsernamePasswordLogin(projectName),
    );
    logger.detail('Generated Username/Password LoginScreen');

    final signupPath = path.join(authDir, 'signup_screen.dart');
    await FileUtils.writeFile(
      signupPath,
      ScreenTemplates.generateUsernamePasswordSignup(projectName),
    );
    logger.detail('Generated Username/Password SignupScreen');
  }

  Future<void> _generatePhoneOTPAuth(String authDir) async {
    final loginPath = path.join(authDir, 'login_screen.dart');
    await FileUtils.writeFile(
      loginPath,
      ScreenTemplates.generatePhoneOTPLogin(projectName),
    );
    logger.detail('Generated Phone/OTP LoginScreen');

    final otpPath = path.join(authDir, 'otp_verification_screen.dart');
    await FileUtils.writeFile(
      otpPath,
      ScreenTemplates.generateOTPVerification(projectName),
    );
    logger.detail('Generated OTP VerificationScreen');
  }

  Future<void> _generateSocialAuth(String authDir) async {
    final loginPath = path.join(authDir, 'login_screen.dart');
    await FileUtils.writeFile(
      loginPath,
      ScreenTemplates.generateSocialLogin(projectName),
    );
    logger.detail('Generated Social LoginScreen');
  }

  Future<void> _generateAllAuth(String authDir) async {
    final loginPath = path.join(authDir, 'login_screen.dart');
    await FileUtils.writeFile(
      loginPath,
      ScreenTemplates.generateUnifiedLogin(projectName),
    );
    logger.detail('Generated Unified LoginScreen');

    final signupPath = path.join(authDir, 'signup_screen.dart');
    await FileUtils.writeFile(
      signupPath,
      ScreenTemplates.generateUnifiedSignup(projectName),
    );
    logger.detail('Generated Unified SignupScreen');

    final otpPath = path.join(authDir, 'otp_verification_screen.dart');
    await FileUtils.writeFile(
      otpPath,
      ScreenTemplates.generateOTPVerification(projectName),
    );
    logger.detail('Generated OTP VerificationScreen');
  }

  Future<void> _generateRouter() async {
    final routerPath =
        path.join(projectName, 'lib', 'app', 'router', 'app_router.dart');
    await Directory(path.dirname(routerPath)).create(recursive: true);

    final content =
        AppRouterTemplate.generate(projectName, includeChatbot: includeChatbot);
    await FileUtils.writeFile(routerPath, content);
    logger.detail('Generated router at $routerPath');
  }

  Future<void> _generateTestFile() async {
    final testPath = path.join(projectName, 'test', 'widget_test.dart');

    final content = '''
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:$projectName/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
''';

    await FileUtils.writeFile(testPath, content);
    logger.detail('Wrote test widget_test.dart for $projectName');
  }

  Future<void> _generateMainFile() async {
    final mainPath = path.join(projectName, 'lib', 'main.dart');
    final content = MainTemplate.generate(
      projectName: projectName,
      stateManagement: stateManagement,
      includeFirebase: includeFirebase,
      useRouter: true,
      useTheme: true,
      includeLocalization: selectedLanguages.length > 1,
    );
    await FileUtils.writeFile(mainPath, content);
    logger.detail('Generated main.dart at $mainPath');

    // Generate FeatureService
    await _generateFeatureService();
  }

  Future<void> _generateFeatureService() async {
    final featureServicePath = path.join(
      projectName,
      'lib',
      'core',
      'services',
      'feature_service.dart',
    );
    await Directory(path.dirname(featureServicePath)).create(recursive: true);
    await FileUtils.writeFile(
      featureServicePath,
      OnboardingTemplate.generateService(),
    );
    logger.detail('Generated FeatureService at $featureServicePath');
  }

  Future<void> _createFlutterProject() async {
    final result = await Process.run(
      'flutter',
      ['create', '--org', organization, projectName],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to create Flutter project: ${result.stderr}');
    }
  }

  Future<void> _generateFolderStructure() async {
    final libPath = path.join(projectName, 'lib');

    final folders = [
      'app',
      'app/router',
      'app/theme',
      'app/di',
      'features/app/screens',
      'features/auth/screens',
      'features/auth/widgets',
      'features/auth/services',
      'features/auth/models',
      'features/home/screens',
      'features/home/widgets',
      'features/home/services',
      'features/home/models',
      'features/profile/screens',
      'features/profile/widgets',
      'features/chatbot/screens',
      'features/chatbot/services',
      'features/chatbot/models',
      'features/chatbot/bloc',
      'shared/widgets',
      'shared/services',
      'shared/utils',
      'shared/constants',
      'shared/repositories',
      'core/errors',
      'core/network',
      'core/storage',
      'core/config',
      'core/services',
      'core/firebase',
      'core/constants',
      'config',
      'models',
      'providers',
    ];

    for (final folder in folders) {
      final dir = Directory(path.join(libPath, folder));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        logger.detail('Created folder: ${dir.path}');
      }
    }
  }

  Future<void> _generatePubspec() async {
    final pubspecPath = path.join(projectName, 'pubspec.yaml');
    final content = PubspecTemplate.generate(
      projectName: projectName,
      stateManagement: stateManagement,
      includeFirebase: includeFirebase,
      firebaseModules: firebaseModules,
      includeChatbot: includeChatbot,
    );
    await FileUtils.writeFile(pubspecPath, content);
    logger.detail('Generated pubspec.yaml');
  }

  Future<void> _runFlutterPubGet() async {
    final result = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: projectName,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      logger.warn('Warning: flutter pub get failed. Run it manually.');
    }
  }

  Future<void> _configureFirebase() async {
    logger.info('');
    logger.info('🔥 Checking Firebase setup...');

    // Check Firebase CLI installation
    if (!await _isCommandAvailable('firebase')) {
      logger.warn('⚠️  Firebase CLI is not installed');
      logger.info('');
      logger.info('Install it with:');
      logger.info('  npm install -g firebase-tools');
      logger.info('');
      logger.info('Then run in your project:');
      logger.info('  cd $projectName');
      logger.info('  firebase login');
      logger.info('  flutterfire configure');
      return;
    }

    // Check if logged in
    if (!await _isFirebaseLoggedIn()) {
      logger.warn('⚠️  Not logged into Firebase CLI');
      logger.info('');
      logger.info('Login with:');
      logger.info('  firebase login');
      logger.info('');
      logger.info('Then configure:');
      logger.info('  cd $projectName');
      logger.info('  flutterfire configure');
      return;
    }

    // Check FlutterFire CLI
    if (!await _isCommandAvailable('flutterfire')) {
      logger.info('📦 Installing FlutterFire CLI...');

      final result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', 'flutterfire_cli'],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        logger.warn('⚠️  Failed to install FlutterFire CLI');
        logger.info('Install manually:');
        logger.info('  dart pub global activate flutterfire_cli');
        return;
      }
      logger.success('✓ FlutterFire CLI installed');
    }

    // Ask user if they want to configure interactively
    logger.info('');
    logger.info('⚠️  Firebase configuration is interactive and requires:');
    logger.info('   • Selecting or creating a Firebase project');
    logger.info('   • Choosing platforms (iOS, Android, Web)');
    logger.info('   • Configuring Firebase options');
    logger.info('');

    // Add helpful tips
    logger.info('💡 Tips:');
    logger.info(
        '   • Use an existing project or create one in Firebase Console first');
    logger.info('   • Project IDs must be unique across all Firebase');
    logger.info('   • Visit console.firebase.google.com to manage projects');
    logger.info('');

    final confirm = logger.confirm(
      '🚀 Run flutterfire configure now?',
      defaultValue: true,
    );

    if (!confirm) {
      logger.info('');
      logger.info('⏭️  Skipped Firebase configuration');
      logger.info('Configure later with:');
      logger.info('  cd $projectName');
      logger.info('  flutterfire configure');
      return;
    }

    // Run interactive configuration
    await _runFlutterfireInteractive();
  }

  Future<void> _runFlutterfireInteractive() async {
    try {
      logger.info('');
      logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      logger.info('🔥 Starting Firebase Configuration');
      logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      logger.info('');

      await Future.delayed(const Duration(milliseconds: 300));

      final process = await Process.start(
        'flutterfire',
        ['configure'],
        workingDirectory: projectName,
        mode: ProcessStartMode.inheritStdio,
        runInShell: true,
      );

      final exitCode = await process.exitCode;

      logger.info('');
      logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (exitCode == 0) {
        logger.success('✅ Firebase configured successfully!');
      } else {
        logger.warn('[WARN] ⚠️  Firebase configuration incomplete');
        logger.info('You can configure manually later:');
        logger.info('  cd $projectName');
        logger.info('  flutterfire configure');
      }

      logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      logger.info('');
    } catch (e) {
      logger.info('');
      logger.err('[ERROR] Firebase configuration failed: $e');
      logger.info('');
      logger.info('To configure manually:');
      logger.info('  cd $projectName');
      logger.info('  flutterfire configure');
      logger.info('');
    }
  }

// Helper methods
  Future<bool> _isCommandAvailable(String command) async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('where', [command], runInShell: true);
        return result.exitCode == 0;
      } else {
        final result = await Process.run('which', [command], runInShell: true);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isFirebaseLoggedIn() async {
    try {
      final result = await Process.run(
        'firebase',
        ['projects:list', '--json'],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> _generateDockerSetup() async {
    if (!includeWeb) {
      logger.warn('⚠️  Docker setup requires Flutter Web to be enabled');
      return;
    }
    logger.info('');
    logger.info('🐳 Generating Docker setup...');

    // Import Docker templates at the top
    // For now, we'll inline the templates or assume they're accessible

    // Generate Dockerfile
    final dockerfilePath = path.join(projectName, 'Dockerfile');
    await FileUtils.writeFile(
        dockerfilePath, DockerTemplates.generateDockerfile());
    logger.detail('✓ Generated Dockerfile');

    // Generate nginx.conf
    final nginxPath = path.join(projectName, 'nginx.conf');
    await FileUtils.writeFile(nginxPath, DockerTemplates.generateNginxConfig());
    logger.detail('✓ Generated nginx.conf');

    // Generate docker-compose.yml
    final dockerComposePath = path.join(projectName, 'docker-compose.yml');
    await FileUtils.writeFile(
      dockerComposePath,
      DockerTemplates.generateDockerCompose(projectName),
    );
    logger.detail('✓ Generated docker-compose.yml');

    // Generate docker-compose.prod.yml
    final dockerComposeProdPath =
        path.join(projectName, 'docker-compose.prod.yml');
    await FileUtils.writeFile(
      dockerComposeProdPath,
      DockerTemplates.generateDockerComposeProduction(projectName),
    );
    logger.detail('✓ Generated docker-compose.prod.yml');

    // Generate .dockerignore
    final dockerignorePath = path.join(projectName, '.dockerignore');
    await FileUtils.writeFile(
        dockerignorePath, DockerTemplates.generateDockerignore());
    logger.detail('✓ Generated .dockerignore');

    // Generate Makefile
    final makefilePath = path.join(projectName, 'Makefile');
    await FileUtils.writeFile(
        makefilePath, DockerTemplates.generateMakefile(projectName));
    logger.detail('✓ Generated Makefile');

    // Generate DOCKER.md
    final dockerReadmePath = path.join(projectName, 'DOCKER.md');
    await FileUtils.writeFile(
      dockerReadmePath,
      DockerTemplates.generateDockerReadme(projectName),
    );
    logger.detail('✓ Generated DOCKER.md');

    // Generate GitHub Actions workflow
    final workflowDir = path.join(projectName, '.github', 'workflows');
    await Directory(workflowDir).create(recursive: true);

    final workflowPath = path.join(workflowDir, 'docker-build.yml');
    await FileUtils.writeFile(
      workflowPath,
      DockerTemplates.generateGithubActionsDocker(projectName),
    );
    logger.detail('✓ Generated GitHub Actions workflow');

    logger.success('✨ Docker setup generated successfully!');
    logger.info('');
    logger.info('🐳 Docker Commands:');
    logger.info('  make build      - Build Docker image');
    logger.info('  make run        - Run production');
    logger.info('  make dev        - Run development with hot-reload');
    logger.info('  make stop       - Stop containers');
    logger.info('  make logs       - View logs');
    logger.info('');
    logger.info('📖 See DOCKER.md for complete documentation');
  }

  Future<void> _enableFlutterWeb() async {
    logger.info('');
    logger.info('🌐 Enabling Flutter Web support...');

    // Check if web is already enabled
    final webDir = Directory(path.join(projectName, 'web'));
    if (await webDir.exists()) {
      logger.detail('✓ Web directory already exists');
      return;
    }

    try {
      // Enable web platform
      final result = await Process.run(
        'flutter',
        ['create', '.', '--platforms=web'],
        workingDirectory: projectName,
        runInShell: true,
      );

      if (result.exitCode == 0) {
        logger.success('✓ Flutter Web enabled successfully!');

        // Update index.html title
        await _updateWebIndexHtml();

        logger.info('');
        logger.info('📝 Next steps for web:');
        logger.info('  • Test locally: flutter run -d chrome');
        logger.info('  • Build: flutter build web');
        if (includeDocker) {
          logger.info('  • Deploy: make build && make run');
        }
      } else {
        logger.warn('Warning: Failed to enable Flutter Web');
        logger.detail('stdout: ${result.stdout}');
        logger.detail('stderr: ${result.stderr}');
      }
    } catch (e) {
      logger.err('Error enabling Flutter Web: $e');
    }
  }

  Future<void> _updateWebIndexHtml() async {
    final indexPath = path.join(projectName, 'web', 'index.html');
    final file = File(indexPath);

    if (!await file.exists()) return;

    var content = await file.readAsString();

    // Update title
    content = content.replaceFirst(
      '<title>$projectName</title>',
      '<title>${_formatAppName(projectName)}</title>',
    );

    await file.writeAsString(content);
    logger.detail('✓ Updated web/index.html');
  }

  String _formatAppName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _generateLocalization() async {
    // If for some reason list is empty, bail early (shouldn't happen now)
    if (selectedLanguages.isEmpty) {
      logger.detail('No languages selected, skipping localization.');
      return;
    }

    logger.info('');
    logger.info('🌍 Generating localization files...');

    // Always ensure 'en' is included as base/template
    final langs = {
      'en',
      ...selectedLanguages,
    }.toList();

    // Create l10n directory
    final l10nDir = path.join(projectName, 'lib', 'l10n');
    await Directory(l10nDir).create(recursive: true);

    // Generate l10n.yaml
    final l10nConfigPath = path.join(projectName, 'l10n.yaml');
    await FileUtils.writeFile(
      l10nConfigPath,
      LocalizationTemplates.generateL10nConfig(langs),
    );
    logger.detail('✓ Generated l10n.yaml');

    // Generate English ARB (template)
    final enArbPath = path.join(l10nDir, 'app_en.arb');
    await FileUtils.writeFile(
      enArbPath,
      LocalizationTemplates.generateEnglishArb(),
    );
    logger.detail('✓ Generated app_en.arb (template)');

    // Generate ARB files for other selected languages
    for (final lang in langs) {
      if (lang == 'en') continue;

      final arbPath = path.join(l10nDir, 'app_$lang.arb');
      await FileUtils.writeFile(
        arbPath,
        LocalizationTemplates.generateArbFile(lang),
      );
      logger.detail('✓ Generated app_$lang.arb');
    }

    // Generate LocaleProvider
    final providersDir = path.join(projectName, 'lib', 'core', 'providers');
    await Directory(providersDir).create(recursive: true);

    final localeProviderPath = path.join(providersDir, 'locale_provider.dart');
    await FileUtils.writeFile(
      localeProviderPath,
      LocalizationTemplates.generateLocaleProvider(projectName),
    );
    logger.detail('✓ Generated locale_provider.dart');

    // Generate LanguageSelector widget
    final languageSelectorPath = path.join(
      projectName,
      'lib',
      'shared',
      'widgets',
      'language_selector.dart',
    );
    await FileUtils.writeFile(
      languageSelectorPath,
      LocalizationTemplates.generateLanguageSelector(projectName),
    );
    logger.detail('✓ Generated language_selector.dart');

    // Generate LOCALIZATION.md
    final localizationReadmePath = path.join(projectName, 'LOCALIZATION.md');
    await FileUtils.writeFile(
      localizationReadmePath,
      LocalizationTemplates.generateLocalizationReadme(),
    );
    logger.detail('✓ Generated LOCALIZATION.md');

    logger.success('✨ Localization generated successfully!');
    logger.info('');
    logger.info('🌍 Supported Languages: ${langs.join(', ')}');
    logger.info('');
    logger.info('Generating localization files...');

    // Run flutter gen-l10n to generate the localization files
    final genL10nResult = await Process.run(
      'flutter',
      ['gen-l10n'],
      workingDirectory: projectName,
      runInShell: true,
    );

    if (genL10nResult.exitCode == 0) {
      logger.success('✓ Localization files generated successfully');
    } else {
      logger.warn(
          'Warning: flutter gen-l10n failed. You may need to run it manually.');
      logger.detail('stdout: ${genL10nResult.stdout}');
      logger.detail('stderr: ${genL10nResult.stderr}');
      logger.detail('Run: cd $projectName && flutter gen-l10n');
    }

    logger.info('');
    logger.info('📖 See LOCALIZATION.md for usage guide');
  }
}
